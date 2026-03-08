class fifo_directed_overflow_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_directed_overflow_seq)

  virtual task body();
    uvm_status_e st;
    int i;

    super.body();

    // Enable FIFO
    rm.ctrl.write(st, 32'h1);

    // Fill FIFO completely
    for (i = 0; i < 16; i++) begin
      rm.data.write(st, i);
    end

    // One extra push → overflow
    rm.data.write(st, 32'hFF);

    `uvm_info("SEQ", "Overflow push issued", UVM_MEDIUM)
  endtask
endclass
