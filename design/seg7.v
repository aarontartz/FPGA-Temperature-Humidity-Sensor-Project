`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 02:38:11 AM
// Design Name: 
// Module Name: top4
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


module seg7(
    input wire clk,
    //input wire data_in,
    output wire ck_io0,
    output wire ck_io1,
    output wire ck_io2,
    output wire ck_io3,
    output wire ck_io4,
    output wire ck_io5,
    output wire ck_io6,
    output wire ck_io7,
    output wire ck_io8,
    output wire ck_io9,
    output wire ck_io10,
    output wire ck_io11,
    output wire ck_io12,
    output wire ck_io13,
    output wire ck_io40,
    output wire ck_io41
    );
    //assign AN = 8'b11111110;
    //reg [15:0] data_out = {ck_io41, ck_io40, ck_io13, ck_io12, ck_io11, ck_io10, ck_io9, ck_io8, ck_io7, ck_io6, ck_io5, ck_io4, ck_io3, ck_io2, ck_io1, ck_io0};
    wire [4:0] data_in_first;
    wire [4:0] data_in_second;
    assign data_in_first = 4'b0110;
    assign data_in_second = 4'b1000;
    reg [7:0] data_out_first; //{ck_io41, ck_io40, ck_io13, ck_io12, ck_io11, ck_io10, ck_io9, ck_io8}
    reg [7:0] data_out_second; //{ck_io7, ck_io6, ck_io5, ck_io4, ck_io3, ck_io2, ck_io1, ck_io0}
    always @(posedge clk) begin
        case (data_in_first)
            4'b0000: 
                data_out_first = 8'b00000000;  //zero
            4'b0001:
                data_out_first = 8'b00100001;  //one
            4'b0010:
                data_out_first = 8'b11001011;  //two
            4'b0011:
                data_out_first = 8'b01101011;  //three
            4'b0100:
                data_out_first = 8'b00101101;  //four
            4'b0101:
                data_out_first = 8'b01101110;  //five
            4'b0110:
                data_out_first = 8'b11101110;  //six
            4'b0111:
                data_out_first = 8'b00100011;  //seven
            4'b1000:
                data_out_first = 8'b11101111;  //eight
            4'b1001:
                data_out_first = 8'b01101111;  //nine
            default:
                data_out_first = 8'b00001000;  //-
        endcase
        case (data_in_second)
            4'b0000: 
                data_out_second = 8'b00000000;  //zero
            4'b0001:
                data_out_second = 8'b00100001;  //one
            4'b0010:
                data_out_second = 8'b11001011;  //two
            4'b0011:
                data_out_second = 8'b01101011;  //three
            4'b0100:
                data_out_second = 8'b00101101;  //four
            4'b0101:
                data_out_second = 8'b01101110;  //five
            4'b0110:
                data_out_second = 8'b11101110;  //six
            4'b0111:
                data_out_second = 8'b00100011;  //seven
            4'b1000:
                data_out_second = 8'b11101111;  //eight
            4'b1001:
                data_out_second = 8'b01101111;  //nine
            default:
                data_out_first = 8'b00001000;  //-
        endcase
    end
    assign {ck_io41, ck_io40, ck_io13, ck_io12, ck_io11, ck_io10, ck_io9, ck_io8} = data_out_first;
    assign {ck_io7, ck_io6, ck_io5, ck_io4, ck_io3, ck_io2, ck_io1, ck_io0} = data_out_second;
endmodule
