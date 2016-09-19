`timescale 1ns/1ps

module rx_SG_packer_reader_tb;

`include "functions.vh"

	parameter C_DATA_WIDTH = 9'd128;
	parameter C_MAIN_FIFO_DEPTH = 1024;
	parameter C_SG_FIFO_DEPTH = 512;
	parameter C_MAX_READ_REQ = 2;					// Max read: 000=128B; 001=256B; 010=512B; 011=1024B; 100=2048B; 101=4096B
	// Local parameters
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1);
	parameter C_MAIN_FIFO_DEPTH_WIDTH = clog2((2**clog2(C_MAIN_FIFO_DEPTH))+1);
	parameter C_SG_FIFO_DEPTH_WIDTH = clog2((2**clog2(C_SG_FIFO_DEPTH))+1);

	reg CLK;
	reg RST;
	wire [2:0] CONFIG_MAX_READ_REQUEST_SIZE;				// Maximum read payload: 000=128B; 001=256B; 010=512B; 011=1024B; 100=2048B; 101=4096B

	wire SG_RX_BUF_RECVD;							// Scatter gather RX buffer completely read (ready for next if applicable)
	wire [31:0] SG_RX_BUF_DATA;					// Scatter gather RX buffer data
	wire SG_RX_BUF_LEN_VALID;						// Scatter gather RX buffer length valid
	wire SG_RX_BUF_ADDR_HI_VALID;					// Scatter gather RX buffer high address valid
	wire SG_RX_BUF_ADDR_LO_VALID;					// Scatter gather RX buffer low address valid

	wire SG_TX_BUF_RECVD;							// Scatter gather TX buffer completely read (ready for next if applicable)
	wire [31:0] SG_TX_BUF_DATA;					// Scatter gather TX buffer data
	wire SG_TX_BUF_LEN_VALID;						// Scatter gather TX buffer length valid
	wire SG_TX_BUF_ADDR_HI_VALID;					// Scatter gather TX buffer high address valid
	wire SG_TX_BUF_ADDR_LO_VALID;					// Scatter gather TX buffer low address valid

	wire [C_DATA_WIDTH-1:0] SG_DATA;				// Scatter gather TX buffer data
	wire SG_DATA_EMPTY;							// Scatter gather TX buffer data empty
	wire SG_DATA_REN;								// Scatter gather TX buffer data read enable
	wire SG_RST;									// Scatter gather TX buffer data reset
	wire SG_ERR;									// Scatter gather TX encountered an error
	
	wire [31:0] TXN_DATA;							// Read transaction data
	wire TXN_LEN_VALID;							// Read transaction length valid
	wire TXN_OFF_LAST_VALID;						// Read transaction offset/last valid
	wire [31:0] TXN_DONE_LEN;						// Read transaction actual transfer length
	wire TXN_DONE;								// Read transaction done
	wire TXN_DONE_ACK;								// Read transaction actual transfer length read

	wire RX_REQ;									// Read request
	wire RX_REQ_ACK;								// Read request accepted
	wire [1:0] RX_REQ_TAG;						// Read request data tag 
	wire [63:0] RX_REQ_ADDR;						// Read request address
	wire [9:0] RX_REQ_LEN;						// Read request length

	wire [C_DATA_WIDTH-1:0] MAIN_DATA;				// Main incoming data 
	wire [C_DATA_WORD_WIDTH-1:0] MAIN_DATA_EN;		// Main incoming data enable
	wire MAIN_DONE;								// Main incoming data complete
	wire MAIN_ERR;									// Main incoming data completed with error
	reg [C_DATA_WIDTH-1:0] SG_RX_DATA;			// Scatter gather for RX incoming data 
	reg [C_DATA_WORD_WIDTH-1:0] SG_RX_DATA_EN;	// Scatter gather for RX incoming data enable
	reg SG_RX_DONE;								// Scatter gather for RX incoming data complete
	reg SG_RX_ERR;								// Scatter gather for RX incoming data completed with error
	wire [C_DATA_WIDTH-1:0] SG_TX_DATA;			// Scatter gather for TX incoming data 
	wire [C_DATA_WORD_WIDTH-1:0] SG_TX_DATA_EN;	// Scatter gather for TX incoming data enable
	wire SG_TX_DONE;								// Scatter gather for TX incoming data complete
	wire SG_TX_ERR;								// Scatter gather for TX incoming data completed with error

	wire CHNL_CLK;									// Channel read clock
	wire CHNL_RX;									// Channel read receive signal
	wire CHNL_RX_ACK;								// Channle read received signal
	wire CHNL_RX_LAST;							// Channel last read
	wire [31:0] CHNL_RX_LEN;						// Channel read length
	wire [30:0] CHNL_RX_OFF;						// Channel read offset
	wire [C_DATA_WIDTH-1:0] CHNL_RX_DATA;			// Channel read data
	wire CHNL_RX_DATA_VALID;						// Channel read data valid
	wire CHNL_RX_DATA_REN;							// Channel read data has been recieved

wire	[C_DATA_WIDTH-1:0]			wPackedMainData;
wire								wPackedMainWen;
wire								wPackedMainDone;
wire								wPackedMainErr;
wire								wMainFlush;
wire								wMainFlushed;

wire	[C_DATA_WIDTH-1:0]			wPackedSgRxData;
wire								wPackedSgRxWen;
wire								wPackedSgRxDone;
wire								wPackedSgRxErr;
wire								wSgRxFlush;
wire								wSgRxFlushed;

wire	[C_DATA_WIDTH-1:0]			wPackedSgTxData;
wire								wPackedSgTxWen;
wire								wPackedSgTxDone;
wire								wPackedSgTxErr;
wire								wSgTxFlush;
wire								wSgTxFlushed;

