`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/15 11:12:19
// Design Name: 
// Module Name: cal
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


module cal(
input           [3:0]       sw,
input           [1:0]       key,
input                       clk_in,
input                       rst,
input                       clk_1hz,
input                       clk_2hz,
input                       clk_1khz,
input                       clk_100khz,//仿真用
output  reg     [5:0]       led=6'b111111,
output  reg     [3:0]       num1,num2,num3,num4,num5,num6,num7,num8
);
reg [2:0]   content=0,next_con;   //控制数码管显示内容，即年月日，时分秒，闹钟之间的切换
reg [3:0]   position=0,next_pos;       //控制对哪个数码管进行加一操作
reg [11:0]  year=1;           //年
reg [4:0]   mon=1;            //月
reg [4:0]   day=1;            //日
reg [4:0]   hour=0;           //小时
reg [5:0]   min=0;            //分钟
reg [5:0]   sec=0;            //秒

reg [11:0]  year_set=1;           //设置界面年
reg [4:0]   mon_set=1;            //设置界面月
reg [4:0]   day_set=1;            //设置界面日
reg [4:0]   hour_set=0;           //设置界面小时
reg [5:0]   min_set=0;            //设置界面分钟
reg [5:0]   sec_set=0;            //设置界面秒
reg [3:0]   out_year1=0,out_year2=0,out_year3=0,out_year4=1;    //当前年的千位、百位、十位、个位数字 

reg [3:0]   ala_year1=0,ala_year2=0,ala_year3=0,ala_year4=1;    //闹钟年的千位、百位、十位、个位数字       
reg [11:0]  ala_year=1;            //闹钟年
reg [4:0]   ala_mon=1;            //闹钟月
reg [4:0]   ala_day=1;            //闹钟日
reg [4:0]   ala_hour=0;           //闹钟小时
reg [5:0]   ala_min=0;            //闹钟分钟
reg [5:0]   ala_sec=0;            //闹钟秒

reg [4:0]   date=0;               //自动计时时不同月份的天数
reg [4:0]   date_set=0;           //设置当前日期时不同月份的天数
reg [4:0]   date_ala=0;           //设置闹钟日期时不同月份的天数




reg cnt_full0,cnt_full1;                //为1表示计数到指定值           
reg key_flag0,key_flag1;                //为1表示按键被按下
reg [17:0] cnt0,cnt1;                   //按键消抖时的计数，计数到指定值表示按键确实被按下

reg idle_hour=0,idle_year=0;            //为0表示还未设置时间/日期，默认0001年1月1日0时0分0秒
reg idle_hour1=0,idle_year1=0;          //为1表示进入时间/日期的显示状态，此时将设置的时间/日期赋给实时变化的量来计数
reg flag_int=0;                     //到达整点
reg flag_ala=0;                     //到达闹钟时刻

reg flag_hour=0;           //计满24小时

parameter  s0=3'b000,           //IDLE
            s1=3'b001,           //年月日的设置
            s2=3'b011,           //时分秒的设置 
            s3=3'b010,           //时分秒的显示 
            s4=3'b110,           //年月日的显示 
            s5=3'b111,          //闹钟时分秒的设置
            s6=3'b101;          //闹钟年月日的设置
            
parameter 	f0=3'b000,
			f1=3'b001,
			f2=3'b010,
			f3=3'b011,
			f4=3'b100,
			f5=3'b101,
			f6=3'b110,
			f7=3'b111;
			
//key[1]的消抖
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt1<=18'b0;
else if (key[1]==0) cnt1<=cnt1+1'b1;        //按下开始计数
else cnt1<=18'b0;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt_full1<=1'b0;
else if(cnt1==24999)
cnt_full1<=1'b1; // 计满说明按键确实被按下，当检测到 cnt 第一次等于 24999时，该标志则被置为高电平，此后cnt_full恒为0
else if (key[1]==1) cnt_full1<=1'b0;
else cnt_full1<=cnt_full1;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) key_flag1<=1'b0;
else if (cnt1==24999&&cnt_full1==1'b0)  //低电平够久，按键确实被按下且保证是第一次，保证后面按一次计数加一
key_flag1=1'b1;             //表示key[1]按下
else key_flag1=1'b0;
end


//key[0]的消抖
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt0<=18'b0;
else if (key[0]==0) cnt0<=cnt0+1'b1;        //从按下开始计数
else cnt0<=18'b0;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt_full0<=1'b0;
else if(cnt0==24999)
cnt_full0<=1'b1;
else if (key[0]==1) cnt_full0<=1'b0;
else cnt_full0<=cnt_full0;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) key_flag0<=1'b0;
else if (cnt0==24999&&cnt_full0==1'b0)
key_flag0=1'b1;             //表示key[0]按下
else key_flag0=1'b0;
end

//always@(posedge clk_100khz or negedge rst)  begin//仿真用
always@(posedge clk_1hz or negedge rst)  begin
//always@(posedge clk_1khz or negedge rst)  begin
    if(!rst) begin
        idle_hour<=0;flag_int<=0;
        hour<=0;min<=0;sec<=0;
    end
    else    begin
    if((idle_hour==0)&&(idle_hour1==1))  begin          //还未进行赋值操作则赋初值
        idle_hour<=1;
        hour<=hour_set; min<=min_set; sec<=sec_set;
    end
    else if((idle_hour==1)&&(idle_hour1==1))           begin    //赋值后在此基础上计数
        if(sec==59) begin
            sec<=0;
            if(min==59) begin
                min<=0;flag_int<=1;             //到达整点
                if(hour==23) begin
                    hour<=0;flag_hour<=1;       //flag_hour为进位信号，表示天数增加1
                end
                else        begin
                    hour<=hour+1;
                end
            end
            else        begin
                min<=min+1;flag_int<=0;     //整点信号清零
            end
        end
        else        begin
            sec<=sec+1;flag_hour<=0;
        end
      end
  end
end

always@(posedge clk_1hz or negedge rst)  begin
//always@(posedge clk_in or negedge rst)  begin       //仿真用
    if(!rst) begin
        idle_year<=0;
        year<=1;mon<=1;day<=1;
    end
    else    begin
        if((idle_year==0)&&(idle_year1==1))  begin                      //还未进行赋值操作则赋初值
            idle_year<=1;
            year<= out_year1*1000+out_year2*100+out_year3*10+out_year4;     
            mon<=mon_set;
            day<=day_set;
        end 
        else if((idle_year==1)&&(idle_year1==1))    begin               //赋值后在此基础上计数
        case(mon)
            1:date<=31;
            2:begin
                if((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) date<=29;   //闰年
                else    date<=28; 
            end
            3:date<=31;
            4:date<=30;
            5:date<=31; 
            6:date<=30;
            7:date<=31;
            8:date<=31; 
            9:date<=30;
            10:date<=31;
            11:date<=30; 
            12:date<=31;
            default:date<=30;
        endcase
        if(flag_hour)    begin
            if(day==date)       begin
            day<=1;
            if(mon==12) begin
                mon<=1;
                year<=year+1;
            end
            else        begin
                mon<=mon+1;
            end
            end
        else                begin
            day<=day+1;
        end
        end

        end
   end  



end

always@(posedge clk_in or negedge rst)begin
if(!rst) content<=s0;
else     content<=next_con;
end

always@(posedge clk_in or negedge rst)begin
if(!rst) position<=f0;
else     position<=next_pos;
end

always@(posedge clk_in or negedge rst)  begin
    if(!rst)        begin
        num1<=0;num2<=0;num3<=0;num4<=0;num5<=0;num6<=0;num7<=0;num8<=0;
        out_year1<=0;out_year2<=0;out_year3<=0;out_year4<=1;
        year_set<=1;mon_set<=1;day_set<=1;hour_set<=0;min_set<=0;sec_set<=0;
        ala_year1<=0;ala_year2<=0;ala_year3<=0;ala_year4<=1;
        ala_year<=1;ala_mon<=1;ala_day<=1;ala_hour<=0;ala_min<=0;ala_sec<=0;
        idle_hour1<=0;idle_year1<=0;
    end
    else  begin           //年月日，时分秒的设置
        ala_year<=ala_year1*1000+ala_year2*100+ala_year3*10+ala_year4;
        case(content)
            s0: begin
                if(sw[2:0]==3'b001)          next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3;
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;              
            end
            s1: begin               //年月日的设置
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3;
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;   
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //按下key[0]到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(out_year1==9)  out_year1<=0;
                            else         out_year1<=out_year1+1;                    //年份千位加一，范围为0-9                        
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(out_year2==9)  out_year2<=0;
                            else         out_year2<=out_year2+1;                //年份百位加一，范围为0-9              
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f3;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(out_year3==9)  out_year3<=0;
                            else         out_year3<=out_year3+1;                //年份十位加一，范围为0-9              
                        end                       
                    end                                        
                    f3: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f4;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f3;                           
                            if(out_year4==9)  out_year4<=0;
                            else         out_year4<=out_year4+1;                     //年份个位位加一，范围为0-9         
                        end                       
                    end
                    f4: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f5;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f4;                           
                            if(mon_set==12)  mon_set<=1;
                            else         mon_set<=mon_set+1;                        //月份的控制，范围1-12    
                        end                       
                    end
                    f5: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f5;
                            year_set<=out_year1*1000+out_year2*100+out_year3*10+out_year4;//当前的年份
                            case(mon_set)       //通过case月份，从而得到当前月的天数
                            1:date_set<=31;
                            2:begin             //如果是二月份则需判断是否为闰年
                                if((year_set % 4 == 0 && year_set % 100 != 0) || (year_set % 400 == 0)) date_set<=29;
                                else    date_set<=28; 
                            end
                            3:date_set<=31;
                            4:date_set<=30;
                            5:date_set<=31; 
                            6:date_set<=30;
                            7:date_set<=31;
                            8:date_set<=31; 
                            9:date_set<=30;
                            10:date_set<=31;
                            11:date_set<=30; 
                            12:date_set<=31;
                            default:date_set<=30;
                        endcase                           
                        if(day_set==date_set)  day_set<=1;  //日期的控制
                        else         day_set<=day_set+1;                            
                        end                       
                    end
                    default:next_pos<=f0;                                                                                             
                endcase
                num1<=out_year1;num2<=out_year2;num3<=out_year3;num4<=out_year4;        //送给数码管显示
                num5<=mon_set / 4'd10 % 4'd10;
                num6<=mon_set % 4'd10;
                num7<=day_set / 4'd10 % 4'd10;
                num8<=day_set % 4'd10;
            end
            s2: begin           //时分秒的设置
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b010)     next_con<=s3;
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;   
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(hour_set==23)  hour_set<=0;
                            else         hour_set<=hour_set+1;              //小时的设置，范围0-23              
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(min_set==59)  min_set<=0;
                            else         min_set<=min_set+1;                 //分钟的设置，范围0-59           
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(sec_set==59)  sec_set<=0;
                            else         sec_set<=sec_set+1;              //秒钟的设置，范围0-59               
                        end                       
                    end                                        
                    default:next_pos<=f0;                                                                                                    
                endcase  //case position结束
                num1<=hour_set / 4'd10 % 4'd10;             //送数码管显示
                num2<=hour_set % 4'd10;
                num3<=min_set / 4'd10 % 4'd10;
                num4<=min_set % 4'd10;
                num5<=sec_set / 4'd10 % 4'd10;
                num6<=sec_set % 4'd10; 
                num7<=0;
                num8<=0;                           
            end         //s2结束   
            s3: begin           //时分秒的实时显示
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b110)     next_con<=s4; 
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;  
                idle_hour1<=1; 
                num1<=hour / 4'd10 % 4'd10;
                num2<=hour % 4'd10;
                num3<=min / 4'd10 % 4'd10;
                num4<=min % 4'd10;
                num5<=sec / 4'd10 % 4'd10;
                num6<=sec % 4'd10; 
                num7<=0;
                num8<=0;                   
            end     //s3结束
            s4: begin           //年月日的实时显示
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3; 
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;  
                idle_year1<=1;
                num1<=year / 10'd1000 % 4'd10;
                num2<=year / 7'd100 % 4'd10;
                num3<=year / 4'd10 % 4'd10;
                num4<=year % 4'd10;
                num5<=mon / 4'd10 % 4'd10;
                num6<=mon % 4'd10;
                num7<=day / 4'd10 % 4'd10;
                num8<=day % 4'd10;                     
            end  //s4结束
            s5: begin           //闹钟时分秒的设置
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3; 
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b101)     next_con<=s6;  
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(ala_hour==23)  ala_hour<=0;
                            else         ala_hour<=ala_hour+1;                            
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(ala_min==59)  ala_min<=0;
                            else         ala_min<=ala_min+1;                            
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(ala_sec==59)  ala_sec<=0;
                            else         ala_sec<=ala_sec+1;                            
                        end                       
                    end                                        
                    default:next_pos<=f0;                                                                                                    
                endcase  //case position结束
                num1<=ala_hour / 4'd10 % 4'd10;
                num2<=ala_hour % 4'd10;
                num3<=ala_min / 4'd10 % 4'd10;
                num4<=ala_min % 4'd10;
                num5<=ala_sec / 4'd10 % 4'd10;
                num6<=ala_sec % 4'd10; 
                num7<=0;
                num8<=0; 
            end             //s5结束
            s6: begin               //闹钟年月日的设置
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3; 
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;    
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(ala_year1==9)  ala_year1<=0;
                            else         ala_year1<=ala_year1+1;                            
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(ala_year2==9)  ala_year2<=0;
                            else         ala_year2<=ala_year2+1;                            
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f3;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(ala_year3==9)  ala_year3<=0;
                            else         ala_year3<=ala_year3+1;                            
                        end                       
                    end                                        
                    f3: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f4;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f3;                           
                            if(ala_year4==9)  ala_year4<=0;
                            else         ala_year4<=ala_year4+1;                            
                        end 
                                              
                    end
                    f4: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f5;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f4;                           
                            if(ala_mon==12)  ala_mon<=1;
                            else         ala_mon<=ala_mon+1;                            
                        end                       
                    end
                    f5: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //到下一个状态
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f5;                         
                            case(ala_mon)
                            1:date_ala<=31;
                            2:begin
                                if((ala_year % 4 == 0 && ala_year % 100 != 0) || (ala_year % 400 == 0)) date_ala<=29;
                                else    date_ala<=28; 
                            end
                            3:date_ala<=31;
                            4:date_ala<=30;
                            5:date_ala<=31; 
                            6:date_ala<=30;
                            7:date_ala<=31;
                            8:date_ala<=31; 
                            9:date_ala<=30;
                            10:date_ala<=31;
                            11:date_ala<=30; 
                            12:date_ala<=31;
                            default:date_ala<=30;
                        endcase                           
                        if(ala_day==date_ala)  ala_day<=1;
                        else         ala_day<=ala_day+1;                            
                        end                       
                    end
                    default:next_pos<=f0;                                                                                             
                endcase
                num1<=ala_year1;num2<=ala_year2;num3<=ala_year3;num4<=ala_year4;
                num5<=ala_mon / 4'd10 % 4'd10;
                num6<=ala_mon % 4'd10;
                num7<=ala_day / 4'd10 % 4'd10;
                num8<=ala_day % 4'd10;
            end            //s6结束           
            default:next_con<=s0;   
        endcase         //case content结束
    end             //else结束 
end

//always@(posedge clk_in or negedge rst)  begin//仿真用
always@(posedge clk_2hz or negedge rst)  begin
    if(!rst)    begin
        led<=6'b111_111;
        flag_ala<=0;
    end
    else        begin
        if( (sw[3])&&(ala_year==year)&&(ala_mon==mon)&&(ala_day==day)&&(ala_hour==hour)&&(ala_min==min)&&(ala_sec==sec) )   begin
             flag_ala<=1;           //sw[3]为1则开启闹钟功能，反之关闭
        end
        if(flag_int)  begin         //到达整点
            led<=~led;         
        end
        else if(flag_ala)    begin  //到达所设闹钟时刻
            led<=~led;
            if(!sw[3]) begin
                flag_ala<=0;
            end
        end
        else    led<=6'b111_111;
    end
end

  
endmodule
