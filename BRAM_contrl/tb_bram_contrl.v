`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/04 20:56:12
// Design Name: 
// Module Name: tb_bram_contrl
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


module tb_bram_contrl();
    
    reg clk;
    reg rst_n;
    reg button;
    reg [31:0] douta;
    
    wire [31:0] dina;
    wire [31:0] addra;
    wire [3:0]  wea;
    wire        clka;
    wire        rsta;
    wire        ena;
    
    parameter [3:0] CLK_PERIOD = 4'd2;
    
    
    always begin
        clk = 1'b1;
        forever #(CLK_PERIOD/4'd2) clk = ~clk;
    end
    
    bram_contrl DUT0(.clk(clk),
                        .rst_n(rst_n),
                        .button(button),
                        .rdata(douta),
                        .wdata(dina),
                        .addra(addra),
                        .wea(wea),
                        .clka(clka),
                        .rsta(rsta),
                        .ena(ena));
    
    initial begin
        rst_n = 1'b0;
        #2;
        rst_n = 1'b1;
        button = 1'b1;
        #2;
        button = 1'b0;
        #2
        douta <= 32'h1050ac8d;
        #2;
        douta <= 32'h3929dfbb;
        #2;
        douta <= 32'h00010001;
        #2;
        douta <= 32'h10020221;
        #1000;
        $finish;
    end
    
endmodule
