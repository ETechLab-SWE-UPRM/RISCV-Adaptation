import time
import struct

def float_to_hex32(f):
    return struct.unpack('<I', struct.pack('<f', f))[0]

def main():
    signal = [0] * 1024
    for i in range(1024):
        signal[i] = float(i + 1)

    kernel = [1.0, 1.0, 1.0]
    result = [0.0] * (len(signal) - len(kernel) + 1)

    start = time.perf_counter() #starts counting at the time of execution
    for i in range(len(result)):
        sum = 0.0 
        for j in range(len(kernel)):
            sum+=signal[i + j] * kernel[j]
        result[i] = (sum)
    
    #finishes time of execution before the print statement is called
    end = (time.perf_counter() - start) * 1_000_000_000 #converts to nanoseconds
    print(end, "nanoseconds")
    for i in range(15):
        hex_val = float_to_hex32(result[i])
        print(f"{result[i]:10.3f}  ->  0x{hex_val:08X}")


if __name__ == "__main__":
    main()