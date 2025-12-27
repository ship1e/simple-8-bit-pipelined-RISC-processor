`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2025 01:49:33 AM
// Design Name: 
// Module Name: MUX_2_1_2bit
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


module MUX_2_1_2bit(
    input wire [1:0] In0,        
    input wire [1:0] In1,        
    input wire Sel,            
    output reg [1:0] Out 
);

    always @(*) begin
        case (Sel)
            1'b0: Out = In0;
            1'b1: Out = In1;
            default: Out = 8'd0;
        endcase
    end
endmodule

