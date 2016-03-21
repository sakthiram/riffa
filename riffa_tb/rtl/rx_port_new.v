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


wire	[C_NUM_MUXES*32-1:0]					wPackedSgRxData;
wire	[C_NUM_MUXES-1:0]					_wen;
reg	[C_NUM_MUXES-1:0]					wen, wWenDefault;
wire								wPackedSgRxDone;
wire								wPackedSgRxErr;
wire								wSgRxFlush;
reg  [C_ROTATE_BITS-1:0]				        _wfifoSelect;
reg  [C_ROTATE_BITS-1:0]					wfifoSelect;
reg  [C_RD_SHIFT_BITS-1:0]					_wRdShift;
reg  [C_RD_SHIFT_BITS-1:0]					wRdShift;
reg  [C_SELECT_WIDTH-1:0]           				_rDataInEn;
reg  [C_SELECT_WIDTH-1:0]           				rDataInEn;

reg [C_NUM_MUXES-1:0]            				wSelectRotated[C_NUM_MUXES-1:0], _wSelectRotated[C_NUM_MUXES-1:0];
wire								wSgRxFlushed;
reg  [C_DATA_WIDTH-1:0] 					_rDataIn;		 
reg  [C_DATA_WIDTH-1:0] 					rDataIn;		 

wire 								wSgRxDataRen[C_DATA_WIDTH/129:0];
wire 								wBuf128Ren;
wire [C_NUM_MUXES-1:0]						wSgRxDataEmpty;
wire 								wBuf128Empty;
wire [C_NUM_MUXES/4-1:0]					wBuf128EmptyArray;
wire [C_NUM_MUXES*32-1:0]					wSgRxData;
wire [127:0]							wBuf128RdData;

reg		[4:0]						rWideRst=0;
reg									rRst=0;

// Generate a wide reset from the input reset.
always @ (posedge CLK) begin
	rRst <= #1 rWideRst[4]; 
	if (RST) 
		rWideRst <= #1 5'b11111;
	else 
		rWideRst <= (rWideRst<<1);
end

    genvar i;

// ROTATE LOGIC (MUX select)
    generate
        for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_rotates
            rotate
                 #(
                   // Parameters
                   .C_DIRECTION         ("RIGHT"),
                   .C_WIDTH             (C_NUM_MUXES)
                   /*AUTOINSTPARAM*/)
            select_rotate_inst_
                 (
                  // Outputs
                  .RD_DATA               (_wSelectRotated[i]),
                  // Inputs
                  .WR_DATA               (wSelectRotated[i]),
                  .WR_SHIFTAMT           (rDataInEn[C_ROTATE_BITS-1:0])
                  /*AUTOINST*/);
        end
    endgenerate

    // WR EN calculation (FIFO select)
    rotate
         #(
           // Parameters
           .C_DIRECTION         ("LEFT"),
           .C_WIDTH             (C_NUM_MUXES)
           /*AUTOINSTPARAM*/)
    fifo_select_rotate
         (
          // Outputs
          .RD_DATA               (_wen),
          // Inputs
          .WR_DATA               (wWenDefault),
          .WR_SHIFTAMT           (wfifoSelect)
          /*AUTOINST*/);

    generate
        for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_multiplexers
            one_hot_mux
                 #(
                   .C_DATA_WIDTH        (32),
                   /*AUTOINSTPARAM*/
                   // Parameters
                   .C_SELECT_WIDTH      (C_SELECT_WIDTH),
                   .C_AGGREGATE_WIDTH   (C_AGGREGATE_WIDTH))
            mux_inst_
                 (
                  // Inputs
                  .ONE_HOT_SELECT       (wSelectRotated[i]),
                  // Outputs
                  .ONE_HOT_OUTPUT       (wPackedSgRxData[32*i +: 32]),
                  .ONE_HOT_INPUTS       (rDataIn)
                  /*AUTOINST*/);
        end
    endgenerate

    generate
        for (i = 0; i < C_NUM_MUXES; i = i + 1) begin : gen_mux_select
            always @(posedge CLK) begin
		wSelectRotated[i] <= #1 (rRst ? 1<<i : _wSelectRotated[i]);
            end
        end
    endgenerate
 
