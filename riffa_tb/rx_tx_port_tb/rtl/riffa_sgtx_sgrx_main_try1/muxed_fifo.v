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
// Filename:			muxed_fifo.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			
// Author:				Sakthi
// History:				@mattj: Version 2.0
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
module muxed_fifo #(
	parameter C_DATA_WIDTH = 9'd128,
	// Local parameters
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1),
	parameter C_SG_FIFO_DEPTH = 512,
    parameter USE_SINGLE_FIFO = 1
)
(
	input CLK,
	input RST,

	input [C_DATA_WIDTH-1:0] WR_DATA,				// Incoming data 
	input [C_DATA_WORD_WIDTH-1:0] WR_DATA_EN,		// Incoming data
	input WR_DATA_DONE,									// Incoming data complete
	input WR_DATA_ERR,									// Incoming data completed with error

	// newly added
	output [C_DATA_WIDTH-1:0] PACKED_DATA,				// Incoming data 
	output [4*(C_DATA_WIDTH/129+1)-1:0] FIFO_SELECT

	//output [63:0] SG_ELEM_ADDR,
	//output [31:0] SG_ELEM_LEN,
	//output SG_ELEM_RDY,
	//input  SG_ELEM_REN

);

`include "functions.vh"

    localparam C_NUM_MUXES =  4*(C_DATA_WIDTH/129+1);
    localparam C_ROTATE_BITS = clog2s(C_NUM_MUXES);
    localparam C_RD_SHIFT_BITS = clog2s(C_NUM_MUXES/4);
    localparam C_AGGREGATE_WIDTH = C_DATA_WIDTH;
    localparam C_SELECT_WIDTH = C_DATA_WIDTH/32;


wire [C_NUM_MUXES*32-1:0]						wPackedSgData;
wire											wSgFlush;

mux_cyclic_array #(
  .C_DATA_WIDTH  (C_DATA_WIDTH),
  .C_NUM_MUXES   (C_NUM_MUXES),
  .C_DATA_WORD_WIDTH  (clog2((C_DATA_WIDTH/32)+1))
)
mux_cyclic_array_inst 
(
  .CLK(CLK),
  .RST(RST),
  .DATA_EN(WR_DATA_EN),
  .DATA(WR_DATA), 
  .PACKED_DATA(wPackedSgData),
  .PACKED_DATA_EN(wPackedSgDataEn)
);

generate
    if (USE_SINGLE_FIFO == 1) begin
        FIFO_SELECT[0:0] = wPackedSgDataEn;
    end
    else begin
        fifo_cyclic_array #(
          .C_DATA_WIDTH (C_DATA_WIDTH),
          .NUM_FIFOS    (C_NUM_MUXES),
          .C_DATA_WORD_WIDTH (clog2((C_DATA_WIDTH/32)+1)),
          .C_FIFO_DEPTH (C_SG_FIFO_DEPTH)
        )
        fifo_cyclic_array_inst 
        (
          .CLK(CLK),
          .RST(RST),
          .WDATA_EN(WR_DATA_EN),
          .FIFO_SELECT(FIFO_SELECT)
        );
    end
endgenerate

endmodule
