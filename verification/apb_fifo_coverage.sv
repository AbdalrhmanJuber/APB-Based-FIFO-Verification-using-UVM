class apb_fifo_coverage extends uvm_component;
  `uvm_component_utils(apb_fifo_coverage)

  // Receive APB transactions
  uvm_analysis_imp #(apb_item, apb_fifo_coverage) ap;

  // Internal sampling variables
  bit        is_write;
  bit [7:0]  addr;
  bit [7:0]  wdata;
  bit [7:0]  rdata;

  // Status bits (decoded from STATUS read)
  bit empty, full, almost_empty, almost_full;
  bit overflow, underflow;

  //-----------------------------------------
  // COVERGROUPS
  //-----------------------------------------

  // 1) Register access coverage
  covergroup cg_apb_access;
    option.per_instance = 1;

    cp_addr : coverpoint addr {
      bins CTRL   = {8'h00};
      bins THRESH = {8'h04};
      bins STATUS = {8'h08};
      bins DATA   = {8'h0C};
    }

    cp_rw : coverpoint is_write {
      bins READ  = {0};
      bins WRITE = {1};
    }

    cp_op : cross cp_addr, cp_rw;
  endgroup


  // 2) FIFO data operations
  covergroup cg_fifo_ops;
    option.per_instance = 1;

    cp_push : coverpoint (addr == 8'h0C && is_write) {
      bins push = {1};
    }

    cp_pop : coverpoint (addr == 8'h0C && !is_write) {
      bins pop = {1};
    }
  endgroup


  // 3) FIFO status coverage
  covergroup cg_fifo_status;
    option.per_instance = 1;

    cp_empty         : coverpoint empty;
    cp_full          : coverpoint full;
    cp_almost_empty  : coverpoint almost_empty;
    cp_almost_full   : coverpoint almost_full;

    cp_overflow  : coverpoint overflow;
    cp_underflow : coverpoint underflow;
  endgroup


  //-----------------------------------------
  // Constructor
  //-----------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);

    cg_apb_access = new();
    cg_fifo_ops   = new();
    cg_fifo_status = new();
  endfunction

  //-----------------------------------------
  // Sample on every APB transaction
  //-----------------------------------------
  virtual function void write(apb_item tr);
    addr  = tr.addr;
    is_write = tr.write;
    wdata = tr.wdata[7:0];
    rdata = tr.rdata[7:0];

    // Sample access & ops
    cg_apb_access.sample();
    cg_fifo_ops.sample();

    // Decode STATUS reads only
    if (!tr.write && tr.addr == 8'h08) begin
      empty        = tr.rdata[0];
      full         = tr.rdata[1];
      almost_full  = tr.rdata[2];
      almost_empty = tr.rdata[3];
      overflow     = tr.rdata[4];
      underflow    = tr.rdata[5];

      cg_fifo_status.sample();
    end
  endfunction
endclass
