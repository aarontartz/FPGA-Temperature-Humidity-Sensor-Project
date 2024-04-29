`timescale 1s / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:22:51 PM
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
    input wire clk,
    input wire [15:0] data_in,
    inout wire ck_sda,
    output wire ck_scl,
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
    output wire ck_io26,
    output wire ck_io27,
    output wire ck_io28,
    output wire ck_io29,
    output wire ck_io30,
    output wire ck_io31,
    output wire ck_io32,
    output wire ck_io33,
    output wire ck_io40,
    output wire ck_io41,
    output wire [15:0] data_out,
    
    //LOGIC ANALYZER TESTING
    output wire ck_io39,
    output wire ck_io38,
    output wire ck_io37,
    output wire ck_io36,
    output wire ck_io35
    );
    
    wire [15:0] meas_out_wire;
    wire [7:0] tens_out;
    wire [7:0] ones_out;
    wire [7:0] decimal_out;
    wire sda_in_wire;
    wire sda_out_wire;
    wire sda_en_wire;
    wire scl_out_wire;
    
    
    //LOGIC ANALYZER TESTING
    wire clk100kHz_double_wire;
    wire nack_ack_wire;
    //=================================
    
    i2c_master i2c_instance (
        .clk100MHz(clk),
        //.clk_100MHz_count(clk_count_wire),
        //.clk_100kHz(clk_100kHz_wire),
        .sda_in(sda_in_wire),
        .sda_out(sda_out_wire),
        .sda_en(sda_en_wire),
        //.sda(sda_wire),
        .scl_out(scl_out_wire),
        .data_out(meas_out_wire),
        
        //TESTING
        .clk100kHz_double(clk100kHz_double_wire),
        .nack_ack_w(nack_ack_wire)
    );
    
    disp_7seg disp_instance (
        .clk100MHz(clk),
        .data_in(meas_out_wire),
        .data_out_tens(tens_out),
        .data_out_ones(ones_out),
        .data_out_decimal(decimal_out)
    );
    
    //LOGIC ANALYZER TESTING
    assign ck_io39 = clk100kHz_double_wire;
    assign ck_io38 = sda_in_wire;
    assign ck_io37 = sda_out_wire;
    assign ck_io36 = sda_en_wire;
    assign ck_io35 = nack_ack_wire;
    //=================================
    
    assign data_out = meas_out_wire;
    
    assign ck_scl = scl_out_wire;
    assign ck_sda = sda_en_wire ? sda_out_wire : 1'bz;
    assign sda_in_wire = ck_sda;
    
    assign {ck_io41, ck_io40, ck_io13, ck_io12, ck_io11, ck_io10, ck_io9, ck_io8} = tens_out;
    assign {ck_io7, ck_io6, ck_io5, ck_io4, ck_io3, ck_io2, ck_io1, ck_io0} = ones_out;
    assign {ck_io26, ck_io27, ck_io28, ck_io29, ck_io30, ck_io31, ck_io32, ck_io33} = decimal_out;
    
endmodule
