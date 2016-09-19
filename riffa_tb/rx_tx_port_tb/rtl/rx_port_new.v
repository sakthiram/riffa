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
// Filename:			rx_port_128.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			Receives data from the rx_engine and buffers the output 
//						for the RIFFA channel.
// Author:				Matt Jacobsen
// History:				@mattj: Version 2.0
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
module rx_port_new #(
  parameter FIFO_TYPE = 2'd0,
	parameter C_DATA_WIDTH = 9'd128,
	parameter C_MAIN_FIFO_DEPTH = 1024,
	parameter C_SG_FIFO_DEPTH = 512,
	parameter C_MAX_READ_REQ = 2,					// Max read: 000=128B, 001=256B, 010=512B, 011=1024B, 100=2048B, 101=4096B
	// Local parameters
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1),
	parameter C_MAIN_FIFO_DEPTH_WIDTH = clog2((2**clog2(C_MAIN_FIFO_DEPTH))+1),
	parameter C_SG_FIFO_DEPTH_WIDTH = clog2((2**clog2(C_SG_FIFO_DEPTH))+1)
)
(
	input CLK,
	input RST,
	input [2:0] CONFIG_MAX_READ_REQUEST_SIZE,				// Maximum read payload: 000=128B, 001=256B, 010=512B, 011=1024B, 100=2048B, 101=4096B

	output SG_RX_BUF_RECVD,							// Scatter gather RX buffer completely read (ready for next if applicable)
	input [31:0] SG_RX_BUF_DATA,					// Scatter gather RX buffer data
	input SG_RX_BUF_LEN_VALID,						// Scatter gather RX buffer length valid
	input SG_RX_BUF_ADDR_HI_VALID,					// Scatter gather RX buffer high address valid
	input SG_RX_BUF_ADDR_LO_VALID,					// Scatter gather RX buffer low address valid

	output SG_TX_BUF_RECVD,							// Scatter gather TX buffer completely read (ready for next if applicable)
	input [31:0] SG_TX_BUF_DATA,					// Scatter gather TX buffer data
	input SG_TX_BUF_LEN_VALID,						// Scatter gather TX buffer length valid
	input SG_TX_BUF_ADDR_HI_VALID,					// Scatter gather TX buffer high address valid
	input SG_TX_BUF_ADDR_LO_VALID,					// Scatter gather TX buffer low address valid

	output [C_DATA_WIDTH-1:0] SG_DATA,				// Scatter gather TX buffer data
	output SG_DATA_EMPTY,							// Scatter gather TX buffer data empty
	input SG_DATA_REN,								// Scatter gather TX buffer data read enable
	input SG_RST,									// Scatter gather TX buffer data reset
	output SG_ERR,									// Scatter gather TX encountered an error
	
	input [31:0] TXN_DATA,							// Read transaction data
	input TXN_LEN_VALID,							// Read transaction length valid
	input TXN_OFF_LAST_VALID,						// Read transaction offset/last valid
	output [31:0] TXN_DONE_LEN,						// Read transaction actual transfer length
	output TXN_DONE,								// Read transaction done
	input TXN_DONE_ACK,								// Read transaction actual transfer length read

	output RX_REQ,									// Read request
	input RX_REQ_ACK,								// Read request accepted
	output [1:0] RX_REQ_TAG,						// Read request data tag 
	output [63:0] RX_REQ_ADDR,						// Read request address
	output [9:0] RX_REQ_LEN,						// Read request length

	input [C_DATA_WIDTH-1:0] MAIN_DATA,				// Main incoming data 
	input [C_DATA_WORD_WIDTH-1:0] MAIN_DATA_EN,		// Main incoming data enable
	input MAIN_DONE,								// Main incoming data complete
	input MAIN_ERR,									// Main incoming data completed with error
	input [C_DATA_WIDTH-1:0] SG_RX_DATA,			// Scatter gather for RX incoming data 
	input [C_DATA_WORD_WIDTH-1:0] SG_RX_DATA_EN,	// Scatter gather for RX incoming data enable
	input SG_RX_DONE,								// Scatter gather for RX incoming data complete
	input SG_RX_ERR,								// Scatter gather for RX incoming data completed with error
	input [C_DATA_WIDTH-1:0] SG_TX_DATA,			// Scatter gather for TX incoming data 
	input [C_DATA_WORD_WIDTH-1:0] SG_TX_DATA_EN,	// Scatter gather for TX incoming data enable
	input SG_TX_DONE,								// Scatter gather for TX incoming data complete
	input SG_TX_ERR,								// Scatter gather for TX incoming data completed with error

	input CHNL_CLK,									// Channel read clock
	output CHNL_RX,									// Channel read receive signal
	input CHNL_RX_ACK,								// Channle read received signal
	output CHNL_RX_LAST,							// Channel last read
	output [31:0] CHNL_RX_LEN,						// Channel read length
	output [30:0] CHNL_RX_OFF,						// Channel read offset
	output [C_DATA_WIDTH-1:0] CHNL_RX_DATA,			// Channel read data
	output CHNL_RX_DATA_VALID,						// Channel read data valid
	input CHNL_RX_DATA_REN,							// Channel read data has been recieved
	// newly added
	output [63:0] SG_ELEM_ADDR,
	output [31:0] SG_ELEM_LEN,
	output SG_ELEM_RDY,
	input  SG_ELEM_REN

);

