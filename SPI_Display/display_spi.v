`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/09 13:47:53
// Design Name: 
// Module Name: display_spi
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


module display_spi(
    input wire clk,
    input wire reset_n,
    
    output reg o_scl,
    output reg o_sda,
    output reg o_res,
    output reg o_cs,
    output reg o_dc

    );
    
    reg [12:0] r_cnt;
    reg [2:0]  r_cycle;
    reg [7:0]  r_data;
    reg [7:0]  r_data_d;
    reg        r_scl_f; 
    reg [22:0] r_dly_110ms_cnt;         //110ms delay count
    reg [4:0]  r_db_cmd_cnt;            //databyte command cont
    reg [10:0]  r_db_cmd_dly_cnt;        //databyte command 100ms delay count
    reg        r_db_en;                 //databyte enable
    reg        r_db_data_en;            //databyte data enable
    reg [6:0]  r_db_col_cnt;            //databyte data colmn count
    reg [2:0]  r_db_page_cnt;           //databyte data page count
    reg        r_flag_cmd;
    reg        r_flag_data;
    reg        r_flag_res;
    reg        r_flag_clr;

    always@(posedge clk) begin
        if (!reset_n) begin
           r_dly_110ms_cnt <= 23'd1;
        end
        else begin
            if (r_dly_110ms_cnt == 23'd5499999) begin 
                r_dly_110ms_cnt <= 23'd0;
            end
            else if (r_dly_110ms_cnt == 23'd0) begin
                r_dly_110ms_cnt <= r_dly_110ms_cnt;
            end
            else begin
                r_dly_110ms_cnt <= r_dly_110ms_cnt + 23'd1;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            o_res <= 1'b0;
        end
        else begin
            if (r_dly_110ms_cnt == 23'd0) begin
                o_res <= 1'b1;
            end
            else begin
                o_res <= 1'b0;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            o_cs <= 1'b1;
        end
        else begin
            if (o_res) begin
                o_cs <= 1'b0;
            end
            else begin
                o_cs <= o_cs;
            end
        end
    end
    
    always@(*) begin
        if (r_flag_clr || r_flag_data) begin
            o_dc = 1'b1;
        end
        else if (r_flag_cmd) begin
            o_dc = 1'b0;
        end
        else begin
            o_dc = 1'b0;
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            o_scl <= 1'b0;
            r_cnt <= 13'd0;
            r_cycle <= 3'd0;
            r_scl_f <= 1'b0;
        end
        else begin
            if (!o_cs) begin
                if (r_cnt == 13'd6249) begin 
                    r_cnt <= 13'd0;
                    o_scl <= ~o_scl;
                    if (o_scl) begin
                        r_scl_f <= 1'b1;
                        if (r_cycle == 3'd7) begin
                            r_cycle <= 3'd0;
                        end
                        else begin
                            r_cycle <= r_cycle + 3'd1;
                        end
                    end
                    else begin
                        r_scl_f <= 1'b0;
                    end
                end
                else begin
                    r_cnt <= r_cnt + 13'd1;
                    r_scl_f <= 1'b0;
                end
            end
            else begin
                o_scl <= o_scl;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_db_cmd_cnt <= 5'd0;
            r_db_cmd_dly_cnt <= 11'd0;
        end
        else begin
            if ((r_cnt == 13'd6249) && o_scl && (r_cycle == 3'd7)) begin
                if (r_db_cmd_cnt == 5'd23) begin
                    if (r_db_cmd_dly_cnt == 11'd1023) begin
                        r_db_cmd_cnt <= r_db_cmd_cnt + 5'd1;
                        r_db_en <= 1'b1;
                    end
                    else begin
                        r_db_cmd_dly_cnt <= r_db_cmd_dly_cnt + 11'd1;
                    end
                end
                else if (r_db_cmd_cnt == 5'd27) begin
                    if (r_db_cmd_dly_cnt == 11'd50) begin
                        r_db_cmd_cnt <= r_db_cmd_cnt + 5'd1;
                        r_db_en <= 1'b1;
                    end
                    else begin
                        r_db_cmd_dly_cnt <= r_db_cmd_dly_cnt + 11'd1;
                    end
                end
                else if (r_db_cmd_cnt == 5'd28) begin
                    r_db_cmd_cnt <= r_db_cmd_cnt;
                end
                else begin
                    r_db_cmd_cnt <= r_db_cmd_cnt + 5'd1;
                    r_db_en <= 1'b1;
                end
            end
            else begin
                r_db_en <= 1'b0;
            end
        end
    end
    
    always@(*) begin
        if (r_db_cmd_cnt == 5'd0) begin
            r_flag_cmd = 1'b0;
            r_flag_data = 1'b0;
            r_flag_data = 1'b0;
        end
        if ((r_db_cmd_cnt >= 5'd1 && r_db_cmd_cnt <= 5'd22) || (r_db_cmd_cnt > 5'd23 && r_db_cmd_cnt <= 5'd26)) begin
            r_flag_cmd = 1'b1;
            r_flag_data = 1'b0;
            r_flag_clr = 1'b0;
        end
        else if (r_db_cmd_cnt == 5'd23 ) begin
            r_flag_cmd = 1'b0;
            r_flag_data = 1'b0;
            r_flag_clr = 1'b1;
        end
        else if(r_db_cmd_cnt == 5'd28) begin
            r_flag_cmd = 1'b0;
            r_flag_data = 1'b1;
            r_flag_clr = 1'b0;
        end
        else begin
            r_flag_cmd = 1'b0;
            r_flag_data = 1'b0;
            r_flag_clr = 1'b0;
        end
    end
    
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_db_col_cnt <= 7'd0;
            r_db_page_cnt <= 3'd0;
        end
        else begin
            if (r_flag_data) begin
                if ((r_cnt == 13'd6249) && o_scl && (r_cycle == 3'd7)) begin
                    r_db_data_en <= 1'b1;
                    if (r_db_col_cnt == 7'd127) begin
                        r_db_col_cnt <= 7'd0;
                        if (r_db_page_cnt == 3'd7) begin
                            r_db_page_cnt <= 3'd0;
                        end
                        else begin
                            r_db_page_cnt <= r_db_page_cnt + 3'd1;
                        end
                    end
                    else begin
                        r_db_col_cnt <= r_db_col_cnt + 7'd1;
                    end
                end
                else begin
                    r_db_data_en <= 1'b0;
                    r_db_col_cnt <= r_db_col_cnt;
                    r_db_page_cnt <= r_db_page_cnt;
                end
            end
            else begin
                r_db_col_cnt <= 7'd0;
                r_db_page_cnt <= 3'd0;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin 
            r_data_d <= 8'd0;
        end
        else begin
            if (r_scl_f) begin
                if (r_db_en || r_db_data_en) begin
                    o_sda <= r_data[7];
                    r_data_d <= {r_data[6:0], 1'b0};
                end
                else begin
                    o_sda <= r_data_d[7];
                    r_data_d <= {r_data_d[6:0], 1'b0};
                end
            end
            else begin
                r_data_d <= r_data_d;
            end
        end
    end
    
    always@(*) begin
        if (r_flag_cmd) begin
            case (r_db_cmd_cnt)
                5'd1  : r_data = 8'hAE;
                5'd2  : r_data = 8'hD5;
                5'd3  : r_data = 8'h90;
                5'd4  : r_data = 8'hA8;
                5'd5  : r_data = 8'h3F;
                5'd6  : r_data = 8'hD3;
                5'd7  : r_data = 8'h00;
                5'd8  : r_data = 8'h40;
                5'd9  : r_data = 8'hA1;
                5'd10 : r_data = 8'hC8;
                5'd11 : r_data = 8'hDA;
                5'd12 : r_data = 8'h12;
                5'd13 : r_data = 8'h81;
                5'd14 : r_data = 8'hD0;
                5'd15 : r_data = 8'hD9;
                5'd16 : r_data = 8'h22;
                5'd17 : r_data = 8'hD8;
                5'd18 : r_data = 8'h30;
                5'd19 : r_data = 8'hA4;
                5'd20 : r_data = 8'hA6;
                5'd21 : r_data = 8'h20;
                5'd22 : r_data = 8'h00;
                5'd24 : r_data = 8'h8D;
                5'd25 : r_data = 8'h14;
                5'd26 : r_data = 8'hAF;
                default : r_data = 8'h00;
            endcase
        end
        else if (r_flag_clr) begin
            r_data = 8'h00;
        end
        else if (r_flag_data && !r_db_page_cnt) begin
            case (r_db_col_cnt)
                7'd0  : r_data = 8'h7F;
                7'd1  : r_data = 8'h08;
                7'd2  : r_data = 8'h08;
                7'd3  : r_data = 8'h08;
                7'd4  : r_data = 8'h7F;
                7'd5  : r_data = 8'h00;
                7'd6  : r_data = 8'h7F;
                7'd7  : r_data = 8'h49;
                7'd8  : r_data = 8'h49;
                7'd9  : r_data = 8'h49;
                7'd10 : r_data = 8'h41;
                7'd11 : r_data = 8'h00;
                7'd12 : r_data = 8'h7F;
                7'd13 : r_data = 8'h40;
                7'd14 : r_data = 8'h40;
                7'd15 : r_data = 8'h40;
                7'd16 : r_data = 8'h40;
                7'd17 : r_data = 8'h00;
                7'd18 : r_data = 8'h7F;
                7'd19 : r_data = 8'h40;
                7'd20 : r_data = 8'h40;
                7'd21 : r_data = 8'h40;
                7'd22 : r_data = 8'h40;
                7'd23 : r_data = 8'h00;
                7'd24 : r_data = 8'h3E;
                7'd25 : r_data = 8'h41;
                7'd26 : r_data = 8'h41;
                7'd27 : r_data = 8'h41;
                7'd28 : r_data = 8'h3E;
                7'd29 : r_data = 8'h00;
                7'd30 : r_data = 8'h00;
                7'd31 : r_data = 8'h00;
                7'd32 : r_data = 8'h00;
                7'd33 : r_data = 8'h00;
                7'd34 : r_data = 8'h00;
                7'd35 : r_data = 8'h7F;
                7'd36 : r_data = 8'h20;
                7'd37 : r_data = 8'h18;
                7'd38 : r_data = 8'h20;
                7'd39 : r_data = 8'h7F;
                7'd40 : r_data = 8'h00;
                7'd41 : r_data = 8'h3E;
                7'd42 : r_data = 8'h41;
                7'd43 : r_data = 8'h41;
                7'd44 : r_data = 8'h41;
                7'd45 : r_data = 8'h3E;
                7'd46 : r_data = 8'h00;
                7'd47 : r_data = 8'h7F;
                7'd48 : r_data = 8'h09;
                7'd49 : r_data = 8'h19;
                7'd50 : r_data = 8'h29;
                7'd51 : r_data = 8'h46;
                7'd52 : r_data = 8'h00;
                7'd53 : r_data = 8'h7F;
                7'd54 : r_data = 8'h40;
                7'd55 : r_data = 8'h40;
                7'd56 : r_data = 8'h40;
                7'd57 : r_data = 8'h40;
                7'd58 : r_data = 8'h00;
                7'd59 : r_data = 8'h7F;
                7'd60 : r_data = 8'h41;
                7'd61 : r_data = 8'h41;
                7'd62 : r_data = 8'h22;
                7'd63 : r_data = 8'h1C;
                default : r_data = 8'd0;
            endcase
        end
        else begin
            r_data = 8'h00;
        end
    end
    reg clk_10us;
    reg clk_1us;
    reg [8:0] clk_10us_cnt;
    reg [5:0] clk_1us_cnt;
    always@(posedge clk) begin
        if (!reset_n) begin
            clk_10us <= 1'b0;
        end
        else begin
            if (clk_10us_cnt == 9'd499) begin
                clk_10us_cnt <= 9'd0;
                clk_10us <= ~clk_10us;
            end
            else begin
                clk_10us_cnt <= clk_10us_cnt + 9'd1;
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            clk_1us <= 1'b0;
        end
        else begin
            if (clk_1us_cnt == 6'd49) begin
                clk_1us_cnt <= 6'd0;
                clk_1us <= ~clk_1us;
            end
            else begin
                clk_1us_cnt <= clk_1us_cnt + 6'd1;
            end
        end
    end
    ila_0 ila_inst( .clk(clk),
                    .probe0(o_sda),
                    .probe1(o_scl),
                    .probe2(o_cs),
                    .probe3(o_dc),
                    .probe4(o_res),
                    .probe5(r_db_col_cnt),
                    .probe6(r_data),
                    .probe7(r_db_cmd_cnt),
                    .probe8(r_cycle),
                    .probe9(clk_10us),
                    .probe10(r_scl_f),
                    .probe11(r_data_d),
                    .probe12(r_db_page_cnt));
    
endmodule