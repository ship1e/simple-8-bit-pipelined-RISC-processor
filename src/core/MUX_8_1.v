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


module MUX_8_1 (
    input wire [7:0] In0,      
    input wire [7:0] In1,       
    input wire [7:0] In2,        
    input wire [7:0] In3,       
    input wire [7:0] In4,       
    input wire [7:0] In5,       
    input wire [7:0] In6,      
    input wire [7:0] In7,        
    input wire [2:0] Sel,        
    output reg [7:0] Out         
);

    always @(*) begin
        case (Sel)
            3'b000: Out = In0;
            3'b001: Out = In1;
            3'b010: Out = In2;
            3'b011: Out = In3;
            3'b100: Out = In4;
            3'b101: Out = In5;
            3'b110: Out = In6;
            3'b111: Out = In7;
            default: Out = 8'd0;
        endcase
    end

endmodule