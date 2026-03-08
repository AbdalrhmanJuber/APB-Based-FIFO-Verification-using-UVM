class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  apb_fifo_env env;

  function new(string name="apb_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_fifo_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    fifo_directed_basic_seq     basic;
    fifo_directed_overflow_seq  ovf;
    fifo_directed_underflow_seq udf;
    fifo_directed_clear_seq     clr;
    fifo_random_seq             rnd;

    phase.raise_objection(this);

    // ---------------------------------
    // Directed tests (deterministic)
    // ---------------------------------
    basic = fifo_directed_basic_seq::type_id::create("basic");
    basic.rm = env.rm;
    basic.start(null);

    ovf = fifo_directed_overflow_seq::type_id::create("ovf");
    ovf.rm = env.rm;
    ovf.start(null);

    udf = fifo_directed_underflow_seq::type_id::create("udf");
    udf.rm = env.rm;
    udf.start(null);

    clr = fifo_directed_clear_seq::type_id::create("clr");
    clr.rm = env.rm;
    clr.start(null);

    // ---------------------------------
    // Random stress test
    // ---------------------------------
    rnd = fifo_random_seq::type_id::create("rnd");
    rnd.rm = env.rm;
    rnd.start(null);

    phase.drop_objection(this);
  endtask
endclass

