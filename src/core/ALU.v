`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2025 12:06:22 AM
// Design Name: 
// Module Name: ALU
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


module ALU (
    input wire [7:0] A,          
    input wire [7:0] B,          
    input wire [3:0] ALU_Op,     
    input wire [3:0] Flags_in,     
    output reg [7:0] Result,     
    output reg [3:0] Flags_out     
);

    // Internal signals for flag calculation
    reg Z, N, C, V;
    reg [8:0] temp_result;  // 9-bit for carry detection
    
    always @(*) begin
        // Default values
        Z = 1'b0;
        N = 1'b0;
        C = Flags_in[2];  // Preserve carry by default
        V = 1'b0;
        Result = 8'd0;
        temp_result = 9'd0;
        
        case (ALU_Op)
            4'b0000: begin  // NOP
                Result = A;
                // No flags affected
                Z = Flags_in[0];
                N = Flags_in[1];
                C = Flags_in[2];
                V = Flags_in[3];
            end
            
            4'b0001: begin  // MOV
                Result = B;
                // No flags affected
                Z = Flags_in[0];
                N = Flags_in[1];
                C = Flags_in[2];
                V = Flags_in[3];
            end
            
            // Arithmetic Operations
            4'b0010: begin  // ADD
                temp_result = A + B;
                Result = temp_result[7:0];
                C = temp_result[8];  // Carry out
                V = (A[7] == B[7]) && (A[7] != Result[7]);  // Overflow
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            4'b0011: begin  // SUB
                temp_result = A - B;
                Result = temp_result[7:0];
                C = ~temp_result[8];  // Borrow indicator (inverted carry)
                V = (A[7] != B[7]) && (A[7] != Result[7]);  // Overflow
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            // Logical Operations
            4'b0100: begin  // AND
                Result = A & B;
                N = Result[7];
                Z = (Result == 8'd0);
                C = Flags_in[2];  // Preserve C
                V = Flags_in[3];  // Preserve V
            end
            
            4'b0101: begin  // OR
                Result = A | B;
                N = Result[7];
                Z = (Result == 8'd0);
                C = Flags_in[2];  // Preserve C
                V = Flags_in[3];  // Preserve V
            end
            
            4'b0110: begin  // NOT
                Result = ~B;
                N = Result[7];
                Z = (Result == 8'd0);
                C = Flags_in[2];  // Preserve C
                V = Flags_in[3];  // Preserve V
            end
            
            4'b0111: begin  // NEG (Two's complement)
                temp_result = 9'd0 - B;
                Result = temp_result[7:0];
                C = ~temp_result[8];  // Borrow indicator
                V = (B == 8'h80);  // Overflow when negating -128
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            4'b1000: begin  // INC_A
                temp_result = A + 1;
                Result = temp_result[7:0];
                C = temp_result[8];
                V = (A == 8'h7F);  // Overflow from 127 to -128
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            4'b1001: begin  // DEC_A
                temp_result = A - 1;
                Result = temp_result[7:0];
                C = ~temp_result[8];
                V = (A == 8'h80);  // Overflow from -128 to 127
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            4'b1010: begin  // INC_B
                temp_result = B + 1;
                Result = temp_result[7:0];
                C = temp_result[8];
                V = (B == 8'h7F);  // Overflow from 127 to -128
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            4'b1011: begin  // DEC_B
                temp_result = B - 1;
                Result = temp_result[7:0];
                C = ~temp_result[8];
                V = (B == 8'h80);  // Overflow from -128 to 127
                N = Result[7];
                Z = (Result == 8'd0);
            end
            
            // Shift Operations
            4'b1100: begin  // RLC (Rotate Left through Carry)
                Result = {B[6:0], Flags_in[2]};  // B shifted left, Carry_in goes to LSB
                C = B[7];  // MSB goes to Carry
                Z = Flags_in[0];  // Preserve Z
                N = Flags_in[1];  // Preserve N
                V = Flags_in[3];  // Preserve V
            end
            
            4'b1101: begin  // RRC (Rotate Right through Carry)
                Result = {Flags_in[2], B[7:1]};  // B shifted right, Carry_in goes to MSB
                C = B[0];  // LSB goes to Carry
                Z = Flags_in[0];  // Preserve Z
                N = Flags_in[1];  // Preserve N
                V = Flags_in[3];  // Preserve V
            end
            
            // Flag Control Operations
            4'b1110: begin  // SETC
                Result = A;  // Pass A through
                C = 1'b1;  // Set carry
                Z = Flags_in[0];  // Preserve other flags
                N = Flags_in[1];
                V = Flags_in[3];
            end
            
            4'b1111: begin  // CLRC
                Result = A;  // Pass A through
                C = 1'b0;  // Clear carry
                Z = Flags_in[0];  // Preserve other flags
                N = Flags_in[1];
                V = Flags_in[3];
            end
            
            default: begin
                Result = 8'd0;
                Z = Flags_in[0];
                N = Flags_in[1];
                C = Flags_in[2];
                V = Flags_in[3];
            end
        endcase
        
        // Pack flags into CCR_out [V, C, N, Z]
        Flags_out = {V, C, N, Z};
    end

endmodule