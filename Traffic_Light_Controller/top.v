`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/10 19:09:09
// Design Name: 
// Module Name: traffic_fsm
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
module top(
    input wire clk,
    input wire reset_n,
    input wire i_start,
    output wire [3:0] o_e_ct,
//    output wire [3:0] o_w_ct,
//    output wire [3:0] o_s_ct,
    output wire [3:0] o_n_ct,
    output wire [1:0] o_e_wt,
//    output wire [1:0] o_w_wt,
//    output wire [1:0] o_s_wt,
    output wire [1:0] o_n_wt
    );
    traffic_fsm U0 (.clk(clk),
                .reset_n(reset_n),
                .i_start(i_start),
                .i_flag(1'b0),
                .o_car_traffic(o_e_ct),
                .o_walker_traffic(o_e_wt));
        
//    traffic_fsm U1 (.clk(clk),
//                .reset_n(reset_n), 
//                .i_start(i_start), 
//                .i_flag(1'b0), 
//                .o_car_traffic(o_w_ct), 
//                .o_walker_traffic(o_w_wt));
        
//    traffic_fsm U2 (.clk(clk), 
//                .reset_n(reset_n), 
//                .i_start(i_start), 
//                .i_flag(1'b1), 
//                .o_car_traffic(o_s_ct), 
//                .o_walker_traffic(o_s_wt));
        
    traffic_fsm U3 (.clk(clk), 
                .reset_n(reset_n), 
                .i_start(i_start), 
                .i_flag(1'b1), 
                .o_car_traffic(o_n_ct), 
                .o_walker_traffic(o_n_wt));
                
    reg clk_100us;
    reg clk_1s;
    ila_0 ila_inst( .clk(clk),
                .probe0(reset_n),
                .probe1(clk_100us),
                .probe2(clk_1s),
                .probe3(i_start),
                .probe4(6'd0),
                .probe5(o_n_ct),
                .probe6(o_n_wt),
                .probe7(o_e_ct),
                .probe8(o_e_wt));
                
                

    reg [11:0] cnt_100us;
    reg [24:0] cnt_1s;
    
    always@(posedge clk) begin
        if (!reset_n) begin
            clk_100us <= 1'b1;
            cnt_100us <= 12'd0;
        end
        else begin
            if (cnt_100us == 12'd2500) begin
                clk_100us <= ~clk_100us;
                cnt_100us <= 12'd0;
            end
            else begin
                cnt_100us <= cnt_100us + 1;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            clk_1s <= 1'b1;
            cnt_1s <= 25'd0;
        end
        else begin
            if (cnt_1s == 25'd25000000) begin
                clk_1s <= ~clk_1s;
                cnt_1s <= 25'd0;
            end
            else begin
                cnt_1s <= cnt_1s + 1;
            end
        end
    end

    
endmodule

module traffic_fsm(

    input wire       clk,
    input wire       reset_n,
    input wire       i_start,
    input wire       i_flag,
    output reg [3:0] o_car_traffic,
    output reg [1:0] o_walker_traffic

    );
    
    parameter [3:0] C_GREEN     = 4'b0001;
    parameter [3:0] C_YELLOW    = 4'b0100;
    parameter [3:0] C_LEFT      = 4'b0010;
    parameter [3:0] C_RED       = 4'b1000;
    parameter [3:0] C_NONE      = 4'b0000;
    parameter [1:0] W_RED       = 2'b10;
    parameter [1:0] W_GREEN     = 2'b01;
    parameter [1:0] W_NONE      = 2'b00;
    
    parameter [2:0] SCG = 3'b000;     //cG   
    parameter [2:0] SCY = 3'b001;     //cY    
    parameter [2:0] SCL = 3'b010;     //cL    
    parameter [2:0] SCR = 3'b011;     //cR
    parameter [2:0] SCN = 3'b100;
    parameter [2:0] SWR = 3'b101;
    parameter [2:0] SWG = 3'b110;
    parameter [2:0] SWN = 3'b111;
    
    reg [2:0] c_state;
    reg [2:0] c_next;
    
    reg [2:0] w_state;
    reg [2:0] w_next;

    reg [6:0] r_cycle;
    reg [24:0] r_count;
    reg clk_en;
    
    reg r_start;
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_count <= 25'd0;
            r_start <= 1'b0;
        end
        else begin
            if (i_start) begin
                r_start <= 1'b1;
            end
            else begin
                if (r_start) begin
                    if (r_count == 25'd25000000) begin
                        r_count <= 25'd0;
                        clk_en <= 1'b1;
                    end
                    else begin
                        r_count <= r_count + 25'd1;
                        clk_en <= 1'b0;
                    end
                end
                else begin
                    r_count <= r_count;
                end
            end
        end
    end

    always@(posedge clk) begin
        if (!reset_n) begin
            if (i_flag) begin
                r_cycle <= 7'd1;
            end
            else begin
                r_cycle <= 7'd35;
            end
        end
        else begin
            if (r_start && clk_en) begin
                if (r_cycle == 7'd68) begin
                    r_cycle <= 7'd1;
                end
                else begin
                    r_cycle <= r_cycle + 7'd1;
                end
            end
            else begin
                r_cycle <= r_cycle;
            end
        end
            
    end
    //새로운 clk 써서 sensitivity list에 넣기
    //r_cycle 초기화 생각해보기
    //clk_enable
    

    always@(*) begin    //combination logic은 값이 바뀔 때 바로 값 반영. sequential에 들어가는 값이 바로 바뀜.
        if (!reset_n || !r_start ) begin
            c_next = SCN;
            w_next = SWN;
        end
        
        else begin  
            if (7'd1 <= r_cycle && r_cycle < 7'd21) begin
                c_next = SCG;
                w_next = SWR;
            end
            else if (7'd21 <= r_cycle && r_cycle < 7'd23) begin
                c_next = SCY;
                w_next = SWR;
            end
            else if (7'd23 <= r_cycle && r_cycle < 7'd33) begin
                c_next = SCL;
                w_next = SWR;
            end
            else if  (7'd33 <= r_cycle && r_cycle < 7'd35) begin
                c_next = SCY;
                w_next = SWR;
            end
            else if (7'd35 <= r_cycle && r_cycle < 7'd49) begin
                c_next = SCR;
                w_next = SWG;
            end
            else if (7'd49 <= r_cycle && r_cycle < 7'd55) begin
                c_next = SCR;
                if (r_cycle[0] == 0) begin
                    w_next = SWG;
                end
                else begin
                    w_next = SWN;
                end
            end
            else  begin
                c_next = SCR;
                w_next = SWR;
            end
        end
    end
 
    always@(posedge clk) begin
        c_state <= c_next;
        w_state <= w_next;
    end
 
    always@(*) begin
        case (c_state)
            SCG : o_car_traffic = C_GREEN;
            SCY : o_car_traffic = C_YELLOW;
            SCL : o_car_traffic = C_LEFT;
            SCR : o_car_traffic = C_RED;
            SCN : o_car_traffic = C_NONE;
            default : o_car_traffic = C_NONE;
        endcase
        case (w_state)
            SWR     : o_walker_traffic = W_RED;
            SWG     : o_walker_traffic = W_GREEN;
            SWN     : o_walker_traffic = W_NONE;
            default : o_walker_traffic = W_NONE;
        endcase
    end
    
endmodule
