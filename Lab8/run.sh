make
perf stat -e L1-dcache-loads -e L1-dcache-load-misses -e LLC-loads -e LLC-load-misses ./kmeans ./Input_Data/$1 ./Output_Data/$1 4
