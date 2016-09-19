`timescale 1ns/1ps

module rx_port_128_tb;

`include "functions.vh"

	parameter FIFO_TYPE = 2'b0;
	parameter C_DATA_WIDTH = 10'd256;
	parameter C_MAX_READ_REQ = 2;					// Max read: 000=128B, 001=256B, 010=512B, 011=1024B, 100=2048B, 101=4096B
	// Local parameters
	parameter C_RX_FIFO_DEPTH = 1024;
	parameter C_TX_FIFO_DEPTH = 512;
	parameter C_SG_FIFO_DEPTH = 1024;
	parameter C_DATA_WORD_WIDTH = clog2((C_DATA_WIDTH/32)+1);

	wire [2:0] CONFIG_MAX_READ_REQUEST_SIZE;		// Maximum read payload: 000=128B; 001=256B; 010=512B; 011=1024B; 100=2048B; 101=4096B
	wire [2:0] CONFIG_MAX_PAYLOAD_SIZE;			// Maximum write payload: 000=128B; 001=256B; 010=512B; 011=1024B

	wire [31:0] PIO_DATA;							// Single word programmed I/O data
	reg  [C_DATA_WIDTH-1:0] ENG_DATA;				// Main incoming data 

	wire SG_RX_BUF_RECVD;							// Scatter gather RX buffer completely read (ready for next if applicable)
	wire SG_RX_BUF_LEN_VALID;						// Scatter gather RX buffer length valid
	wire SG_RX_BUF_ADDR_HI_VALID;					// Scatter gather RX buffer high address valid
	wire SG_RX_BUF_ADDR_LO_VALID;					// Scatter gather RX buffer low address valid

	wire SG_TX_BUF_RECVD;							// Scatter gather TX buffer completely read (ready for next if applicable)
	wire SG_TX_BUF_LEN_VALID;						// Scatter gather TX buffer length valid
	wire SG_TX_BUF_ADDR_HI_VALID;					// Scatter gather TX buffer high address valid
	wire SG_TX_BUF_ADDR_LO_VALID;					// Scatter gather TX buffer low address valid

	wire TXN_RX_LEN_VALID;							// Read transaction length valid
	wire TXN_RX_OFF_LAST_VALID;					// Read transaction offset/last valid
	wire [31:0] TXN_RX_DONE_LEN;					// Read transaction actual transfer length
	wire TXN_RX_DONE;								// Read transaction done
	wire TXN_RX_DONE_ACK;							// Read transaction actual transfer length read

	wire TXN_TX;									// Write transaction notification
	wire TXN_TX_ACK;								// Write transaction acknowledged
	wire [31:0] TXN_TX_LEN;						// Write transaction length
	wire [31:0] TXN_TX_OFF_LAST;					// Write transaction offset/last
	wire [31:0] TXN_TX_DONE_LEN;					// Write transaction actual transfer length
	wire TXN_TX_DONE;								// Write transaction done
	wire TXN_TX_DONE_ACK;							// Write transaction actual transfer length read

	wire RX_REQ;									// Read request
	wire RX_REQ_ACK;								// Read request accepted
	wire [1:0] RX_REQ_TAG;						// Read request data tag 
	wire [63:0] RX_REQ_ADDR;						// Read request address
	wire [9:0] RX_REQ_LEN;						// Read request length

	wire TX_REQ;									// Outgoing write request
	wire TX_REQ_ACK;								// Outgoing write request acknowledged
	wire [63:0] TX_ADDR;							// Outgoing write high address
	wire [9:0] TX_LEN;							// Outgoing write length (in 32 bit words)
	wire [C_DATA_WIDTH-1:0] TX_DATA;				// Outgoing write data
	wire TX_DATA_REN;								// Outgoing write data read enable
	wire TX_SENT;									// Outgoing write complete

	wire [C_DATA_WORD_WIDTH-1:0] MAIN_DATA_EN;		// Main incoming data enable
	wire MAIN_DONE;								// Main incoming data complete
	wire MAIN_ERR;									// Main incoming data completed with error

	reg  [C_DATA_WORD_WIDTH-1:0] SG_DATA_EN;	// Scatter gather for RX incoming data enable
	wire [C_DATA_WORD_WIDTH-1:0] SG_RX_DATA_EN;	// Scatter gather for RX incoming data enable
	reg  SG_DONE;								// Scatter gather for RX incoming data complete
	wire SG_RX_DONE;								// Scatter gather for RX incoming data complete
	reg  SG_ERR;								// Scatter gather for RX incoming data completed with error
	wire SG_RX_ERR;								// Scatter gather for RX incoming data completed with error

	wire [C_DATA_WORD_WIDTH-1:0] SG_TX_DATA_EN;	// Scatter gather for TX incoming data enable
	wire SG_TX_DONE;								// Scatter gather for TX incoming data complete
	wire SG_TX_ERR;								// Scatter gather for TX incoming data completed with error

	wire CHNL_RX_CLK;									// Channel read clock
	wire CHNL_RX;									// Channel read receive signal
	wire CHNL_RX_ACK;								// Channle read received signal
	wire CHNL_RX_LAST;							// Channel last read
	wire [31:0] CHNL_RX_LEN;						// Channel read length
	wire [30:0] CHNL_RX_OFF;						// Channel read offset
	wire [C_DATA_WIDTH-1:0] CHNL_RX_DATA;			// Channel read data
	wire CHNL_RX_DATA_VALID;						// Channel read data valid
	wire CHNL_RX_DATA_REN; 						// Channel read data has been recieved

	wire CHNL_TX_CLK;								// Channel write clock
	wire CHNL_TX;									// Channel write receive signal
	wire CHNL_TX_ACK;								// Channel write acknowledgement signal
	wire CHNL_TX_LAST;								// Channel last write
	wire [31:0] CHNL_TX_LEN;						// Channel write length (in 32 bit words)
	wire [30:0] CHNL_TX_OFF;						// Channel write offset
	wire [C_DATA_WIDTH-1:0] CHNL_TX_DATA;			// Channel write data
	wire CHNL_TX_DATA_VALID;						// Channel write data valid
	wire CHNL_TX_DATA_REN;							// Channel write data has been recieved

	reg CLK;
	reg RST;
	reg state=0;
	reg     wSgElemRen;
	wire	wSgElemRdy;
	wire	[63:0]	wSgElemAddr;
	wire	[31:0]	wSgElemLen;

	reg		[4:0]						rWideRst=0;
	reg								rRst=0;

