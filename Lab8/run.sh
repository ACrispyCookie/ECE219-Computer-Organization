make
perf stat -e L1-dcache-loads -e L1-dcache-load-misses -e LLC-loads -e LLC-load-misses ./kmeans_optimized ./Input_Data/andromeda_tiled_rgb.bmp ./Output_Data/andromeda_tiled_rgb.bmp 4
