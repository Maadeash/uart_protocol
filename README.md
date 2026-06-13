# UART Protocol RTL-to-GDSII Implementation with SystemVerilog Verification

A complete UART design and implementation project covering RTL development,functional verification,synthesis and physical design up to GDSII.

## Overview

This project implements a FIFO-based UART architecture with:

- Baud rate generator
- UART transmitter
- UART receiver
- TX FIFO
- RX FIFO

The design was verified using a SystemVerilog testbench with constrained-random stimulus,scoreboarding,coverage and assertions.  
RTL-to-GDSII implementation was done using Cadence Genus and Cadence Innovus.

## Features

- Parameterized UART RTL
- FIFO-based buffering
- Start bit and stop bit handling
- Self-checking verification environment
- Functional coverage closure
- Assertion-based checks
- Synthesis and physical implementation flow
- Timing closure achieved

## RTL Modules

### `baudgen`
Generates baud tick pulses for UART operation.

### `fifo`
Synchronous FIFO used for transmit and receive buffering.

### `uart_tx`
UART transmitter FSM for serial data transfer.

### `uart_rx`
UART receiver FSM for serial data capture.

### `top`
Top-level module integrating baud generator,UART TX,RX and FIFOs.

## Verification Environment

The design was verified using SystemVerilog with:

- Generator
- Driver
- Monitor
- Scoreboard
- Functional coverage
- Assertions

### Coverage Points

- Data range bins
- Corner cases such as `0x00`,`0xFF`,`0xAA`,`0x55`

### Verification Result

- Scoreboard: PASS
- Functional coverage: 100%

## Physical Design Flow

The project was implemented using:

- **Cadence Genus** for synthesis
- **Cadence Innovus** for floorplanning,placement,CTS,routing and final GDS generation

### Timing Result

- Setup slack met
- Timing closure achieved

## Proof / Results

### Functional Verification 

<img width="1600" height="841" alt="image" src="https://github.com/user-attachments/assets/d8676977-52c3-4177-b654-972b68a7a20c" />


### Simulation Output

<img width="1600" height="852" alt="image" src="https://github.com/user-attachments/assets/6a62f0e4-1061-4bbc-bcde-f105ccbfd328" />


### Synthesis Result

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/4c8ec35c-0349-4a9a-9a30-3c5e4aca5be1" />


### Layout / Floorplan

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/a28c7b8c-d522-4269-9827-f1a225cd8595" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/33fe5997-a288-467e-9762-4f6b6084bc66" />



### Timing Report

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/b8e6c1a8-de8e-4acd-aa6b-6b811a07bda7" />


## Tools Used

- Synopsys VCS
- Cadence Genus
- Cadence Innovus
- DVE

## Languages Used

- Verilog(RTL Design)
- System Verilog(Verification)

