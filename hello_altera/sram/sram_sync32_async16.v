
/*
sram_sync32_async16.dot
digraph sram_sync32_async16 {
	rankdir=LR;

	node [shape = circle];
	
	SpntBegin [shape=point];
	//SpntEnd [shape=point];
	Sidle4A [shape=ellipse,label="STATE_IDLE_4A"];
	Sw1 [label=".",label="STATE_W1_OUTPUT_ADDR_DATA"];
	Sw21 [label=".",label="STATE_W2_OUTPUT_ADDR_DATA_1"];
	Sw22 [label=".",label="STATE_W2_OUTPUT_NONE"];
	Sw23 [label=".",label="STATE_W2_OUTPUT_ADDR_DATA_2"];
	Sr11 [label=".",label="STATE_R1_OUTPUT_ADDR"];
	Sidle4R [label=".",label="STATE_IDLE_4R_UPSTREAM_DATA"];
	Sr21 [label=".",label="STATE_R2_OUTPUT_ADDR_1"];
	Sr22 [label=".",label="STATE_R2_OUTPUT_ADDR_2"];
	Serr [label=".",label="STATE_ERR"];
	  
	SpntBegin -> Sidle4A ;
	
	Sidle4A->Sidle4A[label="not read,not write"];
	
	Sidle4A->Sw1[label="single word write"];
	Sw1->Sidle4A;
	
	Sidle4A -> Sw21[label="double word write"] ;
	Sw21 -> Sw22;
	Sw22 -> Sw23;
	Sw23->Sidle4A;
	
	Sidle4A -> Sr11[label="single world read"] ;
	Sidle4R -> Sr11[label="single world read"] ;
	Sr11 -> Sidle4R;
	Sidle4R -> Sidle4A;
	
	Sidle4A->Sr21[label="double world read"];
	Sidle4R->Sr21[label="double world read"];
	Sr21 -> Sr22 ;
	Sr22 -> Sidle4R;
	Sidle4R -> Serr[label="wr active"] ;
	
	Serr->Serr ;
	 
	"Machine: (S)+ sram_sync32_async16" [ shape = plaintext ];
}

 Machine: (S)+ sram_sync32_async16

                                            not read,not write
                                          +-----------------------+                                                                                                                                                                              +-------+
                                          v                       |                                                                                                                                                                              v       |
                                        +---------------------------------------------------------------+  double world read   +------------------------+     +-----------------------------+     +-----------------------------+  wr active   +-----------+
  *                                 --> |                                                               | -------------------> | STATE_R2_OUTPUT_ADDR_1 | --> |   STATE_R2_OUTPUT_ADDR_2    | --> |                             | -----------> | STATE_ERR |
                                        |                                                               |                      +------------------------+     +-----------------------------+     |                             |              +-----------+
                                        |                                                               |                        ^                        double world read                       |                             |
                                        |                                                               |                        +--------------------------------------------------------------- | STATE_IDLE_4R_UPSTREAM_DATA |
                                        |                                                               |                                                                                         |                             |
                                        |                                                               |                                                                                         |                             |
                                        |                         STATE_IDLE_4A                         | <-------------------------------------------------------------------------------------- |                             | -+
                                        |                                                               |                                                                                         +-----------------------------+  |
                                        |                                                               |                                                                                           ^                              |
                                        |                                                               |                                                                                           |                              |
                                        |                                                               |                                                                                           |                              |
                                        |                                                               |  single world read   +------------------------+                                           |                              |
                                     +> |                                                               | -------------------> |  STATE_R1_OUTPUT_ADDR  | ------------------------------------------+                              |
                                     |  +---------------------------------------------------------------+                      +------------------------+                                                                          |
                                     |    |                            ^    |                                                    ^                        single world read                                                        |
                                     |    | single word write          |    | double word write                                  +-------------------------------------------------------------------------------------------------+
                                     |    v                            |    v
                                     |  +---------------------------+  |  +-----------------------------+                      +------------------------+     +-----------------------------+
                                     |  | STATE_W1_OUTPUT_ADDR_DATA | -+  | STATE_W2_OUTPUT_ADDR_DATA_1 | -------------------> |  STATE_W2_OUTPUT_NONE  | --> | STATE_W2_OUTPUT_ADDR_DATA_2 |
                                     |  +---------------------------+     +-----------------------------+                      +------------------------+     +-----------------------------+
                                     |                                                                                                                          |
                                     +--------------------------------------------------------------------------------------------------------------------------+
*/


