# UART Protocol Design and Verification using Verilog and SystemVerilog

## Introduction

UART (Universal Asynchronous Receiver Transmitter) is an asynchronous serial communication protocol used for transmitting and receiving data between digital systems.

Unlike synchronous protocols, UART does not require a separate clock signal for communication. Both transmitter and receiver communicate using a predefined baud rate.

UART is widely used in:

- FPGA communication
- Embedded systems
- Microcontrollers
- GPS modules
- Bluetooth modules
- Serial debugging

UART mainly uses two communication lines:

- TX (Transmit)
- RX (Receive)

Due to its simple architecture and easy implementation,UART is widely used in FPGA and SoC designs.

---

# UART Frame Format

The UART frame used in this project contains:

| Start Bit | 8 Data Bits | Stop Bit |
|------------|--------------|------------|


# UART Architecture

The UART design consists of the following modules:

- Baud Rate Generator
- UART Transmitter
- UART Receiver
- TX FIFO
- RX FIFO
- Top Module

System specifications:

- Clock Frequency = 100 MHz
- Baud Rate = 9600
- Oversampling = 16x

---

# Baud Rate Generator

The baud rate generator produces sampling ticks required for UART communication.

Formula used:

m = Clock Frequency / (Baud Rate × Oversampling)

For this project:

m = 100000000 / (9600 × 16)

m = 651

The baud generator resets automatically after reaching the maximum count.

---

# FIFO Design

Synchronous FIFOs are used for buffering transmitted and received data.

## TX FIFO
- Stores data before transmission
- Prevents transmitter underflow

## RX FIFO
- Stores received data
- Prevents receiver overflow

FIFO features include:

- Full detection
- Empty detection
- Read and write pointer control


---

# Important UART Signals

| Signal | Description |
|--------|-------------|
| clk | System clock |
| rst | Reset signal |
| tx | UART transmit line |
| rx | UART receive line |
| w_data | Data written into TX FIFO |
| r_data | Data received from RX FIFO |
| wr | Write enable for TX FIFO |
| rd | Read enable for RX FIFO |
| tx_full | TX FIFO full indication |
| rx_empty | RX FIFO empty indication |

---

# Tools Used

- Vivado
- Synopsys VCS

---

# Languages Used

## Design
- Verilog HDL

## Verification
- SystemVerilog

---

# Verification Environment

The UART protocol was verified using a SystemVerilog verification environment.

Verification components include:

- Interface with clocking blocks
- Transaction class
- Constraint-based randomization
- Generator
- Driver
- Monitor
- Scoreboard
- Functional Coverage
- Assertions (SVA)
- Mailbox communication
- Self-checking testbench
- Loopback verification
- Coverage closure event

---

# Interface

The interface connects DUT and verification components using clocking blocks and modports.

Features:
- Driver clocking block
- Monitor clocking block
- Shared DUT access

---

# Generator

The generator creates randomized UART transactions and sends them to the driver using mailbox communication.

---

# Driver

The driver performs:

- TX FIFO write operations
- RX FIFO read operations
- DUT stimulus generation

The driver waits for:
- TX FIFO availability
- RX FIFO data reception

---

# Monitor

The monitor passively observes DUT outputs and captures received UART data.

---

# Scoreboard

The scoreboard compares:

- Expected transmitted data
- Actual received data

---

# Functional Coverage

Functional coverage is implemented using covergroups.

Coverage bins include:

- LOW range data
- MID range data
- HIGH range data

This ensures proper data-space verification.

---

# Assertions

Assertions are implemented to verify protocol correctness.

Assertions check:

- TX idle HIGH after reset
- RX FIFO empty after reset
- TX FIFO not full after reset

---

# Loopback Verification

The UART design uses loopback verification.

TX → RX

The transmitter output is connected directly to the receiver input for self-verification.

---

# Synthesized and Implemented Design(Using Vivado):

<img width="1574" height="733" alt="image" src="https://github.com/user-attachments/assets/0ecaeffa-d8ab-4624-ae3f-854e4f759c01" />


---

# Model Waveform:

<img width="1379" height="379" alt="image" src="https://github.com/user-attachments/assets/b12de688-9e43-4252-81fc-92cf3a431d8f" />

---

# Output Waveform(Simulated using Synopsys VCS):

<img width="1600" height="852" alt="image" src="https://github.com/user-attachments/assets/bf09623a-8d21-4955-a9c5-96b145442167" />

---
# Functional Coverage:

<img width="1600" height="841" alt="image" src="https://github.com/user-attachments/assets/01b8b5f8-7fd6-496f-819c-1acd82bc0e8c" />



# Source Files

## Design Files

- baudgen.v
- fifo.v
- uart_tx.v
- uart_rx.v
- top.v

## Verification Files

- uart_if.sv
- uart_transaction.sv
- uart_generator.sv
- uart_driver.sv
- uart_monitor.sv
- uart_scoreboard.sv
- uart_coverage.sv
- uart_assertions.sv
- tb_uart_vip.sv

---

# Applications of UART

- FPGA communication
- Embedded systems
- Serial communication
- Debugging applications
- Peripheral communication

---

# Conclusion

UART protocol was successfully designed using Verilog HDL and verified using a SystemVerilog verification environment. The design includes UART transmitter, UART receiver, baud rate generator, and FIFO modules. Functional verification was performed using generator, driver, monitor, scoreboard, assertions, and coverage components. Simulation results verified successful UART data transmission and reception using loopback verification.
