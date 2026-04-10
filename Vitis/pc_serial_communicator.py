import serial, struct
import time

def send_u32(ser, v):
    d = struct.pack("<I", v)
    ser.write(d)

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack("<I", b)[0]

def f32_bits(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]

def bits_to_f32(v):
    return struct.unpack("<f", struct.pack("<I", v))[0]

# UART CONFIGURATION
port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

signal = [float(i) for i in range(1,1025)]
kernel = [1.0,1.0,1.0]
result = []
result_len = len(signal) - len(kernel) + 1

SIGN = 0x4E474953
DATAERROR = 0x52524544
KERN = 0x4E52454B
WEIGHTERROR = 0x52524557
DONE = 0x454E4F44
START = 0x54525453

with serial.Serial(port, baud, timeout=5) as ser:
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    
    for v in signal:
        send_u32(ser, f32_bits(v))
    send_u32(ser, f32_bits(-1.0))

    sign = recv_u32(ser)

    if sign == SIGN:
        print(f"Received 'SIGN'")
    elif sign == DATAERROR:
        raise ValueError("\033[31mData input error detected.\033[0m")

    for v in kernel:
        send_u32(ser, f32_bits(v))
    send_u32(ser, f32_bits(-1.0))

    kern = recv_u32(ser)

    if kern == KERN:
        print(f"Received 'KERN'")
    elif kern == WEIGHTERROR:
        raise ValueError("\033[31mWeight input error detected.\033[0m")
    
    start = recv_u32(ser)

    if start == START:
        print("Received 'START'")
    else :
        print("You done goofed")

    start = time.perf_counter()

    done = recv_u32(ser)

    end = time.perf_counter()

    if done == DONE:
        print("Received 'DONE'")

    if (done == DONE):
        elapsed_us = (end - start) * 1e6
        print("Successful Measurement!")
        print(f"Took {elapsed_us:.3f} microseconds")
    else :
        raise ValueError(f"\033[31mDONE not received: 0x{done:08X}\033[0m")

    i = 0
    while i < result_len:
        data = recv_u32(ser)
        result.append(data)
        i += 1

with open("results.txt", "w") as file:
    for v in result:
        file.write(f"0x{v:08x} -> {bits_to_f32(v)}\n")