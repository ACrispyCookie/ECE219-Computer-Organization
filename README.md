# ECE219 — Computer Organization

Coursework repository for ECE219 Computer Organization. It contains MIPS assembly exercises, C/assembly comparisons, Verilog CPU datapath labs, and cache/performance experiments in C.

## Contents

| Folder | Description |
|---|---|
| `Lab1/` | Introductory MIPS assembly exercises. |
| `Lab2/` | Additional MIPS assembly exercises. |
| `Lab3/` | C and assembly implementations for low-level programming exercises. |
| `Lab4/` | Verilog ALU and register-file lab with testbench. |
| `Lab5/` | Single-cycle CPU datapath/control work with Verilog source, program memory files, and lab report. |
| `Lab6/` | Extended CPU implementation with control logic, hazard-related output checks, and report. |
| `Lab7/` | Negedge and posedge CPU variants with Verilog source, program memory files, and reports. |
| `Lab8/` | K-means image-clustering optimization lab with original and optimized C implementations. |
| `Lab9/` | C loop/performance experiments with generated assembly at default and `-O3` optimization levels. |

## Requirements

- MIPS/SPIM/MARS-compatible assembler or simulator for `.asm` programs
- GCC for the C labs
- Icarus Verilog (`iverilog` and `vvp`) for Verilog simulation
- Optional: GTKWave for viewing generated `.vcd` waveforms
- Optional: Linux `perf` for the cache/performance measurement scripts

## C examples

Compile the Lab 3 C programs:

```bash
gcc -std=c11 -Wall -Wextra Lab3/src/exer1.c -o /tmp/ece219-lab3-exer1
gcc -std=c11 -Wall -Wextra Lab3/src/exer2.c -o /tmp/ece219-lab3-exer2
```

Compile the Lab 8 original and optimized implementations:

```bash
gcc -O3 -Wall -std=c99 Lab8/original/qdbmp.c Lab8/original/kmeans.c -lm -o /tmp/ece219-kmeans-original
gcc -O3 -Wall -std=c99 Lab8/optimized/qdbmp.c Lab8/optimized/kmeans.c -lm -o /tmp/ece219-kmeans-optimized
```

Compile the Lab 9 loop program:

```bash
gcc -Wall -Wextra Lab9/lab9_program.c -o /tmp/ece219-lab9
gcc -O3 -Wall -Wextra Lab9/lab9_program.c -o /tmp/ece219-lab9-o3
```

## Verilog examples

Compile the Verilog labs without writing simulator outputs into the repository:

```bash
iverilog -Wall -Winfloop -o /tmp/ece219-lab4 Lab4/src/library.v Lab4/src/testbench.v
iverilog -Wall -Winfloop -I Lab5 -I Lab5/src -o /tmp/ece219-lab5 Lab5/src/library.v Lab5/src/cpu.v Lab5/src/testbench.v
```

For later labs that use local include files, run from the lab directory:

```bash
cd Lab6
iverilog -Wall -Winfloop -o /tmp/ece219-lab6 control.v library.v cpu.v testbench.v
```