// Receiving port (data to the channel)
rx_port_128 #(
//	.FIFO_TYPE(FIFO_TYPE), 
	.C_DATA_WIDTH(C_DATA_WIDTH), 
	.C_MAIN_FIFO_DEPTH(C_RX_FIFO_DEPTH), 
	.C_SG_FIFO_DEPTH(C_SG_FIFO_DEPTH),
	.C_MAX_READ_REQ(C_MAX_READ_REQ)
) rxPort (
	.RST(RST), 
	.CLK(CLK), 
	.CONFIG_MAX_READ_REQUEST_SIZE(CONFIG_MAX_READ_REQUEST_SIZE), 
	
	.SG_RX_BUF_RECVD(SG_RX_BUF_RECVD),
	.SG_RX_BUF_DATA(PIO_DATA),
	.SG_RX_BUF_LEN_VALID(SG_RX_BUF_LEN_VALID),
	.SG_RX_BUF_ADDR_HI_VALID(SG_RX_BUF_ADDR_HI_VALID),
	.SG_RX_BUF_ADDR_LO_VALID(SG_RX_BUF_ADDR_LO_VALID),
	
	.SG_TX_BUF_RECVD(SG_TX_BUF_RECVD),
	.SG_TX_BUF_DATA(PIO_DATA),
	.SG_TX_BUF_LEN_VALID(SG_TX_BUF_LEN_VALID),
	.SG_TX_BUF_ADDR_HI_VALID(SG_TX_BUF_ADDR_HI_VALID),
	.SG_TX_BUF_ADDR_LO_VALID(SG_TX_BUF_ADDR_LO_VALID),
	
	.SG_DATA(wTxSgData),
	.SG_DATA_EMPTY(wTxSgDataEmpty),
	.SG_DATA_REN(wTxSgDataRen),
	.SG_RST(wTxSgDataRst),
	.SG_ERR(wTxSgDataErr),
	
	.TXN_DATA(PIO_DATA), 
	.TXN_LEN_VALID(TXN_RX_LEN_VALID), 
	.TXN_OFF_LAST_VALID(TXN_RX_OFF_LAST_VALID), 
	.TXN_DONE_LEN(TXN_RX_DONE_LEN),
	.TXN_DONE(TXN_RX_DONE),
	.TXN_DONE_ACK(TXN_RX_DONE_ACK),
	
	.RX_REQ(RX_REQ),
	.RX_REQ_ACK(RX_REQ_ACK),
	.RX_REQ_TAG(RX_REQ_TAG),
	.RX_REQ_ADDR(RX_REQ_ADDR),
	.RX_REQ_LEN(RX_REQ_LEN),

	.MAIN_DATA(ENG_DATA),
	.MAIN_DATA_EN(MAIN_DATA_EN), 
	.MAIN_DONE(MAIN_DONE), 
	.MAIN_ERR(MAIN_ERR),
	
	.SG_RX_DATA(ENG_DATA),
	.SG_RX_DATA_EN(SG_RX_DATA_EN), 
	.SG_RX_DONE(SG_RX_DONE), 
	.SG_RX_ERR(SG_RX_ERR),

	.SG_TX_DATA(ENG_DATA),
	.SG_TX_DATA_EN(SG_TX_DATA_EN), 
	.SG_TX_DONE(SG_TX_DONE), 
	.SG_TX_ERR(SG_TX_ERR),

	.CHNL_CLK(CHNL_RX_CLK), 
	.CHNL_RX(CHNL_RX), 
	.CHNL_RX_ACK(CHNL_RX_ACK), 
	.CHNL_RX_LAST(CHNL_RX_LAST), 
	.CHNL_RX_LEN(CHNL_RX_LEN), 
	.CHNL_RX_OFF(CHNL_RX_OFF), 
	.CHNL_RX_DATA(CHNL_RX_DATA), 
	.CHNL_RX_DATA_VALID(CHNL_RX_DATA_VALID), 
	.CHNL_RX_DATA_REN(CHNL_RX_DATA_REN),

	.SG_ELEM_ADDR(wSgElemAddr), 
	.SG_ELEM_LEN(wSgElemLen),
	.SG_ELEM_RDY(wSgElemRdy),
	.SG_ELEM_REN(wSgElemRen)
);