/*
`define STATE_IDLE_OR_PREPARE_1ST_ADR       4'b0001
`define STATE_WRITE_PREPARE_2ND_ADR         4'b0010
`define STATE_READ_PREPARE_2ND_ADR_OR_RTN   4'b0100
`define STATE_READ_RTN                      4'b1000 
*/
/*****I found when test with really ram, if write a byte to sram, its previous clock's byte_enable flag would has side affect, so write oper's previous clock must be idle*/
/*****When read, last clock output q, then wait should not active****/
`define STATE_IDLE_4A               10'h001
`define STATE_W1_OUTPUT_ADDR_DATA   10'h002
`define STATE_W2_OUTPUT_ADDR_DATA_1 10'h004
`define STATE_W2_OUTPUT_NONE        10'h008
`define STATE_W2_OUTPUT_ADDR_DATA_2 10'h010
`define STATE_R1_OUTPUT_ADDR        10'h020
`define STATE_IDLE_4R_UPSTREAM_DATA 10'h040
`define STATE_R2_OUTPUT_ADDR_1      10'h080
`define STATE_R2_OUTPUT_ADDR_2      10'h100
`define STATE_ERR                   10'h200

module sram_sync32_async16(
    iRst,
    iClock,
    iAdaptor_en,
    /****bus signal******/
    iSync32_address,
    iSync32_byteena,
    iSync32_data,
    iSync32_wren,
    iSync32_ce,
    oSync32_q,
    ocSync32_wait,
    /*****ram signal*****/
    oAsync16_address,
    oAsync16_byteena_n,
    oAsync16_data,
    oAsync16_data_oe_tri,
    oAsync16_wren_n,
    oAsync16_ce_n,
    oAsync16_oe_n,
    iAsync16_q,
    );
    parameter ADDR_WIDTH = 11;
    input iRst;
	input    iClock;
	input iAdaptor_en;
    /****bus signal******/
    input	[ADDR_WIDTH-1:0]  iSync32_address;
	input	[3:0]  iSync32_byteena;
	input	[31:0]  iSync32_data;
	input	  iSync32_wren;
	input   iSync32_ce;
	output	[31:0]  oSync32_q;//this would be true wire
	output ocSync32_wait;
	/****ram signal*******/
	output [ADDR_WIDTH-1:0] oAsync16_address;
	output [1:0] oAsync16_byteena_n;
	output [15:0] oAsync16_data;
	output oAsync16_data_oe_tri;
	output oAsync16_wren_n;
	output oAsync16_ce_n;
	output oAsync16_oe_n;
	input [15:0] iAsync16_q;


    /************state process declare**********************************************/
    reg [9:0] state_next/*synthesis keep*/;
    reg [9:0] state/*synthesis preserve*/;
    /************state process declare**********************************************/
	/****************save info at idle state triggle time, later other state could use these info**************/
    reg	[ADDR_WIDTH-1:0]  work_iSync32_address;
	reg	[3:0]  work_iSync32_byteena;
	reg	[31:0]  work_iSync32_data;
	always @(posedge iClock or posedge iRst)begin
	    if(iRst)begin
	        work_iSync32_address<={9{1'bz}};
	        work_iSync32_byteena<={4{1'bz}};
	        work_iSync32_data<={32{1'bz}};
	    end else if(iAdaptor_en&&state==`STATE_IDLE_4A)begin
	        work_iSync32_address<=iSync32_address;
	        work_iSync32_byteena<=iSync32_byteena;
	        work_iSync32_data<=iSync32_data;
	    end else if(iAdaptor_en&&state==`STATE_IDLE_4R_UPSTREAM_DATA)begin
	        work_iSync32_address<=iSync32_address;
	        work_iSync32_byteena<=iSync32_byteena;
	    end else
	        ;
	end
	/**********************************************************************************************************/
    /************state process**********************************************/
/*    
	always @ *
	begin
	    case(state)
	    `STATE_IDLE_OR_PREPARE_1ST_ADR:begin
	        if(!iSync32_ce)begin
	            state_next=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	        end else if(iSync32_wren&&(iSync32_byteena[1:0]==2'b00||iSync32_byteena[3:2]==2'b00))begin
	            state_next=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	        end else if(iSync32_wren)begin
	            state_next=`STATE_WRITE_PREPARE_2ND_ADR;
	        end else begin
	            state_next=`STATE_READ_PREPARE_2ND_ADR_OR_RTN;
	        end
	    end
	    `STATE_WRITE_PREPARE_2ND_ADR:begin
	        state_next=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	    end
	    `STATE_READ_PREPARE_2ND_ADR_OR_RTN:begin
	        if(work_iSync32_byteena[1:0]!=2'b00&&work_iSync32_byteena[3:2]!=2'b00)begin
	            state_next=`STATE_READ_RTN;
	        end else begin
	            state_next=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	        end
	    end
	    `STATE_READ_RTN:begin
	        state_next=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	    end
	    endcase
	end
*/	
	always @ *
	begin
	    case(state)// synthesis full_case 
	    `STATE_IDLE_4A:begin
	        if(!iSync32_ce)begin
	            state_next=`STATE_IDLE_4A;
	        end else if(iSync32_wren&&(iSync32_byteena[1:0]==2'b00||iSync32_byteena[3:2]==2'b00))begin
	            state_next=`STATE_W1_OUTPUT_ADDR_DATA;
	        end else if(iSync32_wren)begin
	            state_next=`STATE_W2_OUTPUT_ADDR_DATA_1;
	        end else if(iSync32_byteena[1:0]==2'b00||iSync32_byteena[3:2]==2'b00)begin
	            state_next=`STATE_R1_OUTPUT_ADDR;
	        end else begin
	            state_next=`STATE_R2_OUTPUT_ADDR_1;
	        end
	    end
	    `STATE_W1_OUTPUT_ADDR_DATA:begin
	        state_next=`STATE_IDLE_4A;
	    end
	    `STATE_W2_OUTPUT_ADDR_DATA_1:begin
	        state_next=`STATE_W2_OUTPUT_NONE;
	    end
	    `STATE_W2_OUTPUT_NONE:begin
	        state_next=`STATE_W2_OUTPUT_ADDR_DATA_2;
	    end
	    `STATE_W2_OUTPUT_ADDR_DATA_2:begin
	        state_next=`STATE_IDLE_4A;
	    end
	    `STATE_R1_OUTPUT_ADDR:begin
	        state_next=`STATE_IDLE_4R_UPSTREAM_DATA;
	    end
	    `STATE_R2_OUTPUT_ADDR_1:begin
	        state_next=`STATE_R2_OUTPUT_ADDR_2;
	    end
	    `STATE_R2_OUTPUT_ADDR_2:begin
	        state_next=`STATE_IDLE_4R_UPSTREAM_DATA;
	    end
	    `STATE_IDLE_4R_UPSTREAM_DATA:begin
	        if(!iSync32_ce)begin
	            state_next=`STATE_IDLE_4A;
	        end else if(iSync32_wren) begin
	            state_next=`STATE_ERR;
	        end else if(iSync32_byteena[1:0]==2'b00||iSync32_byteena[3:2]==2'b00)begin
	            state_next=`STATE_R1_OUTPUT_ADDR;
	        end else begin
	            state_next=`STATE_R2_OUTPUT_ADDR_1;
	        end
	    end
	    `STATE_ERR:begin
	        state_next=`STATE_ERR;
	    end
	    endcase
	end

	always @(posedge iClock or posedge iRst)begin
	    if(iRst)
	        state<=`STATE_IDLE_4A;
	    else if(iAdaptor_en)
	        state<=state_next;
	    else
	        state<=state;
	end
    /************state process**********************************************/
    /************other process**********************************************/
    reg [ADDR_WIDTH-1:0] oAsync16_address_next;
	reg [1:0] oAsync16_byteena_n_next;
	reg [15:0] oAsync16_data_next;
	reg oAsync16_data_oe_tri_next;
	reg oAsync16_wren_n_next;
	reg oAsync16_ce_n_next;
	reg oAsync16_oe_n_next;
	reg	[31:0]  oSync32_q_next;
	reg oSync32_wait_next;

    reg [ADDR_WIDTH-1:0] oAsync16_address;
	reg [1:0] oAsync16_byteena_n;
	reg [15:0] oAsync16_data;
	reg oAsync16_data_oe_tri;
	reg oAsync16_wren_n;
	reg oAsync16_ce_n;
	reg oAsync16_oe_n;
	reg	[31:0]  oSync32_q;
	reg ocSync32_wait;
//	reg oSync32_wait;








/*	just for debug  
if(oAsync16_byteena_n==2'b10) 
    oAsync16_byteena_n_next={2{1'b1}};
else    
    oAsync16_byteena_n_next={2{1'b0}};
*/
/*
	always @ *
	begin
	    case({state,state_next})
	    {`STATE_IDLE_OR_PREPARE_1ST_ADR,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
	        if(!iSync32_ce)begin//not read & not write
	            oAsync16_address_next={ADDR_WIDTH{1'bz}};
	            oAsync16_byteena_n_next={2{1'b1}};
	            oAsync16_data_next={16{1'bz}};
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b1;
	            oAsync16_ce_n_next=1'b1;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q={32{1'bz}};
	            oSync32_wait_next=1'b0;
	        end else begin//single word write
	            if(iSync32_byteena[1:0]!=2'b00)begin
    	            oAsync16_address_next=iSync32_address;
    	            oAsync16_byteena_n_next=~iSync32_byteena[1:0];
    	            oAsync16_data_next=iSync32_data[15:0];
	            end else begin
    	            oAsync16_address_next={iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	            oAsync16_byteena_n_next=~iSync32_byteena[3:2];
    	            oAsync16_data_next=iSync32_data[31:16];
	            end
	            oAsync16_data_oe_tri_next=1'b1;
	            oAsync16_wren_n_next=1'b0;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q={32{1'bz}};
	            oSync32_wait_next=1'b0;
	        end
	    end
        {`STATE_IDLE_OR_PREPARE_1ST_ADR,`STATE_WRITE_PREPARE_2ND_ADR}:begin
    	    oAsync16_address_next=iSync32_address;
    	    oAsync16_byteena_n_next=~iSync32_byteena[1:0];
    	    oAsync16_data_next=iSync32_data[15:0];
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b0;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q={32{1'bz}};
	        oSync32_wait_next=1'b1;
        end
        {`STATE_IDLE_OR_PREPARE_1ST_ADR,`STATE_READ_PREPARE_2ND_ADR_OR_RTN}:begin
	        if(iSync32_byteena[1:0]!=2'b00)begin
    	        oAsync16_address_next=iSync32_address;
    	        oAsync16_byteena_n_next=~iSync32_byteena[1:0];
	        end else begin
    	        oAsync16_address_next={iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	        oAsync16_byteena_n_next=~iSync32_byteena[3:2];
	        end
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q={32{1'bz}};
	        if(iSync32_byteena[1:0]!=2'b00&&iSync32_byteena[3:2]!=2'b00)begin
	            oSync32_wait_next=1'b1;
	        end else begin
	            oSync32_wait_next=1'b0;
	        end
        end
        {`STATE_WRITE_PREPARE_2ND_ADR,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
    	    oAsync16_address_next={work_iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	    oAsync16_byteena_n_next=~work_iSync32_byteena[3:2];
    	    oAsync16_data_next=work_iSync32_data[31:16];
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b0;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q={32{1'bz}};
	        oSync32_wait_next=1'b0;
        end
        {`STATE_READ_PREPARE_2ND_ADR_OR_RTN,`STATE_READ_RTN}:begin
    	    oAsync16_address_next={work_iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	    oAsync16_byteena_n_next=~work_iSync32_byteena[3:2];
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q={{16{1'bz}},iAsync16_q};//let it save to oSync32_q, and next triggle keep to putout
	        oSync32_wait_next=1'b0;
        end
        {`STATE_READ_PREPARE_2ND_ADR_OR_RTN,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
    	    oAsync16_address_next={ADDR_WIDTH{1'bz}};
    	    oAsync16_byteena_n_next={2{1'b1}};
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        if(work_iSync32_byteena[1:0]!=2'b00)begin
	            oSync32_q={{16{1'bz}},iAsync16_q};
	        end else begin
	            oSync32_q={iAsync16_q,{16{1'bz}}};
	        end
	        oSync32_wait_next=1'b0;
        end
	    {`STATE_READ_RTN,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
    	    oAsync16_address_next={ADDR_WIDTH{1'bz}};
    	    oAsync16_byteena_n_next={2{1'b1}};
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q={iAsync16_q,oSync32_q_d[15:0]};
	        oSync32_wait_next=1'b0;
	    end
	    endcase
	end
*/
	always @ *
	begin
	    case(state_next)// synthesis full_case
	    `STATE_IDLE_4A:begin
	        oAsync16_address_next={ADDR_WIDTH{1'bz}};
	        oAsync16_byteena_n_next={2{1'b1}};
	        oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={32{1'bz}};
	        oSync32_wait_next=1'b0;
	    end
	    `STATE_W1_OUTPUT_ADDR_DATA:begin
            if(iSync32_byteena[1:0]!=2'b00)begin
   	            oAsync16_address_next=iSync32_address;
   	            oAsync16_byteena_n_next=~iSync32_byteena[1:0];
   	            oAsync16_data_next=iSync32_data[15:0];
            end else begin
   	            oAsync16_address_next={iSync32_address[ADDR_WIDTH-1:2],2'b10};
   	            oAsync16_byteena_n_next=~iSync32_byteena[3:2];
   	            oAsync16_data_next=iSync32_data[31:16];
            end
            oAsync16_data_oe_tri_next=1'b1;
            oAsync16_wren_n_next=1'b0;
            oAsync16_ce_n_next=1'b0;
            oAsync16_oe_n_next=1'b1;
            oSync32_q_next={32{1'bz}};
            oSync32_wait_next=1'b1;
	    end
	    `STATE_W2_OUTPUT_ADDR_DATA_1:begin
    	    oAsync16_address_next=iSync32_address;
    	    oAsync16_byteena_n_next=~iSync32_byteena[1:0];
    	    oAsync16_data_next=iSync32_data[15:0];
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b0;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={32{1'bz}};
	        oSync32_wait_next=1'b1;
	    end
	    `STATE_W2_OUTPUT_NONE:begin
	        oAsync16_address_next={ADDR_WIDTH{1'bz}};
	        oAsync16_byteena_n_next={2{1'b1}};
	        oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={32{1'bz}};
	        oSync32_wait_next=1'b1;
	    end
	    `STATE_W2_OUTPUT_ADDR_DATA_2:begin
    	    oAsync16_address_next={work_iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	    oAsync16_byteena_n_next=~work_iSync32_byteena[3:2];
    	    oAsync16_data_next=work_iSync32_data[31:16];
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b0;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={32{1'bz}};
	        oSync32_wait_next=1'b1;
	    end
	    `STATE_R1_OUTPUT_ADDR:begin
	        if(iSync32_byteena[1:0]!=2'b00)begin
    	        oAsync16_address_next=iSync32_address;
    	        oAsync16_byteena_n_next=~iSync32_byteena[1:0];
	        end else begin
    	        oAsync16_address_next={iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	        oAsync16_byteena_n_next=~iSync32_byteena[3:2];
	        end
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q_next={32{1'bz}};
            oSync32_wait_next=1'b1;
	    end
/*	    
	    `STATE_R1_OUTPUT_DATA:begin
    	    oAsync16_address_next={ADDR_WIDTH{1'bz}};
    	    oAsync16_byteena_n_next={2{1'b1}};
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        if(work_iSync32_byteena[1:0]!=2'b00)begin
	            oSync32_q_next={{16{1'bz}},iAsync16_q};
	        end else begin
	            oSync32_q_next={iAsync16_q,{16{1'bz}}};
	        end
	        oSync32_wait_next=1'b0;
	    end
*/	    
	    `STATE_R2_OUTPUT_ADDR_1:begin
   	        oAsync16_address_next=iSync32_address;
   	        oAsync16_byteena_n_next=~iSync32_byteena[1:0];
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q_next={32{1'bz}};
            oSync32_wait_next=1'b1;
	    end
	    `STATE_R2_OUTPUT_ADDR_2:begin
    	    oAsync16_address_next={work_iSync32_address[ADDR_WIDTH-1:2],2'b10};
    	    oAsync16_byteena_n_next=~work_iSync32_byteena[3:2];
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q_next={{16{1'bz}},iAsync16_q};
            oSync32_wait_next=1'b1;
	    end
/*	    
	    `STATE_R2_OUTPUT_DATA:begin
    	    oAsync16_address_next={ADDR_WIDTH{1'bz}};
    	    oAsync16_byteena_n_next={2{1'b1}};
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={iAsync16_q,oSync32_q[15:0]};
	        oSync32_wait_next=1'b0;
	    end
*/	    
	    `STATE_IDLE_4R_UPSTREAM_DATA:begin
    	    oAsync16_address_next={ADDR_WIDTH{1'bz}};
    	    oAsync16_byteena_n_next={2{1'b1}};
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        if(state==`STATE_R1_OUTPUT_ADDR)begin
    	        if(work_iSync32_byteena[1:0]!=2'b00)begin
    	            oSync32_q_next={{16{1'bz}},iAsync16_q};
    	        end else begin
    	            oSync32_q_next={iAsync16_q,{16{1'bz}}};
    	        end
	        end else begin//`STATE_R2_OUTPUT_ADDR_2
	            oSync32_q_next={iAsync16_q,oSync32_q[15:0]};
	        end
	        oSync32_wait_next=1'b0;
	    end
	    `STATE_ERR:begin
	        oAsync16_address_next={ADDR_WIDTH{1'bz}};
	        oAsync16_byteena_n_next={2{1'b1}};
	        oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q_next={32{1'bz}};
	        oSync32_wait_next=1'b0;
	    end
	    endcase
	end






/*
	always @ *
	begin
	    case(state)
	    `STATE_IDLE_OR_PREPARE_1ST_ADR:begin
	        if(!iSync32_ce)begin
	            oAsync16_address_next={9{1'bz}};
	            oAsync16_byteena_n_next={2{1'bz}};
	            oAsync16_data_next={16{1'bz}};
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b1;
	            oAsync16_ce_n_next=1'b1;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={15{1'bz}};
	            oSync32_wait_next=1'b0;
	        end else if(iSync32_wren&&(iSync32_byteena[1:0]==2'b00||iSync32_byteena[3:2]==2'b00))begin
	            if(iSync32_byteena[1:0]!=2'b00)begin
    	            oAsync16_address_next=iSync32_address;
    	            oAsync16_byteena_n_next=iSync32_byteena[1:0];
    	            oAsync16_data_next=iSync32_data[15:0];
	            end else begin
    	            oAsync16_address_next={iSync32_address[8:1],1'b1};
    	            oAsync16_byteena_n_next=iSync32_byteena[3:2];
    	            oAsync16_data_next=iSync32_data[31:16];
	            end
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b0;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={15{1'bz}};
	            oSync32_wait_next=1'b0;
	        end else if(iSync32_wren)begin//to STATE_IDLE_OR_PREPARE_1ST_ADR or to STATE_WRITE_PREPARE_2ND_ADR, same process
	            if(iSync32_byteena[1:0]!=2'b00)begin
    	            oAsync16_address_next=iSync32_address;
    	            oAsync16_byteena_n_next=iSync32_byteena[1:0];
    	            oAsync16_data_next=iSync32_data[15:0];
	            end else begin
    	            oAsync16_address_next={iSync32_address[8:1],1'b1};
    	            oAsync16_byteena_n_next=iSync32_byteena[3:2];
    	            oAsync16_data_next=iSync32_data[31:16];
	            end
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b0;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={15{1'bz}};
	            oSync32_wait_next=1'b1;
	        end else begin
	            if(iSync32_byteena[1:0]!=2'b00)begin
    	            oAsync16_address_next=iSync32_address;
    	            oAsync16_byteena_n_next=iSync32_byteena[1:0];
	            end else begin
    	            oAsync16_address_next={iSync32_address[8:1],1'b1};
    	            oAsync16_byteena_n_next=iSync32_byteena[3:2];
	            end
    	        oAsync16_data_next={15{1'bz}};
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b1;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={15{1'bz}};
	            oSync32_wait_next=1'b1;
	        end
	    end
	    `STATE_WRITE_PREPARE_2ND_ADR:begin
    	        oAsync16_address_next={work_iSync32_address[8:1],1'b1};
    	        oAsync16_byteena_n_next=work_iSync32_byteena[3:2];
    	        oAsync16_data_next=work_iSync32_data[31:16];
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b0;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={15{1'bz}};
	            oSync32_wait_next=1'b0;
	    end
	    `STATE_READ_PREPARE_2ND_ADR_OR_RTN:begin
	        if(work_iSync32_byteena[1:0]!=2'b00&&work_iSync32_byteena[3:2]!=2'b00)begin
    	        oAsync16_address_next={work_iSync32_address[8:1],1'b1};
    	        oAsync16_byteena_n_next=work_iSync32_byteena[3:2];
    	        oAsync16_data_next={15{1'bz}};
	            oAsync16_data_oe_tri_next=1'b0;
	            oAsync16_wren_n_next=1'b1;
	            oAsync16_ce_n_next=1'b0;
	            oAsync16_oe_n_next=1'b1;
	            oSync32_q_next={{16{1'bz}},iAsync16_q};//let it save to oSync32_q, and next triggle keep to putout
	            oSync32_wait_next=1'b1;
	        end else begin
    	        oAsync16_address_next={16{1'bz}};
    	        oAsync16_byteena_n_next={2{1'bz}};
    	        oAsync16_data_next={15{1'bz}};
	            oAsync16_data_oe_tri_next=1'b1;
	            oAsync16_wren_n_next=1'b1;
	            oAsync16_ce_n_next=1'b1;
	            oAsync16_oe_n_next=1'b0;
	            if(work_iSync32_byteena[1:0]!=2'b00)begin
	                oSync32_q_next={{16{1'bz}},iAsync16_q};
	            end else begin
	                oSync32_q_next={iAsync16_q,{16{1'bz}}};
	            end
	            oSync32_wait_next=1'b0;
	        end
	    end
	    `STATE_READ_RTN:begin
    	    oAsync16_address_next={16{1'bz}};
    	    oAsync16_byteena_n_next={2{1'bz}};
    	    oAsync16_data_next={15{1'bz}};
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b1;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q_next={iAsync16_q,oSync32_q[7:0]};
	        oSync32_wait_next=1'b0;
	    end
	    endcase
	end
*/	
	always @(posedge iClock or posedge iRst)begin
	    if(iRst)begin
	        oAsync16_address<={ADDR_WIDTH{1'b0}};
	        oAsync16_byteena_n<={2{1'b0}};
	        oAsync16_data<={16{1'b0}};
	        oAsync16_data_oe_tri<=1'b0;
	        oAsync16_wren_n<=1'b1;
	        oAsync16_ce_n<=1'b1;
	        oAsync16_oe_n<=1'b1;
	        oSync32_q<={16{1'bz}};
	        ocSync32_wait<=1'b0;
	    end else if (iAdaptor_en)begin
	        oAsync16_address<=oAsync16_address_next;
	        oAsync16_byteena_n<=oAsync16_byteena_n_next;
	        oAsync16_data<=oAsync16_data_next;
	        oAsync16_data_oe_tri<=oAsync16_data_oe_tri_next;
	        oAsync16_wren_n<=oAsync16_wren_n_next;
	        oAsync16_ce_n<=oAsync16_ce_n_next;
	        oAsync16_oe_n<=oAsync16_oe_n_next;
	        oSync32_q<=oSync32_q_next;
	        ocSync32_wait<=oSync32_wait_next;
	    end else
	        ;
	end

endmodule
