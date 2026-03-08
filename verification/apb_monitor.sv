class apb_monitor extends uvm_component;
  `uvm_component_utils(apb_monitor)

  virtual apb_if.mon vif;
  uvm_analysis_port #(apb_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.mon)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "apb_monitor: vif not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    apb_item tr;

    wait (vif.PRESETn === 1'b1);

    forever begin
      @(posedge vif.PCLK);

      if (vif.PSEL && vif.PENABLE && vif.PREADY) begin
        tr = apb_item::type_id::create("tr");
        tr.addr   = vif.PADDR;
        tr.write  = vif.PWRITE;
        tr.wdata  = vif.PWDATA;
        tr.rdata  = vif.PRDATA;     // valid for reads; harmless for writes
        tr.slverr = vif.PSLVERR;
        tr.ok     = (vif.PSLVERR === 1'b0);

        ap.write(tr);
      end
    end
  endtask
endclass
