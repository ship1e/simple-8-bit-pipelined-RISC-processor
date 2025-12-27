`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 03:05:28 PM
// Design Name: 
// Module Name: Memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Memory (
    input wire CLK,              
    input wire [7:0] Address,    
    input wire [7:0] Data_in,    
    input wire W_En,     
    input wire R_En,      
    output reg [7:0] Data_out   
);

    // Memory array: 256 bytes
    reg [7:0] Memory [0:255];
    
    // Asynchronous Read Operation
    always @(*) begin
        if (R_En) begin
            Data_out = Memory[Address];
        end else begin
            Data_out = 8'b0;  // Output zero when not reading
        end
    end
    
    // Synchronous Write Operation
    always @(posedge CLK) begin
        if (W_En) begin
            Memory[Address] <= Data_in;
        end
    end

endmodule