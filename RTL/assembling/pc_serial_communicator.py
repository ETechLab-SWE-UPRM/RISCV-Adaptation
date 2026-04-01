import serial, struct

def send_u32(ser, v):
    d = struct.pack(">I", v)
    ser.write(d)

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack(">I", b)[0]

def f32_bits(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]

def bits_to_f32(v):
    return struct.unpack("<f", struct.pack("<I", v))[0]

# UART CONFIGURATION
port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

signal = [float(i) for i in range(1,1025)]
kernel = [1.0,1.0,1.0]

SIGN = 0x5349474E
DATAERROR = 0x44455252
KERN = 0x4B45524E
WEIGHTERROR = 0x57455252
DONE = 0x444F4E45

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

    out = []
    for i in signal:
        v = recv_u32(ser)
        print(f"Added 0x{v:08X} to array")
        if v == DONE:
            break
        out.append(v)

    for i in out:
        print(f"{i:08X} -> {bits_to_f32(i)}")
