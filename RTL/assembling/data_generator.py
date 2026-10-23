# Helpful in order to already have the data in memory.
import numpy as np

data = np.arange(1, 301, dtype=np.float32).reshape(50, 6)
data_flat = data.flatten()
signal = data_flat.tolist()

print("Signal:")
print(data)

kernel1 = np.ones((16, 3, 6), dtype=np.float32)

print("\nKernel1:")
print(kernel1)

kernel1 = kernel1.flatten().tolist()

print("\nFlattened input:")
print(signal)

print("\nFlattened 1st kernel:")
print(kernel1)

kernel2 = np.ones((3,16,32), dtype=np.float32)
kernel2 = kernel2.transpose(2, 0, 1).flatten()
kernel2 = kernel2.tolist()

print("\nFlattened 2nd kernel:")
print(kernel2)

kernel3 = np.ones((1,32,64), dtype=np.float32)
kernel3 = kernel3.transpose(2, 0, 1).flatten()
kernel3 = kernel3.tolist()

print("\nFlattened 3rd kernel:")
print(kernel3)

with open("signal_data.inc", "w",) as file:
    for i in signal:
        file.write(f"{i},\n")

with open("kernel_data.inc", "w",) as file:
    for i in kernel1:
        file.write(f"{i},\n")

with open("kernel_data2.inc", "w",) as file:
    for i in kernel2:
        file.write(f"{i},\n")

with open("kernel_data3.inc", "w",) as file:
    for i in kernel3:
        file.write(f"{i},\n")