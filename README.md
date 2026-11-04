# 8-bit RISC-V-style CPU on a Lattice CrossLink-NX

A small single-cycle CPU written in Verilog, simulated with Icarus Verilog and running on the
Lattice CrossLink-NX Evaluation Board (LIFCL-40-EVN). The board's LEDs show the CPU's registers,
so you can watch programs run on real hardware.

The design follows the single-cycle RISC-V microarchitecture from Harris & Harris,
*Digital Design and Computer Architecture: RISC-V Edition*, scaled down to an 8-bit datapath with
a custom 16-bit instruction set. It is RISC-V-inspired, not RISC-V compatible.

## Features

- 8-bit datapath, 16-bit instructions, one instruction per clock cycle
- 8 registers (`x0`–`x7`); `x0` always reads 0
- ALU with 8 operations: ADD, SUB, AND, OR, XOR, NOT, shift left, shift right
- Loads/stores, a conditional branch, jumps and function calls (`JAL` / `JALR`)
- 256 × 16-bit instruction memory, loaded from `program file/program.mem` at synthesis
- 256 × 8-bit data memory
- LED *n* lights when register `xn` equals *n*

## Folder layout

```
Risc_v/                  CPU and board Verilog
  RISCV_Top.v            the CPU: wires the blocks below together
  Control_Unit.v         decodes the opcode into control signals
  ALU.v                  arithmetic and logic unit
  Register_File.v        8 x 8-bit registers, x0 = 0
  Extend.v               builds the immediate for each instruction type
  Instruction_Memory.v   program ROM, loaded from program file/program.mem
  Data_Memory.v          256-byte RAM for LW / SW
  LEDS.v                 LED n on when xn == n
  CrossLinkNX_Top.v      board top: inverts the active-low reset button and LEDs
  HDLStudio_Top.v        top for viewing the CPU in the VS Code HDL Studio extension
Constraint file/
  CrossLinkNX_EVN.ldc    pin constraints for the CrossLink-NX Evaluation Board
program file/
  program.mem            the program the CPU runs
  examples/              example programs (copy one into program.mem)
simulation files/
  tb_RISCV_Top.v         self-checking testbench for Icarus Verilog
```

## Architecture

Each clock cycle:

1. The **PC** addresses the **instruction memory**, which outputs a 16-bit instruction.
2. The **control unit** decodes the opcode; **Extend** builds the immediate.
3. The **register file** reads `rs1` and `rs2`; the **ALU** combines `rs1` with `rs2` or the immediate.
4. The ALU result is either written back, or used as the **data memory** address for `LW` / `SW`.
5. The value written to `rd` is the ALU result, the loaded byte, or `PC + 1` (for `JAL` / `JALR`).
6. The next PC is `PC + 1`, a branch/jump target `PC + imm`, or `rs1 + imm` for `JALR`.

Every instruction completes in one clock cycle. The PC counts instructions (not bytes), so branch
and jump offsets are measured in instructions.

## Instruction set

All instructions are 16 bits:

| Type | Bits 15–12 | 11–9 | 8–6 | 5–3 | 2–0 |
|---|---|---|---|---|---|
| R (register ops) | opcode | rd | rs1 | rs2 | funct3 |
| I (ADDI, LW, JALR) | opcode | rd | rs1 | imm[5:3] | imm[2:0] |
| S / B (SW, BEQ) | opcode | imm[5:3] | rs1 | rs2 | imm[2:0] |

`JAL` has its own layout: opcode in bits 15–12, rd in 11–9, bit 8 unused (0), and an 8-bit
immediate in bits 7–0.

| Opcode | Instruction | Meaning |
|---|---|---|
| `0000` | R-type | `rd = rs1 (op) rs2`, operation chosen by funct3 |
| `0001` | `ADDI rd, rs1, imm` | `rd = rs1 + imm` |
| `0010` | `LW rd, imm(rs1)` | `rd = mem[rs1 + imm]` |
| `0011` | `SW rs2, imm(rs1)` | `mem[rs1 + imm] = rs2` |
| `0100` | `BEQ rs1, rs2, imm` | if `rs1 == rs2`: `PC = PC + imm` |
| `0101` | `JAL rd, imm` | `rd = PC + 1`, `PC = PC + imm` |
| `0110` | `JALR rd, imm(rs1)` | `rd = PC + 1`, `PC = rs1 + imm` |

| funct3 | R-type operation |
|---|---|
| `000` | ADD: `rs1 + rs2` |
| `001` | SUB: `rs1 - rs2` |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | NOT: `~rs1` |
| `110` | SHL: `rs1 << 1` |
| `111` | SHR: `rs1 >> 1` |

Immediates are signed: 6 bits (−32 to +31) for ADDI, LW, SW, BEQ and JALR, and 8 bits for JAL.
Registers are 8 bits, so `ADDI x1, x0, -2` gives 254.

Handy patterns:
- **Load a constant:** `ADDI x1, x0, 5`
- **Unconditional jump:** `JAL x0, offset` (the return address goes to `x0` and is thrown away)
- **Halt:** `JAL x0, 0` jumps to itself forever
- **Function call / return:** `JAL x4, offset` to call, `JALR x0, 0(x4)` to return
- **Loop until equal:** there is no "branch if not equal", so exit with `BEQ` and jump back with `JAL`

