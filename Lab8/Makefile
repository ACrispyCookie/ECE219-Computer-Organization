SOURCES=original/qdbmp.c original/kmeans.c
OPTIMIZED_SOURCES=optimized/qdbmp.c optimized/kmeans.c
TARGET=kmeans
GCC=gcc
CFLAGS=-O3 -Wall -std=c99

optimized: $(OPTIMIZED_SOURCES)
	$(GCC) $(CFLAGS) -o $(TARGET) $(OPTIMIZED_SOURCES) -lm

original: $(SOURCES)
	$(GCC) $(CFLAGS) -o $(TARGET) $(SOURCES) -lm

clean:
	rm -Rf *.o $(TARGET) 	