// Sending port (data from the channel)
tx_port_128 #(
	.C_DATA_WIDTH(C_DATA_WIDTH), 
	.C_FIFO_DEPTH(C_TX_FIFO_DEPTH)
) txPort (
	.CLK(CLK), 
	.RST(RST), 
	.CONFIG_MAX_PAYLOAD_SIZE(CONFIG_MAX_PAYLOAD_SIZE), 
	
	.TXN(TXN_TX),
	.TXN_ACK(TXN_TX_ACK),
	.TXN_LEN(TXN_TX_LEN),
	.TXN_OFF_LAST(TXN_TX_OFF_LAST),
	.TXN_DONE_LEN(TXN_TX_DONE_LEN),
	.TXN_DONE(TXN_TX_DONE),
	.TXN_DONE_ACK(TXN_TX_DONE_ACK),
	
	.SG_DATA(wTxSgData),
	.SG_DATA_EMPTY(wTxSgDataEmpty),
	.SG_DATA_REN(wTxSgDataRen),
	.SG_RST(wTxSgDataRst),
	.SG_ERR(wTxSgDataErr),
	
	.TX_REQ(TX_REQ), 
	.TX_REQ_ACK(TX_REQ_ACK),
	.TX_ADDR(TX_ADDR), 
	.TX_LEN(TX_LEN), 
	.TX_DATA(TX_DATA),
	.TX_DATA_REN(TX_DATA_REN), 
	.TX_SENT(TX_SENT),

	.CHNL_CLK(CHNL_TX_CLK), 
	.CHNL_TX(CHNL_TX), 
	.CHNL_TX_ACK(CHNL_TX_ACK),
	.CHNL_TX_LAST(CHNL_TX_LAST), 
	.CHNL_TX_LEN(CHNL_TX_LEN), 
	.CHNL_TX_OFF(CHNL_TX_OFF), 
	.CHNL_TX_DATA(CHNL_TX_DATA), 
	.CHNL_TX_DATA_VALID(CHNL_TX_DATA_VALID), 
	.CHNL_TX_DATA_REN(CHNL_TX_DATA_REN)
);

	// Generate a wide reset from the input reset.
	always @ (posedge CLK) begin
		rRst <= #1 rWideRst[4]; 
		if (RST) 
			rWideRst <= #1 5'b11111;
		else 
			rWideRst <= (rWideRst<<1);
	end

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
	always @ (posedge CLK or posedge rRst) begin
		if (rRst)
			iPktCount <= 1;
		else 
			iPktCount <= iPktCount + 1;


		if (rRst) begin
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

	if (FIFO_TYPE == 0) begin
	  assign SG_RX_DATA_EN = SG_DATA_EN;
	  assign SG_RX_DONE    = SG_DONE;
	  assign SG_RX_ERR     = SG_ERR;
	end
	else if (FIFO_TYPE == 1) begin
	  assign SG_TX_DATA_EN = SG_DATA_EN;
	  assign SG_TX_DONE    = SG_DONE;
	  assign SG_TX_ERR     = SG_ERR;

	end
	else if (FIFO_TYPE == 2) begin
	  assign MAIN_DATA_EN = SG_DATA_EN;
	  assign MAIN_DONE    = SG_DONE;
	  assign MAIN_ERR     = SG_ERR;

	end


	always @ (posedge CLK) begin
		if (rRst) begin
			ENG_DATA <= 512'h0;
			SG_DATA_EN <= 3'h0;
			SG_DONE <= 0;
			SG_ERR <= 0;
		end
		else begin
			//case (iPktCount)
			
			//0 : begin
				SG_DATA_EN <= {$random}%(C_DATA_WIDTH/32+1);
				SG_DONE <= {$random}%2;
				ENG_DATA <= {$unsigned($random), $unsigned($random), $unsigned($random), $unsigned($random), 
					     $unsigned($random), $unsigned($random), $unsigned($random), $unsigned($random),
					     $unsigned($random), $unsigned($random), $unsigned($random), $unsigned($random),
					     $unsigned($random), $unsigned($random), $unsigned($random), $unsigned($random)};
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
