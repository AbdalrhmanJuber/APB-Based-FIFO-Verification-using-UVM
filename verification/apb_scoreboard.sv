class apb_scoreboard extends uvm_component;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_item, apb_scoreboard) ap;

  bit [7:0] ref_fifo[$];

  int DEPTH = 16;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void write(apb_item tr);
    // Only care about DATA register accesses
    if (tr.addr != 8'h0C)
      return;

    //-----------------------------------------
    // WRITE DATA → PUSH
    //-----------------------------------------
    if (tr.write) begin
      if (ref_fifo.size() < DEPTH) begin
        ref_fifo.push_back(tr.wdata[7:0]);
        `uvm_info("SB",
          $sformatf("PUSH: 0x%02h (depth=%0d)",
                    tr.wdata[7:0], ref_fifo.size()),
          UVM_LOW)
      end else begin
        `uvm_warning("SB",
          "Reference FIFO overflow (DUT should assert overflow)")
      end
    end

    //-----------------------------------------
    // READ DATA → POP
    //-----------------------------------------
    else begin
      if (ref_fifo.size() > 0) begin
        bit [7:0] exp;
        exp = ref_fifo.pop_front();

        if (tr.rdata[7:0] !== exp) begin
          `uvm_error("SB",
            $sformatf("DATA MISMATCH: expected=0x%02h got=0x%02h",
                      exp, tr.rdata[7:0]))
        end else begin
          `uvm_info("SB",
            $sformatf("POP OK: 0x%02h (depth=%0d)",
                      exp, ref_fifo.size()),
            UVM_LOW)
        end
      end else begin
        `uvm_warning("SB",
          "Reference FIFO underflow (DUT should assert underflow)")
      end
    end
  endfunction
endclass
