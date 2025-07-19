#  Verilog Error Correction & Communication Pipeline

This project implements a complete digital communication system in **Verilog**, featuring:

- **LFSR-based data generation**
- **(2,1,3) Convolutional encoding**
- **Parallel-to-serial conversion**
- **Matrix-based interleaving**
- **16-QAM modulation**
- **MATLAB-based channel simulation with AWGN and burst error injection**
- **Deinterleaving and Viterbi decoding**
- **Python and testbench validation with EBR tracking**

---

##  Project Overview

The pipeline simulates a real-world forward error correction (FEC) system, transmitting pseudo-random data over a noisy channel. Modulation and noise injection are handled in MATLAB, while all hardware logic is written in Verilog.

The system is verified using a testbench that:
- Feeds encoded bits into the channel,
- Demodulates the received symbols (with optional noise/burst errors),
- Routes them through the receiver logic (deinterleaver + Viterbi),
- Logs the decoded bits for error analysis.

---

##  Features

- ✅ LFSR (7-bit) for pseudo-random input
- ✅ (2,1,3) Convolutional encoder with generator polynomials (7, 5)
- ✅ Bit-serial output via custom serializer
- ✅ Matrix-based interleaving (8×16)
- ✅ 16-QAM modulation/demodulation in MATLAB
- ✅ Burst error simulation and SNR variation
- ✅ Deinterleaver and hardware Viterbi decoder
- ✅ Output bit logging + EBR analysis in Python

---

## Performance Summary

| SNR (dB) | EBR (No Burst) | EBR (With Burst) |
|----------|----------------|------------------|
| 5        | 24.6%          | 24.3%            |
| 10       | 0.8%           | 3.3%             |
| 15       | 0.0%           | 1.2%             |
| 20       | 0.0%           | 2.3%             |

>  *The pipeline reliably decodes data at 10 dB and above. Even under burst noise, it remains resilient—demonstrating the strength of convolutional coding and interleaving.*

---

## 🛠 Tools & Environment

- **HDL**: Verilog
- **Simulation**: Vivado / ModelSim
- **Scripting**: Python, MATLAB
- **Output**: Plaintext bit logs (`.txt`)

---

## Structure

/src
├── dflipflop.v
├── shiftr.v
├── LFSR.v
├── convenc.v
├── serializer.v
├── interleaver.v
├── deinterleaver.v
├── vitebri.v
└── TopMod.v
└── QAMMOD.v
└── serial_to_pair.v
└── TopMod2.v

/test
├── convecut.v
└── deinterleaverut.v
└──interleaverut.v
└──LFSRtu.v
└──qamsysut.v
└──regt.v 
└──topmod2_tb.v
└──vir.v

/scripts
├── ebrcalculation.m
└──demod.m
└──burst.m
