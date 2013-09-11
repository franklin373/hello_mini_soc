module sram_extern_32 (
	clock,
	rst,
	/************bus32*****************/
	address_bus,
	byteena_bus,
	data_bus,
	wren_bus,
	ce_bus,
	q_bus,
	wait_bus,
	/************ram16*****************/
    address_ram,
    byteena_ram,
    data_ram,
    data_oe_tri,
    wren_ram,
    ce_ram,
    oe_ram,
    q_ram,
	);

	input	  clock;
	input     rst;
	
	input	[8:0]  address_bus;
	input	[3:0]  byteena_bus;
	input	[31:0]  data_bus;
	input	  wren_bus;
	input ce_bus;
	output	[31:0]  q_bus;
	output wait_bus;

	output [8:0] address_ram;
	output [1:0] byteena_ram;
	output [15:0] data_ram;
	output data_oe_tri;
	output wren_ram;
	output ce_ram;
	output oe_ram;
	input [15:0] q_ram;


    wire [9:0] address_16;
    wire [1:0] byteena_16;
    wire [15:0] data_16;
    wire wren_16;
    wire ce_16;
    wire [15:0] q_16;
    wire wait_16;
/*
module sram_conv_32_16(
    rst,
    clock,

    address_32,
    byteena_32,
    data_32,
    wren_32,
    ce_32,
    q_32,
    wait_32,

    address_16,
    byteena_16,
    data_16,
    wren_16,
    ce_16,
    q_16,
    wait_16,
    );
*/
    sram_conv_32_16 conv(
        .rst(rst),
        .clock(clock),
        .address_32(address_bus),
        .byteena_32(byteena_bus),
        .data_32(data_bus),
        .wren_32(wren_bus),
        .ce_32(ce_bus),
        .q_32(q_bus),
        .wait_32(wait_bus),
        .address_16(address_16),
        .byteena_16(byteena_16),
        .data_16(data_16),
        .wren_16(wren_16),
        .ce_16(ce_16),
        .q_16(q_16),
        .wait_16(wait_16)
    );
/*
module sram_extern_16(
    rst,
    clock,

    address_bus,
    byteena_bus,
    data_bus,
    wren_bus,
    ce_bus,
    q_bus,
    wait_bus,

    address_ram,
    byteena_ram,
    data_ram,
    wren_ram,
    ce_ram,
    oe_ram,
    q_ram,
    );
*/
    sram_extern_16 bus_ram_16(
        .rst(rst),
        .clock(clock),

        .address_bus(address_16),
        .byteena_bus(byteena_16),
        .data_bus(data_16),
        .wren_bus(wren_16),
        .ce_bus(ce_16),
        .q_bus(q_16),
        .wait_bus(wait_16),

        .address_ram(address_ram),
        .byteena_ram(byteena_ram),
        .data_ram(data_ram),
        .data_oe_tri(data_oe_tri),
        .wren_ram(wren_ram),
        .ce_ram(ce_ram),
        .oe_ram(oe_ram),
        .q_ram(q_ram)
    );

endmodule

