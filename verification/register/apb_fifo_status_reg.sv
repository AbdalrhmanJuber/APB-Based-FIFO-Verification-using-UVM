class apb_fifo_status_reg extends uvm_reg;
  `uvm_object_utils(apb_fifo_status_reg)

  uvm_reg_field empty;
  uvm_reg_field full;
  uvm_reg_field almost_full;
  uvm_reg_field almost_empty;
  uvm_reg_field overflow;
  uvm_reg_field underflow;
  uvm_reg_field count;

  function new(string name="apb_fifo_status_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    empty        = uvm_reg_field::type_id::create("empty");
    full         = uvm_reg_field::type_id::create("full");
    almost_full  = uvm_reg_field::type_id::create("almost_full");
    almost_empty = uvm_reg_field::type_id::create("almost_empty");
    overflow     = uvm_reg_field::type_id::create("overflow");
    underflow    = uvm_reg_field::type_id::create("underflow");
    count        = uvm_reg_field::type_id::create("count");

    empty.configure       (this, 1, 0,  "RO", 1, 1, 1, 0, 1);
    full.configure        (this, 1, 1,  "RO", 1, 0, 1, 0, 1);
    almost_full.configure (this, 1, 2,  "RO", 1, 0, 1, 0, 1);
    almost_empty.configure(this, 1, 3,  "RO", 1, 1, 1, 0, 1);

    // sticky flags in RTL but cleared by reads (buggy: cleared by any read). Still RO to SW.
    overflow.configure    (this, 1, 4,  "RO", 1, 0, 1, 0, 1);
    underflow.configure   (this, 1, 5,  "RO", 1, 0, 1, 0, 1);

    count.configure       (this, 8, 6,  "RO", 1, 0, 1, 0, 1);
  endfunction
endclass
