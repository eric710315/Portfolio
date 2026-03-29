`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/03/24 13:09:03
// Design Name: 
// Module Name: tb_APBmst
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


module tb_APBmst();
    reg pclk;
    reg prst_n;
    reg psel;
    reg pwrite;
    reg penable;
    reg [31:0] pwdata;
    reg [31:0] paddr;
    
    wire pready;
    wire pslverr;
    wire [31:0] prdata;
    
    parameter [3:0] CLK_PERIOD = 4'd10;
    
    always begin
        pclk = 1'b1;
        forever #(CLK_PERIOD/4'd2) pclk = ~pclk;
    end
    
    APBslv DUT(.pclk(pclk),
                .prst_n(prst_n),
                .psel(psel),
                .pwrite(pwrite),
                .penable(penable),
                .pwdata(pwdata),
                .paddr(paddr),
                .pready(pready),
                .prdata(prdata),
                .pslverr(pslverr));
    
    initial begin
        prst_n <= 1'b0;
        #10
        prst_n <= 1'b1;
        #10
        psel <= 1'b1;
        penable <= 1'b0;
        pwrite <= 1'b1;
        pwdata <= 32'h12345678;
        paddr <= 32'h10002024;
        #10
        penable <= 1'b1;
        #10
        
        penable <= 1'b0;
        pwrite <= 1'b0;
        paddr <= 32'h10002024;
        #10
        penable <= 1'b1;
        #10
        
        penable <= 1'b0;
        pwrite <= 1'b1;
        paddr <= 32'h10002024;
        pwdata <= 32'h87654321;
        #10
        penable <= 1'b1;
        #10
        
        penable <= 1'b0;
        pwrite <= 1'b0;
        paddr <= 32'h10002024;
        #10
        penable <= 1'b1;
        #10
        psel <= 1'b0;
        #20
        
        psel <= 1'b1;
        penable <= 1'b0;
        pwrite <= 1'b1;
        pwdata <= 32'h14356002;
        paddr <= 32'h10002023;
        #10
        penable <= 1'b1;
        #10
        psel <= 1'b0;
        #20
        
        psel <= 1'b1;
        penable <= 1'b0;
        pwrite <= 1'b0;
        paddr <= 32'h10002011;
        #10
        penable <= 1'b1;
        #10
        psel <= 1'b0;
        #20
        $finish;
        
    end
    
    
endmodule
