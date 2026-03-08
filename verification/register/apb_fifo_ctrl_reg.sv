class apb_fifo_ctrl_reg extends uvm_reg;
  `uvm_object_utils(apb_fifo_ctrl_reg)

  uvm_reg_field en;
  uvm_reg_field clr;
  uvm_reg_field drop_on_full;

  function new(string name="apb_fifo_ctrl_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    en           = uvm_reg_field::type_id::create("en");
    clr          = uvm_reg_field::type_id::create("clr");
    drop_on_full = uvm_reg_field::type_id::create("drop_on_full");

    // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
    en.configure(this, 1, 0, "RW", 0, 0, 1, 0, 1);
    clr.configure(this, 1, 1, "RW", 0, 0, 1, 0, 1);
    drop_on_full.configure(this, 1, 2, "RW", 0, 0, 1, 0, 1);
  endfunction
endclass
