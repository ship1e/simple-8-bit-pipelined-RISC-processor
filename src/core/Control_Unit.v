`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2025 03:34:42 PM
// Design Name: 
// Module Name: Control_Unit
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


module CU(
    input  wire        CLK,
    input  wire        RESET,
    input  wire [7:0]  MEM_Data,
    input  wire [3:0]  CCR,
    input  wire        INTR_IN,
    input  wire        Z_flag,
    output reg         Output_Port,
    output reg         CCR_En,
    output reg         CCR_RST,
    output reg         CCR_Shift_L,
    output reg         CCR_shift_R,
    output reg         PC_En,
    output reg [18:0]  L_En,
    output reg [18:0]  L_RST,
    output reg [3:0]   ALU_Op,
    output reg [1:0]   M1_S,
    output reg         M2_S,
    output reg         M3_S,
    output reg [2:0]   M4_S,
    output reg [2:0]   M5_S,
    output reg         M6_S,
    output reg         M7_S,
    output reg [1:0]   M8_S,
    output reg [1:0]   M9_S,
    output reg         M10_S,
    output reg         M11_S,
    output reg         MEM_W_En,
    output reg         MEM_R_En,
    output reg         Reg_file_W_En,
    output reg         Reg_file_RST
);       
    // Pipeline Stage Registers
    reg [7:0] Next_ID,Next_EX,Next_M,Next_WB;
    reg [7:0] Prev_ID,Prev_EX,Prev_M,Prev_WB;
    
    // Instruction Decode
    wire [3:0] F_op  = MEM_Data[7:4];
    wire [1:0] F_ra  = MEM_Data[3:2];
    wire [1:0] F_rb  = MEM_Data[1:0];
    
    wire [3:0] D_op  = Prev_ID[7:4];
    wire [1:0] D_ra  = Prev_ID[3:2];
    wire [1:0] D_rb  = Prev_ID[1:0];
    
    wire [3:0] EX_op = Prev_EX[7:4];
    wire [1:0] EX_ra = Prev_EX[3:2];
    wire [1:0] EX_rb = Prev_EX[1:0];
    
    wire [3:0] M_op  = Prev_M[7:4];
    wire [1:0] M_ra  = Prev_M[3:2];
    wire [1:0] M_rb  = Prev_M[1:0];
    
    wire [3:0] WB_op = Prev_WB[7:4];
    wire [1:0] WB_ra = Prev_WB[3:2];
    wire [1:0] WB_rb = Prev_WB[1:0];
     
    // Interrupt Control
    reg intr_prev;
    reg PC_saving;
    wire intr_edge;    
    assign intr_edge = INTR_IN & ~intr_prev;
    
    // memory is busy
    wire mem_busy = (M_op == 4'hC && M_ra != 2'b00) || M_op == 4'hD || M_op == 4'hE ||(M_op == 4'h7 && M_ra < 2'b10) || (M_op == 4'hB && M_ra != 2'b00 || M_op == 4'hF);
    
    //data hazards
    wire read_after_load_stall = (((((D_op==4'h1)||(D_op==4'h2)||(D_op==4'h3)||(D_op==4'h4)||(D_op==4'h5)||(D_op==4'h6&&D_ra<2)||(D_op==4'h7&&(D_ra==0||D_ra==2))||(D_op==4'h8)||(D_op==4'h9)||(D_op==4'hB&&D_ra==0)||(D_op==4'hE)||(D_op==4'hA))&& (D_rb==EX_rb))||(((D_op==4'hE)||(D_op==4'h2)||(D_op==4'h3)||(D_op==4'h4)||(D_op==4'h5)||(D_op==4'hA)||(D_op==4'hD))&&(D_ra==EX_rb))) && ((EX_op==4'hD)||(EX_op==4'hC &&EX_ra==1)||(EX_op==4'h7 &&EX_ra==1)||(EX_op==4'h7 &&EX_ra==3)));
    wire read_after_load_ra = (((EX_op==4'hE)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'hA)||(EX_op==4'hD)) && ((WB_op==4'hD)||(WB_op==4'hC &&WB_ra==1)||(WB_op==4'h7 &&WB_ra==1)||(WB_op==4'h7 &&WB_ra==3)) && (EX_ra==WB_rb));
    wire read_after_load_rb = (((EX_op==4'h1)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'h6&&EX_ra<2)||(EX_op==4'h7&&(EX_ra==0||EX_ra==2))||(EX_op==4'h8)||(EX_op==4'h9)||(EX_op==4'hB&&EX_ra==0)||(EX_op==4'hE)||(EX_op==4'hA)) && ((WB_op==4'hD)||(WB_op==4'hC &&WB_ra==1)||(WB_op==4'h7 &&WB_ra==1)||(WB_op==4'h7 &&WB_ra==3)) && (EX_rb==WB_rb));
    wire RAW_EX_M_ra = (((EX_op==4'hE)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'hA)||(EX_op==4'hD)) && ((((M_op==4'h1)||(M_op==4'h2)||(M_op==4'h3)||(M_op==4'h4)||(M_op==4'h5)||(M_op==4'hA)) && EX_ra==M_ra)||(((M_op==4'h6&&M_ra<2)||(M_op==4'h8)||(M_op==4'hC&&M_ra==0))&&EX_ra==M_rb)));
    wire RAW_EX_M_rb = (((EX_op==4'h1)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'h6&&EX_ra<2)||(EX_op==4'h7&&(EX_ra==0||EX_ra==2))||(EX_op==4'h8)||(EX_op==4'h9)||(EX_op==4'hB&&EX_ra==0)||(EX_op==4'hE)||(EX_op==4'hA)) && ((((M_op==4'h6&&M_ra<2)||(M_op==4'h8)||(M_op==4'hC&&M_ra==0)) && EX_rb==M_rb)||(((M_op==4'h1)||(M_op==4'h2)||(M_op==4'h3)||(M_op==4'h4)||(M_op==4'h5)||(M_op==4'hA)) && EX_rb==M_ra)));
    wire RAW_EX_WB_ra=(((EX_op==4'hE)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'hA)||(EX_op==4'hD)) && ((((WB_op==4'h1)||(WB_op==4'h2)||(WB_op==4'h3)||(WB_op==4'h4)||(WB_op==4'h5)||(WB_op==4'hA)) && EX_ra==WB_ra)||(((WB_op==4'h6&&WB_ra<2)||(WB_op==4'h8)||(WB_op==4'hC&&WB_ra==0))&&EX_ra==WB_rb)));
    wire RAW_EX_WB_rb = (((EX_op==4'h1)||(EX_op==4'h2)||(EX_op==4'h3)||(EX_op==4'h4)||(EX_op==4'h5)||(EX_op==4'h6&&EX_ra<2)||(EX_op==4'h7&&(EX_ra==0||EX_ra==2))||(EX_op==4'h8)||(EX_op==4'h9)||(EX_op==4'hB&&(EX_ra==0||EX_ra==1))||(EX_op==4'hE)||(EX_op==4'hA)) && ((((WB_op==4'h6&&WB_ra<2)||(WB_op==4'h8)||(WB_op==4'hC&&WB_ra==0)) && EX_rb==WB_rb)||(((WB_op==4'h1)||(WB_op==4'h2)||(WB_op==4'h3)||(WB_op==4'h4)||(WB_op==4'h5)||(WB_op==4'hA)) && EX_rb==WB_ra)));
    wire RAW_EX_M_SP=((EX_op==4'h7 &&(EX_ra==0||EX_ra==1))||(EX_op==4'hB && EX_ra!=0))&&((M_op==4'h7 &&(M_ra==0||M_ra==1))||(M_op==4'hB && M_ra!=0));
    wire RAW_EX_WB_SP=((EX_op==4'h7 &&(EX_ra==0||EX_ra==1))||(EX_op==4'hB && EX_ra!=0))&&((WB_op==4'h7 &&(WB_ra==0||WB_ra==1))||(WB_op==4'hB && WB_ra!=0));
    wire Inst2clk_M= mem_busy &&D_op==4'hc;
    wire RAW_D_WB_SP=((D_op==4'h7 &&(D_ra==0||D_ra==1))||(D_op==4'hB && D_ra!=0))&&((WB_op==4'h7 &&(WB_ra==0||WB_ra==1))||(WB_op==4'hB && WB_ra!=0));
    wire RAW_D_WB_rb=(((D_op==4'h1)||(D_op==4'h2)||(D_op==4'h3)||(D_op==4'h4)||(D_op==4'h5)||(D_op==4'h6&&D_ra<2)||(D_op==4'h7&&(D_ra==0||D_ra==2))||(D_op==4'h8)||(D_op==4'h9)||(D_op==4'hB&&D_ra==0)||(D_op==4'hE)||(D_op==4'hA)) && ((((WB_op==4'h6&&WB_ra<2)||(WB_op==4'h8)||(WB_op==4'hC&&WB_ra==0)) && D_rb==WB_rb)||(((WB_op==4'h1)||(WB_op==4'h2)||(WB_op==4'h3)||(WB_op==4'h4)||(WB_op==4'h5)||(WB_op==4'hA)) && D_rb==WB_ra)));
    wire RAW_D_WB_ra=(((D_op==4'hE)||(D_op==4'h2)||(D_op==4'h3)||(D_op==4'h4)||(D_op==4'h5)||(D_op==4'hA)||(D_op==4'hD)) && ((((WB_op==4'h1)||(WB_op==4'h2)||(WB_op==4'h3)||(WB_op==4'h4)||(WB_op==4'h5)||(WB_op==4'hA)) && D_ra==WB_ra)||(((WB_op==4'h6&&WB_ra<2)||(WB_op==4'h8)||(WB_op==4'hC&&WB_ra==0))&&D_ra==WB_rb)));
    reg RAW_D_WB_SP_handling,RAW_D_WB_rb_handling,RAW_D_WB_ra_handling;
    always @(posedge CLK)begin
        if(RAW_D_WB_SP)
            RAW_D_WB_SP_handling<=1;
        else
            RAW_D_WB_SP_handling<=0;
        if(RAW_D_WB_rb)
            RAW_D_WB_rb_handling<=1;
        else
            RAW_D_WB_rb_handling<=0;
        if(RAW_D_WB_ra)
            RAW_D_WB_ra_handling<=1;
        else
            RAW_D_WB_ra_handling<=0;
    end
    
    // stall handling
    reg fetch_2CLK,WB_2CLK;
    wire Stall = (intr_edge==1 || (D_op==4'hC && !fetch_2CLK) ||(WB_op==4'h7 &&WB_ra==2'b01 && !WB_2CLK ));
    
    //branch handling
    wire C_branch=((EX_op==4'h9 && ((EX_ra==2'b00 &&CCR[0]) || (EX_ra==2'b01 &&CCR[1]) || (EX_ra==2'b10 &&CCR[2]) || (EX_ra==2'b11 &&CCR[3]) )) || (EX_op==4'hA &&!Z_flag));
    wire U_branch=( D_op==4'hB || EX_op==4'hB || (M_op==4'hB &&M_ra>2'b01) );
    
    //2_clk fetch and 2_clk WB hndling
    always @(posedge CLK) begin
        if(RESET) begin
            fetch_2CLK <= 0;
        end
        else if(D_op==4'hC && !fetch_2CLK &&!Inst2clk_M) begin
            fetch_2CLK <= 1;  // First clock: opcode received, set flag                    
        end                                  
        else begin                           
            fetch_2CLK <= 0;  // Second clock: immediate received, clear flag                    
        end                                     
    end
    always @(posedge CLK) begin
        if(RESET) begin
            WB_2CLK <= 0;
        end
        else if(WB_op==4'h7 &&WB_ra==2'b01&& !WB_2CLK) begin   
            WB_2CLK <= 1;  // First clock: opcode received, set flag                    
        end                                  
        else begin                           
            WB_2CLK <= 0;  // Second clock: immediate received, clear flag                    
        end                                     
    end
    
    // Interrupt Handling
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin 
            PC_saving <= 0; 
        end
        else begin
            intr_prev <= INTR_IN;
            if(intr_edge)begin
                PC_saving <= 1;
            end
            else if (PC_saving==1 && (Stall || read_after_load_stall))begin
                PC_saving <= 1;
            end
            else begin
                PC_saving <= 0;
            end 
        end
    end
    // Normal run
    reg Flush_for_rst;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            Flush_for_rst <= 1;
            Prev_ID <= 8'h00;
            Prev_EX <= 8'h00;
            Prev_M <= 8'h00;
            Prev_WB <= 8'h00;
        end else begin
            Flush_for_rst <= 0;
            if(!Stall||((D_op==4'hC && !fetch_2CLK)))
            begin
                if (!read_after_load_stall )begin
                    if (PC_saving==1) begin
                        Prev_ID <= 8'hFF;
                    end
                    else begin
                        if(Inst2clk_M)begin
                            Prev_ID <= Prev_ID;
                            Prev_EX <= 8'h00;
                        end
                        else begin
                            Prev_ID <= Next_ID;
                            Prev_EX <= Next_EX;
                        end
                    end
                    
                end
                else begin
                    Prev_ID <= Prev_ID;
                    Prev_EX <=8'h00;
                end
                Prev_M <= Next_M;
                Prev_WB <= Next_WB;
            end
            else begin            
                Prev_ID <= Prev_ID;
                
                Prev_EX <= Prev_EX;
                Prev_M <= Prev_M;
                Prev_WB <= Prev_WB;                        
            end
        end
    end
      
    //next state
    always @(*) begin
        if(mem_busy==1|| C_branch==1'b1 || U_branch==1'b1 || Flush_for_rst==1'b1 ||(D_op==4'hC && !fetch_2CLK)||Inst2clk_M) begin
            Next_ID = 8'h00;
        end
        else begin
            Next_ID = MEM_Data;
        end
        if(C_branch==1'b1) begin
            Next_EX = 8'h00;
        end
        else begin
            Next_EX = Prev_ID;
        end
        
        Next_M =  Prev_EX;
        Next_WB = Prev_M;
    end
    // control_signals
    always @(*) begin
        // Default values
        PC_En = 1'b1;
        L_En = 19'hfffBf;
        L_RST= 19'h00000;
        MEM_R_En = 1'b0;
        MEM_W_En = 1'b0;
        Reg_file_W_En = 1'b0;
        Reg_file_RST = 1'b0;
        CCR_En=1'b1;
        CCR_RST=1'b0;
        CCR_Shift_L=1'b0;
        CCR_shift_R=1'b0;  
        M1_S = 2'b11;
        Output_Port=1'b0;
        M2_S = 1'b0;
        M3_S = 1'b0;
        M4_S = 3'b000;
        M5_S = 3'b001;
        M6_S = 1'b0;
        M7_S = 1'b0;
        M8_S = 2'b01;
        M9_S = 2'b00;
        M10_S = 1'b0;
        M11_S = 1'b0;
        ALU_Op = 4'h0;
        if(Flush_for_rst)begin
            L_RST= 19'hfffff;
            M5_S = 3'b011;
            MEM_R_En = 1'b1;
            MEM_W_En=1'b0;
            Reg_file_W_En=1'b0;
            PC_En = 1'b1;
            CCR_RST=1'b1;
            CCR_En=1'b0;
            M1_S = 2'b00;
            Reg_file_RST = 1'b1;        
        end
        else begin
            if(intr_edge)begin
                M5_S = 3'b100;
                L_En [17]=1'b0;
                M1_S = 2'b00;
                PC_En = 1'b1;
                MEM_R_En = 1'b1;
            end
            else begin
                if(Stall || mem_busy || read_after_load_stall ||PC_saving )begin
                    if((D_op==4'hC && !fetch_2CLK))begin
                        if(Inst2clk_M)
                            PC_En = 1'b0;
                        else
                            PC_En = 1'b1;
                            
                        if ((C_branch==1'b1 || (EX_op==4'hB && (EX_ra == 2'b00 ||EX_ra == 2'b01)))&&(D_op!=4'hF)) begin                                                                                    
                                M1_S = 2'b10;                                                                        
                        end                                                                                      
                        else if ((M_op==4'hB && (M_ra == 2'b10 ||M_ra == 2'b11))&&(D_op!=4'hF||EX_op!=4'hF))begin
                                M1_S = 2'b00;                                                                        
                        end   
                        else begin                                                                                  
                            M1_S = 2'b11;
                        end
                    end
                    else begin
                        PC_En = 1'b0;
                    end
                    L_En [17]=1'b0;
                    L_En [0]=1'b0;
                    L_En [1]=1'b0;
                    L_En [2]=1'b0;
                    if(mem_busy==1'b1)begin
                        if ((C_branch==1'b1 || (EX_op==4'hB && (EX_ra == 2'b00 ||EX_ra == 2'b01)))&&(D_op!=4'hF))
                        begin
                            M1_S = 2'b10;
                            PC_En = 1'b1;
                        end
                        else if ((M_op==4'hB && (M_ra == 2'b10 ||M_ra == 2'b11))&&(D_op!=4'hF||EX_op!=4'hF))begin
                            M1_S = 2'b00;
                            PC_En = 1'b1;
                        end
                        else begin
                            PC_En = 1'b0;
                            M1_S = 2'b11;
                        end                    
                    end                 
                end
                else begin
                    PC_En = 1'b1;
                    if ((C_branch==1'b1 || (EX_op==4'hB && (EX_ra == 2'b00 ||EX_ra == 2'b01)))&&(D_op!=4'hF))
                    begin
                        M1_S = 2'b10;
                    end
                    else if ((M_op==4'hB && (M_ra == 2'b10 ||M_ra == 2'b11))&&(D_op!=4'hF||EX_op!=4'hF))begin
                        M1_S = 2'b00;
                    end
                    else begin
                        M1_S = 2'b11;
                    end
                end
                if((Stall&&!(D_op==4'hC && !fetch_2CLK)) || read_after_load_stall || D_op==4'h0) begin
                    L_En [3]=1'b0;
                    L_En [4]=1'b0;
                    L_En [5]=1'b0;
                    
                    
                    L_En [7]=1'b0;
                    L_En [8]=1'b0;
                    //if(D_op==4'hC && !fetch_2CLK)begin
                       //L_En [6]=1'b1;
                    //end
                    //else begin
                        L_En [6]=1'b0;
                    //end
                end
                else begin
                    L_En [3]=1'b1;
                    L_En [4]=1'b1;
                    L_En [5]=1'b1;
                    L_En [6]=1'b1;
                    L_En [7]=1'b1;
                    L_En [8]=1'b1;
                end
                if((Stall&&!(D_op==4'hC && !fetch_2CLK)) || EX_op==4'h0) begin
                    L_En [9]=1'b0;
                    L_En [10]=1'b0;
                    L_En [11]=1'b0;
                    L_En [13]=1'b0;
                    L_En [14]=1'b0;
                    L_En [15]=1'b0;
                    CCR_En=1'b0;
                end
                else begin
                    L_En [9]=1'b1;
                    L_En [10]=1'b1;
                    L_En [11]=1'b1;
                    L_En [13]=1'b1;
                    L_En [14]=1'b1;
                    L_En [15]=1'b1;
                    CCR_En=1'b1;
                end
                if ((Stall&&!(D_op==4'hC && !fetch_2CLK)) || M_op==4'h0) begin
                    L_En [12]=1'b0;
                    L_En [16]=1'b0;
                    L_En [18]=1'b0;
                end
                else begin
                    L_En [12]=1'b1;
                    L_En [16]=1'b1;
                    L_En [18]=1'b1;
                end
                //instruction handling
                //D_Stage
                case(D_op)
                    4'h0:begin
                        M2_S=1'b00;
                        M3_S=1'b0;
                    end
                    4'h1:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'h2:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'h3:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'h4:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'h5:begin
                        M2_S=2'b1;
                        M3_S=1'b1;
                    end
                    4'h6:begin
                        M2_S=1'b0;
                        M3_S=1'b1;
                    end
                    4'h7:begin
                        case(D_ra)
                        2'b00:begin
                            M2_S=1'b0;
                            M3_S=1'b0;
                        end
                        2'b01:begin
                            M2_S=1'b0;
                            M3_S=1'b0;
                        end
                        2'b10:begin
                            M2_S=1'b1;
                            M3_S=1'b1;
                        end
                        default:begin
                            M2_S=1'b0;
                            M3_S=1'b1;
                        end
                        endcase
                    end
                    4'h8:begin
                        M2_S=1'b0;
                        M3_S=1'b1;  
                    end
                    4'h9:begin
                        M3_S=1'b1;
                        M2_S=1'b1;
                    end
                    4'hA:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'hB:begin
                        case(D_ra)
                        2'b00:begin
                            M2_S=1'b1;
                            M3_S=1'b1;
                        end
                        2'b01:begin
                            M3_S=1'b0;
                            M2_S=1'b1;
                        end
                        2'b10:begin
                            M2_S=1'b1;
                            M3_S=1'b0;
                        end
                        default:begin
                            M2_S=1'b1;
                            M3_S=1'b0;
                        end
                        endcase
                    end
                    4'hC:begin
                        case(D_ra)
                        2'b00:begin
                            M2_S=1'b0;
                            M3_S=1'b1;
                        end
                        2'b01:begin
                            M2_S=1'b0;
                            M3_S=1'b1;
                        end
                        2'b10:begin
                            M2_S=1'b0;
                            M3_S=1'b1;
                        end
                        default:begin
                            M2_S=1'b1;
                            M3_S=1'b1;
                        end
                        endcase
                    end
                    4'hD:begin
                        M2_S=1'b0;
                        M3_S=1'b1;
                    end
                    4'hE:begin
                        M2_S=1'b1;
                        M3_S=1'b1;
                    end
                    4'hF:begin
                        M2_S=1'b1;
                        M3_S=1'b0;
                    end
                endcase
                
                // EX_Stage
                if(RAW_EX_M_ra==1 || RAW_EX_M_SP==1)begin
                    M4_S=3'b010;
                end
                else if(EX_op==4'hC)begin
                    M4_S=3'b001;
                end
                else if(read_after_load_ra||RAW_EX_WB_ra||RAW_EX_WB_SP ||RAW_D_WB_SP_handling ||RAW_D_WB_ra_handling)begin
                    if((WB_op==4'h7 && WB_ra==1)&&(EX_op==4'h7 && EX_ra==0))begin
                        M4_S=3'b100;
                    end
                    else begin
                        M4_S=3'b011;
                    end
                end
                else begin
                    M4_S=3'b000;
                end
                if(RAW_EX_M_rb==1)begin
                    M9_S=2'b10;
                end
                else if(read_after_load_rb||RAW_EX_WB_rb||RAW_D_WB_rb_handling)begin
                    M9_S=2'b01;
                end
                else begin
                    M9_S=2'b00;
                end
                case(EX_op)
                    4'h0:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0000;
                    end
                    4'h1:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0001;
                    end
                    4'h2:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0010;
                    end
                    4'h3:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0011;
                    end
                    4'h4:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0100;
                    end
                    4'h5:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0101;
                    end
                    4'h6:begin
                        case(EX_ra)
                        2'b00:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1100;
                        end
                        2'b01:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1101;
                        end
                        2'b10:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1110;
                        end
                        default:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1111;
                        end
                        endcase
                    end
                    4'h7:begin
                        case(EX_ra)
                        2'b00:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1001;
                        end
                        2'b01:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1000;
                        end
                        2'b10:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b0001;
                            Output_Port=1'b1;
                        end
                        default:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b0000;
                        end
                        endcase
                    end
                    4'h8:begin
                        case(EX_ra)
                        2'b00:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b0110;
                        end
                        2'b01:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b0111;
                        end
                        2'b10:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1010;
                        end
                        default:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1011;
                        end
                        endcase
                    end
                    4'h9:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0000;
                    end
                    4'hA:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b1001;
                    end
                    4'hB:begin
                        case(EX_ra)
                        2'b00:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b0000;
                        end
                        2'b01:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1001;
                        end
                        2'b10:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b0;
                            ALU_Op=4'b1000;
                        end
                        default:begin
                            CCR_Shift_L=1'b0;
                            CCR_shift_R=1'b1;
                            ALU_Op=4'b1000;
                            CCR_En=1'b0;
                        end
                        endcase
                    end
                    4'hC:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0000;
                    end
                    4'hD:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0000;
                    end
                    4'hE:begin
                        CCR_Shift_L=1'b0;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b0000;
                    end
                    default:begin
                        CCR_Shift_L=1'b1;
                        CCR_shift_R=1'b0;
                        ALU_Op=4'b1001;
                        CCR_En=1'b0;
                    end
                endcase
                
                //M_stage
                if(Stall &&!Inst2clk_M)begin
                    if(D_op==4'hC && Stall==1)begin
                        MEM_R_En = 1'b1;
                        MEM_W_En = 1'b0;
                        M5_S = 3'b010;
                    end
                    else begin
                        MEM_R_En = 1'b0;
                        MEM_W_En = 1'b0;                             
                    end                    
                end
                else if (!mem_busy) begin
                    MEM_R_En = 1'b1;
                    if(M_op==4'h7&&M_ra==3)begin
                        M8_S = 2'b10;
                    end
                    else begin
                        M8_S = 2'b01;
                    end
                end
                else begin
                    case(M_op)
                    4'h7:begin
                        case(M_ra)
                        2'b00:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b1;
                            M5_S = 3'b000;
                            M6_S = 1'b1;
                            M7_S = 1'b0;
                            M8_S = 2'b01;
                        end
                        2'b01:begin
                            MEM_R_En = 1'b1;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b1;
                            M7_S = 1'b0;
                            M8_S = 2'b00;
                        end
                        2'b10:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b1;
                            M7_S = 1'b0;
                            M8_S = 2'b01;
                        end
                        default:begin
                            M8_S = 2'b10;
                        end
                        endcase
                    end
                    4'hB:begin
                        case(M_ra)
                        2'b00:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b1;
                            M7_S = 1'b0;
                            M8_S = 2'b01;
                        end
                        2'b01:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b1;
                            M5_S = 3'b000;
                            M6_S = 1'b0;
                            M7_S = 1'b0;
                            M8_S = 2'b01;
                        end
                        default:begin
                            MEM_R_En = 1'b1;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b0;
                            M7_S = 1'b0;
                            M8_S = 2'b01;
                        end
                        endcase
                    end
                    4'hC:begin
                        case(M_ra)
                        2'b01:begin
                            MEM_R_En = 1'b1;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b0;
                            M7_S = 1'b0;
                            M8_S = 2'b00;                        
                        end
                        2'b10:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b1;
                            M5_S = 3'b101;
                            M6_S = 1'b1;
                            M7_S = 1'b0;
                            M8_S = 2'b00;                     
                        end
                        default:begin
                            MEM_R_En = 1'b0;
                            MEM_W_En = 1'b0;
                            M5_S = 3'b101;
                            M6_S = 1'b0;
                            M7_S = 1'b0;
                            M8_S = 2'b01;                       
                        end
                        endcase
                    end
                    4'hD:begin
                        MEM_R_En = 1'b1;
                        MEM_W_En = 1'b0;
                        M5_S = 3'b000;
                        M6_S = 1'b0;
                        M7_S = 1'b0;
                        M8_S = 2'b00;
                    end
                    4'hE:begin
                        MEM_R_En = 1'b0;
                        MEM_W_En = 1'b1;
                        M5_S = 3'b000;
                        M6_S = 1'b1;
                        M7_S = 1'b0;
                        M8_S = 1'b0;
                    end
                    4'hF:begin
                        MEM_R_En = 1'b0;
                        MEM_W_En = 1'b1;
                        M5_S = 3'b000;
                        M6_S = 1'b0;
                        M7_S = 1'b1;
                        M8_S = 2'b01;
                    end
                    default:begin
                        MEM_R_En = 1'b0;
                        MEM_W_En = 1'b0;
                        M5_S = 3'b001;
                        M6_S = 1'b0;
                        M7_S = 1'b0;
                        M8_S = 2'b01;                  
                    end
                endcase                              
                end
                
                //WB_Stage
                case(WB_op)
                    4'h0:begin
                        M10_S = 1'b0;
                        M11_S = 1'b1;
                        Reg_file_W_En=1'b0;
                    end
                    4'h1:begin
                         M10_S = 1'b0;
                         M11_S = 1'b0;
                         Reg_file_W_En=1'b1;
                    end
                    4'h2:begin
                         M10_S = 1'b0;
                         M11_S = 1'b0;
                         Reg_file_W_En=1'b1;
                    end
                    4'h3:begin
                         M10_S = 1'b0;
                         M11_S = 1'b0;
                         Reg_file_W_En=1'b1;
                    end
                    4'h4:begin
                         M10_S = 1'b0;
                         M11_S = 1'b0;
                         Reg_file_W_En=1'b1;
                    end
                    4'h5:begin
                         M10_S = 1'b0;
                         M11_S = 1'b0;
                         Reg_file_W_En=1'b1;
                    end
                    4'h6:begin
                        case(WB_ra)
                        2'b00:begin
                             M10_S = 1'b0;
                             M11_S = 1'b0;
                             Reg_file_W_En=1'b1;
                        end
                        2'b01:begin
                             M10_S = 1'b0;
                             M11_S = 1'b0;
                             Reg_file_W_En=1'b1;
                        end
                        2'b10:begin
                             M10_S = 1'b0;
                             M11_S = 1'b1;
                             Reg_file_W_En=1'b0;
                        end
                        default:begin
                            M10_S = 1'b0;
                            M11_S = 1'b1;
                            Reg_file_W_En=1'b0;
                        end
                        endcase
                    end
                    4'h7:begin
                        case(WB_ra)
                        2'b00:begin
                            M10_S = 1'b0;
                            M11_S = 1'b1;
                            Reg_file_W_En=1'b1;
                        end
                        2'b01:begin
                            if(Stall)begin                        
                                M10_S = 1'b0;
                                M11_S = 1'b0;
                            end
                            else begin
                                M10_S = 1'b1;
                                M11_S = 1'b1;
                            end
                            Reg_file_W_En=1'b1;
                        end
                        2'b10:begin
                            M10_S = 1'b0;
                            M11_S = 1'b1;
                            Reg_file_W_En=1'b0;
                        end
                        default:begin
                            M10_S = 1'b0;
                            M11_S = 1'b0;
                            Reg_file_W_En=1'b1;
                        end
                        endcase
                    end
                    4'h8:begin
                        M10_S = 1'b0;
                        M11_S = 1'b0;
                        Reg_file_W_En=1'b1;
                    end
                    4'h9:begin
                        M10_S = 1'b0;     
                        M11_S = 1'b0;      
                        Reg_file_W_En=1'b0;
                    end
                    4'hA:begin
                        M10_S = 1'b0;     
                        M11_S = 1'b0;      
                        Reg_file_W_En=1'b1;
                    end
                    4'hB:begin
                        case(WB_ra)
                        2'b00:begin
                            M10_S = 1'b0;     
                            M11_S = 1'b0;      
                            Reg_file_W_En=1'b0;
                        end
                        2'b01:begin
                            M10_S = 1'b0;     
                            M11_S = 1'b1;      
                            Reg_file_W_En=1'b1;
                        end
                        2'b10:begin
                           M10_S = 1'b0;     
                           M11_S = 1'b1;      
                           Reg_file_W_En=1'b1;
                        end
                        default:begin
                           M10_S = 1'b0;     
                           M11_S = 1'b1;      
                           Reg_file_W_En=1'b1;
                        end
                        endcase
                    end
                    4'hC:begin
                        case(WB_ra)
                        2'b00:begin
                            M10_S = 1'b0;
                            M11_S = 1'b0;
                            Reg_file_W_En=1'b1;                            
                        end
                        2'b01:begin
                            M10_S = 1'b0;
                            M11_S = 1'b0;
                            Reg_file_W_En=1'b1;                              
                        end
                        default:begin
                            M10_S = 1'b0;
                            M11_S = 1'b0;
                            Reg_file_W_En=1'b0;                           
                        end
                        endcase
                    end
                    4'hD:begin
                        M10_S = 1'b0;     
                        M11_S = 1'b0;                              
                        Reg_file_W_En=1'b1;
                    end
                    4'hE:begin
                        M10_S = 1'b0;     
                        M11_S = 1'b0;      
                        Reg_file_W_En=1'b0;
                    end
                    default:begin
                        M10_S = 1'b0;     
                        M11_S = 1'b1;      
                        Reg_file_W_En=1'b1;
                    end
                endcase                
                
            end
        end
        
    end
    
endmodule