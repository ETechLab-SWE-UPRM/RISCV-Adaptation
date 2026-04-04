import serial, struct

def send_u32(ser, v):
    ser.write(struct.pack(">I", v))

def recv_u32(ser):
    b = ser.read(4)
    if len(b) != 4:
        raise TimeoutError("timeout")
    return struct.unpack(">I", b)[0]

def f32_bits(x):
    return struct.unpack("<I", struct.pack("<f", x))[0]

def bits_to_f32(v):
    return struct.unpack("<f", struct.pack("<I", v))[0]

port = "/dev/ttyUSB1" # Change this to your serial port
baud = 115200

SIGN = 0x5349474E
KERN      = 0x4B45524E
DATAERROR = 0x44455252
WEIGHTSERROR = 0x57455252
signal = [float(i) for i in range(1,1025)]
kernel = [1.0, 1.0, 1.0]

with serial.Serial(port, baud, timeout=5) as ser:
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    for v in signal:
        send_u32(ser, f32_bits(v))
    send_u32(ser, f32_bits(-1.0))

    sign = recv_u32(ser)
    if sign == SIGN:
        print("Received 'SIGN'")
    else:
        raise ValueError("Received Data Garbage")

    for k in kernel:
        send_u32(ser, f32_bits(k))
    send_u32(ser, f32_bits(-1.0))

    sign = recv_u32(ser)
    if sign == KERN:
        print("Received 'KERN'")
    else:
        raise ValueError("Received Kernel Garbage")
    
    print(len(signal), len(kernel))
    output = []
    i = 0
    while i < len(signal):
        sign = recv_u32(ser)
        output.append(bits_to_f32(sign))
        i += 1

    j = 0
    while j < len(kernel):
        sign = recv_u32(ser)
        output.append(bits_to_f32(sign))
        j += 1 

    with open("UART_test.txt", "w") as file:
        for i in output:
            file.write(f"{i}\n")