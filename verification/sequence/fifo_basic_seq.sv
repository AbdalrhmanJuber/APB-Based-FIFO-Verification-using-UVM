class fifo_basic_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(fifo_basic_seq)

  apb_fifo_reg_block rm;

  function new(string name="fifo_basic_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e  st;
    uvm_reg_data_t data_rd;

     if (rm == null)
      `uvm_fatal("NO_RM", "Register model handle is null")

    // Write THRESH: almost_full=12, almost_empty=1
    rm.thresh.write(st, (12) | (1<<8));

    // Enable FIFO (en=1)
    rm.ctrl.write(st, 32'h1);

    // Push 3 bytes via DATA (writes push)
    rm.data.write(st, 32'hA1);
    rm.data.write(st, 32'hB2);
    rm.data.write(st, 32'hC3);

    // Read STATUS
    rm.status.read(st, data_rd);
    `uvm_info("STATUS", $sformatf("STATUS=0x%08h", data_rd), UVM_MEDIUM)

    // Pop 3 bytes via DATA (reads pop)
    rm.data.read(st, data_rd); `uvm_info("POP", $sformatf("POP1=0x%02h", data_rd[7:0]), UVM_MEDIUM)
    rm.data.read(st, data_rd); `uvm_info("POP", $sformatf("POP2=0x%02h", data_rd[7:0]), UVM_MEDIUM)
    rm.data.read(st, data_rd); `uvm_info("POP", $sformatf("POP3=0x%02h", data_rd[7:0]), UVM_MEDIUM)
  endtask
endclass