always @ (posedge CLK) begin
	rDataIn <= #1 _rDataIn;
	rDataInEn <= #1 (rRst ? {C_ROTATE_BITS{1'b0}} : _rDataInEn);
	wfifoSelect <= #1 (rRst ? 0 : _wfifoSelect);
	wRdShift <= #1 (rRst ? 0 : _wRdShift);
	wen <= #1 (rRst ? 0 : _wen);
end

always @ (*) begin
	// Buffer and mask the input data.
	_rDataIn = SG_RX_DATA;
	_rDataInEn = SG_RX_DATA_EN;
	_wfifoSelect = wfifoSelect+_rDataInEn; // wfifoSelect is 2 bits (so rollover automatically happens)

	if (rRst) 
		_wRdShift = 0;
	if (C_DATA_WIDTH <= 128)
		_wRdShift = 0;
	else if (SG_ELEM_REN == 1)
		_wRdShift = wRdShift+1;

 	 //wWenDefault = {C_DATA_WIDTH/32{SG_RX_DATA_EN}}; 
 	 wWenDefault = (1<<SG_RX_DATA_EN)-1; 

end 

    generate
        for (i = 0; i < 4*(C_DATA_WIDTH/129+1); i = i + 1) begin : gen_fifos
	   (* RAM_STYLE="BLOCK" *)
	   sync_fifo #(.C_WIDTH(32), .C_DEPTH(C_SG_FIFO_DEPTH), .C_PROVIDE_COUNT(1)) sgRxFifo_ 
                 (
		   .RST(rRst),
		   .CLK(CLK),
		   .WR_EN(wen[i:i]),
		   .WR_DATA(wPackedSgRxData[32*(i+1)-1:32*i]),
		   .FULL(),
		   .RD_EN(wSgRxDataRen[i/4] && ~wSgRxDataEmpty[4*(i/5+1)-1:4*(i/5+1)-1]),
		   .RD_DATA(wSgRxData[32*(i+1)-1:32*i]),
		   .EMPTY(wSgRxDataEmpty[i:i]),
		   .COUNT()
                  );
        end
    endgenerate

// Multiple bits to 1 conversion => Requires MUX logic (else range unbound error)
//assign wBuf128Empty = wSgRxDataEmpty[4*(wRdShift+1)-1:4*(wRdShift+1)-1];

    generate
        for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
	    assign wSgRxDataRen[i] = (i==wRdShift) ? wBuf128Ren : 0;
        end
    endgenerate

    if (C_DATA_WIDTH <= 128) begin
    assign wBuf128Empty = wSgRxDataEmpty[3:3];
    assign wBuf128RdData = wSgRxData;
    end
    
    generate 
	if (C_DATA_WIDTH > 128) begin

	for (i = 0; i < C_NUM_MUXES/4; i = i + 1) begin : gen_rx_data_ren
	    assign wBuf128EmptyArray[i:i] = wSgRxDataEmpty[4*(i+1)-1:4*(i+1)-1];
        end


    	mux
    	     #(
    	       .C_NUM_INPUTS        (C_NUM_MUXES/4),
    	       /*AUTOINSTPARAM*/
    	       // Parameters
    	       .C_CLOG_NUM_INPUTS   (C_RD_SHIFT_BITS),
    	       .C_WIDTH   	    (1),
	       .C_MUX_TYPE          ("SELECT"))
    	mux_inst_fifo_empty
    	     (
    	      // Inputs
    	      .MUX_SELECT       (wRdShift),
    	      // Outputs
    	      .MUX_OUTPUT       (wBuf128Empty),
    	      .MUX_INPUTS       (wBuf128EmptyArray)
    	      /*AUTOINST*/);

    	mux
    	     #(
    	       .C_NUM_INPUTS        (C_NUM_MUXES/4),
    	       /*AUTOINSTPARAM*/
    	       // Parameters
    	       .C_CLOG_NUM_INPUTS   (C_RD_SHIFT_BITS),
    	       .C_WIDTH   	    (128),
	       .C_MUX_TYPE          ("SELECT"))
    	mux_inst_fifo_data
    	     (
    	      // Inputs
    	      .MUX_SELECT       (wRdShift),
    	      // Outputs
    	      .MUX_OUTPUT       (wBuf128RdData),
    	      .MUX_INPUTS       (wSgRxData)
    	      /*AUTOINST*/);
	end
    endgenerate

// TODO read logic for 256/512 logic to be updated
// currently C_DATA_WIDTH parameter is fixed, so need to pass
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