`include "functions.vh"

    localparam C_NUM_MUXES =  4*(C_DATA_WIDTH/129+1);
    localparam C_ROTATE_BITS = clog2s(C_NUM_MUXES);
    localparam C_RD_SHIFT_BITS = clog2s(C_NUM_MUXES/4);
    localparam C_AGGREGATE_WIDTH = C_DATA_WIDTH;
    localparam C_SELECT_WIDTH = C_DATA_WIDTH/32;


wire	[C_NUM_MUXES*32-1:0]					wPackedSgData;
wire								wPackedSgDone;
wire								wPackedSgErr;
wire								wSgFlush;
reg  [C_ROTATE_BITS-1:0]				        _rFifoSelect;
reg  [C_ROTATE_BITS-1:0]					rFifoSelect;
reg  [C_RD_SHIFT_BITS-1:0]					_rRdShift;
reg  [C_RD_SHIFT_BITS-1:0]					rRdShift;

reg  [C_NUM_MUXES-1:0]            				rSelectRotated[C_NUM_MUXES-1:0], _rSelectRotated[C_NUM_MUXES-1:0];
wire								wSgFlushed;

wire [C_DATA_WIDTH/129:0]					wSgDataRen;
wire [C_DATA_WORD_WIDTH-1:0]		wSgDataEn;
wire 								wBuf128Ren;
wire [C_NUM_MUXES-1:0]						wSgRdDataEmpty;
wire 								wBuf128Empty;
wire [C_NUM_MUXES/4-1:0]					wBuf128EmptyArray;
wire [C_DATA_WIDTH-1:0]				wSgData;
wire [C_DATA_WIDTH-1:0]				wSgRdData;
wire [127:0]							wBuf128RdData;

reg		[4:0]						rWideRst=0;
reg								rRst=0;

// Generate a wide reset from the input reset.
always @ (posedge CLK) begin
	rRst <= #1 rWideRst[4]; 
	if (RST) 
		rWideRst <= #1 5'b11111;
	else 
		rWideRst <= (rWideRst<<1);
end

generate
if (FIFO_TYPE == 0) begin
  assign wSgDataEn = SG_RX_DATA_EN;
  assign wSgData   = SG_RX_DATA;
end
else if (FIFO_TYPE == 1) begin
  assign wSgDataEn = SG_TX_DATA_EN;
  assign wSgData   = SG_TX_DATA;
end
else if (FIFO_TYPE == 2) begin
  assign wSgDataEn = MAIN_DATA_EN;
  assign wSgData   = MAIN_DATA;
end
endgenerate

mux_cyclic_array #(
  .C_DATA_WIDTH  (C_DATA_WIDTH),
  .C_NUM_MUXES   (C_NUM_MUXES),
  .C_DATA_WORD_WIDTH  (clog2((C_DATA_WIDTH/32)+1))
)
mux_cyclic_array_inst 
(
  .CLK(CLK),
  .RST(rRst),
  .DATA_EN(wSgDataEn),
  .DATA(wSgData), 
  .PACKED_DATA(wPackedSgData)
);

fifo_cyclic_array #(
  .C_DATA_WIDTH (C_DATA_WIDTH),
  .NUM_FIFOS    (C_NUM_MUXES),
  .C_DATA_WORD_WIDTH (clog2((C_DATA_WIDTH/32)+1)),
  .C_FIFO_DEPTH (C_SG_FIFO_DEPTH)
)
fifo_cyclic_array_inst 
(
  .CLK(CLK),
  .RST(rRst),
  .WDATA_EN(wSgDataEn),
  .RDATA_EN(wSgDataRen),
  .WDATA(wPackedSgData),
  .RDATA(wSgRdData),
  .EMPTY_V(wSgRdDataEmpty)
);

always @ (posedge CLK) begin
	rFifoSelect <= #1 (rRst ? 0 : _rFifoSelect);
	rRdShift <= #1 (rRst ? 0 : _rRdShift);
end

always @ (*) begin
	_rFifoSelect = rFifoSelect+wSgDataEn; // rFifoSelect is 2 bits (so rollover automatically happens)
	if (rRst) 
		_rRdShift = 0;
	if (C_DATA_WIDTH <= 128)
		_rRdShift = 0;
	else if (SG_ELEM_REN == 1)
		_rRdShift = rRdShift+1;    
end 

// Multiple bits to 1 conversion => Requires MUX logic (else range unbound error)
//assign wBuf128Empty = wSgRdDataEmpty[4*(rRdShift+1)-1:4*(rRdShift+1)-1];

genvar i;

//TODO Demux Logic
generate
    for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
  assign wSgDataRen[i:i] = (i==rRdShift) ? wBuf128Ren : 0;
    end
endgenerate

if (C_DATA_WIDTH <= 128) begin
assign wBuf128Empty = wSgRdDataEmpty[3:3];
assign wBuf128RdData = wSgRdData;
end
    
generate 
	if (C_DATA_WIDTH > 128) begin

	for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
	    assign wBuf128EmptyArray[i:i] = wSgRdDataEmpty[4*(i+1)-1:4*(i+1)-1];
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
    	      .MUX_OUTPUT       (wBuf128Empty),
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
    	      .MUX_OUTPUT       (wBuf128RdData),
    	      .MUX_INPUTS       (wSgRdData)
    	     );
	end
endgenerate

sg_list_reader_128 sgListReader (
	.CLK(CLK),
	.RST(rRst),
	.BUF_DATA(wBuf128RdData),
	.BUF_DATA_EMPTY(wBuf128Empty), 
	.BUF_DATA_REN(wBuf128Ren),
	.VALID(SG_ELEM_RDY),
	.EMPTY(),
	.REN(SG_ELEM_REN),
	.ADDR(SG_ELEM_ADDR),
	.LEN(SG_ELEM_LEN)
);


endmodule
