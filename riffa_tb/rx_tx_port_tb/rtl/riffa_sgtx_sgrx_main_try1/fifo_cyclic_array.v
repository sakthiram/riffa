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
// Filename:			fifo_cyclic_array.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			Receives data from the rx_engine and buffers the output 
//						for the RIFFA channel.
// Author:				Matt Jacobsen
// History:				@mattj: Version 2.0
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
module fifo_cyclic_array #(
	parameter C_DATA_WIDTH = 128,
	parameter NUM_FIFOS = 4,
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1)
)
(
	input CLK,
	input RST,
	input [C_DATA_WORD_WIDTH-1:0] WDATA_EN,
    output reg [NUM_FIFOS-1:0] FIFO_WR_EN
);

`include "functions.vh"

	localparam C_ROTATE_BITS = clog2s(NUM_FIFOS);
	localparam C_SELECT_WIDTH = NUM_FIFOS;


reg  [C_DATA_WORD_WIDTH-1:0]           				_rDataInEn;
reg  [C_DATA_WORD_WIDTH-1:0]           				rDataInEn;
wire	[NUM_FIFOS-1:0]					wWenShifted;
reg	[NUM_FIFOS-1:0]					rWenDefault;
reg  [C_ROTATE_BITS-1:0]				        _rFifoSelect;
reg  [C_ROTATE_BITS-1:0]					rFifoSelect;

	// WR EN calculation (FIFO select)
	rotate
	     #(
	       // Parameters
	       .C_DIRECTION         ("LEFT"),
	       .C_WIDTH             (NUM_FIFOS)
	      )
	fifo_select_rotate
	     (
	      // Outputs
	      .RD_DATA               (wWenShifted),
	      // Inputs
	      .WR_DATA               (rWenDefault),
	      .WR_SHIFTAMT           (rFifoSelect)
	     );

	always @ (posedge CLK) begin
		rDataInEn <= #1 (RST ? {C_ROTATE_BITS{1'b0}} : _rDataInEn);
		rFifoSelect <= #1 (RST ? 0 : _rFifoSelect);
		FIFO_WR_EN <= #1 (RST ? 0 : wWenShifted);
	end
	
	always @ (*) begin
		_rDataInEn = WDATA_EN;
		_rFifoSelect = rFifoSelect+_rDataInEn; // rFifoSelect is 2 bits (so rollover automatically happens)
	 	 rWenDefault = (1<<WDATA_EN)-1; 
	
	end 

endmodule
