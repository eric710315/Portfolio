`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/20 10:36:49
// Design Name: 
// Module Name: APBslv
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


module APBslv(
    input wire          prst_n,
    input wire          pclk,
    input wire [31:0]   paddr,
    input wire          pwrite,
    input wire          psel,
    input wire          penable,
    input wire [31:0]   pwdata,
    
    output reg [31:0]   prdata,
    output reg          pready,
    output reg          pslverr

    );
    
    reg [7:0] registry [64:0];

    
    always@(posedge pclk) begin
        if (!prst_n) begin
            pready <= 1'b0;
        end
        else begin
            if (psel && !penable) begin
                pready <= 1'b1;
            end
            else begin
                pready <= 1'b0;
            end
        end
    end
    
    always@(posedge pclk) begin
        if (!prst_n) begin
            prdata <= 32'd0;
            pslverr <= 1'b0;
        end
        else begin
            if (psel && !penable) begin
                if (pwrite) begin
                    registry[paddr[7:0]]        <= pwdata[7:0];
                    registry[paddr[7:0]+8'h1]   <= pwdata[15:8];
                    registry[paddr[7:0]+8'h2]   <= pwdata[23:16];
                    registry[paddr[7:0]+8'h3]   <= pwdata[31:24];
                end
                else begin
                    prdata <= {registry[paddr[7:0]+8'h3], registry[paddr[7:0]+8'h2], registry[paddr[7:0]+8'h1], registry[paddr[7:0]]};
                end
            end
            else begin
                prdata <= prdata;
                pslverr <= 1'b0;
            end
        end
    end
    
    always@(posedge pclk) begin
        if (!prst_n) begin
            pslverr <= 1'b0;
        end
        else begin
            if (psel && !penable) begin
                if (!paddr[1:0]) begin
                    pslverr <= 1'b0;
                end
                else begin
                    pslverr <= 1'b1;
                end
            end
            else begin
                pslverr <= 1'b0;
            end
        end
    end
    
endmodule
