CC = iverilog
FLAGS = -Wall -Winfloop

all:
	$(CC) $(FLAGS) -o verilog.out library.v testbench.v
	vvp verilog.out
	gtkwave dumpfile.vcd
