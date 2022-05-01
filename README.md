# Adler-32-Offload-engine
This is an Adler32 checksum offload engine for veryfing transmission of data using the Adler32 checksum 
You can find out more about this below
https://en.wikipedia.org/wiki/Adler-32

This is my implementation in verilog for a class project.

Signals:

module adler32(

    input clock,
    
    input rst_n,
    
    input size_valid,
    
    input [31:0] size,
    
    input data_start,
    
    input [7:0] data,
    
    output checksum_valid,
    
    output [31:0] checksum
);


Above is the highest level module. The module takes input from another system for the size of the data, and a size_valid signal to let my system know when it's sending the size. It also sends data, char values one per clock after data_start is high. The output checksum_valid goes high once the checksum output is the correct value for input of another system.
