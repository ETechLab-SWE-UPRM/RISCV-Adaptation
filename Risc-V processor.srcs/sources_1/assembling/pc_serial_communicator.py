import serial, struct

def send_i32(ser, v):
    data = struct.pack(">i", v)
    ser.write(data)
    print(f"Sent {v} as {data}")


def recv_i32(ser):
    b = ser.read(4)
    if len(b) != 4:
        print(b)
        raise TimeoutError("timeout")
    return struct.unpack(">i", b)[0]

port = "COM4" # Change this to your serial port
baud = 115200

signal = [i for i in range(1,11)]
kernel = [1,1,1]

with serial.Serial(port, baud, timeout=5) as ser:
    for v in signal:
        send_i32(ser, v)
    send_i32(ser, -1)

    sign = recv_i32(ser)
    if sign != 0x5349474E:  # SIGN
        raise ValueError("Invalid signature: 0x{:08X}".format(sign))

    for v in kernel:
        send_i32(ser, v)
    send_i32(ser, -1)

    sign = recv_i32(ser)
    if sign != 0x4B45524E:  # KERN
        raise ValueError("Invalid signature: 0x{:08X}".format(sign))

    DONE = 0x444F4E45

    out = []
    while True:
        v = recv_i32(ser)
        if v == DONE:
            break
        out.append(v)

    print(out[:20])
