`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/26 13:08:30
// Design Name: 
// Module Name: tb_light_sensor
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


module tb_light_sensor();

    reg clk;
    reg rst_n;
    reg start;
    reg miso;
    reg [2:0] switch;
    
    wire mosi;
    wire sck;
    wire cs;
    
    
    parameter CLK_PERIOD = 2'd2;
    
    light_sensor DUT ( 
            .clk(clk),
            .reset_n(rst_n),
            .i_start(start),
            .i_switch(switch),
            .miso(miso),
            .mosi(mosi),
            .sck(sck),
            .cs(cs));
    
    always begin
        clk = 1'b1;
        forever #(CLK_PERIOD/4'd2) clk = ~clk;
    end
    
    initial begin
        miso = 1'b1;
        switch = 3'b100;
        rst_n = 1'b0;
        #2
        rst_n = 1'b1;
        #2
        start = 1'b1;
        #6
        start = 1'b0;
        #1000
        $finish;
    end
    
endmodule
