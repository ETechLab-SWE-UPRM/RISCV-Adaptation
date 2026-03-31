import serial, struct
from time import sleep


def send_u32(ser, v):
    ser.write(struct.pack(">I", v))

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack(">I", b)[0]

def f32_bits(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]
port = "/dev/ttyUSB1"
baud = 115200

SIGN = 0x5349474E
KERN      = 0x4B45524E
DATAERROR = 0x44455252
WEIGHTSERROR = 0x57455252
signal = [float(i) for i in range(1,11)]

with serial.Serial("/dev/ttyUSB1",115200,timeout=5) as ser:
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    while True:
        data = recv_u32(ser)
        print(f"Received 0x{data:08X}")