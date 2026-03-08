class fifo_directed_basic_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_directed_basic_seq)

  virtual task body();
    uvm_status_e st;
    uvm_reg_data_t data;

    super.body();

    // Configure FIFO
    rm.thresh.write(st, (12) | (1 << 8));
    rm.ctrl.write(st, 32'h1); // en=1

    // Push known pattern
    rm.data.write(st, 32'hA1);
    rm.data.write(st, 32'hB2);
    rm.data.write(st, 32'hC3);

    // Read status
    rm.status.read(st, data);
    `uvm_info("SEQ", $sformatf("STATUS=0x%08h", data), UVM_MEDIUM)

    // Pop data
    rm.data.read(st, data);
    rm.data.read(st, data);
    rm.data.read(st, data);
  endtask
endclass
