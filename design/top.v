`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent
// Engineer: Arthur Brown
// 
// Create Date: 04/13/2018 03:33:26 PM
// Design Name: Cora Z7-10 Basic I/O Demo
// Module Name: top
// Target Devices: Cora Z7-10
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    // 125MHz System Clock
    input wire clk,
    // RGB LED (Active Low)
    output wire led0_r,
    output wire led0_g,
    output wire led0_b,
    output wire led1_r,
    output wire led1_g,
    output wire led1_b,
    // 2 Buttons
    input wire [1:0] btn
);
    localparam CD_COUNT_MAX = 125000000/2;
    wire brightness;
    reg [$clog2(CD_COUNT_MAX-1)-1:0] cd_count = 'b0;
    reg [3:0] led_shift = 4'b0001;
    wire [1:0] db_btn;
        
    pwm #(
        .COUNTER_WIDTH(8),
        .MAX_COUNT(255)
    ) m_pwm (
        .clk(clk),
        .duty(8'd127),
        .pwm_out(brightness)
    );
    
    always@(posedge clk)
        if (cd_count >= CD_COUNT_MAX-1) begin // 2Hz
            cd_count <= 'b0;
            led_shift <= {led_shift[2:0], led_shift[3]}; // cycle the LEDs and the color of the RGB LED. blue-green-red-black
        end else
            cd_count <= cd_count + 1'b1;
    assign {led0_r, led0_g, led0_b} = led_shift[2:0] & {3{brightness & ~db_btn[0]}};
    assign {led1_r, led1_g, led1_b} = led_shift[2:0] & {3{brightness & ~db_btn[1]}};
    
    debouncer #(
        .WIDTH(2),
        .CLOCKS(1024),
        .CLOCKS_CLOG2(10)
    ) m_db_btn (
        .clk(clk),
        .din(btn),
        .dout(db_btn)
    );
endmodule
