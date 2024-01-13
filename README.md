# Multi-Stage Pipelined RISC-V Compliant Processor
This repository is dedicated to a work-in-progress SystemVerilog design of a 4-stage RISC-V processor inspired by RI5CY.  
A link to the project planning interface (Notion) can be found [here.](https://boatneck-ping-f37.notion.site/Individual-Project-24f37a1b95bd4415b68c7d97c25824d7?pvs=4) It documents the journey so far!

![Block_Diagram](https://github.com/will-arden/risc-v-core/blob/main/doc/block_diagram?raw=true)

### Changelog (v0.3.1)
* Tidied-up register_file.sv
* Register values become `0x0` on reset, and register `x0` is hard-wired to `0x0`
* ALU subtraction bug fixed
* `JAL` instructions now write the link address (`PC+4`) to the register file
* 3:1 multiplexer added to select the output from the Execute stage (selecting using `ExPathE`)
* `BEQ` is partially implemented, in that it behaves identically to a `JAL` instruction.

### To-do
* Fully implement `BEQ` instruction
* Implement other B-type instructions
* Add pipeline registers and hazard control unit
* Add BNN unit
