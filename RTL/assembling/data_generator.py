# Helpful in order to already have the data in memory.
import numpy as np

data = np.arange(1, 301, dtype=np.float32).reshape(50, 6)
data_flat = data.flatten()
signal = data_flat.tolist()

kernel = np.ones((3, 6, 16), dtype=np.float32)

# [filter][kernel_position][input_channel]
kernel = kernel.transpose(2, 0, 1).flatten()
kernel = kernel.tolist()

print("Flattened input:")
print(signal)

print("\nFlattened kernel:")
print(kernel)

with open("signal_data.inc", "w",) as file:
    for i in signal:
        file.write(f"{i},\n")

with open("kernel_data.inc", "w",) as file:
    for i in kernel:
        file.write(f"{i},\n")