class apb_fifo_data_reg extends uvm_reg;
  `uvm_object_utils(apb_fifo_data_reg)

  uvm_reg_field data;

  function new(string name="apb_fifo_data_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    // Treat as RW but volatile; its semantics are special.
    data.configure(this, 8, 0, "RW", 1, 0, 1, 0, 1);
  endfunction
endclass
