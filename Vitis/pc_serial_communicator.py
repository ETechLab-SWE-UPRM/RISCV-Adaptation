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

def int_to_bits(v):
    e = struct.unpack(">I", struct.pack("<i", v))[0]
    print(f"int_to_bits: {v} -> 0x{e:08x}")
    return e

# UART CONFIGURATION
port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

signal = [float(i) for i in range(1,1025)]
kernel = [1.0 for i in range(11)]
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
    
    send_u32(ser, int_to_bits(-1)) # Send start signal

    elapsed = recv_u32(ser)

    print(f"Elapsed time: {elapsed} cycles")

    i = 0
    while i < result_len:
        data = recv_u32(ser)
        result.append(data)
        i += 1

with open("results.txt", "w") as file:
    for v in result:
        file.write(f"0x{v:08x} -> {bits_to_f32(v)}\n")