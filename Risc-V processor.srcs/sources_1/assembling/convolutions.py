import time

def main():
    start = time.perf_counter() #starts counting at the time of execution
    signal = [0] * 1024
    for i in range(1024):
        signal[i] = i + 1

    kernel = [1, 1, 1]
    result = [0] * (len(signal) - len(kernel) + 1)
    for i in range(len(result)):
        sum = 0 
        for j in range(len(kernel)):
            sum+=signal[i + j] * kernel[j]
        result[i] = (sum)
    
    #finishes time of execution before the print statement is called
    end = time.perf_counter() - start
    print(end)
    print(result)

if __name__ == "__main__":
    main()