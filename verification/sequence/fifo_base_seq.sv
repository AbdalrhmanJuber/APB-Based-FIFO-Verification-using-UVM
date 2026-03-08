class fifo_base_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(fifo_base_seq)

  apb_fifo_reg_block rm;

  function new(string name="fifo_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    if (rm == null)
      `uvm_fatal("NO_RM", "Register model handle is null")
  endtask
endclass
