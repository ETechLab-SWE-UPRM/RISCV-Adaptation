# Helpful in order to already have the data in memory.

signal = [i for i in range(1,1025)]
kernel = [1 for i in range(11)]

with open("signal_data.inc", "w",) as file:
    for i in signal:
        file.write(f"{i},\n")

with open("kernel_data.inc", "w",) as file:
    for i in kernel:
        file.write(f"{i},\n")