`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2025 12:37:15 AM
// Design Name: 
// Module Name: Reg_2bit
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


module Reg_2bit(
    input wire CLK,              
    input wire RST,              
    input wire En,               
    input wire [1:0] Data_in,    
    output reg [1:0] Data_out    
);

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Data_out <= 2'd0;
        end else begin
            if (En) begin
                Data_out <= Data_in;
            end else begin
                Data_out <= Data_out;
            end
        end
    end
endmodule
