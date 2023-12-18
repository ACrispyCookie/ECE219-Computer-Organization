CC = iverilog
FLAGS = -Wall -Winfloop

all:
	$(CC) $(FLAGS) -o ./src/verilog.out ./src/library.v ./src/testbench.v
	vvp ./out/verilog.out
	gtkwave ./out/dumpfile.vcd