wire								wMainDataRen;
wire								wMainDataEmpty;
wire	[C_DATA_WIDTH-1:0]			wMainData;

wire								wSgRxRst;
wire								wSgRxDataRen;
wire								wSgRxDataEmpty;
wire	[C_DATA_WIDTH-1:0]			wSgRxData;
wire	[C_SG_FIFO_DEPTH_WIDTH-1:0]	wSgRxFifoCount;

wire								wSgTxRst;
wire	[C_SG_FIFO_DEPTH_WIDTH-1:0]	wSgTxFifoCount;

wire								wSgRxReq;
wire	[63:0]						wSgRxReqAddr;
wire	[9:0]						wSgRxReqLen;

wire								wSgTxReq;
wire	[63:0]						wSgTxReqAddr;
wire	[9:0]						wSgTxReqLen;

wire								wSgRxReqProc;
wire								wSgTxReqProc;
wire								wMainReqProc;
wire								wReqAck;

wire								wSgElemRdy;
reg								wSgElemRen;
wire	[63:0]						wSgElemAddr;
wire	[31:0]						wSgElemLen;

wire								wSgRst;
wire								wMainReq;
wire	[63:0]						wMainReqAddr;
wire	[9:0]						wMainReqLen;
wire								wTxnErr;
wire								wChnlRx;
wire								wChnlRxRecvd;
wire								wChnlRxAckRecvd;
wire								wChnlRxLast;
wire	[31:0]						wChnlRxLen;
wire	[30:0]						wChnlRxOff;
wire	[31:0]						wChnlRxConsumed;

reg		[4:0]						rWideRst=0;
reg									rRst=0;
reg             state=0;

fifo_packer_128 sgRxFifoPacker (
	.CLK(CLK),
	.RST(RST),
	.DATA_IN(SG_RX_DATA),
	.DATA_IN_EN(SG_RX_DATA_EN),
	.DATA_IN_DONE(SG_RX_DONE),
	.DATA_IN_ERR(SG_RX_ERR),
	.DATA_IN_FLUSH(wSgRxFlush),
	.PACKED_DATA(wPackedSgRxData),
	.PACKED_WEN(wPackedSgRxWen),
	.PACKED_DATA_DONE(wPackedSgRxDone),
	.PACKED_DATA_ERR(wPackedSgRxErr),
	.PACKED_DATA_FLUSHED(wSgRxFlushed)
);
(* RAM_STYLE="BLOCK" *)
sync_fifo #(.C_WIDTH(C_DATA_WIDTH), .C_DEPTH(C_SG_FIFO_DEPTH), .C_PROVIDE_COUNT(1)) sgRxFifo (
	.RST(RST),
	.CLK(CLK),
	.WR_EN(wPackedSgRxWen),
	.WR_DATA(wPackedSgRxData),
	.FULL(),
	.RD_EN(wSgRxDataRen),
	.RD_DATA(wSgRxData),
	.EMPTY(wSgRxDataEmpty),
	.COUNT(wSgRxFifoCount)
);
sg_list_reader_128 #(.C_DATA_WIDTH(C_DATA_WIDTH)) sgListReader (
	.CLK(CLK),
	.RST(RST),
	.BUF_DATA(wSgRxData),
	.BUF_DATA_EMPTY(wSgRxDataEmpty),
	.BUF_DATA_REN(wSgRxDataRen),
	.VALID(wSgElemRdy),
	.EMPTY(),
	.REN(wSgElemRen),
	.ADDR(wSgElemAddr),
	.LEN(wSgElemLen)
);


	// Generate clock
	initial begin
		CLK = 0;
		#100;
		forever #2.5 CLK = ~CLK;
	end
	
	// Generate reset
	initial begin
		RST = 0;
		#100;
		RST = 1;
		#5;
		RST = 0;
	end
	


	integer iPktCount;
	always @ (posedge CLK or posedge RST) begin
		if (RST)
			iPktCount <= 1;
		else 
			iPktCount <= iPktCount + 1;


		if (RST) begin
			wSgElemRen <= 0;
			state <= 0;
		end

		if (wSgElemRdy) begin
			wSgElemRen <= 1;
			state <= 0;
		end

		if (state == 0) begin
			wSgElemRen <= 0;
			state <= 1;
		end

	end

	always @ (posedge CLK) begin
		if (RST) begin
			SG_RX_DATA <= 128'h0;
			SG_RX_DATA_EN <= 3'h0;
			SG_RX_DONE <= 0;
			SG_RX_ERR <= 0;
		end
		else begin
			//case (iPktCount)
			
			//0 : begin
				SG_RX_DATA_EN <= {$random}%5;
				SG_RX_DONE <= {$random}%2;
				SG_RX_DATA <= {$unsigned($random), $unsigned($random), $unsigned($random), $unsigned($random)};
			//end

			//1 : begin
			//	SG_RX_DATA_EN <= #1 3'h4;
			//	SG_RX_DONE <= #1 3'h7;
			//	SG_RX_DATA <= #1 {32'hBBBB_FFFF, 32'h1111_ACDF, 32'hFCCF_ABCD,32'h1234_9876};
			//end

			//2 : begin
			//	SG_RX_DATA_EN <= #1 3'h2;
			//	SG_RX_DONE <= #1 3'h1;
			//	SG_RX_DATA <= #1 {32'hFD12_EEEF, 32'hA345_1834, 32'h1526_AEFC,32'hAAAA_DDDD};
			//end
			//endcase
		end
	end


endmodule
