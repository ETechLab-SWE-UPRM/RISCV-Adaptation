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

# UART CONFIGURATION
port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

signal = [float(i) for i in range(1,11)]
kernel = [1.0,1.0,1.0]

SIGN = 0x5349474E
DATAERROR = 0x44455252
KERN = 0x4B45524E
WEIGHTERROR = 0x57455252
DONE = 0x444F4E45


with serial.Serial(port, baud, timeout=10) as ser:
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    
    for v in signal:
        send_u32(ser, f32_bits(v))
        data = recv_u32(ser)
        print(f"\033[32mReceived data: 0x{data:08X}\033[0m")
        data = recv_u32(ser)
        print(f"\033[33mReceived data_length: 0x{data:08X}\033[0m")

    send_u32(ser, f32_bits(-1.0))

    sign = recv_u32(ser)

    if sign == SIGN:
        print(f"Received 'SIGN'")
    elif sign == DATAERROR:
        raise ValueError("\033[31mData inputs exceed allocated space. Increase size of data array or RAM in Vivado.\033[0m]")

    out = []
    for i in range(1,11):
        v = recv_u32(ser)
        print(f"Added 0x{v:08X} to array")
        if v == DONE:
            break
        out.append(v)

    print(out[:20])
