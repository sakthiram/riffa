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
// Filename:			mux_cyclic_array.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			Receives data from the rx_engine and buffers the output 
//						for the RIFFA channel.
// Author:				Matt Jacobsen
// History:				@mattj: Version 2.0
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
module mux_cyclic_array #(
	parameter C_DATA_WIDTH = 128,
	parameter C_NUM_MUXES = 4,
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1)
)
(
	input CLK,
	input RST,
	input [C_DATA_WORD_WIDTH-1:0] DATA_EN,
	input [C_DATA_WIDTH-1:0] DATA,
	output [C_DATA_WIDTH-1:0] PACKED_DATA
);

`include "functions.vh"

	localparam C_ROTATE_BITS = clog2s(C_NUM_MUXES);
	localparam C_SELECT_WIDTH = C_NUM_MUXES;
   	localparam C_AGGREGATE_WIDTH = C_DATA_WIDTH;


reg  [C_DATA_WORD_WIDTH-1:0]           				_rDataInEn;
reg  [C_DATA_WORD_WIDTH-1:0]           				rDataInEn;
reg  [C_NUM_MUXES-1:0]            				rSelectRotated[C_NUM_MUXES-1:0], _rSelectRotated[C_NUM_MUXES-1:0];
reg  [C_DATA_WIDTH-1:0] 					_rDataIn;		 
reg  [C_DATA_WIDTH-1:0] 					rDataIn;		 



   	genvar i;
    	// ROTATE LOGIC (MUX select)
    	generate
    	    for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_rotates
    	        rotate
    	             #(
    	               // Parameters
    	               .C_DIRECTION         ("RIGHT"),
    	               .C_WIDTH             (C_NUM_MUXES)
    	              )
    	        select_rotate_inst_
    	             (
    	              // Outputs
    	              .RD_DATA               (_rSelectRotated[i]),
    	              // Inputs
    	              .WR_DATA               (rSelectRotated[i]),
    	              .WR_SHIFTAMT           (rDataInEn[C_ROTATE_BITS-1:0])
    	             );
    	    end
    	endgenerate

    	generate
    	    for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_multiplexers
    	        one_hot_mux
    	             #(
    	               .C_DATA_WIDTH        (32),
    	               // Parameters
    	               .C_SELECT_WIDTH      (C_SELECT_WIDTH),
    	               .C_AGGREGATE_WIDTH   (C_AGGREGATE_WIDTH))
    	        mux_inst_
    	             (
    	              // Inputs
    	              .ONE_HOT_SELECT       (rSelectRotated[i]),
    	              // Outputs
    	              .ONE_HOT_OUTPUT       (PACKED_DATA[32*i +: 32]),
    	              .ONE_HOT_INPUTS       (rDataIn)
    	             );
    	    end
    	endgenerate

    	generate
    	    for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_mux_select
    	        always @(posedge CLK) begin
    	    	rSelectRotated[i] <= #1 (RST ? 1<<i : _rSelectRotated[i]);
    	        end
    	    end
    	endgenerate
 
    always @ (posedge CLK) begin
    	rDataIn <= #1 _rDataIn;
    	rDataInEn <= #1 (RST ? {C_ROTATE_BITS{1'b0}} : _rDataInEn);
    end
    
    always @ (*) begin
    	_rDataIn = DATA;
    	_rDataInEn = DATA_EN;
    end 

endmodule
