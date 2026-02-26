import serial, struct

def send_i32(ser, v):
    ser.write(struct.pack("<i", v))

def send_f32(ser, v):
    ser.write(struct.pack("<f", v))

def recv_i32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack("<i", b)[0]

def recv_f32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack("<f", b)[0]

def float_to_hex(f):
    return struct.unpack("<I", struct.pack("<f", f))[0]

port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

with serial.Serial(port, baud, timeout=5) as ser:
    message = 1.0
    send_f32(ser, message)
    
    data = recv_f32(ser)

    print(f"Sent float: {message}")
    print(f"Sent hex: 0x{float_to_hex(message):08X}")
    print(f"Received float: {data}")
    print(f"Received hex: 0x{float_to_hex(data):08X}")