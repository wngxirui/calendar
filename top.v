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
input       [3:0]    sw,                     //�ĸ����뿪�أ�������ʾ���ݵ�ת��
input       [1:0]    key,                    //���������������ֱ��������ܵ�λѡ�����ֵĵ���
input                rst,                    //ȫ�ָ�λ
output      [7:0]    en,                     //�����ʹ���ź�
output      [7:0]    disp1,                  //�����������ʾ
output      [5:0]    led
    );
wire    clk_in;                     //���ʱ���źű䵥����� 100MHz
reg     clk_1khz=0;                 //1khzʱ�ӣ����������ɨ��
reg     clk_1hz=0;                  //1hzʱ��
reg     clk_2hz=0;                  //2hzʱ��
reg     clk_100khz=0;               //100khz��������
reg     [31:0]  count=0;            //��Ƶ�õ�1khzʱ��ʱ�ļ���
reg     [31:0]  count1=0;           //��Ƶ�õ�1hzʱ��ʱ�ļ���
reg     [31:0]  count2=0;           //��Ƶ�õ�100khzʱ��ʱ�ļ���,������ 
reg     [31:0]  count3=0;           //��Ƶ�õ�2hzʱ��ʱ�ļ���

//num1��num2��num3��num4,num5,num6,num7,num8�ֱ��Ӧ�˸����������Ҫ��ʾ������
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
always@(posedge clk_in)     //ʱ�ӷ�Ƶ
begin
    if(count < 49_999)    count <= count + 1;
    else 
        begin
          count <= 0;
          clk_1khz <= ~clk_1khz;
        end
end
always@(posedge clk_1khz)   //ʱ�ӷ�Ƶ
begin
    if(count1 < 499)    count1 <= count1 + 1;
    else 
        begin
          count1 <= 0;
          clk_1hz <= ~clk_1hz;
        end
end
always@(posedge clk_in)   //ʱ�ӷ�Ƶ
begin
    if(count3 < 24_999_999)    count3 <= count3 + 1;
    else 
        begin
          count3 <= 0;
          clk_2hz <= ~clk_2hz;
        end
end
always@(posedge clk_in)     //ʱ�ӷ�Ƶ
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
