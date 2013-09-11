
/*
sram_sync32_async16.dot
digraph sram_sync32_async16 {
	rankdir=LR;

	node [shape = circle];
	
	SpntBegin [shape=point];
	//SpntEnd [shape=point];
	Sidle [shape=ellipse,label="STATE_IDLE_OR_PREPARE_1ST_ADR"];
	Sw2 [label=".",label="STATE_WRITE_PREPARE_2ND_ADR"];
	Sr2 [label=".",label="STATE_READ_PREPARE_2ND_ADR_OR_RTN"];
	Srtn [label=".",label="STATE_READ_RTN"];
	  
	SpntBegin -> Sidle ;
	Sidle->Sidle[label="not read,not write,or single word write"];
	Sidle -> Sw2 ;
	Sw2->Sidle;
	Sidle -> Sr2 ;
	Sr2->Sidle;
	Sr2 -> Srtn ;
	Srtn -> Sidle ;
	 
	"Machine: (S)+ sram_sync32_async16" [ shape = plaintext ];
}

 Machine: (S)+ sram_sync32_async16

                                            not read,not write,or single word write
                                          +-----------------------------------------+
                                          v                                         |
                                        +--------------------------------------------------+     +-----------------------------------+     +----------------+
  *                                 --> |                                                  | --> | STATE_READ_PREPARE_2ND_ADR_OR_RTN | --> | STATE_READ_RTN |
                                        |                                                  |     +-----------------------------------+     +----------------+
                                        |                                                  |       |                                         |
                                        |          STATE_IDLE_OR_PREPARE_1ST_ADR           | <-----+                                         |
                                        |                                                  |                                                 |
                                        |                                                  |                                                 |
                                        |                                                  | <-----------------------------------------------+
                                        +--------------------------------------------------+
                                          |                                              ^
                                          |                                              |
                                          v                                              |
                                        +---------------------------------------------+  |
                                        |         STATE_WRITE_PREPARE_2ND_ADR         | -+
                                        +---------------------------------------------+

*/



