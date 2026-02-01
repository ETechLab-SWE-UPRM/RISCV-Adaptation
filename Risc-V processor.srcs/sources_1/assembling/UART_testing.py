import serial, struct

def send_i32(ser, v):
    ser.write(struct.pack("<i", v))

def recv_i32(ser):
    b = ser.read(4)
    c = ser.read_all()
    if len(b) != 4:
        print(c)
        raise TimeoutError("timeout")
    return struct.unpack("<i", b)[0]

port = "COM4"
baud = 115200

with serial.Serial(port, baud, timeout=5) as ser:
    send_i32(ser, 0x12345678)
    recv_i32(ser)
    print("Test message sent and response received.")