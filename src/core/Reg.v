`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 03:54:27 PM
// Design Name: 
// Module Name: Reg
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

module Reg (
    input wire CLK,              
    input wire RST,              
    input wire En,               
    input wire [7:0] Data_in,    
    output reg [7:0] Data_out    
);

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Data_out <= 8'd0;
        end else begin
            if (En) begin
                Data_out <= Data_in;
            end else begin
                Data_out <= Data_out;
            end
        end
    end

endmodule
