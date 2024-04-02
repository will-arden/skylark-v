# skylark-v
*skylark-v* is a lightweight and straightforward 4-stage [RISC-V](https://riscv.org/) processor, inspired by [RI5CY](https://www.pulp-platform.org/docs/ri5cy_user_manual.pdf) and implemented in SystemVerilog. The most notable feature of this design is the inclusion of a hardware acceleration unit for [Binarized Neural Network (BNN)](https://arxiv.org/abs/1603.05279) inference operations.  

This university project is designed for the Digilent Basys 3 development board. The IP, along with the constraint file and the zipped Vivado project (2018.3 webpack edition) can be found in the build folder.

### Demo:
This short demo shows *skylark-v* on the Digilent Basys 3; the clock speed has been significantly reduced for demonstration purposes. The simple program (`skylark-v/sample_programs/program4.txt`) involves each digit counting to 15 (`0xF`), before sitting idle in an infinite *terminate* loop.  

https://github.com/will-arden/skylark-v/assets/31668269/915a5bab-3a69-4408-a080-b200a94aae29

In `tools/img_converter` there is a simple Python script which may be useful for easily converting a 1-bit PNG image to plain text (and vice versa) in order to store in program/data memory, and to provide some visual of any convolution operations. Opening up the file will reveal some important user-configurable variables. In order to use this Python script, the [Pillow](https://github.com/python-pillow/Pillow) package is required, which can be installed with `pip`.

A link to the project planning interface (Notion) can be found [here.](https://boatneck-ping-f37.notion.site/Individual-Project-24f37a1b95bd4415b68c7d97c25824d7?pvs=4) It documents the journey so far!

### System Design Diagram:
![Block_Diagram](https://github.com/will-arden/risc-v-core/blob/main/doc/block_diagram?raw=true)
*Note: This is an outdated system diagram.*

---

### Why is the BNN unit useful?
A very popular type of machine learning algorithm is a *Convolutional Neural Network (CNN)*; these are expensive to implement in a processor design, since they typically rely on a dedicated *Vector Register File (VRF)* and a *Multiply-Accumulate unit (MAC)*.

One way to reduce the computation (and therefore simplify & speed-up the hardware) is to constrain the precision of the CNN to a lesser number of bits; this is known as a *Quantized Neural Network (QNN)*. Usually this quantization involves reducing the precision to 16 or 8 bits, while only a (relatively) small degree of accuracy is lost in the final result. Taking this concept to the extreme, one is able to represent every operand as a 1-bit integer; this is known as a *Binarized Neural Network (BNN)*.

BNNs are extremely fast since meaningful computations can be carried out using individual logic gates. If we represent (-1) as `0`, and 1 as `1`, then an XNOR gate can be considered as a multiplier of two 1-bit numbers. To perform a binarized convolution of two 1-bit nxn matrices, an array of XNOR gates may be used to perform the element-wise multiplication, before these products are summed using a *popcount* operation (also known as a *1's count*).

To go an extra step and calculate the activation of a neuron in this case is simple; since we are expecting a *binary* result, a step function should be used to calculate the activation of the neuron, with an appropriate *activation threshold*.

### How does this processor implement the BNN unit?

The BNN unit in *skylark-v* is split across two pipeline stages, in order to meet narrower timing constraints (otherwise it does not reach 100MHz). In the *Execute* stage, the ALU is recycled to perform an XOR computation, before passing this result to the BNN unit. The BNN unit first inverts the bits (to compute the *XNOR* of the operands) before zeroing some MSBs to ensure that the following popcount operation will only consider the bits that fall within the matrix size (which is configurable via the custom `BNNCMS` instruction).

The length-adjusted XNOR result is pipelined, where it becomes an input to the BNN unit in the *Writeback* stage. In this second stage, the popcount operation is carried out using an adder tree. Since a `0` is really representing (-1), the result of the convolution between the two input matrices will be equal to `2*popcount - matrix_size`. This can be achieved simply with a logical shift and a binary subtraction. In the case of a `BCNV` instruction, this convolution result is written back to the general-purpose register file.

In the case of a `BNN` instruction, the popcount result is passed through an additional *activation* stage, where it is compared with an activation threshold (configurable via the custom `BNNCAT` instruction); the binary result is then written back to the register file.

The two matrix operands of a BNN operation include the input matrix (an image, *x*), and the binary weights (*w*). If the model requires biases for each connection between neurons, then this does not require extra hardware; since biases result in adding some constant to the convolution result for each layer, the activation threshold can simply be offset by the same amount to achieve the equivalent behaviour.

---

### To-do
* Support the `jalr` instruction such that program function returns are possible
* Rewrite the logic in the `decoder` module

### Changelog (v0.8)
* The BNN unit has been shortened to exclude the activation step
  - Reduces hardware that will probably be useless in realistic applications where the image size may be greater than 32
  - Activation computation can still be easily achieved using the `bcnv` instruction, followed by conditional branches
* The *Hazard Control Unit* has been updated:
  - To fix bugs introduced by the pipelined BNN unit (which now writes back in the final stage)
  - To fix a bug where branches would always be taken if they were being decoded whilst a stall/flush was occurring
* The *Load Stall Buffer* now holds `ExPathW2` and `BNNResultW2`, the latter of which is used for forwarding
* `bnn_instruction_hex.py` has been tweaked to ensure `bcnv` operations have the correct `funct3` bits

---

### Previous versions

#### Changelog (v0.7.1)
* *Load Upper-Immediate* (`LUI`) instructions (U-type) are now supported
* Latch in *Decode* stage removed
* Due to minor changes in hardware, timing constraints for 100MHz are no longer met (improvement to come)
* Added a basic Python script in `tools/bnn_instruction_hex` which converts a custom BNN instruction to machine code

#### Changelog (v0.7)
* Split the BNN unit across two pipeline stages (*Execute* and *Writeback*) to reduce the critical path
  - Now meets all timing constraints at 100MHz
  - Popcount operation and activation threshold are computed in the *Writeback* stage
  - Decode logic adjusted to allow `BNN` and `BCNV` instructions to write back from the final pipeline stage
  - Multiplexer added in the *Writeback* stage to select between `ReadData` (from data memory) and `BNNResult` - `ExPathW` determines this selection
* *Clocking Wizard* (Vivado IP) replaces the `clk_div` module as a more reliable and professional solution
* Minor presentation adjustments

#### Changelog (v0.6.2)
* Fixed the 7-seg display issue with the low clock speed
* Altered the `bnn` logic to marginally improve the timing with Vivado's synthesizer

#### Changelog (v0.6.1)
* Fixed `BNN` instruction (now R-type)
* Added an additional *activation threshold* register in the `bnn` module (similar to `matrix_size`)
* Added logic for an extra instruction (`BNNCAT`) to configure the activation threshold
* Fixed a significant issue surrounding the load stall buffer (erroneous forwarding in some cases)
* Created a new test program based on *Single-Layer Perceptron (SLP)*
  - Identifies eight 1-bit 5x5 images as either *"mountains"* or *not "mountains"*
  - A *"mountain"* is defined in a *"mountain definition"* image (a white triangle at the bottom of the image)
  - Activation threshold set to 15 for optimal results (correctly identifies 8/8 test images)
  - All images may be found in `skylark-v/sample_programs/mountains`

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
