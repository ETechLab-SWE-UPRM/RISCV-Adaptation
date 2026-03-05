import serial, struct

def send_u32(ser, v):
    w = ser.write(struct.pack(">I", v))
    print(f"Sent 0x{v:08X}")

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        print(f"{b} received only") 
        raise TimeoutError("timeout")
    return struct.unpack(">I", b)[0]

def int_to_hex(i):
    return struct.unpack("<I", struct.pack("<i", i))[0]

def float_to_hex(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]

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
        send_u32(ser, float_to_hex(v))
    send_u32(ser, float_to_hex(-1.0))

    sign = recv_u32(ser)

    if sign == KERN:
        print(f"Received 'SIGN'")
    elif sign == DATAERROR:
        finished = recv_u32(ser) # waiting for DONE
        raise ValueError("Error occurred in input data acquisition")

    for v in kernel:
        send_u32(ser, float_to_hex(v))
    send_u32(ser, float_to_hex(-1.0))

    sign = recv_u32(ser)

    if sign == SIGN:
        print(f"Received 'KERN'")
    elif sign == WEIGHTERROR:
        finished = recv_u32(ser) # waiting for DONE
        raise ValueError("Error occurred in weights data acquisition")

    out = []
    for i in range(1,11):
        v = recv_u32(ser)
        if v == DONE:
            break
        out.append(v)

    print(out[:20])
