`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 03:24:13 PM
// Design Name: 
// Module Name: CCR
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


module CCR (
    input wire CLK,              
    input wire RST,              
    input wire Enable,           
    input wire Shift_Left,       
    input wire Shift_Right, 
    input wire [3:0] Data_in,    
    output reg [3:0] Data_out    
);
    reg [7:0] CCR_internal; 
    always @(*) begin
        Data_out = CCR_internal[3:0];
    end    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            CCR_internal <= 8'd0;
        end else begin
            if (Shift_Left) begin
                CCR_internal <= {CCR_internal[3:0], 4'b0000};
            end else if (Shift_Right) begin
                CCR_internal <= {4'b0000, CCR_internal[7:4]};
            end else if (Enable) begin
                CCR_internal <= {CCR_internal[7:4], Data_in};
            end else begin
                CCR_internal <= CCR_internal;
            end
        end
    end
endmodule
