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


module MUX_4_1 (
    input wire [7:0] In0,       
    input wire [7:0] In1,       
    input wire [7:0] In2,       
    input wire [7:0] In3,       
    input wire [1:0] Sel,       
    output reg [7:0] Out        
);

    always @(*) begin
        case (Sel)
            2'b00: Out = In0;
            2'b01: Out = In1;
            2'b10: Out = In2;
            2'b11: Out = In3;
            default: Out = 8'd0;
        endcase
    end

endmodule
