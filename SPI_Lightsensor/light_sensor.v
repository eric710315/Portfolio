`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/25 11:28:01
// Design Name: 
// Module Name: light_sensor
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


module light_sensor(
    input wire clk,
    input wire reset_n,
    input wire i_start,
    input wire miso,
    input wire [2:0] i_switch,
    
    output reg mosi,
    output reg sck,
    output reg cs,
    output reg [2:0] led
    );
    
    reg [11:0] r_count;
    reg [5:0] r_cycle;
    reg [1:0] r_ch_cnt;
    reg [9:0] r_data;
    reg [9:0] r_data_0;
    reg [9:0] r_data_1;
    reg [9:0] r_data_2;
    reg [4:0] r_ch_sel;
    reg r_start;
    reg sck_f;
    reg sck_r;
    
    parameter [4:0] CH0 = 5'b11100;
    parameter [4:0] CH1 = 5'b11101;
    parameter [4:0] CH2 = 5'b11110;
    parameter [4:0] CH3 = 5'b11111;
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_start <= 1'b0;
        end
        else begin
            if (i_start) begin
                r_start <= 1'b1;
            end
            else begin
                r_start <= r_start;
            end
        end
    end

    always@(posedge clk) begin
        if (!reset_n) begin
            cs <= 1'b1;
        end
        else begin
            if (r_start) begin
                if (r_cycle == 6'd34 && r_count >= 12'd0) begin
                    cs <= 1'b1;
                end
                else begin
                    cs <= 1'b0;
                end
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            sck <= 1'b0;
            r_count <= 12'd0;
            r_cycle <= 6'd0;
            r_ch_cnt <= 2'd0;
            sck_r <= 1'b0;
            sck_f <= 1'b0;
        end
        else begin
            if (!cs) begin
                if (r_count == 12'd2499) begin //50us
                    if (sck) begin
                        sck_f <= 1'b1;
                    end
                    else begin
                        sck_r <= 1'b1;
                    end
                    r_count <= 12'd0;
                    sck <= ~sck;
                    r_cycle <= r_cycle + 6'd1;
                end
                else if (!r_cycle && !r_count) begin
                    sck_f <= 1'b1;
                    r_count <= r_count + 12'd1;
                end
                else begin
                    r_count <= r_count + 12'd1;
                    sck_r <= 1'b0;
                    sck_f <= 1'b0;
                end
            end
            else begin
                if (r_count == 12'd2499) begin
                    r_cycle <= 6'd0;
                    sck_r <= 1'b0;
                    sck_f <= 1'b1;
                    sck <= 1'b0;
                    r_count <= 12'b0;
                    if ( r_ch_cnt == 2'd2) begin
                        r_ch_cnt <= 2'd0;
                    end
                    else begin
                        r_ch_cnt <= r_ch_cnt + 2'd1;
                    end
                end
                else begin
                    r_count <= r_count + 12'd1;
                end
            end
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_ch_sel <= 5'b00000;
        end
        else begin
            if (!cs) begin
                if (sck_f) begin
                    mosi <= r_ch_sel[4];
                    r_ch_sel <= {r_ch_sel[3:0], 1'b0};
                end
                else begin
                    mosi <= mosi;
                end
            end
            else begin
                case (r_ch_cnt)
                    2'd0 : r_ch_sel <= i_switch[0] ?  CH0 : 5'd0;
                    2'd1 : r_ch_sel <= i_switch[1] ?  CH1 : 5'd0;
                    2'd2 : r_ch_sel <= i_switch[2] ?  CH2 : 5'd0;
                    default : r_ch_sel <= 5'd0;
                endcase
            end
        end
    end

    always@(posedge clk) begin
        if (!cs) begin
            if (sck_r) begin
                r_data <= {r_data[8:0], miso};
            end
            else begin
                r_data <= r_data;
            end
        end
        else begin
            r_data <= 10'd0;
        end
    end
    
    always@(posedge clk) begin
        if (!reset_n) begin
            r_data_0 <= 10'd1023;
            r_data_1 <= 10'd1023;
            r_data_2 <= 10'd1023;
        end
        else begin
            if (r_cycle == 6'd33 ) begin
                if (r_ch_cnt == 2'd0) begin
                    r_data_0 <= r_data;
                end
                else if (r_ch_cnt == 2'd1) begin
                    r_data_1 <= r_data;
                end
                else if (r_ch_cnt == 2'd2) begin
                    r_data_2 <= r_data;
                end
                else begin
                    r_data_0 <= r_data_0;
                    r_data_1 <= r_data_1;
                    r_data_2 <= r_data_2;
                end
            end
            else begin
                r_data_0 <= r_data_0;
                r_data_1 <= r_data_1;
                r_data_2 <= r_data_2;
            end
        end
    end
    
    always@(*) begin
        if (!reset_n) begin
            led[0] = 1'b1;
        end
        else begin
            if (r_data_0 == 10'd0) begin
                led[0] = 1'b1;
            end
            else if (r_data_0 < 10'b1100100000) begin
                led[0] = 1'b0;
            end
            else begin
                led[0] = 1'b1;
            end
        end
    end
    
    always@(*) begin
        if (!reset_n) begin
            led[1] = 1'b1;
        end
        else begin
            if (r_data_1 == 10'd0) begin
                led[1] = 1'b1;
            end
            else if (r_data_1 < 10'b1100100000) begin
                led[1] = 1'b0;
            end
            else begin
                led[1] = 1'b1;
            end
        end
    end
    
    always@(*) begin
        if (!reset_n) begin
            led[2] = 1'b1;
        end
        else begin
            if (r_data_2 == 10'd0) begin
                led[2] = 1'b1;
            end
            else if (r_data_2 < 10'b1100100000) begin
                led[2] = 1'b0;
            end
            else begin
                led[2] = 1'b1;
            end
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
    
    
            
    ila_0 ila_inst(
        .clk(clk),
        .probe0(reset_n),
        .probe1(sck),
        .probe2(cs),
        .probe3(r_data),
        .probe4(mosi),
        .probe5(miso),
        .probe6(clk_1us),
        .probe7(clk_10us));
    
endmodule
