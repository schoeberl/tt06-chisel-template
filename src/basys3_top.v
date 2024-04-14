/*
 * Basys3 top level module to test the design in an FPGA.
 * This top level is also good for the Nexys A7 board.
 *
 * Copyright (c) 2024 Martin Schoeberl
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module basys3_top (
    input  wire clock,        // clock
    input  wire reset,        // reset - high active

    input  wire [15:0] sw,    // Switches
    output  wire [7:0] led,   // LEDs (not part of the TT board)
    output  wire [6:0] seg,   // 7-segment
    output  wire dp,          // 7-segment
    output  wire [3:0] an,    // 7-segment

    output  wire [3:0] vga_r,
    output  wire [3:0] vga_g,
    output  wire [3:0] vga_b,
    output  wire vga_hs,
    output  wire vga_vs
);

    wire rst_n = ~reset; // Isn't that button low active anyway?
    wire ena = 1'b1;
    reg clk;
    // a crude clock divider to get 50 MHz out of the 100 MHz clock
    // Not recommended, but we know what we do here ;-)
    always @(posedge clock) begin
      clk <= ~clk;
    end
    wire [7:0] ui_in = sw [7:0];
    wire [7:0] uo_out;
    wire [7:0] uio_in = sw [15:8];
    wire [7:0] uio_out; // TODO: shall go to PMOD, depending on the design
    wire [7:0] uio_oe;  // ignored

    tt_um_example user_project (
          .ui_in  (ui_in),    // Dedicated inputs
          .uo_out (uo_out),   // Dedicated outputs
          .uio_in (uio_in),   // IOs: Input path
          .uio_out(uio_out),  // IOs: Output path
          .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
          .ena    (ena),      // enable - goes high when design is selected
          .clk    (clk),      // clock
          .rst_n  (rst_n)     // not reset
      );


    assign led = uo_out;
    assign an = 4'b1110;
    assign {dp, seg} = ~uo_out;

    assign vga_r [1:0] = 2'b00;
    assign vga_r [2] = uo_out[4];
    assign vga_r [3] = uo_out[0];
    assign vga_g [1:0] = 2'b00;
    assign vga_g [2] = uo_out[5];
    assign vga_g [3] = uo_out[1];
    assign vga_b [1:0] = 2'b00;
    assign vga_b [2] = uo_out[6];
    assign vga_b [3] = uo_out[2];
    assign vga_hs = uo_out[7];
    assign vga_vs = uo_out[3];

endmodule
