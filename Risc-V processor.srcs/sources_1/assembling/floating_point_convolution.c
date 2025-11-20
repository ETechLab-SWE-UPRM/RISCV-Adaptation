#include <stdio.h>
#include <time.h>

int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    float signal[1024];
    for(int i = 0; i < 1024; i++){
        signal[i] = (float)(i + 1);
    }

    float kernel[3] = {1.0, 1.0, 1.0};
    int result_length = 1024 - 3 + 1;
    float result[result_length];

    for(int i = 0; i < result_length; i++){
        float sum = 0.0f;
        for(int j = 0; j < 3; j++){
            sum += signal[i + j] * kernel[j];
        }
        result[i] = sum;
    }

    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed =
        (end.tv_sec - start.tv_sec) * 1e6 +
        (end.tv_nsec - start.tv_nsec) / 1e3;

    printf("Execution time: %.3f microseconds\n", elapsed);

    return 0;
}
