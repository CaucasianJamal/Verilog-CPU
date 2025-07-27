# Verilog-CPU
Rudimentary Central Processing Unit made from logic gates in iVerilog

## Requirements

- Must have [Icarus Verilog](https://bleyer.org/icarus/)
- All files must reside in the same directory

## Getting Started
To test this CPU, run the following commands in a command terminal at the directory where these files were saved  
( ``` cd <Replace this with your directory path> ``` )
```
> iverilog CPUTester.v cpu.v
> vvp a.out
```

The program in ram.dat will be executed by cpu.v through CPUTester.v
