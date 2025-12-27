`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 03:15:42 PM
// Design Name: 
// Module Name: Reg_file
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


module Reg_file (
    input wire CLK,              
    input wire RST,              
    input wire W_En,             
    input wire [1:0] W_Adr,      
    input wire [7:0] Data_in,    
    input wire [1:0] R1_Adr,     
    input wire [1:0] R2_Adr,     
    output reg [7:0] R1,         
    output reg [7:0] R2          
);

    // Register array: 4 registers of 8 bits each
    reg [7:0] registers [0:3];
    
    // Synchronous Write and Reset
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            registers[0] <= 8'd0;    // R0 = 0
            registers[1] <= 8'd0;    // R1 = 0
            registers[2] <= 8'd0;    // R2 = 0
            registers[3] <= 8'd255;  // R3 (SP) = 255
        end else begin
            if (W_En) begin
                registers[W_Adr] <= Data_in;
            end else begin
                registers[0] <= registers[0];
                registers[1] <= registers[1];
                registers[2] <= registers[2];
                registers[3] <= registers[3];
            end
        end
    end
    
    // Asynchronous Read 
    always @(*) begin
        R1 = registers[R1_Adr];
    end
    
    always @(*) begin
        R2 = registers[R2_Adr];
    end

endmodule
