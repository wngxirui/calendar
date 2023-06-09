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
input                       clk_100khz,//������
output  reg     [5:0]       led=6'b111111,
output  reg     [3:0]       num1,num2,num3,num4,num5,num6,num7,num8
);
reg [2:0]   content=0,next_con;   //�����������ʾ���ݣ��������գ�ʱ���룬����֮����л�
reg [3:0]   position=0,next_pos;       //���ƶ��ĸ�����ܽ��м�һ����
reg [11:0]  year=1;           //��
reg [4:0]   mon=1;            //��
reg [4:0]   day=1;            //��
reg [4:0]   hour=0;           //Сʱ
reg [5:0]   min=0;            //����
reg [5:0]   sec=0;            //��

reg [11:0]  year_set=1;           //���ý�����
reg [4:0]   mon_set=1;            //���ý�����
reg [4:0]   day_set=1;            //���ý�����
reg [4:0]   hour_set=0;           //���ý���Сʱ
reg [5:0]   min_set=0;            //���ý������
reg [5:0]   sec_set=0;            //���ý�����
reg [3:0]   out_year1=0,out_year2=0,out_year3=0,out_year4=1;    //��ǰ���ǧλ����λ��ʮλ����λ���� 

reg [3:0]   ala_year1=0,ala_year2=0,ala_year3=0,ala_year4=1;    //�������ǧλ����λ��ʮλ����λ����       
reg [11:0]  ala_year=1;            //������
reg [4:0]   ala_mon=1;            //������
reg [4:0]   ala_day=1;            //������
reg [4:0]   ala_hour=0;           //����Сʱ
reg [5:0]   ala_min=0;            //���ӷ���
reg [5:0]   ala_sec=0;            //������

reg [4:0]   date=0;               //�Զ���ʱʱ��ͬ�·ݵ�����
reg [4:0]   date_set=0;           //���õ�ǰ����ʱ��ͬ�·ݵ�����
reg [4:0]   date_ala=0;           //������������ʱ��ͬ�·ݵ�����




reg cnt_full0,cnt_full1;                //Ϊ1��ʾ������ָ��ֵ           
reg key_flag0,key_flag1;                //Ϊ1��ʾ����������
reg [17:0] cnt0,cnt1;                   //��������ʱ�ļ�����������ָ��ֵ��ʾ����ȷʵ������

reg idle_hour=0,idle_year=0;            //Ϊ0��ʾ��δ����ʱ��/���ڣ�Ĭ��0001��1��1��0ʱ0��0��
reg idle_hour1=0,idle_year1=0;          //Ϊ1��ʾ����ʱ��/���ڵ���ʾ״̬����ʱ�����õ�ʱ��/���ڸ���ʵʱ�仯����������
reg flag_int=0;                     //��������
reg flag_ala=0;                     //��������ʱ��

reg flag_hour=0;           //����24Сʱ

parameter  s0=3'b000,           //IDLE
            s1=3'b001,           //�����յ�����
            s2=3'b011,           //ʱ��������� 
            s3=3'b010,           //ʱ�������ʾ 
            s4=3'b110,           //�����յ���ʾ 
            s5=3'b111,          //����ʱ���������
            s6=3'b101;          //���������յ�����
            
parameter 	f0=3'b000,
			f1=3'b001,
			f2=3'b010,
			f3=3'b011,
			f4=3'b100,
			f5=3'b101,
			f6=3'b110,
			f7=3'b111;
			
