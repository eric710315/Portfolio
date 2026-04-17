`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/03 15:56:15
// Design Name: 
// Module Name: bram_contrl
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



module bram_contrl(
    input wire clk,
    input wire rst_n,
    input wire button,
    input wire [31:0] rdata,
    
    output reg [31:0]   wdata,
    output reg [31:0]   addra,
    output reg [3:0]    wea,
    output reg          ena,
    output reg          rsta,
    output wire         clka,
    output reg [31:0]   data0,
    output reg [31:0]   data1,
    output reg [31:0]   data2,
    output reg [31:0]   data3,
    output reg [3:0] r_cnt

    );
    
    
    
    reg r_button;
    reg r_button_delay;
    
    assign clka = clk;
    
    always@(posedge clk) begin
        if(!rst_n) begin
            r_button <= 1'b0;
            r_button_delay <= 1'b0;
        end
        else begin
            if(button) begin
                r_button <= 1'b1;
                r_button_delay <= r_button;
            end
            else begin
                r_button <= r_button;
                r_button_delay <= r_button;
            end
        end
    end
    
    always@(posedge clk) begin
        if(!rst_n) begin
            rsta <= 1'b1;
        end
        else begin
            rsta <= 1'b0;
        end
    end
    
    always@(posedge clk) begin
        if(!rst_n) begin
            ena <= 1'b0;
        end
        else begin
            if (r_button && !r_button_delay) begin
                ena <= 1'b1;
            end
            else begin
                if (r_cnt == 4'd9) begin
                    ena <= 1'b0;
                end
                else begin
                    ena <= ena;
                end
            end
        end
    end
    
    
    
    always@(posedge clk) begin
        if (!rst_n) begin
            r_cnt <= 4'd0;
        end
        else begin
            if (r_cnt == 4'd10) begin
                r_cnt <= 4'd0;
            end
            else if (ena) begin
                r_cnt <= r_cnt + 4'd1;
            end
            else begin
                r_cnt <= r_cnt;
            end
        end
    end
    
    always @(*) begin
        if (ena) begin
            case (r_cnt)
                4'd0 :  begin
                            addra = 32'h00000004;
                            wdata = 32'h0;
                            wea = 4'b0000; 
                        end
                4'd1 :  begin
                            addra = 32'h00000000;
                            wdata = 32'h1050ac8d;
                            wea = 4'b1111; 
                        end
                4'd2 :  begin 
                            addra = 32'h00000004;
                            wdata = 32'h3929dfbb;
                            wea = 4'b1111; 
                        end
                4'd3 :  begin 
                            addra = 32'h00000008;
                            wdata = 32'h00010001;
                            wea = 4'b1111; 
                        end
                4'd4 :  begin 
                            addra = 32'h0000000c;
                            wdata = 32'h10020221;
                            wea = 4'b1111; 
                        end
                4'd5 :  begin 
                            addra = 32'h00000000;
                            wdata = 32'h00000000;
                            wea = 4'b0000; 
                        end
                4'd6 :  begin 
                            addra = 32'h00000004;
                            wdata = 32'h00000000;
                            wea = 4'b0000; 
                        end
                4'd7 :  begin 
                            addra = 32'h00000008;
                            wdata = 32'h00000000;
                            wea = 4'b0000; 
                        end
                4'd8 :  begin 
                            addra = 32'h0000000c;
                            wdata = 32'h00000000;
                            wea = 4'b0000; 
                        end
                default : begin
                            addra = 32'h0; 
                            wdata = 32'h0; 
                            wea = 4'b0000; 
                           end
            endcase
        end 
        else begin
            addra = 32'h0;
            wdata = 32'h0;
            wea = 4'd0;
        end
    end
    

    always@(posedge clk) begin
        if (!rst_n) begin
            data0 <= 32'd0;
            data1 <= 32'd0;
            data2 <= 32'd0;
            data3 <= 32'd0;
        end
        else begin
            if (ena) begin
                case (r_cnt)
                    4'd6 : data0 <= rdata;
                    4'd7 : data1 <= rdata;
                    4'd8 : data2 <= rdata;
                    4'd9 : data3 <= rdata;
                    default : data0 <= data0;
                endcase
            end
            else begin
                data0 <= data0;
            end
        end
    end

endmodule
