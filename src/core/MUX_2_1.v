`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2025 04:38:21 PM
// Design Name: 
// Module Name: MUX_4_1
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


module mux_2_1 (
    input wire [7:0] In0,        
    input wire [7:0] In1,        
    input wire Sel,            
    output reg [7:0] Out 
);

    always @(*) begin
        case (Sel)
            1'b0: Out = In0;
            1'b1: Out = In1;
            default: Out = 8'd0;
        endcase
    end

endmodule