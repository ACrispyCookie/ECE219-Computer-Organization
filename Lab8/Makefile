SOURCES=qdbmp.c kmeans-better.c
TARGET=kmeans
GCC=gcc
CFLAGS=-O3 -Wall -std=c99

all: $(SOURCES)
	$(GCC) $(CFLAGS) -o $(TARGET) $(SOURCES) -lm

clean:
	rm -Rf *.o $(TARGET) 	
