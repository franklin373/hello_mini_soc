`define STAGE_IDLE 3'b001
`define STAGE_LOW  3'b010
`define STAGE_HIGH 3'b100
module sram_conv_32_16(
    rst,
    clock,
    /****bus signal******/
    address_32,
    byteena_32,
    data_32,
    wren_32,
    ce_32,
    q_32,
    wait_32,
    /*****ram signal*****/
    address_16,
    byteena_16,
    data_16,
    wren_16,
    ce_16,
    q_16,
    wait_16,
    );
    input rst;
	input    clock;
    /****bus signal******/
    input	[8:0]  address_32;
	input	[3:0]  byteena_32;
	input	[31:0]  data_32;
	input	  wren_32;
	input   ce_32;
	output	[31:0]  q_32;
	output wait_32;
    /*****ram signal*****/
    output	[9:0]  address_16;
	output	[1:0]  byteena_16;
	output	[15:0]  data_16;
	output	  wren_16;
	output   ce_16;
	input	[15:0]  q_16;
	input wait_16;

    reg [31:0] q_32;
    reg [15:0] data_16;
    reg [1:0] byteena_16;
    reg [9:0] address_16;

	reg [2:0] stage_next;
	reg [2:0] stage;
	reg [15:0] q_buf;

    always @(*)
        if(stage_next==`STAGE_HIGH) 
            address_16={address_32[8:0],1'b1};
        else
            address_16={address_32[8:0],1'b0};
    always @(*)
        if(stage_next==`STAGE_HIGH)
            byteena_16=byteena_32[3:2];
        else
            byteena_16=byteena_32[1:0];
    always @(*)
        if(stage_next==`STAGE_HIGH)
            data_16=data_32[31:16];
        else
            data_16=data_32[15:0];
    always @(*)
        if(stage_next==`STAGE_HIGH)
            q_32={q_16,q_buf};
        else
            q_32={16'bX,q_16};
    always @(posedge clock or posedge rst)
        if(rst)
            q_buf<={16{1'b0}};
        else if(stage_next==`STAGE_LOW&&~wait_16)
            q_buf<=q_16;
        else;
        
    assign wren_16=wren_32;
    assign ce_16=ce_32;
    assign wait_32=wait_16;

    always @(*)
        case(stage)
        `STAGE_IDLE:
            if(ce_32&byteena_32[1:0]&~wait_16)
                stage_next=`STAGE_LOW;
            else if(ce_32&~byteena_32[1:0]&~wait_16)
                stage_next=`STAGE_HIGH;
            else
                stage_next=stage;
        `STAGE_LOW:
            if(ce_32&byteena_32[3:2]&~wait_16)
                stage_next=`STAGE_HIGH;
            else if(~ce_16&~wait_16)
                stage_next=`STAGE_IDLE;
            else
                stage_next=stage;
        `STAGE_HIGH:
            if(ce_32&byteena_32[1:0]&~wait_16)
                stage_next=`STAGE_LOW;
            else if(~ce_16&~wait_16)
                stage_next=`STAGE_IDLE;
            else
                stage_next=stage;
        default:
            stage_next=stage;
        endcase

    always @(posedge clock or posedge rst)
        if(rst)
            stage<=`STAGE_IDLE;
        else
            stage<=stage_next;
endmodule   

