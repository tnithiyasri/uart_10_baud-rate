`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 12:47:01 PM
// Design Name: 
// Module Name: uart_rx_baudrate
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


module uart_rx_baudrate
(
    input clk_urb_in,
    input rst_urb_in,
    input rx_urb_in,
    input [19:0] baud_div_urb_in,
    output reg [7:0] rx_data_urb_out
 );

    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    wire [19:0] sample_point = baud_div_urb_in >> 1;
    
    reg rx_ready;
    reg [1:0]  state;
    reg [19:0] baud_cnt;
    reg [2:0]  bit_cnt;
    reg [7:0]  rx_shift_reg;

   
    reg rx_sync0;
    reg rx_sync1;

    
    always @(posedge clk_urb_in) begin
        if (rst_urb_in) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end
        else begin
            rx_sync0 <= rx_urb_in;
            rx_sync1 <= rx_sync0;
        end
    end

   
    always @(posedge clk_urb_in) begin
        if (rst_urb_in) begin
            state        <= STATE_IDLE;
            baud_cnt     <= 20'd0;
            bit_cnt      <= 3'd0;
            rx_shift_reg <= 8'd0;
            rx_data_urb_out <= 8'd0;
            rx_ready     <= 1'b0;
        end
        else begin

           
            rx_ready <= 1'b0;

            case (state)

                
                STATE_IDLE: begin
                    baud_cnt <= 20'd0;
                    bit_cnt  <= 3'd0;

                    if (rx_sync1 == 1'b0) begin
                        state <= STATE_START;
                    end
                end

               
                STATE_START: begin
                    if (baud_cnt == sample_point - 1) begin
                        baud_cnt <= 20'd0;

                        if (rx_sync1 == 1'b0) begin
                            state <= STATE_DATA;
                        end
                        else begin
                            state <= STATE_IDLE;
                        end
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

               
                STATE_DATA: begin
                    if (baud_cnt == baud_div_urb_in - 1) begin
                        baud_cnt <= 20'd0;

                       
                        rx_shift_reg <= {
                            rx_sync1,
                            rx_shift_reg[7:1]
                        };

                        if (bit_cnt == 3'd7) begin
                            bit_cnt <= 3'd0;
                            state   <= STATE_STOP;
                        end
                        else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

               
                STATE_STOP: begin
                    if (baud_cnt == baud_div_urb_in - 1) begin
                        baud_cnt <= 20'd0;

                        if (rx_sync1 == 1'b1) begin
                           
                            rx_data_urb_out  <= rx_shift_reg;
                            rx_ready <= 1'b1;
                        end

                        state <= STATE_IDLE;
                    end
                    else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: begin
                    state        <= STATE_IDLE;
                    baud_cnt     <= 20'd0;
                    bit_cnt      <= 3'd0;
                    rx_shift_reg <= 8'd0;
                end

            endcase
        end
    end

endmodule

