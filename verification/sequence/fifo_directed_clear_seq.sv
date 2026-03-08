class fifo_directed_clear_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_directed_clear_seq)

  virtual task body();
    uvm_status_e st;
    uvm_reg_data_t data;

    super.body();

    rm.ctrl.write(st, 32'h1); // enable

    // Push data
    rm.data.write(st, 8'hAA);
    rm.data.write(st, 8'hBB);

    // Clear FIFO
    rm.ctrl.write(st, 32'h2); // clr=1

    // Read status after clear
    rm.status.read(st, data);
    `uvm_info("SEQ", $sformatf("STATUS after CLR=0x%08h", data), UVM_MEDIUM)
  endtask
endclass
