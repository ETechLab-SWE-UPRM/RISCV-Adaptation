cmake_minimum_required(VERSION 3.10)
project(ConvolutionBenchmark C)

# Use C11
set(CMAKE_C_STANDARD 11)

# Enable high-performance optimizations
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -march=native -Wall -Wextra")

add_executable(floating_point_convolution floating_point_convolution.c)