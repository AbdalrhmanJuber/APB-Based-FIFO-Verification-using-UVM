class apb_driver extends uvm_driver #(apb_item);
  `uvm_component_utils(apb_driver)

  virtual apb_if.drv vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.drv)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "apb_driver: vif not set")
  endfunction

  task reset_signals();
    vif.PSEL    <= 1'b0;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= 1'b0;
    vif.PADDR   <= '0;
    vif.PWDATA  <= '0;
  endtask

  virtual task run_phase(uvm_phase phase);
    apb_item tr;

    // drive idle
    reset_signals();

    // wait for reset deassert (active low)
    @(posedge vif.PCLK);
    wait (vif.PRESETn === 1'b1);

    forever begin
      seq_item_port.get_next_item(tr);

      // ---- SETUP phase (cycle 1) ----
      @(posedge vif.PCLK);
      vif.PSEL    <= 1'b1;
      vif.PENABLE <= 1'b0;
      vif.PWRITE  <= tr.write;
      vif.PADDR   <= tr.addr;
      vif.PWDATA  <= tr.wdata;

      // ---- ACCESS phase (cycle 2) ----
      @(posedge vif.PCLK);
      vif.PENABLE <= 1'b1;

      // Since PREADY is always 1 in DUT, complete immediately
      // Sample read data / error in ACCESS
      tr.slverr = vif.PSLVERR;
      tr.ok     = (vif.PREADY === 1'b1) && (vif.PSLVERR === 1'b0);

      if (!tr.write) begin
        tr.rdata = vif.PRDATA;
      end

      // ---- Return to IDLE ----
      @(posedge vif.PCLK);
      reset_signals();

      seq_item_port.put_response(tr);
      seq_item_port.item_done();
    end
  endtask
endclass
