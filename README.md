# APB-AMBA-UVM-Verification
Verified AMBA APB interconnect thorugh Universal Verification Methodology 

# APB Slave UVM Verification Project

UVM-based functional verification environment for an APB (Advanced Peripheral Bus) 
slave memory controller with error detection.

## Overview

This project verifies an APB slave DUT that implements a 64KB memory with 
out-of-bounds and misalignment error detection. The testbench is built using 
UVM methodology with layered architecture.

## DUT Features

- APB slave protocol (SETUP → ACCESS phases)
- 64 KB memory (byte-addressable, 64-bit data width)
- Write strobe (PSTRB) support for partial writes
- Error generation:
  - Out-of-bounds access (address ≥ 64 KB)
  - Misaligned access (address not 8-byte aligned)
- PSLVERR assertion on invalid transfers

## Testbench Architecture
```bash
apb_full_test / apb_random_test / apb_wr_rd_test / apb_err_test / apb_boundary_test
│
▼
apb_env
┌───┴───┐
apb_agent apb_scoreboard
┌────┼────┐ ▲
│ │ │ │ (analysis port)
driver seq monitor───┘
│ │
└──► apb_interface
│
▼
DUT
```

## Components

| Component | Purpose |
|---|---|
| `apb_seq_item` | Transaction with constraints and field macros |
| `apb_sequencer` | Routes transactions from sequences to driver |
| `apb_driver` | Drives APB protocol signals to DUT |
| `apb_monitor` | Captures transactions from interface |
| `apb_agent` | Bundles driver + sequencer + monitor |
| `apb_scoreboard` | Reference memory model + comparison |
| `apb_coverage` | Functional coverage (covergroups + crosses) |
| `apb_env` | Top-level environment |
| `apb_base_test` | Base test class |
| `apb_full_test` | Runs all sequences in one simulation |

## Sequences

- `apb_base_seq` – Random transactions
- `wr_rd_seq` – Write followed by read on same address
- `apb_err_seq` – Error injection (OOB + misaligned)
- `apb_boundary_seq` – Lower (0x0) and upper (0xFFF8) boundary test

## Functional Coverage

Covergroup includes:
- `cp_write` – Read/Write toggle
- `cp_strb` – Strobe patterns (FF, 0F, F0, 01, 80, 55, AA, 00)
- `cp_addr` – Address regions (LOW, MID, HIGH, OOB, boundaries)
- `cp_data` – Data patterns (zero, all-ones, AAAA, 5555, random)
- `cp_pslverr` – Error signal states
- Cross coverage: write×strb, write×pslverr, addr×data, align×pslverr

## How to Run

### Compile individual test
```bash
make compile TEST=[test]
make compile TEST=apb_random_test
make compile TEST=apb_wr_rd_test
make compile TEST=apb_err_test
make compile TEST=apb_boundary_test
```
### Simulate Individual Test
```bash
make sim TEST=[test]
make sim TEST=apb_random_test
make sim TEST=apb_wr_rd_test
make sim TEST=apb_err_test
make sim TEST=apb_boundary_test
```
### Project Structure
```bash
├── rtl/
│   ├── design.sv            # apb_wrapper (top DUT)
│   ├── apb_fsm.sv           # APB slave state machine
│   ├── err_gen.sv           # Error generation logic
│   ├── generic_mem.sv       # Parameterized memory wrapper
│   └── mem_1024x32.sv       # 1024x32 RAM block
│
├── tb/
│   ├── apb_interface.sv     # Interface with clocking blocks
│   ├── apb_tb_uvm_pkg.sv    # Package with all includes
│   ├── apb_seq_item.sv
│   ├── apb_sequencer.sv
│   ├── apb_driver.sv
│   ├── apb_monitor.sv
│   ├── apb_agent.sv
│   ├── apb_scoreboard.sv
│   ├── apb_coverage.sv
│   ├── apb_env.sv
│   ├── apb_base_seq.sv
│   ├── wr_rd_seq.sv
│   ├── apb_err_seq.sv
│   ├── apb_boundary_seq.sv
│   ├── apb_base_test.sv
│   ├── apb_random_test.sv
│   ├── apb_wr_rd_test.sv
│   ├── apb_err_test.sv
│   ├── apb_boundary_test.sv
│   └── apb_full_test.sv
│
├── testbench.sv             # Top module (clock, reset, DUT, run_test)
├── Makefile
└── README.md
```

### Tools Used
```bash
Simulator: Synopsys VCS (L-2016.06)
Methodology: UVM 1.2
Language: SystemVerilog
```

### Key Concepts Demonstrated
```bash
UVM factory pattern (type_id::create)
Config DB (set / get) for virtual interface passing
Phases: build, connect, run, report
TLM connections: seq_item_port ↔ seq_item_export
Analysis port for monitor → scoreboard/coverage broadcast
Field macros for auto print/copy/compare
Functional coverage with cross coverage
```

Reset handling and protocol-compliant driver
