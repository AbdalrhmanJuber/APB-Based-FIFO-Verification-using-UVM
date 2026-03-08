`include "uvm_macros.svh"
import uvm_pkg::*;
`include "design/apb_sync_fifo.sv"
`include "verification/apb_if.sv"
`include "verification/apb_sequence_item.sv"
`include "verification/apb_sequencer.sv"
`include "verification/apb_driver.sv"
`include "verification/apb_scoreboard.sv"
`include "verification/apb_monitor.sv"
`include "verification/apb_agent.sv"
`include "verification/apb_fifo_coverage.sv"
`include "verification/register/apb_fifo_ctrl_reg.sv"
`include "verification/register/apb_fifo_data_reg.sv"
`include "verification/register/apb_fifo_status_reg.sv"
`include "verification/register/apb_fifo_threesh_reg.sv"
`include "verification/register/apb_fifo_reg_block.sv"
`include "verification/register/apb_reg_adapter.sv"
`include "verification/sequence/fifo_basic_seq.sv"
`include "verification/sequence/fifo_base_seq.sv"
`include "verification/sequence/fifo_directed_basic_seq.sv"
`include "verification/sequence/fifo_directed_clear_seq.sv"
`include "verification/sequence/fifo_directed_overflow_seq.sv"
`include "verification/sequence/fifo_directed_underflow_seq.sv"
`include "verification/sequence/fifo_random_seq.sv"
`include "verification/apb_fifo_env.sv"
`include "verification/apb_test.sv"

module testbench;

  // Clock
  logic PCLK;

  // APB interface
  apb_if apb_if_inst (PCLK);

  // -------------------------------------------------
  // Clock generation
  // -------------------------------------------------
  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // 100 MHz
  end

  // -------------------------------------------------
  // Reset generation (active-low)
  // -------------------------------------------------
  initial begin
    apb_if_inst.PRESETn = 0;
    apb_if_inst.PSEL    = 0;
    apb_if_inst.PENABLE = 0;
    apb_if_inst.PWRITE  = 0;
    apb_if_inst.PADDR   = 0;
    apb_if_inst.PWDATA  = 0;

    #50;
    apb_if_inst.PRESETn = 1;
  end

  // -------------------------------------------------
  // DUT instance
  // -------------------------------------------------
  apb_sync_fifo dut (
    .PCLK    (PCLK),
    .PRESETn (apb_if_inst.PRESETn),
    .PSEL    (apb_if_inst.PSEL),
    .PENABLE (apb_if_inst.PENABLE),
    .PWRITE  (apb_if_inst.PWRITE),
    .PADDR   (apb_if_inst.PADDR),
    .PWDATA  (apb_if_inst.PWDATA),
    .PRDATA  (apb_if_inst.PRDATA),
    .PREADY  (apb_if_inst.PREADY),
    .PSLVERR (apb_if_inst.PSLVERR)
  );

  // -------------------------------------------------
  // UVM start + VIF configuration
  // -------------------------------------------------
  initial begin
    // Driver virtual interface
    uvm_config_db#(virtual apb_if.drv)::set(
      null, "uvm_test_top.env.m_apb.driver", "vif", apb_if_inst
    );

    // Monitor virtual interface
    uvm_config_db#(virtual apb_if.mon)::set(
      null, "uvm_test_top.env.m_apb.monitor", "vif", apb_if_inst
    );

    // Start UVM
    run_test("apb_test");
  end

endmodule

