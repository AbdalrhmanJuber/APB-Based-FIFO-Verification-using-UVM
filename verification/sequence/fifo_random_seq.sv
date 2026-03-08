class fifo_random_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_random_seq)

  rand int num_ops;
  constraint c_ops { num_ops inside {[50:200]}; }

virtual task body();
  uvm_status_e st;
  uvm_reg_data_t data;
  int i;

  super.body();

  if (!randomize())
    `uvm_fatal("RAND", "Randomization failed");

  rm.ctrl.write(st, 32'h1); // enable FIFO

  for (i = 0; i < num_ops; i++) begin
    if ($urandom_range(0,1)) begin
      rm.data.write(st, $urandom_range(0,255));
    end else begin
      rm.data.read(st, data);
    end
  end

  `uvm_info("SEQ",
    $sformatf("Random FIFO sequence completed (%0d ops)", num_ops),
    UVM_MEDIUM)
endtask
endclass