`define STATE_IDLE_OR_PREPARE_1ST_ADR       4'b0001
`define STATE_WRITE_PREPARE_2ND_ADR         4'b0010
`define STATE_READ_PREPARE_2ND_ADR_OR_RTN   4'b0100
`define STATE_READ_RTN                      4'b1000 
module sram_sync32_async16(
    iRst,
    iClock,
    /****bus signal******/
    iSync32_address,
    iSync32_byteena,
    iSync32_data,
    iSync32_wren,
    iSync32_ce,
    oSync32_q,
    oSync32_wait,
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
    input iRst;
	input    iClock;
    /****bus signal******/
    input	[8:0]  iSync32_address;
	input	[3:0]  iSync32_byteena;
	input	[31:0]  iSync32_data;
	input	  iSync32_wren;
	input   iSync32_ce;
	output	[31:0]  oSync32_q;//this would be true wire
	output oSync32_wait;
	/****ram signal*******/
	output [8:0] oAsync16_address;
	output [1:0] oAsync16_byteena_n;
	output [15:0] oAsync16_data;
	output oAsync16_data_oe_tri;
	output oAsync16_wren_n;
	output oAsync16_ce_n;
	output oAsync16_oe_n;
	input [15:0] iAsync16_q;


    /************state process declare**********************************************/
    reg [3:0] state_next;
    reg [3:0] state;
    /************state process declare**********************************************/
	/****************save info at idle state triggle time, later other state could use these info**************/
    reg	[8:0]  work_iSync32_address;
	reg	[3:0]  work_iSync32_byteena;
	reg	[31:0]  work_iSync32_data;
	always @(posedge iClock or posedge iRst)begin
	    if(iRst)begin
	        work_iSync32_address<={9{1'bz}};
	        work_iSync32_byteena<={4{1'bz}};
	        work_iSync32_data<={32{1'bz}};
	    end else if(state==`STATE_IDLE_OR_PREPARE_1ST_ADR)begin
	        work_iSync32_address<=iSync32_address;
	        work_iSync32_byteena<=iSync32_byteena;
	        work_iSync32_data<=iSync32_data;
	    end else
	        ;
	end
	/**********************************************************************************************************/
    /************state process**********************************************/
    
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
	always @(posedge iClock or posedge iRst)begin
	    if(iRst)
	        state<=`STATE_IDLE_OR_PREPARE_1ST_ADR;
	    else
	        state<=state_next;
	end
    /************state process**********************************************/
    /************other process**********************************************/
    reg [8:0] oAsync16_address_next;
	reg [1:0] oAsync16_byteena_n_next;
	reg [15:0] oAsync16_data_next;
	reg oAsync16_data_oe_tri_next;
	reg oAsync16_wren_n_next;
	reg oAsync16_ce_n_next;
	reg oAsync16_oe_n_next;
	reg	[31:0]  oSync32_q;
	reg oSync32_wait_next;

    reg [8:0] oAsync16_address;
	reg [1:0] oAsync16_byteena_n;
	reg [15:0] oAsync16_data;
	reg oAsync16_data_oe_tri;
	reg oAsync16_wren_n;
	reg oAsync16_ce_n;
	reg oAsync16_oe_n;
	reg	[31:0]  oSync32_q_d;
	reg oSync32_wait;








	always @ *
	begin
	    case({state,state_next})
	    {`STATE_IDLE_OR_PREPARE_1ST_ADR,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
	        if(!iSync32_ce)begin//not read & not write
	            oAsync16_address_next={9{1'bz}};
	            oAsync16_byteena_n_next={2{1'bz}};
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
    	            oAsync16_byteena_n_next=iSync32_byteena[1:0];
    	            oAsync16_data_next=iSync32_data[15:0];
	            end else begin
    	            oAsync16_address_next={iSync32_address[8:2],2'b10};
    	            oAsync16_byteena_n_next=iSync32_byteena[3:2];
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
    	    oAsync16_byteena_n_next=iSync32_byteena[1:0];
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
    	        oAsync16_byteena_n_next=iSync32_byteena[1:0];
	        end else begin
    	        oAsync16_address_next={iSync32_address[8:2],2'b10};
    	        oAsync16_byteena_n_next=iSync32_byteena[3:2];
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
    	    oAsync16_address_next={work_iSync32_address[8:2],2'b10};
    	    oAsync16_byteena_n_next=work_iSync32_byteena[3:2];
    	    oAsync16_data_next=work_iSync32_data[31:16];
	        oAsync16_data_oe_tri_next=1'b1;
	        oAsync16_wren_n_next=1'b0;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b1;
	        oSync32_q={32{1'bz}};
	        oSync32_wait_next=1'b0;
        end
        {`STATE_READ_PREPARE_2ND_ADR_OR_RTN,`STATE_READ_RTN}:begin
    	    oAsync16_address_next={work_iSync32_address[8:2],2'b10};
    	    oAsync16_byteena_n_next=work_iSync32_byteena[3:2];
    	    oAsync16_data_next={16{1'bz}};
	        oAsync16_data_oe_tri_next=1'b0;
	        oAsync16_wren_n_next=1'b1;
	        oAsync16_ce_n_next=1'b0;
	        oAsync16_oe_n_next=1'b0;
	        oSync32_q={{16{1'bz}},iAsync16_q};//let it save to oSync32_q, and next triggle keep to putout
	        oSync32_wait_next=1'b0;
        end
        {`STATE_READ_PREPARE_2ND_ADR_OR_RTN,`STATE_IDLE_OR_PREPARE_1ST_ADR}:begin
    	    oAsync16_address_next={16{1'bz}};
    	    oAsync16_byteena_n_next={2{1'bz}};
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
    	    oAsync16_address_next={16{1'bz}};
    	    oAsync16_byteena_n_next={2{1'bz}};
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
	        oAsync16_address<={9{1'bz}};
	        oAsync16_byteena_n<={2{1'bz}};
	        oAsync16_data<={16{1'bz}};
	        oAsync16_data_oe_tri<=1'b0;
	        oAsync16_wren_n<=1'b1;
	        oAsync16_ce_n<=1'b1;
	        oAsync16_oe_n<=1'b1;
	        oSync32_q_d<={16{1'bz}};
	        oSync32_wait<=1'bz;
	    end else begin
	        oAsync16_address<=oAsync16_address_next;
	        oAsync16_byteena_n<=oAsync16_byteena_n_next;
	        oAsync16_data<=oAsync16_data_next;
	        oAsync16_data_oe_tri<=oAsync16_data_oe_tri_next;
	        oAsync16_wren_n<=oAsync16_wren_n_next;
	        oAsync16_ce_n<=oAsync16_ce_n_next;
	        oAsync16_oe_n<=oAsync16_oe_n_next;
	        oSync32_q_d<=oSync32_q;
	        oSync32_wait<=oSync32_wait_next;
	    end
	end

endmodule
