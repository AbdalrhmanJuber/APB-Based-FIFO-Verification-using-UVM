class apb_fifo_thresh_reg extends uvm_reg;
  `uvm_object_utils(apb_fifo_thresh_reg)

  uvm_reg_field almost_full_th;
  uvm_reg_field almost_empty_th;

  function new(string name="apb_fifo_thresh_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    almost_full_th  = uvm_reg_field::type_id::create("almost_full_th");
    almost_empty_th = uvm_reg_field::type_id::create("almost_empty_th");

    almost_full_th.configure(this, 8, 0,  "RW", 0, 0, 1, 0, 1);
    almost_empty_th.configure(this, 8, 8, "RW", 0, 1, 1, 0, 1); // RTL reset is 1
  endfunction
endclass
