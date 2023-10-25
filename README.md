# Multi-Stage Pipelined RISC-V Compliant Processor
This repository is dedicated to a work-in-progress SystemVerilog design of a multi-stage pipelined RISC-V compliant processor. Between October 2023 - June 2024 this page should be updated frequently.

The SystemVerilog is designed for the Icarus Verilog compiler, and should be run with the `-g2012` option.

For example:

      iverilog -g2012 ALU.sv
      vvp a.out
      gtkwave dut.vcd

`gtkwave` is a visualisation tool which is especially useful when working with SystemVerilog.
