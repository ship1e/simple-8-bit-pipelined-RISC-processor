`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2025 12:20:08 AM
// Design Name: 
// Module Name: RISC
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

module RISC(
    input wire [7:0] Data_in,
    input wire INTR,
    input wire CLK,
    input wire RST,
    output reg [7:0] Data_out
    );
    wire out_data;
    always @(*)begin
        if (out_data==1'b1)begin
            Data_out = Wire_1[26];
        end
        else begin
            Data_out=8'h00;
        end
    end
    wire [18:0]  Reg_E;
    wire [18:0]  Reg_RST;
    wire         CCR_En;         
    wire         CCR_RST;        
    wire         CCR_Shift_L;    
    wire         CCR_shift_R;    
    wire         PC_En;          
    wire [18:0]  L_En;           
    wire [18:0]  L_RST;          
    wire [3:0]   ALU_Op;         
    wire [1:0]   M1_S;           
    wire         M2_S;           
    wire         M3_S;           
    wire [2:0]   M4_S;           
    wire [2:0]   M5_S;           
    wire         M6_S;           
    wire         M7_S;           
    wire [1:0]   M8_S;           
    wire [1:0]   M9_S;           
    wire         M10_S;          
    wire         M11_S;          
    wire         MEM_W_En;       
    wire         MEM_R_En;       
    wire         Reg_file_W_En;  
    wire         Reg_file_RST;    
    wire [7:0]   Wire_1 [29:0];
    wire [1:0]   Wire_2 [5:0];
    wire [3:0]   CCR_wire [1:0];
    
    ALU MY_ALU (.B(Wire_1[26]),.A(Wire_1[14]),.ALU_Op(ALU_Op),.Flags_in(CCR_wire[1]),.Result(Wire_1[15]),.Flags_out(CCR_wire[0]));
    CCR MY_CCR (.CLK(CLK),             
                .RST(CCR_RST),             
                .Enable(CCR_En),          
                .Shift_Left(CCR_Shift_L),      
                .Shift_Right(CCR_shift_R),     
                .Data_in(CCR_wire[0]),   
                .Data_out(CCR_wire[1]));
    Memory MY_MEMORY (  .CLK(CLK),            
                        .Address(Wire_1[22]),  
                        .Data_in(Wire_1[23]),  
                        .W_En(MEM_W_En),           
                        .R_En(MEM_R_En),           
                        .Data_out(Wire_1[24]));
                        
    Reg_file MY_REG_FILE (  .CLK(CLK),            
                            .RST(Reg_file_RST),            
                            .W_En(Reg_file_W_En),           
                            .W_Adr(Wire_2[4]),    
                            .Data_in(Wire_1[28]),  
                            .R1_Adr(Wire_1[3][1:0]),   
                            .R2_Adr(Wire_2[5]),   
                            .R1(Wire_1[4]),       
                            .R2(Wire_1[5]));
                            
    
    PC MY_PC (.CLK(CLK),          
              .En(PC_En),           
              .Data_in(Wire_1[0]),
              .Data_out(Wire_1[1]));
              
    Adder PC_Adder (.Data_in(Wire_1[1]),   
                    .Data_out(Wire_1[2]));
    
    MUX_4_1 M1 (.In0(Wire_1[24]),.In1(Wire_1[19]),.In2(Wire_1[26]),.In3(Wire_1[2]),.Sel(M1_S),.Out(Wire_1[0]));
    MUX_2_1_2bit M2 (.In0(Wire_1[3][1:0]),.In1(Wire_1[3][3:2]),.Sel(M2_S),.Out(Wire_2[0]));
    MUX_2_1_2bit M3 (.In0(2'b11),.In1(Wire_1[3][3:2]),.Sel(M3_S),.Out(Wire_2[5])); 
    MUX_8_1 M4 (.In0(Wire_1[10]),.In1(Wire_1[11]),.In2(Wire_1[19]),.In3(Wire_1[29]),.In4(Wire_1[27]),.In5(8'h00),.In6(8'h00),.In7(8'h00),.Sel(M4_S),.Out(Wire_1[14]));          
    MUX_8_1 M5 (.In0(Wire_1[20]),.In1(Wire_1[1]),.In2(Wire_1[6]),.In3(8'h00),.In4(8'h01),.In5(Wire_1[19]),.In6(8'h00),.In7(8'h00),.Sel(M5_S),.Out(Wire_1[22]));          
    mux_2_1 M6(.In0(Wire_1[21]),.In1(Wire_1[18]),.Sel(M6_S),.Out(Wire_1[23]));
    mux_2_1 M7(.In0(Wire_1[17]),.In1(Wire_1[16]),.Sel(M7_S),.Out(Wire_1[21]));
    MUX_4_1 M8 (.In0(Wire_1[24]),.In1(Wire_1[19]),.In2(Data_in),.In3(8'h00),.Sel(M8_S),.Out(Wire_1[25]));
    MUX_4_1 M9 (.In0(Wire_1[9]),.In1(Wire_1[29]),.In2(Wire_1[19]),.In3(8'h00),.Sel(M9_S),.Out(Wire_1[26]));
    mux_2_1 M10(.In0(Wire_1[29]),.In1(Wire_1[27]),.Sel(M10_S),.Out(Wire_1[28]));
    MUX_2_1_2bit M11 (.In0(Wire_2[3]),.In1(2'b11),.Sel(M11_S),.Out(Wire_2[4]));
    
    Reg L0 (.CLK(CLK),.RST(L_RST[0]),.En(L_En[0]),.Data_in(Wire_1[24]),.Data_out(Wire_1[3]));
    Reg L1 (.CLK(CLK),.RST(L_RST[1]),.En(L_En[1]),.Data_in(Wire_1[2]),.Data_out(Wire_1[6]));
    Reg L2 (.CLK(CLK),.RST(L_RST[2]),.En(L_En[2]),.Data_in(Wire_1[8]),.Data_out(Wire_1[7]));
    Reg_2bit L3 (.CLK(CLK),.RST(L_RST[3]),.En(L_En[3]),.Data_in(Wire_2[0]),.Data_out(Wire_2[1]));
    Reg L4 (.CLK(CLK),.RST(L_RST[4]),.En(L_En[4]),.Data_in(Wire_1[4]),.Data_out(Wire_1[9]));
    Reg L5 (.CLK(CLK),.RST(L_RST[5]),.En(L_En[5]),.Data_in(Wire_1[5]),.Data_out(Wire_1[10]));
    Reg L6 (.CLK(CLK),.RST(L_RST[6]),.En(L_En[6]),.Data_in(Wire_1[24]),.Data_out(Wire_1[11]));
    Reg L7 (.CLK(CLK),.RST(L_RST[7]),.En(L_En[7]),.Data_in(Wire_1[6]),.Data_out(Wire_1[12]));
    Reg L8 (.CLK(CLK),.RST(L_RST[8]),.En(L_En[8]),.Data_in(Wire_1[7]),.Data_out(Wire_1[13]));
    Reg_2bit L9 (.CLK(CLK),.RST(L_RST[9]),.En(L_En[9]),.Data_in(Wire_2[1]),.Data_out(Wire_2[2]));
    Reg L10 (.CLK(CLK),.RST(L_RST[10]),.En(L_En[10]),.Data_in(Wire_1[14]),.Data_out(Wire_1[20]));
    Reg L11 (.CLK(CLK),.RST(L_RST[11]),.En(L_En[11]),.Data_in(Wire_1[15]),.Data_out(Wire_1[19]));
    Reg_2bit L12 (.CLK(CLK),.RST(L_RST[12]),.En(L_En[12]),.Data_in(Wire_2[2]),.Data_out(Wire_2[3]));
    Reg L13 (.CLK(CLK),.RST(L_RST[13]),.En(L_En[13]),.Data_in(Wire_1[26]),.Data_out(Wire_1[18]));
    Reg L14 (.CLK(CLK),.RST(L_RST[14]),.En(L_En[14]),.Data_in(Wire_1[12]),.Data_out(Wire_1[17]));
    Reg L15 (.CLK(CLK),.RST(L_RST[15]),.En(L_En[15]),.Data_in(Wire_1[13]),.Data_out(Wire_1[16]));
    Reg L16 (.CLK(CLK),.RST(L_RST[16]),.En(L_En[16]),.Data_in(Wire_1[25]),.Data_out(Wire_1[29]));
    Reg L17 (.CLK(CLK),.RST(L_RST[17]),.En(L_En[17]),.Data_in(Wire_1[0]),.Data_out(Wire_1[8]));
    Reg L18 (.CLK(CLK),.RST(L_RST[18]),.En(L_En[18]),.Data_in(Wire_1[19]),.Data_out(Wire_1[27]));
    
    CU MY_CU (  .CLK(CLK),          
                .RESET(RST),        
                .MEM_Data(Wire_1[24]),     
                .CCR(CCR_wire[1]),          
                .INTR_IN(INTR),      
                .Z_flag(CCR_wire[0][0]),       
                .CCR_En(CCR_En),       
                .CCR_RST(CCR_RST),      
                .CCR_Shift_L(CCR_Shift_L),  
                .CCR_shift_R(CCR_shift_R),  
                .PC_En(PC_En),        
                .L_En(L_En),         
                .L_RST(L_RST),        
                .ALU_Op(ALU_Op),       
                .M1_S(M1_S),         
                .M2_S(M2_S),         
                .M3_S(M3_S),         
                .M4_S(M4_S),         
                .M5_S(M5_S),         
                .M6_S(M6_S),         
                .M7_S(M7_S),         
                .M8_S(M8_S),         
                .M9_S(M9_S),         
                .M10_S(M10_S),        
                .M11_S(M11_S),        
                .MEM_W_En(MEM_W_En),     
                .MEM_R_En(MEM_R_En),     
                .Reg_file_W_En(Reg_file_W_En),
                .Reg_file_RST(Reg_file_RST),
                .Output_Port(out_data));
endmodule
