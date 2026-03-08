class apb_fifo_reg_block extends uvm_reg_block;
  `uvm_object_utils(apb_fifo_reg_block)

  apb_fifo_ctrl_reg   ctrl;
  apb_fifo_thresh_reg thresh;
  apb_fifo_status_reg status;
  apb_fifo_data_reg   data;

  uvm_reg_map         apb_map;

  function new(string name="apb_fifo_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Create regs
    ctrl   = apb_fifo_ctrl_reg  ::type_id::create("ctrl");
    thresh = apb_fifo_thresh_reg::type_id::create("thresh");
    status = apb_fifo_status_reg::type_id::create("status");
    data   = apb_fifo_data_reg  ::type_id::create("data");

    // Build fields
    ctrl.build();
    thresh.build();
    status.build();
    data.build();

    // Configure with this block as parent
    ctrl.configure  (this, null, "");
    thresh.configure(this, null, "");
    status.configure(this, null, "");
    data.configure  (this, null, "");

    // Create map: base_addr, n_bytes (bus width in bytes), endian, byte_addressing
    apb_map = create_map("apb_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);

    // Add regs at offsets
    apb_map.add_reg(ctrl,   'h00, "RW");
    apb_map.add_reg(thresh, 'h04, "RW");
    apb_map.add_reg(status, 'h08, "RO");
    apb_map.add_reg(data,   'h0C, "RW");

    // lock the model (cannot edit the reg)
    lock_model();
  endfunction
endclass
