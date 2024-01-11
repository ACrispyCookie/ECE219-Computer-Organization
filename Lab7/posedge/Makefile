CC = iverilog
FLAGS = -Wall -Winfloop
EXE = lab7a.out
SRCS = control.v library.v cpu.v testbench.v

all:
	$(CC) $(FLAGS) -o $(EXE) $(SRCS)
	vvp $(EXE)
	gtkwave tb_dumpfile.vcd waveform.gtkw

clean:
	rm -rf $(EXE)
	rm -rf tb_dumpfile.vcd
	rm -rf output.txt
