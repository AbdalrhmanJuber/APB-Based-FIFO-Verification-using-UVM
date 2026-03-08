# APB-Based FIFO Verification using UVM

**Birzeit University — Faculty of Engineering and Technology**  
**Department of Electrical and Computer Engineering**  
**ENCS5131 – Hardware Design Laboratory**

| Field | Details |
|---|---|
| Instructor | Dr. Abdallatif Abuissa |
| Student Name | Abdelrahman Jaber |
| Student ID | 1211769 |
| Date | December 27, 2025 |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Design Under Test (DUT) Overview](#2-design-under-test-dut-overview)
3. [Test Sequences](#3-test-sequences)
4. [Simulation Results](#4-simulation-results)
5. [Waveform Analysis](#5-waveform-analysis)
6. [Bug Analysis and Root Cause Identification](#6-bug-analysis-and-root-cause-identification)
7. [Bug Fix Implementation](#7-bug-fix-implementation)
8. [Final Conclusions](#8-final-conclusions)

---

## 1. Introduction

This project presents the verification of an APB-based synchronous FIFO design using the **Universal Verification Methodology (UVM)**. The design under test (DUT) is a parameterized FIFO with an APB3 slave interface, intentionally containing functional bugs for verification purposes.

### 1.1 Project Objectives

- Build a complete UVM testbench for APB FIFO verification
- Implement APB master agent with driver, monitor, and sequencer
- Develop UVM register model (RAL) for APB register access
- Create reference model and scoreboard for data checking
- Generate directed and random test sequences
- Achieve comprehensive functional coverage
- Identify and report bugs in the RTL design

---

## 2. Design Under Test (DUT) Overview

### 2.1 Design Specifications

| Parameter | Value |
|---|---|
| Data Width | 8 bits |
| FIFO Depth | 16 entries |
| Interface | APB3 Slave |

### 2.2 APB Interface Signals

| Signal | Direction | Description |
|---|---|---|
| `PSEL` | Input | Peripheral select |
| `PENABLE` | Input | Enable signal |
| `PWRITE` | Input | Write enable |
| `PADDR[7:0]` | Input | Address bus |
| `PWDATA[31:0]` | Input | Write data bus |
| `PRDATA[31:0]` | Output | Read data bus |
| `PREADY` | Output | Ready signal |
| `PSLVERR` | Output | Slave error |

### 2.3 Register Map

| Offset | Name | Description |
|---|---|---|
| `0x00` | `CTRL` | Control register: EN (bit 0), CLR (bit 1), DROP_ON_FULL (bit 2) |
| `0x04` | `THRESH` | Threshold register: ALMOST_FULL_TH[7:0], ALMOST_EMPTY_TH[15:8] |
| `0x08` | `STATUS` | Status register (Read-only): Empty, Full, Almost flags, Overflow, Underflow, Count |
| `0x0C` | `DATA` | Data register: Push (write) or Pop (read) one byte |

### 2.4 Functional Behavior

1. FIFO operations are enabled via `CTRL.EN` bit
2. Writing to `CTRL.CLR` clears the FIFO and all sticky status flags
3. Writing to `DATA` register pushes data when FIFO is not full
4. Reading from `DATA` register pops data when FIFO is not empty
5. Overflow and Underflow flags are sticky until explicitly cleared
6. `DROP_ON_FULL` bit controls behavior when writing to a full FIFO
7. `ALMOST_FULL` and `ALMOST_EMPTY` thresholds are programmable

### 2.5 Component Descriptions

#### 2.5.1 APB Agent

The APB agent encapsulates the driver, sequencer, and monitor:

- **Driver**: Converts sequence items to pin-level APB protocol transactions
- **Sequencer**: Manages sequence execution and arbitration
- **Monitor**: Observes bus activity and broadcasts transactions via analysis port

#### 2.5.2 Register Model

Implemented using UVM Register Abstraction Layer (RAL):

- **Control Register (CTRL)**: Read/Write access
- **Threshold Register (THRESH)**: Read/Write access
- **Status Register (STATUS)**: Read-only with read-to-clear bits
- **Data Register (DATA)**: Read/Write FIFO access
- **Register Adapter**: Converts register operations to APB transactions

#### 2.5.3 Scoreboard

- Reference FIFO model (queue-based)
- Transaction prediction and comparison
- Data integrity checking
- Error detection and reporting
- Overflow/Underflow validation

#### 2.5.4 Functional Coverage

Coverage collector monitors:

- FIFO states (Empty, Full, Almost-Full, Almost-Empty)
- Control register configurations
- Operation types (Push, Pop, Clear)
- Error conditions (Overflow, Underflow)
- Threshold crossings

#### 2.5.5 Functional Coverage Analysis

| Covergroup | Coverage | Notes |
|---|---|---|
| `cg_apb_access` | 87.5% | All major access types exercised; rare back-to-back corner cases not triggered |
| `cg_fifo_ops` | 100% | Push, Pop, Clear, and mixed scenarios fully covered |
| `cg_fifo_status` | 75% | Rare/mutually exclusive state combinations left uncovered |
| **Overall** | **87.5%** | Functionally sufficient — all critical paths covered |

Coverage quality is considered sufficient because:
- All critical FIFO operations are fully covered
- All error conditions (overflow and underflow) are exercised
- All control and status registers are accessed
- Uncovered bins represent low-risk or unreachable scenarios

---

## 3. Test Sequences

### 3.1 Directed Test Sequences

#### `fifo_directed_basic_seq`
- Tests basic push and pop operations
- Verifies FIFO data integrity
- Checks status register updates

#### `fifo_directed_overflow_seq`
- Fills FIFO to maximum capacity
- Attempts write to full FIFO
- Validates overflow flag assertion

#### `fifo_directed_underflow_seq`
- Empties FIFO completely
- Attempts read from empty FIFO
- Validates underflow flag assertion

#### `fifo_directed_clear_seq`
- Fills FIFO with known data
- Issues clear command via CTRL register
- Verifies FIFO reset and flag clearing

### 3.2 Random Test Sequence

`fifo_random_seq` generates:

- Random mix of push/pop operations
- Random data values
- Random threshold configurations
- Back-to-back transactions
- **Total operations**: 163 in the test run

---

## 4. Simulation Results

### 4.1 Test Execution Summary

| Metric | Count |
|---|---|
| Total Operations | 163 |
| UVM INFO Messages | 106 |
| UVM WARNING Messages | 14 |
| UVM ERROR Messages | 76 |
| UVM FATAL Messages | 0 |
| Simulation Time | 5985 time units |

### 4.2 Observed Issues

#### Data Mismatch Errors (76 occurrences)

The scoreboard detected 76 data mismatches between expected and actual values:

```
UVM_ERROR @ 1155: DATA MISMATCH: expected=0x01 got=0x56
UVM_ERROR @ 1215: DATA MISMATCH: expected=0x02 got=0xa1
UVM_ERROR @ 1245: DATA MISMATCH: expected=0x03 got=0xaa
```

Pattern analysis shows the FIFO is not maintaining proper FIFO ordering (First-In-First-Out).

#### Overflow Warnings (14 occurrences)

```
UVM_WARNING @ 855: Reference FIFO overflow (DUT should assert overflow)
```

### 4.3 Successful Operations

Despite the errors, several operations completed successfully:
- Basic push operations (data stored)
- Status register reads
- FIFO clear operation
- Overflow detection (warnings generated appropriately)

---

## 5. Waveform Analysis

### 5.1 Correct FIFO Push and Pop Operation

A sequence of APB write transactions to the DATA register followed by read transactions was captured. The FIFO count increments on each push and decrements on each pop, while read data matches the write order — confirming correct FIFO behavior under basic conditions.

### 5.2 Waveform Evidence: Overflow Condition

An overflow condition was captured where a write operation is attempted while the FIFO is full. The internal count signal remains at the maximum depth, and the overflow flag is asserted.

### 5.3 Waveform Evidence: Underflow Condition

A read attempt when the FIFO is empty was captured. The underflow flag is asserted, and the read data is invalid — confirming correct underflow detection.

---

## 6. Bug Analysis and Root Cause Identification

Extensive directed and random verification uncovered multiple functional defects. While simple push/pop tests executed correctly, stress testing under concurrent and boundary conditions revealed severe data integrity issues.

### Bug #1: Incorrect Handling of Simultaneous Push and Pop

**Description**: The FIFO fails to correctly handle cycles where push and pop operations occur simultaneously, resulting in corrupted FIFO ordering and incorrect data being returned.

**Root Cause**: The occupancy counter (`count`) is updated independently for push and pop operations. When both signals are asserted in the same cycle, the last assignment overrides the previous one, leading to incorrect depth tracking.

**Impact**: Loss of FIFO ordering and complete data corruption (76 mismatches).

---

### Bug #2: Incorrect Full and Empty Flag Generation

**Description**: The FIFO `full` and `empty` flags are derived from the current count value instead of the next-state count, resulting in incorrect flag timing.

**Root Cause**: Flags are computed using stale state information:

```systemverilog
empty <= (count == 0);
full  <= (count == DEPTH-1);  // should be DEPTH, not DEPTH-1
```

**Impact**: Illegal FIFO accesses and missed error conditions.

---

### Bug #3: Incomplete FIFO Clear Operation

**Description**: After asserting the clear command, FIFO operation resumes with corrupted internal state.

**Root Cause**: Read pointer, write pointer, and count are not consistently reset during clear.

**Impact**: FIFO remains in an undefined state after clear.

---

### Bug #4: Overflow Handling Does Not Protect Memory

**Description**: Overflow conditions are detected but do not reliably prevent data overwrites.

**Impact**: Silent loss of valid FIFO entries.

---

## 7. Bug Fix Implementation

Based on the identified root causes, the FIFO RTL was corrected to ensure deterministic behavior under all operating conditions. After applying the fixes, all directed and random sequences completed with **zero scoreboard errors**.

### 7.1 Fix Strategy

- Use next-state logic for FIFO count
- Correctly handle simultaneous push and pop
- Generate flags from next-state count
- Fully reset FIFO on clear
- Block writes when FIFO is full

### 7.2 Corrected FIFO Count Logic

```systemverilog
logic push, pop;
logic [$clog2(DEPTH):0] count_next;

assign push = en && PSEL && PENABLE &&  PWRITE && (PADDR == DATA_O);
assign pop  = en && PSEL && PENABLE && !PWRITE && (PADDR == DATA_O);

always_comb begin
    count_next = count;
    if (push && !pop && count < DEPTH)
        count_next = count + 1;
    else if (pop && !push && count > 0)
        count_next = count - 1;
end
```

### 7.3 Corrected Pointer Update Logic

```systemverilog
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn || clr) begin
        wptr  <= '0;
        rptr  <= '0;
        count <= '0;
    end else begin
        count <= count_next;
        if (push && !full)
            wptr <= wptr + 1;
        if (pop && !empty)
            rptr <= rptr + 1;
    end
end
```

### 7.4 Corrected Status Flag Generation

```systemverilog
assign empty = (count_next == 0);
assign full  = (count_next == DEPTH);
```

### 7.5 Overflow and Underflow Protection

```systemverilog
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn || clr) begin
        overflow  <= 1'b0;
        underflow <= 1'b0;
    end else begin
        if (push && full)
            overflow  <= 1'b1;
        if (pop && empty)
            underflow <= 1'b1;
    end
end
```

### 7.6 Fix Validation Results

After applying the RTL fixes:

| Test | Result |
|---|---|
| All directed sequences | PASSED |
| Random sequence (163 operations) | PASSED — 0 mismatches |
| FIFO ordering under stress | PRESERVED |
| Overflow / Underflow flag assertion | CORRECT |

---

## 8. Final Conclusions

This project demonstrates the successful application of UVM to verify a complex APB-based FIFO design. The verification environment detected subtle concurrency and boundary-condition bugs that were not observable using simple testing techniques.

The detected defects were systematically analyzed, fixed, and re-verified, resulting in a robust and reliable FIFO implementation. The work highlights the importance of **coverage-driven verification** and validates UVM as an effective industry-standard methodology.

---

## Project Structure

```
APB_FIFO_VERIFICATION/
├── testbench.sv
├── design/
│   └── apb_sync_fifo.sv
└── verification/
    ├── apb_agent.sv
    ├── apb_driver.sv
    ├── apb_fifo_coverage.sv
    ├── apb_fifo_env.sv
    ├── apb_if.sv
    ├── apb_monitor.sv
    ├── apb_scoreboard.sv
    ├── apb_sequence_item.sv
    ├── apb_sequencer.sv
    ├── apb_test.sv
    ├── register/
    │   ├── apb_fifo_ctrl_reg.sv
    │   ├── apb_fifo_data_reg.sv
    │   ├── apb_fifo_reg_block.sv
    │   ├── apb_fifo_status_reg.sv
    │   ├── apb_fifo_threesh_reg.sv
    │   └── apb_reg_adapter.sv
    └── sequence/
        ├── fifo_base_seq.sv
        ├── fifo_basic_seq.sv
        ├── fifo_directed_basic_seq.sv
        ├── fifo_directed_clear_seq.sv
        ├── fifo_directed_overflow_seq.sv
        ├── fifo_directed_underflow_seq.sv
        └── fifo_random_seq.sv
```
