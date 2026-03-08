class fifo_directed_underflow_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_directed_underflow_seq)

  virtual task body();
    uvm_status_e st;
    uvm_reg_data_t data;

    super.body();

    // Enable FIFO
    rm.ctrl.write(st, 32'h1);

    // Pop without push → underflow
    rm.data.read(st, data);

    `uvm_info("SEQ", "Underflow pop issued", UVM_MEDIUM)
  endtask
endclass
