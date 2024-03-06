# skylark-v
*skylark-v* is a lightweight and straightforward 4-stage [RISC-V](https://riscv.org/) processor, inspired by [RI5CY](https://www.pulp-platform.org/docs/ri5cy_user_manual.pdf) and implemented in SystemVerilog. The most notable feature of this design is the inclusion of a hardware acceleration unit for [Binarized Neural Network (BNN)](https://arxiv.org/abs/1603.05279) inference operations.  

This university project is designed for the Digilent Basys 3 development board, and is compatible with the undivided 100MHz clock provided onboard. The IP, along with the constraint file and the zipped Vivado project (2018.3 webpack edition) can be found in the build folder.  

In `tools/img_converter` there is a simple Python script which may be useful for easily converting a 1-bit PNG image to plain text (and vice versa) in order to store in program/data memory, and to provide some visual of any convolution operations. Opening up the file will reveal some important user-configurable variables. In order to use this Python script, the [Pillow](https://github.com/python-pillow/Pillow) package is required, which can be installed with `pip`.

A link to the project planning interface (Notion) can be found [here.](https://boatneck-ping-f37.notion.site/Individual-Project-24f37a1b95bd4415b68c7d97c25824d7?pvs=4) It documents the journey so far!

### System Design Diagram:
![Block_Diagram](https://github.com/will-arden/risc-v-core/blob/main/doc/block_diagram?raw=true)
*Note: This is an outdated system diagram.*

---

### To-do
* Create a demo to show the efficiency of *skylark-v* compared to a single-cycle processor (from the Harris & Harris book)
* Write a sample program demonstrating ML-related tasks with and without the use of the BNN unit
* Update the `bnn` module to allow for easy concatenation of BNN results:
  - Create an additional `bnn_index` register such that subsequent activations can be easily concatenated in the same destination register
  - Support a simple instruction to write to the `bnn_index` register, similar to `BNNCMS`
* Explore the benefits of a branch prediction unit

### Changelog (v0.6.0)
* Fixed `BNN` instruction (now R-type)
* Added an additional *activation threshold* register in the `bnn` module (similar to `matrix_size`)
* Added logic for an extra instruction (`BNNCAT`) to configure the activation threshold
* Fixed a significant issue surrounding the load stall buffer (erroneous forwarding in some cases)
* Created a new test program based on *Single-Layer Perceptron (SLP)*
  - Identifies eight 1-bit 5x5 images as either *"mountains"* or *not "mountains"*
  - A *"mountain"* is defined in a *"mountain definition"* image (a white triangle at the bottom of the image)
  - Activation threshold set to 15 for optimal results (correctly identifies 8/8 test images)

---

### Previous versions

#### Changelog (v0.6.0)
* Updated `bnn` module and `tb_bnn`
  - Included a configurable activation threshold, such that both the binarized convolution and the neuron activation may be calculated
  - Contains a register which holds the `matrix_size` (default is 3x3=9), which may be written to by asserting `ms_WE`
  - *XOR* result from the ALU is input, before being inverted within the `bnn` module (to get *XNOR*), in the interest of minimizing hardware
  - Results verified with handwritten matrix convolution calculations
* Updated the control logic to support the new *BNN instructions*:
  - **Binarized Convolution** (`BCNV`) - outputs the result of the matrix convolution
  - **BNN Operation** (`BNN`) - convolves the two matrices and applies the activation threshold specific to the instruction (immediate)
  - **Configure Matrix Size** (`BNNCMS`) - writes an immediate value to the `matrix_size` register in the `bnn` module

#### Changelog (v0.5.1)
* Fixed RAW hazard for store operations
* Fixed issue in the `decoder` module which was leading to an incorrect data memory write address
* Added a `clk_div` module for producing a low-speed clock signal, more suitable for FPGA demonstrations
* 7-segment display for Basys 3 now working

#### Changelog (v0.5.0)
* Created a `soc` module, which replaces the top level testbench for FPGA synthesis
  - Instantiated instruction memory and data memory
  - Proves functionality via two LEDs
  - 7-segment display is utilised in a very basic manner (to prove it is a resource that can be accessed)
* Constraint file added
* Bitstreams generated and IP made available on GitHub
* Vivado project included on GitHub (configured for the Basys 3 development board)

#### Other minor changes
* `display_encoder` module created but not used
* `timescale` directive added to every module, based on guidance from Frank Bruno's book

#### Changelog (v0.4.4)
* Simplified the branch behaviour of the processor
  - Removed the `branched_flag_F` and `branched_flag_D` signals
  - Updated the `hcu` to accommodate for new branch behaviour
  - Updated the `decoder` to detect mispredictions (calculated in the *Execute* stage) and handle branches/jumps correctly
  - Updated the `c_id_ex_pipeline_register` module to assist the `decoder`
* Separated the `hcu` module into *Forwarding* and *Stalling & Flushing* - improves readability and less error-prone
* Small readability improvements

#### Changelog (v0.4.3)
* if/else logic updated in the `hcu` module to avoid potential bugs
* Comments added to better describe the branch behaviour of this version (soon to be updated)

#### Changelog (v0.4.2)
* Added a *load stall buffer*, doubling the efficiency when handling *load use* data hazards
* Included - **but not instantiated** - a `bnn` module and testbench
* Small syntax and presentation fixes

#### Changelog (v0.4.1)
* Tidied SystemVerilog code and comments
* Removed unused/unnecesary signals
* Created a `decoder` module within `control` to handle the instruction decode logic in a dedicated unit
* Moved the `hcu` module into the `control` module

#### Changelog (v0.4.0)
* Three pipeline registers added to create a 4-stage pipelined implementation
* Hazard Control Unit created
* Forwarding multiplexers added for RAW hazards
* Pipeline stalling and flushing implemented
* Load stalling for 2 cycles
* Branch instructions supported for pipelined architecture
  - AGU moved to the Decode stage
  - Fetch stage outputs a `branched_flag_F` signal following a branch
#### Other minor changes
* Changed `Instr` to `InstrF` in the top-level modules
* Changed `zero` and `negative` to `Z` and `N` respectively
* Removed the `timescale` directive from all modules bar the top-level testbench
* The `WriteAddr` signal was previously always set to `0x0`. Instead, the `ALUResult` signal should be used when specifying the write address to external data memory.
* Used a for-loop in the register file for zeroing the registers on reset - much more code-efficient.
* On reset, the pipeline is filled with `NOP` instructions.

#### Changelog (v0.3.5)
* Register file reset bug fixed
* Latch generated by `condition_met` signal has been removed
* `BEQ`, `BNE`, `BLT` and `BGE` are fully implemented
* Fixed negative flag issue in `ALU.sv`
* `JAL` instructions now write the link address (`PC+4`) to the register file
* 3:1 multiplexer added to select the output from the Execute stage (selecting using `ExPathE`)

![Skylark](https://github.com/will-arden/risc-v-core/blob/main/doc/skylark2.jfif?raw=true)
