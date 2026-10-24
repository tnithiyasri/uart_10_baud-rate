`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 12:46:40 PM
// Design Name: 
// Module Name: uart_tx_baudrate
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


module uart_tx_baudrate
(
    input clk_utb_in,
    input rst_utb_in,
    input  [7:0] tx_data_utb_in,
    input  [19:0] baud_div_utb_in,
    output reg   tx_utb_out
);

    localparam START = 2'd0;
    localparam DATA  = 2'd1;
    localparam STOP  = 2'd2;

    reg [1:0]  state;
    reg [3:0]  bit_count;
    reg [19:0] baud_count;

    always @(posedge clk_utb_in or posedge rst_utb_in) begin
        if (rst_utb_in) begin
            state      <= START;
            bit_count  <= 4'd0;
            baud_count <= 20'd0;
            tx_utb_out <= 1'b1;
        end
        else begin
            case (state)

                START: begin
                    tx_utb_out <= 1'b0;

                    if (baud_count == baud_div_utb_in - 1) begin
                        baud_count <= 20'd0;
                        state      <= DATA;
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                DATA: begin
                    tx_utb_out <= tx_data_utb_in[bit_count];

                    if (baud_count == baud_div_utb_in - 1) begin
                        baud_count <= 20'd0;

                        if (bit_count == 4'd7) begin
                            bit_count <= 4'd0;
                            state     <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                STOP: begin
                    tx_utb_out <= 1'b1;

                    if (baud_count == baud_div_utb_in - 1) begin
                        baud_count <= 20'd0;
                        state      <= START;
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                default: begin
                    state      <= START;
                    bit_count  <= 4'd0;
                    baud_count <= 20'd0;
                    tx_utb_out <= 1'b1;
                end

            endcase
        end
    end

endmodule

