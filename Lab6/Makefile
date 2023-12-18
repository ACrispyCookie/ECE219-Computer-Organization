CC = iverilog
FLAGS = -Wall -Winfloop
EXE = ./out/lab6a.out
SRCS = ./src/control.v ./src/library.v ./src/cpu.v ./src/testbench.v

all:
	$(CC) $(FLAGS) -o $(EXE) $(SRCS)
	vvp $(EXE)
	gtkwave ./out/tb_dumpfile.vcd ./out/waveform.gtkw

clean:
	rm -rf $(EXE)
