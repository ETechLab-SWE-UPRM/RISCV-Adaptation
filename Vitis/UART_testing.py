import serial, struct

def send_u32(ser, v):
    ser.write(struct.pack("<I", v))

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack("<I", b)[0]

port = "/dev/ttyUSB1"
baudrate = 115200

with serial.Serial(port, baudrate, timeout=5) as ser:
    # Send signal to start
    send_u32(ser, 0x12345678)

    # Receive result
    result = recv_u32(ser)
    print(f"Received: 0x{result:08x}")
