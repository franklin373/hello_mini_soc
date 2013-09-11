/*
ram u_ram (
	     .address                 (    ram_addr[10:2]                      ),
	     .byteena                   (    ram_flag            ),
         .clock                  (    clk                                 ),
	     .data                  (    ram_wdata                           ),
	     .wren                   (    ram_wen & mod_sel[0]   ),
	     .q                 (    ram_rdata_ram                       )
	);		  
*/
`define STATE_IDLE 3'b001
`define STATE_1    3'b010
`define STATE_2    3'b100
module sram_extern_16(
    rst,
    clock,
    /****bus signal******/
    address_bus,
    byteena_bus,
    data_bus,
    wren_bus,
    ce_bus,
    q_bus,
    wait_bus,
    /*****ram signal*****/
    address_ram,
    byteena_ram,
    data_ram,
    data_oe_tri,
    wren_ram,
    ce_ram,
    oe_ram,
    q_ram,
    );
    input rst;
    input	[9:0]  address_bus;
	input	[1:0]  byteena_bus;
	input	  clock;
	input	[15:0]  data_bus;
	input	  wren_bus;
	input   ce_bus;
	output	[15:0]  q_bus;
	output wait_bus;
	output [8:0] address_ram;
	output [1:0] byteena_ram;
	output [15:0] data_ram;
	output data_oe_tri;
	output wren_ram;
	output ce_ram;
	output oe_ram;
	input [15:0] q_ram;

	reg [2:0] state_next;
	reg [2:0] state;

    assign address_ram=address_bus;
    assign byteena_ram=byteena_bus;
    assign data_ram=data_bus;
    assign data_oe_tri=wren_ram;
    assign ce_ram=ce_bus;
    
    assign oe_ram=((ce_bus&~wren_bus&state_next==`STATE_1)?1'b1:1'b0);
    assign wren_ram=((ce_bus&wren_bus&state_next==`STATE_1)?1'b1:1'b0);
    assign wait_bus=((state_next==`STATE_1)?1'b1:1'b0);

    always @(*)
        case(state)
        `STATE_IDLE:
            if(ce_bus)
                state_next=`STATE_1;
            else
                state_next=state;
        `STATE_1:
            state_next=`STATE_2;
        `STATE_2:
            if(ce_bus)
                state_next=`STATE_1;
            else
                state_next=`STATE_IDLE;
        endcase

    always @(posedge clock or posedge rst)
        if(rst)
            state<=`STATE_IDLE;
        else
            state<=state_next;
    
endmodule   
