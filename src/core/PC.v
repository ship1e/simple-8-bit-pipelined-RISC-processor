`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 03:33:38 PM
// Design Name: 
// Module Name: PC
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


module PC (
    input wire CLK,          
    input wire En,           
    input wire [7:0] Data_in,
    output reg [7:0] Data_out
);

    always @(posedge CLK) begin
        if (En) begin
            Data_out <= Data_in;
        end else begin
            Data_out <= Data_out;
        end
    end

endmodule