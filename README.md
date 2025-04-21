# FIFO Buffer Module

## Overview
This repository contains a Verilog implementation of a First-In-First-Out (FIFO) buffer module. The FIFO is designed with a capacity of 64 bytes (8-bit width) and includes standard control signals for writing and reading operations, along with status flags to indicate buffer state.

## Features
- 64-byte deep, 8-bit wide FIFO buffer
- Synchronous read and write operations
- Empty and full status flags
- Circular buffer implementation with read and write pointers
- FIFO counter to track the number of elements in the buffer
- Supports simultaneous read and write operations

## Module Description

The `fifo` module implements a standard FIFO buffer with the following ports:

### Inputs
- `clk`: System clock signal
- `rst`: Active-high reset signal
- `buf_in[7:0]`: 8-bit data input
- `wr_en`: Write enable signal (active high)
- `rd_en`: Read enable signal (active high)

### Outputs
- `buf_out[7:0]`: 8-bit data output
- `buf_empty`: Flag indicating whether the FIFO is empty (1 = empty)
- `buf_full`: Flag indicating whether the FIFO is full (1 = full)
- `fifo_counter[7:0]`: Counter showing the number of elements in the FIFO
- `wr_pt[3:0]`: Write pointer location (current write position)
- `rd_pt[3:0]`: Read pointer location (current read position)

## Internal Structure
The FIFO buffer uses a circular buffer architecture with the following components:
- An 8-bit wide, 64-entry memory array (`buf_mem[63:0]`)
- Read and write pointers that wrap around after reaching the end of the buffer
- Full and empty flags derived from the FIFO counter and operation states
- FIFO counter that tracks the number of valid data elements in the buffer

## Operational Logic

### Empty and Full Flag Logic
- Empty flag is set when the counter is 0, or when the counter is 1 and a read operation (without a write) is in progress
- Full flag is set when the counter is 63, or when the counter is 62 and a write operation (without a read) is in progress

### FIFO Counter Logic
- Increments on write operations (if not full)
- Decrements on read operations (if not empty)
- Stays unchanged when both reading and writing simultaneously or when no operation is performed

### Data Output Logic
- Outputs the data at the read pointer position when reading from a non-empty FIFO
- Maintains the last output value otherwise

### Memory Write Logic
- Writes input data to the write pointer position when writing to a non-full FIFO
- No change to memory otherwise

### Pointer Management
- Both pointers wrap around to 0 after reaching 63 (end of buffer)
- Write pointer increments on write operations (if not full)
- Read pointer increments on read operations (if not empty)

## Timing Diagrams

### Write Operation
```
      ___     ___     ___     ___     ___
clk _|   |___|   |___|   |___|   |___|   |___
       _______
wr_en _|       |___________________________
       _______
buf_in X_Data__X___________________________

wr_pt  N   ->   N+1
```

### Read Operation
```
      ___     ___     ___     ___     ___
clk _|   |___|   |___|   |___|   |___|   |___
       _______
rd_en _|       |___________________________
              _______
buf_out XXXXX_|_Data_|_XXXXXXXXXXXXXXXXXXX

rd_pt  M   ->   M+1
```

## Applications
This FIFO buffer is suitable for:
- Data rate matching between different clock domains
- Input/output buffering in communication systems
- Command queuing in processors
- Temporary storage in pipelined designs

## Contributing
Contributions to improve the FIFO module are welcome. Please feel free to submit a pull request.
