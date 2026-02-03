// cpu_ode.cpp
#include <iostream>
#include <fstream>
#include <vector>

double f(double x) {
    // dx/dt = -x
    return -x;
}

int main() {
    double t0 = 0.0;
    double x0 = 1.0;      // x(0) = 1
    double dt = 0.01;
    double T  = 5.0;

    int N = static_cast<int>((T - t0) / dt);

    std::vector<double> t(N + 1);
    std::vector<double> x(N + 1);

    t[0] = t0;
    x[0] = x0;

    // Euler integration on CPU
    for (int n = 0; n < N; ++n) {
        t[n + 1] = t[n] + dt;
        x[n + 1] = x[n] + dt * f(x[n]);
    }

    // Save to CSV
    std::ofstream out("solution_cpu.csv");
    if (!out) {
        std::cerr << "Error: cannot open output file\n";
        return 1;
    }

    out << "t,x\n";
    for (int n = 0; n <= N; ++n) {
        out << t[n] << "," << x[n] << "\n";
    }
    out.close();

    std::cout << "CPU solution saved to solution_cpu.csv\n";
    return 0;
}
