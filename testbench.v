`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/16 11:12:51
// Design Name: 
// Module Name: testbench
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


module testbench();
reg                clk_in_p , clk_in_n;
reg       [3:0]    sw;                     //四个拨码开关，控制显示内容的转变
reg       [1:0]    key;                    //两个独立按键，分别控制数码管的位选和数字的递增
reg                rst;                    //全局复位
wire      [7:0]    en;                     //数码管使能信号
wire      [7:0]    disp1;                  //控制数码管显示
wire      [5:0]    led;
top top_sim(
    .clk_in_p(clk_in_p),
    .clk_in_n(clk_in_n),
    .rst(rst),
    .led(led),
    .sw(sw),
    .key(key),
    .en(en),
    .disp1(disp1)
);
initial    begin
    clk_in_p=0;
    clk_in_n=1;
    sw[3:0]=4'b0000;
    key[1:0]=2'b11;
    rst=1;
    #100000
    sw[3:0]=4'b0001;//年月日的设置
    #100000
    key[1:0]=2'b01;//年份千位加一
    #10000000
    key[1:0]=2'b11;
    
    #100000
    sw[3:0]=4'b0011;//时分秒的设置
    #100000
    key[1:0]=2'b01;//小时加一
    #10000000
    key[1:0]=2'b11;
//    #10000000
//    key[1:0]=2'b01;//小时加一
//    #10000000
//    key[1:0]=2'b11;
//    sw[3:0]=4'b1010;//实时显示时间
    #100000
    sw[3:0]=4'b0010;//实时显示时间
    #100000
    sw[3:0]=4'b1110;//实时显示日期
    #100000
    sw[3:0]=4'b1010;//实时显示时间
    
    #100000
    sw[3:0]=4'b1101;//闹钟年月日的设置
    #100000
    key[1:0]=2'b01;//年份千位加一
    #10000000
    key[1:0]=2'b11;
    sw[3:0]=4'b1111;//闹钟时分秒的设置
    #100000
    key[1:0]=2'b01;//小时加一
    #10000000
    key[1:0]=2'b11;  
    #100000
    key[1:0]=2'b01;//小时加一
    #10000000
    key[1:0]=2'b11;
    #100000
    key[1:0]=2'b10;//分钟的设置
    #10000000
    key[1:0]=2'b11;  
    #100000
    key[1:0]=2'b01;//分钟加一
    #10000000
    key[1:0]=2'b11; 
 
    #100000  
    sw[3:0]=4'b1010;//实时显示时间
    #10000000
    sw[3:0]=4'b0010;//关闭闹钟


//    #100000
//    key[1:0]=2'b10;//状态跳转
//    #100000
    
//        #100000
//    key[1:0]=2'b01;


end
always      begin
#5
    clk_in_p=~clk_in_p;
    clk_in_n=~clk_in_n;
end
endmodule
