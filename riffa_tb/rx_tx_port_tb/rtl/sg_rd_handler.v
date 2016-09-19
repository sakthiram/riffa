// ----------------------------------------------------------------------
// Copyright (c) 2015, The Regents of the University of California All
// rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
// 
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
// 
//     * Neither the name of The Regents of the University of California
//       nor the names of its contributors may be used to endorse or
//       promote products derived from this software without specific
//       prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL REGENTS OF THE
// UNIVERSITY OF CALIFORNIA BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
// OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
// USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
// DAMAGE.
// ----------------------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:            sg_rd_handler.v
// Version:             1.00.a
// Verilog Standard:    Verilog-2001
// Description:         
// Author:              Sakthi
// History:             @mattj: Version 2.0
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
module sg_rd_handler #(
    parameter C_DATA_WIDTH = 9'd128,
    // Local parameters
    parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1)
)
(
    input CLK,
    input RST,

    output [C_DATA_WIDTH/129:0] FIFO_RD_EN,               // Incoming data 
    input [C_DATA_WIDTH-1:0] FIFO_RD_DATA,
    input [4*(C_DATA_WIDTH/129+1)-1:0] FIFO_EMPTY,
    output [127:0] SG_DATA,
    output SG_DATA_EMPTY,
    input SG_DATA_REN,
    input SG_ELEM_REN
);

`include "functions.vh"

    localparam C_NUM_MUXES =  4*(C_DATA_WIDTH/129+1);
    localparam C_RD_SHIFT_BITS = clog2s(C_NUM_MUXES/4);


reg  [C_RD_SHIFT_BITS-1:0]                      _rRdShift;
reg  [C_RD_SHIFT_BITS-1:0]                      rRdShift;
wire [C_NUM_MUXES/4-1:0]                        wBuf128EmptyArray;


always @ (posedge CLK) begin
	rRdShift <= #1 (RST ? 0 : _rRdShift);
end

always @ (*) begin
	if (RST) 
		_rRdShift = 0;
	if (C_DATA_WIDTH <= 128)
		_rRdShift = 0;
	else if (SG_ELEM_REN == 1)
		_rRdShift = rRdShift+1;    
end 

genvar i;

//TODO Demux Logic
generate
    for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
  assign FIFO_RD_EN[i:i] = RST?0:((i==rRdShift) ? SG_DATA_REN : 0);
    end
endgenerate

if (C_DATA_WIDTH <= 128) begin
assign SG_DATA_EMPTY = FIFO_EMPTY[3:3];
assign SG_DATA = FIFO_RD_DATA;
end
    
generate 
	if (C_DATA_WIDTH > 128) begin

	for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
	    assign wBuf128EmptyArray[i:i] = FIFO_EMPTY[4*(i+1)-1:4*(i+1)-1];
        end


    	mux
    	     #(
    	       .C_NUM_INPUTS        (C_NUM_MUXES/4),
    	       // Parameters
    	       .C_CLOG_NUM_INPUTS   (C_RD_SHIFT_BITS),
    	       .C_WIDTH   	    (1),
	           .C_MUX_TYPE          ("SELECT"))
    	mux_inst_fifo_empty
    	     (
    	      // Inputs
    	      .MUX_SELECT       (rRdShift),
    	      // Outputs
    	      .MUX_OUTPUT       (SG_DATA_EMPTY),
    	      .MUX_INPUTS       (wBuf128EmptyArray)
    	     );

    	mux
    	     #(
    	       .C_NUM_INPUTS        (C_NUM_MUXES/4),
    	       // Parameters
    	       .C_CLOG_NUM_INPUTS   (C_RD_SHIFT_BITS),
    	       .C_WIDTH   	    (128),
	           .C_MUX_TYPE          ("SELECT"))
    	mux_inst_fifo_data
    	     (
    	      // Inputs
    	      .MUX_SELECT       (rRdShift),
    	      // Outputs
    	      .MUX_OUTPUT       (SG_DATA),
    	      .MUX_INPUTS       (FIFO_RD_DATA)
    	     );
	end
endgenerate

endmodule