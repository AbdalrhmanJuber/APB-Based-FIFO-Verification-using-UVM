class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)

  function new(string name="apb_reg_adapter");
    super.new(name);
    provides_responses = 1;
    supports_byte_enable = 0;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_item t = apb_item::type_id::create("t");
    t.addr  = rw.addr[7:0];
    t.write = (rw.kind == UVM_WRITE);
    t.wdata = rw.data;
    return t;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_item t;
    if (!$cast(t, bus_item)) begin
      rw.status = UVM_NOT_OK;
      return;
    end

    rw.addr   = t.addr;
    rw.kind   = t.write ? UVM_WRITE : UVM_READ;
    rw.data   = t.write ? t.wdata   : t.rdata;
    rw.status = t.ok ? UVM_IS_OK : UVM_NOT_OK;
  endfunction
endclass
