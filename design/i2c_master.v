`timescale 1s / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2024 04:40:53 AM
// Design Name: 
// Module Name: i2c
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


module i2c_master(
    input wire clk100MHz,                      // clk driven from processor at 100MHz
    input wire sda_in,
    //input wire clk_100MHz_count,
    //input wire clk_100kHz,
    output wire sda_out,
    output wire sda_en,
    //inout wire sda,
    output wire scl_out,
    output wire [15:0] data_out,          //
    //output reg [15:0] data_out
    
    //TESTING
    output wire clk100kHz_double,
    output wire nack_ack_w
    );
    
    //wire sda_dir;                   // SDA direction signal
    reg sda_write_en = 1;             // starts HIGH for START state
    //reg scl_en = 0;
    
    // Using 100MHz to make I2C count more legible only using 100 vs 600 and going up by 500 each instead of weird value
    // *** GENERATE 100kHz SCL clk from 50MHz ***************************
    // 50 x 10^6 / 100 x 10^3 / 2 = 250
    //reg [8:0] clk_gen_counter = 9'b0;  // count up to 500, only used to generate 100kHz SCL clk
    //reg clk_reg;                 // SCL clk starts HIGH
      
    // Set value of i2c SCL signal to the sensor - 100kHz            
    //assign scl = clk_reg;   
    // ********************************************************************     

    // Signal Declarations               
    parameter [6:0] sensor_addr         = 7'b1000_000;     // Sensor address (add on LSB in FSM, write = 0, read = 1)
    //parameter [7:0] measure_rh_cmd      = 8'b1111_0101;     // 0xF5 measure relative humidity (RH)
    parameter [7:0] measure_rh_cmd      = 8'b1111_0011;     // 0xF3 (DELETE LATER AND UNCOMMENT ABOVE, USED FOR TESTING)
    parameter [7:0] temp_from_rh_cmd    = 8'b1110_0000;     // 0xE0 read temp from RH
    parameter [7:0] write_user_reg_cmd  = 8'b1110_0110;     // 0xE6 write to user register
    reg [7:0] MSB_byte = 0;                                     // data MSB
    reg [7:0] LSB_byte = 0;                                     // data LSB
    
    //16'b0110010001011100; should print 21
    reg o_bit = 1;
    reg i_bit = 0;
    reg nack_ack = 0;                                       // checks when slave is done converting - will nack until done
    //reg o_bit = 1;                                       // output bit to SDA - starts HIGH
    //wire i_bit;                                      // input bit from SDA
    //reg [22:0] count = 23'b0;                               // State Machine Synchronizing Counter
    //reg [15:0] temp_data_reg = 16'b0;					            // Temperature data register	
    //reg [15:0] hum_data_reg = 16'b0;                                 // Humidity data register	
    reg [15:0] temp_data;
    reg [15:0] hum_data;	

    // State Declarations
    localparam [4:0] START              = 5'b0000,
                     START_REP          = 5'b0001,         
                     SEND_ADDR          = 5'b0010,
                     //SEND_ADDR2         = 5'b0010,
                     SEND_USER_REG      = 5'b0111,          // send write user register cmd
                     WRITE_USER_REG     = 5'b0101,          // write to user register
                     SEND_MEAS_RH       = 5'b0011,          // send measure RH cmd
                     SEND_TEMP_FROM_RH  = 5'b0100,          // send read temp from RH cmd
                     GET_ACK            = 5'b0110,
                     //READ_ACK2          = 5'b0111,                       
                     //READ_ACK3          = 5'b1000,
                     GET_NACK_ACK       = 5'b1001,
                     //READ_NACK2         = 5'b1010,
                     SEND_ACK           = 5'b1011,
                     SEND_NACK          = 5'b1100,
                     READ_MSB           = 5'b1101,
                     READ_LSB           = 5'b1110,
                     STOP               = 5'b1111;
                     
                     
    reg [4:0] state = START;                         // state register
    
   // counters
    reg [2:0] index_counter_addr = 0;
    reg [2:0] index_counter_cmd = 0;
    reg [2:0] index_counter_MSB = 0;
    reg [2:0] index_counter_LSB = 0;
    reg [2:0] send_addr_counter = 0;
    reg [2:0] get_nack_ack_counter = 0;
    reg [2:0] send_nack_counter = 0;
    reg [2:0] get_ack_counter = 0;
    
    // for clk generation
    reg [9:0] clk_gen_counter = 10'b0;
    reg clk_reg = 1;
    reg clk_reg_double = 1;
    //wire clk100kHz;
    
    // doubles frequency for 100kHz posedge and negedge detection
    reg r_clk100kHz = 0;
    //wire w_xor_clk100kHz; //= (r_clk100kHz ^ clk_reg);
    
    //wire [15:0] test = 16'b0110010001011100;
    // Control direction of SDA bidirectional inout signal
    /*
    assign sda_dir = (state == START || state == START_REP || state == SEND_ADDR || state == SEND_USER_REG ||
                      state == SEND_MEAS_RH || state == SEND_TEMP_FROM_RH || state == SEND_ACK ||
                      state == SEND_NACK) ? 1 : 0;          // 1 = output, 0 = input
    */
                      
                      
    //assign scl = clk_reg;                   // set scl to generated clk_reg
    //assign sda = sda_write_en ? o_bit : 1'bz;    // if sda_write_en == 1, write to o_bit, else read i_bit
    //assign scl_out = (scl_en == 0) ? 1 : clk100kHz;
    assign sda_out = sda_write_en ? o_bit : 1'bz;
    //assign sda_in = (sda_write_en == 0) ? i_bit : 1'bz;
    assign sda_en = sda_write_en;
    assign scl_out = clk_reg;
    
    //assign w_xor_clk100kHz = (r_clk100kHz ^ clk_reg);
    assign clk100kHz_double = clk_reg_double;
    //assign scl_out = clk100kHz;
    //assign clk100kHz = clk_reg;
    
    // Set value of input wire when SDA is used as an input - from sensor to master
    //assign i_bit = sda;
    
    //assign data_out = {MSB_byte[7:0], LSB_byte[7:0]};
    assign data_out = temp_data;
    
    //TESTING
    assign nack_ack_w = nack_ack;
    //=================================
    
    always @(posedge clk100MHz) begin
        // Generate 100kHz clk
        if (clk_gen_counter == 499) begin
            clk_reg <= ~clk_reg;            // Changes 100kHz clock to LOW
            //clk_gen_counter <= 9'b0;
        end
        else if (clk_gen_counter == 999) begin
            clk_reg <= ~clk_reg;            // Changes 100kHz clock to HIGH
        end
        // Generate 200kHz clk
        if (clk_gen_counter == 299 || clk_gen_counter == 799) begin
            clk_reg_double <= ~clk_reg_double;
        end
        else if (clk_gen_counter == 549 || clk_gen_counter == 49) begin
            clk_reg_double <= ~clk_reg_double;
        end
        //else
            //clk_gen_counter <= clk_gen_counter + 1;
        clk_gen_counter <= clk_gen_counter + 1;
        if (clk_gen_counter == 999)
            clk_gen_counter <= 9'b0;
    end
    
    always @(negedge clk100kHz_double) begin     // double frequency of 100kHz clk, allows for posedge and negedge functions of 100kHz
        //r_clk100kHz <= ~r_clk100kHz;
        case (state)
            START: begin
                if (clk_gen_counter < 499) begin
                    sda_write_en <= 1;
                    //sda_write_en <= 1;
                    // to start I2C, pull SDA LOW while SCL HIGH
                    o_bit <= 0;                 // send START condition  
                    send_addr_counter <= 1;     // 1 instance of sending slave addr + x instances of sending addr until conversion is complete
                    get_nack_ack_counter <= 1;
                    send_nack_counter <= 3;     // 1 instance sending nack bit + 
                    get_ack_counter <= 2;       // 2 instances of receiving ack bit + 1 instance of state acting as STOP state for START_REP
                                                // (also 1 more instance of receiving ack bit, but is in GET_NACK_ACK state)
                    
                    index_counter_addr <= 7;    // address 7 bits, + read/write bit
                    index_counter_cmd <= 7;     // measure cmd 8 bits
                    index_counter_MSB <= 7;     // MSB 8 bits
                    index_counter_LSB <= 7;     // LSB 8 bits
                    //sda_write_en <= 1;
                    state <= SEND_ADDR; 
                end
            end
            
            START_REP: begin
                if (clk_gen_counter < 499) begin
                    sda_write_en <= 1;
                    //sda_write_en <= 1;
                    o_bit <= 0;
                    index_counter_addr <= 4'd7;
                    //sda_write_en <= 1;
                    state <= SEND_ADDR;
                end
            end
            
            SEND_ADDR: begin
                if (clk_gen_counter >= 499) begin
                    sda_write_en <= 1;
                    //sda_write_en <= 1;
                    if (index_counter_addr >= 1) begin
                        o_bit <= sensor_addr[index_counter_addr - 1];
                        index_counter_addr <= index_counter_addr - 1;
                    end
                    else if (index_counter_addr == 0 && send_addr_counter == 1) begin
                        o_bit <= 0;                      //write bit
                        send_addr_counter <= send_addr_counter - 1;
                        //sda_write_en <= 0;
                        state <= GET_ACK;
                    end
                    else if (index_counter_addr == 0 && send_addr_counter == 0) begin
                        o_bit <= 1;                      //read bit
                        //sda_write_en <= 0;
                        get_nack_ack_counter <= 4'd1;
                        state <= GET_NACK_ACK;
                    end
                end
            end
            
            GET_ACK: begin
                //sda_write_en <= 0;
                if (clk_gen_counter >= 499) begin
                    sda_write_en <= 0;
                    if (get_ack_counter == 2) begin
                        //sda_write_en <= 0;
                        get_ack_counter <= get_ack_counter - 1;
                        //sda_write_en <= 1;
                        state <= SEND_MEAS_RH;
                    end
                    else if (get_ack_counter == 1)
                        //sda_write_en <= 0;
                        get_ack_counter <= get_ack_counter - 1;
                    else if (get_ack_counter == 0) begin    // Doesn't actually get ack - allows o_bit to go to 1 so START_REP can go from 1 to 0
                        sda_write_en <= 1;
                        o_bit <= 1;                         // Because ACK bit is 0, in order to start again SDA needs to go from HIGH to LOW
                        state <= START_REP;
                    end
                end
            end
            
            GET_NACK_ACK: begin
                sda_write_en <= 0;
                nack_ack <= sda_in;     // NACK = 1, ACK = 0: Slave will not send ACK until conversion is done
                //sda_write_en <= 0;
                if (clk_gen_counter >= 499) begin
                    //sda_write_en <= 0;
                    //nack_ack <= sda_in;
                    if (nack_ack == 0)
                        //sda_write_en <= 0;
                        state <= READ_MSB;
                    else if (get_nack_ack_counter == 1)
                        get_nack_ack_counter <= get_nack_ack_counter - 1;
                    else if (get_nack_ack_counter == 0) begin
                        sda_write_en <= 1;
                        o_bit <= 1;
                        state <= START_REP;
                    end
                end
            end
                /*
            SEND_ACK: begin
                if (clk_gen_counter >= 499) begin                    
                    sda_write_en <= 1;
                    o_bit <= 0;                  // ACK bit is 0
                    state <= READ_LSB;
                end
            end
                */
            /*
            SEND_NACK: begin
                //sda_write_en <= 1;
                if (clk_gen_counter >= 499) begin
                    //sda_write_en <= 1;
                    if (send_nack_counter == 1) begin
                        //sda_write_en <= 1;
                        o_bit <= 1;
                        send_nack_counter <= send_nack_counter - 1;
                    end
                    if (send_nack_counter == 0) begin
                        //sda_write_en <= 1;
                        o_bit <= 0;                  // NACK bit is 1
                        state <= STOP;
                    end
                end
            end
            */
            SEND_MEAS_RH: begin
                //sda_write_en <= 1;
                if (clk_gen_counter >= 499) begin
                    sda_write_en <= 1;
                    if (index_counter_cmd >= 1) begin
                        o_bit <= measure_rh_cmd[index_counter_cmd];
                        index_counter_cmd <= index_counter_cmd - 1;
                    end
                    else if (index_counter_cmd == 0) begin
                        o_bit <= measure_rh_cmd[0];
                        //sda_write_en <= 0;
                        state <= GET_ACK;
                    end
                end
            end
            
            READ_MSB: begin
                //sda_write_en <= 0;
                if (clk_gen_counter >= 499) begin
                    sda_write_en <= 0;
                    if (index_counter_MSB >= 1) begin
                        //MSB_byte[index_counter_MSB] <= sda_in;
                        temp_data[index_counter_MSB + 8] <= sda_in;
                        index_counter_MSB <= index_counter_MSB - 1;
                    end
                    else if (index_counter_MSB == 0) begin
                        temp_data[8] <= sda_in;
                        sda_write_en <= 1;      // Send ACK
                        o_bit <= 0;  
                        state <= READ_LSB;
                    end
                end
            end
            
            READ_LSB: begin
                //sda_write_en <= 0;
                if (clk_gen_counter >= 499) begin
                    sda_write_en <= 0;
                    if (index_counter_LSB >= 1) begin
                        temp_data[index_counter_MSB] <= sda_in;
                        index_counter_LSB <= index_counter_LSB - 1;
                    end
                    else if (index_counter_LSB == 0 && send_nack_counter == 3) begin
                        temp_data[0] <= sda_in;
                        send_nack_counter <= send_nack_counter - 1;
                    end
                    else if (index_counter_LSB == 0 && (send_nack_counter == 2 || send_nack_counter == 1)) begin
                        sda_write_en <= 1;
                        o_bit <= 1;
                        send_nack_counter <= send_nack_counter - 1;
                    end
                    else if (index_counter_LSB == 0 && send_nack_counter == 0) begin
                        sda_write_en <= 1;
                        o_bit <= 0;
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                //sda_write_en <= 1;
                //o_bit <= 0;
                if (clk_gen_counter < 499) begin
                    sda_write_en <= 1;
                    o_bit <= 1;
                    //sda_write_en <= 1;
                    state <= START;
                end
            end
 
        endcase
    end
endmodule
