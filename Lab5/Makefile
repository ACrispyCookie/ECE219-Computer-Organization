CC = iverilog
FLAGS = -Wall -Winfloop

all:
	$(CC) $(FLAGS) -o verilog.out library.v cpu.v testbench.v
	vvp verilog.out
	gtkwave cpu_tb.vcd
