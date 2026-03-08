class apb_fifo_env extends uvm_env;
  `uvm_component_utils(apb_fifo_env)

  apb_agent              m_apb;
  apb_fifo_reg_block     rm;
  apb_reg_adapter        adapter;
  uvm_reg_predictor #(apb_item) predictor;
  apb_scoreboard    sb;
  apb_fifo_coverage cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_apb     = apb_agent::type_id::create("m_apb", this);

    rm        = apb_fifo_reg_block::type_id::create("rm");
    rm.build();
    rm.lock_model();

    adapter   = apb_reg_adapter::type_id::create("adapter");
    predictor = uvm_reg_predictor#(apb_item)::type_id::create("predictor", this);

    sb = apb_scoreboard::type_id::create("sb", this);
    cov = apb_fifo_coverage::type_id::create("cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect reg model to APB sequencer via adapter
    rm.apb_map.set_sequencer(m_apb.sequencer, adapter);

    // Predictor setup
    predictor.map     = rm.apb_map;
    predictor.adapter = adapter;

    // Connect monitor -> predictor
    m_apb.monitor.ap.connect(predictor.bus_in);
    m_apb.monitor.ap.connect(sb.ap);
    m_apb.monitor.ap.connect(cov.ap);
  endfunction
endclass
