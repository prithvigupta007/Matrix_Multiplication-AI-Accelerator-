`timescale 1ns / 1ps
module bcd_segment7_1digit(bcd, seg);    
    input [3:0] bcd;
    output reg [6:0] seg;
    
    //always block for converting bcd digit into 7 segment format
    always @(bcd)
    begin
        case (bcd) //case statement
            4'd0 : seg = 7'b0000001;
            4'd1 : seg = 7'b1001111;
             4'd2 : seg = 7'b0010010;
             4'd3 : seg = 7'b0000110;
             4'd4 : seg = 7'b1001100;
             4'd5 : seg = 7'b0100100;
             4'd6 : seg = 7'b0100000;
             4'd7 : seg = 7'b0001111;
             4'd8 : seg = 7'b0000000;
             4'd9 :  seg = 7'b0000100;
             4'd10 : seg = 7'b0001001;
             4'd11 : seg = 7'b1100000;
             4'd12 : seg = 7'b0110000;
             4'd13 : seg = 7'b1000010;
             4'd14 : seg = 7'b0110000;
             4'd15 : seg = 7'b0111000;
        endcase
    end
  
endmodule
