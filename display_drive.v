`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 11:37:21
// Design Name: 
// Module Name: display_drive
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


module display_drive(
    input clk_1khz,
    input [3:0] num1,
    input [3:0] num2,
    input [3:0] num3,
    input [3:0] num4,
    input [3:0] num5,
    input [3:0] num6,
    input [3:0] num7,
    input [3:0] num8,
    output reg [7:0] en,
    output reg [7:0] disp1
    );
reg [3:0] num=4'b0;         //接收数码管上要显示的数字
reg [2:0] cnt = 3'b000;       //数码管通断的不同状态
parameter 	s0=4'b0000,
            s1=4'b0001,
            s2=4'b0010,
            s3=4'b0011,
            s4=4'b0100,
            s5=4'b0101,
            s6=4'b0110,
            s7=4'b0111,
            s8=4'b1000,
            s9=4'b1001;
//数码管译码，1表示亮，0表示灭
parameter	seg0=8'b01111110,     //显示数字0
            seg1=8'b00110000,     //显示数字1
            seg2=8'b01101101,     //显示数字2
            seg3=8'b01111001,     //显示数字3
            seg4=8'b00110011,     //显示数字4
            seg5=8'b01011011,     //显示数字5
            seg6=8'b01011111,     //显示数字6
            seg7=8'b01110000,     //显示数字7
            seg8=8'b01111111,     //显示数字8
            seg9=8'b01111011;     //显示数字9
always@(posedge clk_1khz)
begin
    case(cnt)
        3'd0:cnt <= cnt + 1'b1;
        3'd1:cnt <= cnt + 1'b1;
        3'd2:cnt <= cnt + 1'b1;
        3'd3:cnt <= cnt + 1'b1;
        3'd4:cnt <= cnt + 1'b1;
        3'd5:cnt <= cnt + 1'b1;
        3'd6:cnt <= cnt + 1'b1;
        3'd7:cnt <= cnt + 1'b1;
//        default:cnt <= 2'b0; 
    endcase    
end
always@(posedge clk_1khz)
begin
    case(cnt)      
        3'd0:begin en <= 8'b01111111;num <= num2;end
        3'd1:begin en <= 8'b10111111;num <= num3;end
        3'd2:begin en <= 8'b11011111;num <= num4;end
        3'd3:begin en <= 8'b11101111;num <= num5;end
        3'd4:begin en <= 8'b11110111;num <= num6;end
        3'd5:begin en <= 8'b11111011;num <= num7;end
        3'd6:begin en <= 8'b11111101;num <= num8;end
        3'd7:begin en <= 8'b11111110;num <= num1;end
        //default:begin en <= 4'b0111;num <= num1;end
    endcase    
end
always@(posedge clk_1khz)
begin
    case(num)
        s0:disp1<=seg0;
        s1:disp1<=seg1;
        s2:disp1<=seg2;
        s3:disp1<=seg3;
        s4:disp1<=seg4;
        s5:disp1<=seg5;
        s6:disp1<=seg6;
        s7:disp1<=seg7;
        s8:disp1<=seg8;
        s9:disp1<=seg9;
        default:disp1<=seg0;
    endcase    
end
endmodule
