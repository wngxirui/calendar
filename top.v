`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/15 11:00:23
// Design Name: 
// Module Name: top
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
input                clk_in_p , clk_in_n,
input       [3:0]    sw,                     //四个拨码开关，控制显示内容的转变
input       [1:0]    key,                    //两个独立按键，分别控制数码管的位选和数字的递增
input                rst,                    //全局复位
output      [7:0]    en,                     //数码管使能信号
output      [7:0]    disp1,                  //控制数码管显示
output      [5:0]    led
    );
wire    clk_in;                     //差分时钟信号变单端输出 100MHz
reg     clk_1khz=0;                 //1khz时钟，用于数码管扫描
reg     clk_1hz=0;                  //1hz时钟
reg     clk_2hz=0;                  //2hz时钟
reg     clk_100khz=0;               //100khz，仿真用
reg     [31:0]  count=0;            //分频得到1khz时钟时的计数
reg     [31:0]  count1=0;           //分频得到1hz时钟时的计数
reg     [31:0]  count2=0;           //分频得到100khz时钟时的计数,仿真用 
reg     [31:0]  count3=0;           //分频得到2hz时钟时的计数

//num1，num2，num3，num4,num5,num6,num7,num8分别对应八个数码管上需要显示的数字
wire  [3:0]   num1;                  
wire  [3:0]   num2;
wire  [3:0]   num3;
wire  [3:0]   num4;
wire  [3:0]   num5;
wire  [3:0]   num6;
wire  [3:0]   num7;
wire  [3:0]   num8;
IBUFDS clkin1_buf(
     .O   (clk_in),
     .I   (clk_in_p),
     .IB  (clk_in_n)
);
always@(posedge clk_in)     //时钟分频
begin
    if(count < 49_999)    count <= count + 1;
    else 
        begin
          count <= 0;
          clk_1khz <= ~clk_1khz;
        end
end
always@(posedge clk_1khz)   //时钟分频
begin
    if(count1 < 499)    count1 <= count1 + 1;
    else 
        begin
          count1 <= 0;
          clk_1hz <= ~clk_1hz;
        end
end
always@(posedge clk_in)   //时钟分频
begin
    if(count3 < 24_999_999)    count3 <= count3 + 1;
    else 
        begin
          count3 <= 0;
          clk_2hz <= ~clk_2hz;
        end
end
always@(posedge clk_in)     //时钟分频
begin
    if(count2 < 499)    count2 <= count2 + 1;
    else 
        begin
          count2 <= 0;
          clk_100khz <= ~clk_100khz;
        end
end
cal cal_u(
    .sw(sw),
    .key(key),
    .clk_in(clk_in),
    .rst(rst),
    .led(led),
    .clk_1hz(clk_1hz),
    .clk_2hz(clk_2hz),
    .clk_1khz(clk_1khz),
    .clk_100khz(clk_100khz),
    .num1(num1),
    .num2(num2),
    .num3(num3),
    .num4(num4),
    .num5(num5),
    .num6(num6),
    .num7(num7),
    .num8(num8)
);
display_drive ds(
    .clk_1khz(clk_1khz),
    .num1(num1),
    .num2(num2),
    .num3(num3),
    .num4(num4),
    .num5(num5),
    .num6(num6),
    .num7(num7),
    .num8(num8),
    .en(en),
    .disp1(disp1)
);
endmodule
