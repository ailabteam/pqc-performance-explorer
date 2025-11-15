# PQC Performance Explorer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An open-source project dedicated to benchmarking, analyzing, and exploring the performance of Post-Quantum Cryptography (PQC) algorithms.

## Motivation

The advent of large-scale quantum computers poses a significant threat to modern public-key cryptography, which underpins the security of the internet. The field of Post-Quantum Cryptography (PQC) aims to develop new cryptographic algorithms that are secure against both classical and quantum computers.

As the world prepares to transition to these new standards, understanding their real-world performance characteristics (speed, memory usage, key sizes) is crucial for developers, engineers, and researchers. This project provides a transparent, reproducible framework for conducting these performance measurements.

## Project Goals

*   To establish a consistent and automated pipeline for benchmarking PQC algorithms.
*   To measure and compare the performance of leading PQC candidates on various hardware platforms.
*   To analyze the trade-offs between security, speed, and other performance metrics.
*   To share our findings with the community through open-source code and detailed reports.

---

## Phase 1: CPU Performance Benchmark (Completed)

We have successfully completed the first phase of this project, focusing on the core computational speed of the PQC algorithms selected for standardization by NIST.

**Achievements:**
*   Established a self-contained, reproducible build environment using Conda.
*   Built a stable version of the **Open Quantum Safe (OQS) `liboqs` library (v0.10.0)**.
*   Developed an automated benchmarking pipeline that:
    1.  Runs speed tests for selected KEMs and digital signature schemes.
    2.  Parses the raw text output into structured CSV data.
    3.  Generates high-quality charts for analysis and visualization.

### Results

The following charts represent the average time taken for cryptographic operations, measured on an x86-64 server without AVX2 extensions. All benchmarks were run for a duration of 1 second per algorithm.

#### Key Encapsulation Mechanisms (KEMs) Performance

![KEM Performance Comparison](figures/kem_performance_comparison.png)

#### Digital Signature Schemes Performance

![Signature Performance Comparison](figures/sig_performance_comparison.png)

### Preliminary Analysis

*   **Lattice-Based Efficiency:** Lattice-based schemes like **Kyber (KEM)** and **Dilithium (Signature)** demonstrate excellent all-around performance, showcasing why they were chosen as primary NIST standards. They offer a strong balance of speed across key generation, encapsulation/signing, and decapsulation/verification.
*   **Code-Based Trade-offs:** **Classic-McEliece** exhibits extremely fast encapsulation but has a significantly slower key generation process, which is a well-known characteristic.
*   **Falcon's Speed:** The **Falcon** signature scheme shows remarkable speed, particularly in the verification step, making it a compelling choice for scenarios where verification is frequent.

---

## Getting Started: How to Reproduce Our Results

You can easily reproduce these results on your own machine by following these steps.

### Prerequisites

*   A Linux-based operating system.
*   Git
*   Conda package manager.

### Setup & Execution

1.  **Clone the Repository**

    Clone this project along with its `liboqs` submodule.
    ```bash
    git clone --recurse-submodules https://github.com/ailabteam/pqc-performance-explorer.git
    cd pqc-performance-explorer
    ```

2.  **Set Up the Environment**

    This script creates a self-contained Conda environment named `pqc-research` with all necessary dependencies, including a compatible version of OpenSSL.
    ```bash
    bash setup/setup_env.sh
    conda activate pqc-research
    ```

3.  **Build the `liboqs` Library**

    This script compiles the stable `v0.10.0` of `liboqs` within our isolated Conda environment.
    ```bash
    bash setup/build_liboqs.sh
    ```

4.  **Run the Full Pipeline**

    To make things easy, you can run the entire pipeline with a single script. It will clean old results, run new benchmarks, parse the data, and generate the final charts in the `figures/` directory.

    ```bash
    bash run_full_pipeline.sh
    ```
    *(Note: You can create a file named `run_full_pipeline.sh` with the combined commands from our debugging session for convenience).*

---

## Project Structure

```
.
├── analysis/         # Python scripts for parsing and visualization
├── figures/          # Output charts and plots
├── results/          # Raw (.txt) and processed (.csv) benchmark data
├── scripts/          # Shell scripts for running benchmarks
├── setup/            # Environment and library build scripts
└── third_party/      # Git submodule for liboqs
```

## Roadmap: Future Work

This project is just getting started. Our roadmap includes several exciting extensions:

-   [ ] **Phase 2: Expand Performance Metrics**
    -   [ ] Measure and analyze key sizes, ciphertext sizes, and signature sizes.
    -   [ ] Integrate memory profiling to measure RAM consumption during cryptographic operations.

-   [ ] **Phase 3: Cross-Platform Benchmarking**
    -   [ ] Run the same benchmark suite on a resource-constrained device (e.g., Raspberry Pi 4) to analyze performance in an IoT context.
    -   [ ] Benchmark on an ARM64-based server (e.g., AWS Graviton) to compare x86-64 vs. ARM performance.

-   [ ] **Phase 4: Real-World Scenario Analysis**
    -   [ ] Utilize the OQS integration with OpenSSL to benchmark the overhead of PQC in a full TLS 1.3 handshake.
    -   [ ] Compare the performance of hybrid modes (e.g., Kyber + X25519) vs. PQC-only modes.

-   [ ] **Phase 5: Publication & Reporting**
    -   [ ] Summarize all findings into a detailed technical report or blog post.
    -   [ ] Create interactive visualizations for easier data exploration.

## Contributing

Contributions are welcome! If you have ideas for new benchmarks, find a bug, or want to improve the analysis scripts, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

This work would not be possible without the incredible efforts of the [Open Quantum Safe (OQS) project](https://openquantumsafe.org/), which provides the open-source library for post-quantum cryptography used in our experiments.
