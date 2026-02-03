// gpu_ode.cu
#include <iostream>
#include <fstream>
#include <cuda_runtime.h>

// CUDA kernel: single thread does Euler integration
__global__
void solveEuler(double* t, double* x,
                double t0, double x0,
                double dt, int N)
{s
    // Only one thread is used
    t[0] = t0;
    x[0] = x0;

    for (int n = 0; n < N; ++n) {
        t[n + 1] = t[n] + dt;
        // dx/dt = -x
        x[n + 1] = x[n] + dt * (-x[n]);
    }
}

int main() {
    double t0 = 0.0;
    double x0 = 1.0;      // x(0) = 1
    double dt = 0.01;
    double T  = 5.0;

    int N = static_cast<int>((T - t0) / dt);

    size_t size = (N + 1) * sizeof(double);

    // Host arrays
    double* h_t = new double[N + 1];
    double* h_x = new double[N + 1];

    // Device arrays
    double* d_t = nullptr;
    double* d_x = nullptr;

    cudaError_t err;
    err = cudaMalloc((void**)&d_t, size);
    if (err != cudaSuccess) {
        std::cerr << "cudaMalloc d_t failed: "
                  << cudaGetErrorString(err) << "\n";
        return 1;
    }

    err = cudaMalloc((void**)&d_x, size);
    if (err != cudaSuccess) {
        std::cerr << "cudaMalloc d_x failed: "
                  << cudaGetErrorString(err) << "\n";
        cudaFree(d_t);
        return 1;
    }

    // Launch kernel with 1 block, 1 thread
    solveEuler<<<1, 1>>>(d_t, d_x, t0, x0, dt, N);

    err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "Kernel launch failed: "
                  << cudaGetErrorString(err) << "\n";
        cudaFree(d_t);
        cudaFree(d_x);
        return 1;
    }

    // Copy results back to host
    err = cudaMemcpy(h_t, d_t, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        std::cerr << "cudaMemcpy t failed: "
                  << cudaGetErrorString(err) << "\n";
        cudaFree(d_t);
        cudaFree(d_x);
        return 1;
    }

    err = cudaMemcpy(h_x, d_x, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        std::cerr << "cudaMemcpy x failed: "
                  << cudaGetErrorString(err) << "\n";
        cudaFree(d_t);
        cudaFree(d_x);
        return 1;
    }

    // Free device memory
    cudaFree(d_t);
    cudaFree(d_x);

    // Save to CSV
    std::ofstream out("solution_gpu.csv");
    if (!out) {
        std::cerr << "Error: cannot open output file\n";
        delete[] h_t;
        delete[] h_x;
        return 1;
    }

    out << "t,x\n";
    for (int n = 0; n <= N; ++n) {
        out << h_t[n] << "," << h_x[n] << "\n";
    }
    out.close();

    std::cout << "GPU solution saved to solution_gpu.csv\n";

    delete[] h_t;
    delete[] h_x;
    return 0;
}