//key[1]������
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt1<=18'b0;
else if (key[1]==0) cnt1<=cnt1+1'b1;        //���¿�ʼ����
else cnt1<=18'b0;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt_full1<=1'b0;
else if(cnt1==24999)
cnt_full1<=1'b1; // ����˵������ȷʵ�����£�����⵽ cnt ��һ�ε��� 24999ʱ���ñ�־����Ϊ�ߵ�ƽ���˺�cnt_full��Ϊ0
else if (key[1]==1) cnt_full1<=1'b0;
else cnt_full1<=cnt_full1;
end
always@(posedge clk_in or negedge rst)begin
if(!rst) key_flag1<=1'b0;
else if (cnt1==24999&&cnt_full1==1'b0)  //�͵�ƽ���ã�����ȷʵ�������ұ�֤�ǵ�һ�Σ���֤���水һ�μ�����һ
key_flag1=1'b1;             //��ʾkey[1]����
else key_flag1=1'b0;
end


//key[0]������
always@(posedge clk_in or negedge rst)begin
if(!rst) cnt0<=18'b0;
else if (key[0]==0) cnt0<=cnt0+1'b1;        //�Ӱ��¿�ʼ����
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
key_flag0=1'b1;             //��ʾkey[0]����
else key_flag0=1'b0;
end

//always@(posedge clk_100khz or negedge rst)  begin//������
always@(posedge clk_1hz or negedge rst)  begin
//always@(posedge clk_1khz or negedge rst)  begin
    if(!rst) begin
        idle_hour<=0;flag_int<=0;
        hour<=0;min<=0;sec<=0;
    end
    else    begin
    if((idle_hour==0)&&(idle_hour1==1))  begin          //��δ���и�ֵ�����򸳳�ֵ
        idle_hour<=1;
        hour<=hour_set; min<=min_set; sec<=sec_set;
    end
    else if((idle_hour==1)&&(idle_hour1==1))           begin    //��ֵ���ڴ˻����ϼ���
        if(sec==59) begin
            sec<=0;
            if(min==59) begin
                min<=0;flag_int<=1;             //��������
                if(hour==23) begin
                    hour<=0;flag_hour<=1;       //flag_hourΪ��λ�źţ���ʾ��������1
                end
                else        begin
                    hour<=hour+1;
                end
            end
            else        begin
                min<=min+1;flag_int<=0;     //�����ź�����
            end
        end
        else        begin
            sec<=sec+1;flag_hour<=0;
        end
      end
  end
end

always@(posedge clk_1hz or negedge rst)  begin
//always@(posedge clk_in or negedge rst)  begin       //������
    if(!rst) begin
        idle_year<=0;
        year<=1;mon<=1;day<=1;
    end
    else    begin
        if((idle_year==0)&&(idle_year1==1))  begin                      //��δ���и�ֵ�����򸳳�ֵ
            idle_year<=1;
            year<= out_year1*1000+out_year2*100+out_year3*10+out_year4;     
            mon<=mon_set;
            day<=day_set;
        end 
        else if((idle_year==1)&&(idle_year1==1))    begin               //��ֵ���ڴ˻����ϼ���
        case(mon)
            1:date<=31;
            2:begin
                if((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) date<=29;   //����
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
    else  begin           //�����գ�ʱ���������
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
            s1: begin               //�����յ�����
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3;
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;   
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //����key[0]����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(out_year1==9)  out_year1<=0;
                            else         out_year1<=out_year1+1;                    //���ǧλ��һ����ΧΪ0-9                        
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(out_year2==9)  out_year2<=0;
                            else         out_year2<=out_year2+1;                //��ݰ�λ��һ����ΧΪ0-9              
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f3;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(out_year3==9)  out_year3<=0;
                            else         out_year3<=out_year3+1;                //���ʮλ��һ����ΧΪ0-9              
                        end                       
                    end                                        
                    f3: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f4;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f3;                           
                            if(out_year4==9)  out_year4<=0;
                            else         out_year4<=out_year4+1;                     //��ݸ�λλ��һ����ΧΪ0-9         
                        end                       
                    end
                    f4: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f5;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f4;                           
                            if(mon_set==12)  mon_set<=1;
                            else         mon_set<=mon_set+1;                        //�·ݵĿ��ƣ���Χ1-12    
                        end                       
                    end
                    f5: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f5;
                            year_set<=out_year1*1000+out_year2*100+out_year3*10+out_year4;//��ǰ�����
                            case(mon_set)       //ͨ��case�·ݣ��Ӷ��õ���ǰ�µ�����
                            1:date_set<=31;
                            2:begin             //����Ƕ��·������ж��Ƿ�Ϊ����
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
                        if(day_set==date_set)  day_set<=1;  //���ڵĿ���
                        else         day_set<=day_set+1;                            
                        end                       
                    end
                    default:next_pos<=f0;                                                                                             
                endcase
                num1<=out_year1;num2<=out_year2;num3<=out_year3;num4<=out_year4;        //�͸��������ʾ
                num5<=mon_set / 4'd10 % 4'd10;
                num6<=mon_set % 4'd10;
                num7<=day_set / 4'd10 % 4'd10;
                num8<=day_set % 4'd10;
            end
            s2: begin           //ʱ���������
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b010)     next_con<=s3;
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;
                else if(sw[2:0]==3'b101)     next_con<=s6;   
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(hour_set==23)  hour_set<=0;
                            else         hour_set<=hour_set+1;              //Сʱ�����ã���Χ0-23              
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(min_set==59)  min_set<=0;
                            else         min_set<=min_set+1;                 //���ӵ����ã���Χ0-59           
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(sec_set==59)  sec_set<=0;
                            else         sec_set<=sec_set+1;              //���ӵ����ã���Χ0-59               
                        end                       
                    end                                        
                    default:next_pos<=f0;                                                                                                    
                endcase  //case position����
                num1<=hour_set / 4'd10 % 4'd10;             //���������ʾ
                num2<=hour_set % 4'd10;
                num3<=min_set / 4'd10 % 4'd10;
                num4<=min_set % 4'd10;
                num5<=sec_set / 4'd10 % 4'd10;
                num6<=sec_set % 4'd10; 
                num7<=0;
                num8<=0;                           
            end         //s2����   
            s3: begin           //ʱ�����ʵʱ��ʾ
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
            end     //s3����
            s4: begin           //�����յ�ʵʱ��ʾ
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
            end  //s4����
            s5: begin           //����ʱ���������
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3; 
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b101)     next_con<=s6;  
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(ala_hour==23)  ala_hour<=0;
                            else         ala_hour<=ala_hour+1;                            
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(ala_min==59)  ala_min<=0;
                            else         ala_min<=ala_min+1;                            
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(ala_sec==59)  ala_sec<=0;
                            else         ala_sec<=ala_sec+1;                            
                        end                       
                    end                                        
                    default:next_pos<=f0;                                                                                                    
                endcase  //case position����
                num1<=ala_hour / 4'd10 % 4'd10;
                num2<=ala_hour % 4'd10;
                num3<=ala_min / 4'd10 % 4'd10;
                num4<=ala_min % 4'd10;
                num5<=ala_sec / 4'd10 % 4'd10;
                num6<=ala_sec % 4'd10; 
                num7<=0;
                num8<=0; 
            end             //s5����
            s6: begin               //���������յ�����
                if(sw[2:0]==3'b000)          next_con<=s0;
                else if(sw[2:0]==3'b001)     next_con<=s1;
                else if(sw[2:0]==3'b011)     next_con<=s2;
                else if(sw[2:0]==3'b010)     next_con<=s3; 
                else if(sw[2:0]==3'b110)     next_con<=s4;
                else if(sw[2:0]==3'b111)     next_con<=s5;    
                case(position)
                    f0: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f1;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f0;                           
                            if(ala_year1==9)  ala_year1<=0;
                            else         ala_year1<=ala_year1+1;                            
                        end                       
                    end
                    f1: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f2;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f1;                           
                            if(ala_year2==9)  ala_year2<=0;
                            else         ala_year2<=ala_year2+1;                            
                        end                       
                    end
                    f2: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f3;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f2;                           
                            if(ala_year3==9)  ala_year3<=0;
                            else         ala_year3<=ala_year3+1;                            
                        end                       
                    end                                        
                    f3: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f4;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f3;                           
                            if(ala_year4==9)  ala_year4<=0;
                            else         ala_year4<=ala_year4+1;                            
                        end 
                                              
                    end
                    f4: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f5;     //����һ��״̬
                        else if((key_flag0==0)&&(key_flag1==1))  begin 
                            next_pos<=f4;                           
                            if(ala_mon==12)  ala_mon<=1;
                            else         ala_mon<=ala_mon+1;                            
                        end                       
                    end
                    f5: begin
                        if((key_flag0==1)&&(key_flag1==0))       next_pos<=f0;     //����һ��״̬
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
            end            //s6����           
            default:next_con<=s0;   
        endcase         //case content����
    end             //else���� 
end

//always@(posedge clk_in or negedge rst)  begin//������
always@(posedge clk_2hz or negedge rst)  begin
    if(!rst)    begin
        led<=6'b111_111;
        flag_ala<=0;
    end
    else        begin
        if( (sw[3])&&(ala_year==year)&&(ala_mon==mon)&&(ala_day==day)&&(ala_hour==hour)&&(ala_min==min)&&(ala_sec==sec) )   begin
             flag_ala<=1;           //sw[3]Ϊ1�������ӹ��ܣ���֮�ر�
        end
        if(flag_int)  begin         //��������
            led<=~led;         
        end
        else if(flag_ala)    begin  //������������ʱ��
            led<=~led;
            if(!sw[3]) begin
                flag_ala<=0;
            end
        end
        else    led<=6'b111_111;
    end
end

  
endmodule
