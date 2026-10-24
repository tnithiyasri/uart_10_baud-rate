`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2026 01:01:10 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top 
 #( 
    parameter CLK_FREQ = 100_000_000 
  )
  ( 
    input clk, 
    input rst, 
    input [3:0] baud_sel, 
    input data,
    
    output data_out
  ); 
  
  reg [19:0] baud_div; 
  

  always @(*) 
    begin 
      case (baud_sel) 
        4'd0: baud_div = CLK_FREQ / 2400; 
        4'd1: baud_div = CLK_FREQ / 4800; 
        4'd2: baud_div = CLK_FREQ / 9600; 
        4'd3: baud_div = CLK_FREQ / 14400;
        4'd4: baud_div = CLK_FREQ / 19200; 
        4'd5: baud_div = CLK_FREQ / 28800; 
        4'd6: baud_div = CLK_FREQ / 38400; 
        4'd7: baud_div = CLK_FREQ / 56000; 
        4'd8: baud_div = CLK_FREQ / 57600; 
        4'd9: baud_div = CLK_FREQ / 115200; 
        default: 
        baud_div = CLK_FREQ / 9600; 
      endcase 
    end

  //-------------------------------uart_tx_baudrate_interface------------------------------------
    wire clk_utb_in;
    wire rst_utb_in;
    wire [7:0] tx_data_utb_in;
    wire [19:0] baud_div_utb_in;
    
    wire tx_utb_out;
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_rx_baudrate_interface------------------------------------
    wire clk_urb_in;
    wire rst_urb_in;
    wire rx_urb_in;
    wire [19:0] baud_div_urb_in;
    
    wire [7:0] rx_data_urb_out;
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_tx_baudrate_interface------------------------------------
    assign clk_utb_in = clk;
    assign rst_utb_in = rst;
    assign tx_data_utb_in = rx_data_urb_out;
    assign baud_div_utb_in = baud_sel;
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_rx_baudrate_interface------------------------------------
    assign clk_urb_in = clk;
    assign  rst_urb_in = rst;
    assign rx_urb_in = data;
    assign baud_div_urb_in = baud_sel;
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_top_interface--------------------------------------------
    assign data_out = tx_utb_out;
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_tx_baudrate_interface------------------------------------
    uart_tx_baudrate  utb_inst
      (
        .clk_utb_in(clk_utb_in),
        .rst_utb_in(rst_utb_in),
        .tx_data_utb_in(tx_data_utb_in),
        .baud_div_utb_in(baud_div_utb_in),
    
        .tx_utb_out(tx_utb_out)
      );
  //---------------------------------------------------------------------------------------------

  //-------------------------------uart_rx_baudrate_interface------------------------------------
    uart_rx_baudrate  urb_inst
     ( 
      .clk_urb_in(clk_urb_in),
      .rst_urb_in(rst_urb_in),
      .rx_urb_in(rx_urb_in),
      .baud_div_urb_in(baud_div_urb_in),
      
      .rx_data_urb_out(rx_data_urb_out) 
     );
  //---------------------------------------------------------------------------------------------
    /*
  //-------------------------------vio_uart_interface--------------------------------------------
    vio_uart  vu_inst
     ( 
      .clk(clk_utb_in),
      
      .probe_out0(tx_data) 
     );
  //---------------------------------------------------------------------------------------------
   */
endmodule