## Writing a program

`program file/program.mem` holds one instruction per line in binary. Underscores and `//`
comments are allowed, so you can split each instruction into its fields:

```
// op   rd  rs1 imm
0001_001_000_000101   // ADDI x1, x0, 5      x1 = 5
0000_011_001_010_000  // ADD  x3, x1, x2     x3 = x1 + x2
0101_000_0_00000000   // JAL  x0, 0          halt
```

The program is built into the hardware, so after changing `program.mem` you need to
re-run the simulation or rebuild the bitstream (see below).

## Example programs

The `program file/examples/` folder has ready-made programs. Copy one over `program.mem` to run it.
Each one was checked in simulation.

| File | What it shows | LEDs at the end |
|---|---|---|
| `01_led_test.mem` | Loading constants; the LED rule | LED2, LED3, LED7 |
| `02_alu_all_leds.mem` | All 8 ALU operations | LED1–LED7 |
| `03_loop_count.mem` | A counting loop with `BEQ` + `JAL` | LED5 |
| `04_memory.mem` | Storing and loading with `SW` / `LW` | LED2, LED6 |
| `05_function_call.mem` | Calling a function with `JAL`, returning with `JALR` | LED1, LED3, LED7 |
| `06_blink.mem` | Nested delay loops: LED1 blinks about once a second | LED1 blinking |
| `07_alternate_blink.mem` | LED1 and LED2 take turns | LED1 / LED2 alternating |

The blink programs run three nested loops of 127 steps each, so LED1 toggles every
6,193,919 clock cycles, which is 0.516 s at 12 MHz. Their delay counters only hold even
numbers, so LED3, LED5 and LED7 never flash while the CPU is counting.

## Simulation (Icarus Verilog)

From the `simulation files` folder:

```
iverilog -o cpu.vvp tb_RISCV_Top.v ../Risc_v/RISCV_Top.v ../Risc_v/ALU.v ../Risc_v/Control_Unit.v ../Risc_v/Data_Memory.v ../Risc_v/Extend.v ../Risc_v/Instruction_Memory.v ../Risc_v/Register_File.v ../Risc_v/LEDS.v
vvp cpu.vvp
gtkwave cpu.vcd
```

The testbench prints every instruction, then the registers, then `PASS` or what failed. It also
writes `cpu.vcd`, where `x0`–`x7` appear as separate signals in GTKWave.

- The testbench checks the results of `01_led_test.mem`. With any other program it reports FAIL.
- After changing `program.mem`, just run `vvp cpu.vvp` again. Recompile only after changing `.v` files.
- The real blink programs need millions of cycles. To see them blink in simulation, change the
  three `ADDI ..., -2` lines that start the counters to a small value such as `000110` (6).
- Icarus and GTKWave come with [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build).

## Running on the CrossLink-NX Evaluation Board (Lattice Radiant)

1. Create a project for device **LIFCL-40-8BG400C** (match the marking on your chip) with
   **Lattice LSE** as the synthesis tool.
2. Add every file in `Risc_v/` **except `HDLStudio_Top.v`**. Don't add the testbench.
3. Add `Constraint file/CrossLinkNX_EVN.ldc` under **Pre-Synthesis Constraint Files** and set it as active.
4. Set **`CrossLinkNX_Top`** as the top-level unit.
5. **Radiant 2.0 only:** open Strategy → LSE and set **Resource Sharing** to **False**.
   Otherwise synthesis crashes with `segmentation violation` on some programs.
6. Run through **Export Files** and program the board with Radiant Programmer.

After editing `program.mem`, force a rerun of **Synthesize Design**. Radiant does not track the
`.mem` file and may otherwise reuse the old program. A Map report with 0 LUTs means the program
did nothing or was not found.

### Board connections

| Signal | Pin | On the board |
|---|---|---|
| `clk` | L13 | 12 MHz oscillator (jumper JP2 fitted) |
| `rst_n` | G14 | push button SW2: hold to reset |
| `led_n[0]`–`led_n[7]` | E17, F13, G13, F14, L16, L15, L20, L19 | LEDs D3–D10 |

The board's LEDs light when driven low and its buttons read 0 when pressed. `CrossLinkNX_Top.v`
inverts both, so the CPU itself stays active-high. LED0 (D3) is always off, because `x0` is
always 0. LEDs D11–D16 aren't used by the design and light up, since nothing drives them.

## Known limitations

- 256 instructions maximum (8-bit PC)
- Immediates are only 6 bits, so larger constants take several instructions
- `BEQ` is the only conditional branch
- The program is fixed at synthesis time; changing it means rebuilding the bitstream
- `HDLStudio_Top.v` is for the VS Code HDL Studio extension, which copies `.mem` files into its
  own work folder. It may not find the program through the `../program file/` path.

## Credits

Microarchitecture based on the single-cycle processor in Harris & Harris,
*Digital Design and Computer Architecture: RISC-V Edition*.
