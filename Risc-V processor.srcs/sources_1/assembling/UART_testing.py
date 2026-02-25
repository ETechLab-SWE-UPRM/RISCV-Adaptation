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

port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

with serial.Serial(port, baud, timeout=5) as ser:
    message =  0x12345678
    send_i32(ser, message)
    data = recv_i32(ser)
    print(f"Test message sent {hex(message)} and response received {hex(data)}.")