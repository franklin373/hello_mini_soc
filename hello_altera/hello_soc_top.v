module hello_soc_top (
   clk_50m,
   rst_n,
   RxD,
   
   TxD,
   LED_out,
   KEY_in,

    /*external SRAM*/
    o_address_ram,
    o_byteena_ram,
    io_ram,
    o_wren_ram,
    o_ce_ram,
    o_oe_ram
   );
//parameter SRAM_ADDR_WIDTH = 11;//internal ram
parameter SRAM_ADDR_WIDTH = 19;//external ram
   
input              clk_50m;
input              rst_n;
input              RxD;

output             TxD;
output     [1:0]        LED_out;
input              KEY_in;

	output [SRAM_ADDR_WIDTH-1:0] o_address_ram;
	output [1:0] o_byteena_ram;
	inout [15:0] io_ram;
	output o_wren_ram;
	output o_ce_ram;
	output o_oe_ram;


wire               rst;
wire  [31:0]       rom_data;
wire  [31:0]       ram_addr;
wire               ram_cen;
wire  [3:0]        ram_flag;
wire  [31:0]       ram_wdata;
wire               ram_wen;
wire  [31:0]       rom_addr;
wire               rom_en;
wire  [31:0]       gpio_rdata;
wire  [31:0]       uart_rdata;
wire  [31:0]       ram_rdata_rom;
wire  [31:0]       ram_rdata_ram;
wire               rx_vld;
wire  [7:0]        rx_data;
wire               txrdy;

//wire               rx_n;
//wire               tx_n;

reg   [31:0]       ram_rdata;
reg   [3:0]        mod_sel;
reg   [3:0]        mod_sel_d;
reg                tx_vld;
reg   [7:0]        tx_data;

wire               clk;
wire               wait_cpu;
/*
reg                clk;
wire                clk2;
*/

wire[15:0] io_ram;
wire[15:0] data_ram;
wire data_oe_tri;



  pll u_pll
   (// Clock in ports
    .inclk0            (clk_50m),      // IN
    // Clock out ports
    .c1           (clk));    // OUT

assign rst = ~rst_n;

/*
	always @ ( posedge clk2 or posedge rst )
        if( rst ) 
            clk <= 1'b0;
        else 
            clk <= ~clk;
*/
arm9_compatiable_code u_arm9(
          .clk                 (    clk                   ),
          .cpu_en              (    ~wait_cpu/*1'b1*/                  ),
          .cpu_restart         (    1'b0                  ),
          .fiq                 (    1'b0                  ),
          .irq                 (    1'b0                  ),
          .ram_abort           (    1'b0                  ),
          .ram_rdata           (    ram_rdata             ),
          .rom_abort           (    1'b0                  ),
          .rom_data            (    rom_data              ),
          .rst                 (    rst                   ),

          .ram_addr            (    ram_addr              ),
          .ram_cen             (    ram_cen               ),
          .ram_flag            (    ram_flag              ),
          .ram_wdata           (    ram_wdata             ),
          .ram_wen             (    ram_wen               ),
          .rom_addr            (    rom_addr              ),
          .rom_en              (    rom_en                )
        ); 

rom  u_rom(
	      .address_a               (    rom_addr[12:2]                               ),
	      .address_b               (    ram_addr[12:2]                               ),
	      .clock_a                (    clk                                          ),
	      .clock_b                (    clk                                          ),
	      .enable_a                 (    rom_en                                       ),
	      .enable_b                 (    ram_cen & ~ram_wen & (ram_addr[31:28]==4'h0) ),
	      .q_a               (    rom_data                                     ),
	      .q_b               (    ram_rdata_rom                                )
		  );		

/*
ram u_ram (

         .clka                  (    clk                                 ),
	     .ena                   (    ram_cen & (ram_addr[31:28]==4'h4)   ),
	     .wea                   (    ram_wen ? ram_flag : 4'h0           ),
	     .addra                 (    ram_addr[10:2]                      ),
	     .dina                  (    ram_wdata                           ),
	     
	     .douta                 (    ram_rdata_ram                       )
	);		  
*/
/*ram altera internal ram*/
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
/*
module sram_sync32_async16(
    iRst,
    iClock,
    //****bus signal******
    iSync32_address,
    iSync32_byteena,
    iSync32_data,
    iSync32_wren,
    iSync32_ce,
    oSync32_q,
    oSync32_wait,
    //*****ram signal*****
    oAsync16_address,
    oAsync16_byteena_n,
    oAsync16_data,
    oAsync16_data_oe_tri,
    oAsync16_wren_n,
    oAsync16_ce_n,
    oAsync16_oe_n,
    iAsync16_q,
    );
*/    
assign io_ram=( data_oe_tri? data_ram : {32{1'bZ}} );
wire adaptor_en;//just for debug, slow beat
defparam u_ram.ADDR_WIDTH = SRAM_ADDR_WIDTH;
sram_sync32_async16 u_ram(
    .iRst(rst),
    .iClock(clk),
    .iAdaptor_en(adaptor_en),

    .iSync32_address(ram_addr[SRAM_ADDR_WIDTH-1:0]),
    .iSync32_byteena(ram_flag),
    .iSync32_data(ram_wdata),
    .iSync32_wren(ram_wen),
    .iSync32_ce(mod_sel[0]),
    .oSync32_q(ram_rdata_ram),
    .ocSync32_wait(wait_cpu),
    //*****ram signal*****
    .oAsync16_address(o_address_ram),
    .oAsync16_byteena_n(o_byteena_ram),
    .oAsync16_data(data_ram),
    .oAsync16_data_oe_tri(data_oe_tri),
    .oAsync16_wren_n(o_wren_ram),
    .oAsync16_ce_n(o_ce_ram),
    .oAsync16_oe_n(o_oe_ram),
    .iAsync16_q(io_ram)
    );
sram_adaptor_en u_ram_adaptor_en(
    .iRst(rst),
    .iClock(clk),
    .oAdaptor_en(adaptor_en)
    );
/*
sram_extern_32 u_ram(
        .clock(clk),
        .rst(rst),

        .address_bus(ram_addr[10:2]),
        .byteena_bus(ram_flag),
        .data_bus(ram_wdata),
        .wren_bus(ram_wen),
        .ce_bus(mod_sel[0]),
        .q_bus(ram_rdata_ram),
        .wait_bus(wait_cpu),

        .address_ram(o_address_ram),
        .byteena_ram(o_byteena_ram),
        .data_ram(data_ram),
        .data_oe_tri(data_oe_tri),
        .wren_ram(o_wren_ram),
        .ce_ram(o_ce_ram),
        .oe_ram(o_oe_ram),
        .q_ram(io_ram)
    );
*/    
/*	
module sram_extern_32 (
	clock,
	rst,

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
    data_oe_tri,
    wren_ram,
    ce_ram,
    oe_ram,
    q_ram,
	);
*/	
/*
rxtx 
#( .baud ( 115200 ),
   .mhz  ( 25     )
 )
u_uart (
         .clk                  (    clk                  ),
		 .rst                  (    rst                  ),
		 .rx                   (    RxD                  ),
		 .tx_vld               (    tx_vld               ),
		 .tx_data              (    tx_data              ),
		
		 .rx_vld               (    rx_vld               ),
		 .rx_data              (    rx_data              ),
		 .tx                   (    TxD                  ),
		 .txrdy                (    txrdy                )
			);	
*/	
rxtx_bus u_uart(
   .clk(clk),
   .rst(rst),
   .ce(mod_sel[2]),
   .we(ram_wen),
   .addr(ram_addr[3:0]),
   .din(ram_wdata),
   .dout(uart_rdata),

   .RxD(RxD/*rx_n*/),
   .TxD(TxD/*tx_n*/)
   );
//assign rx_n=~RxD;   
//assign TxD=~tx_n;  

gpio_bus u_gpio(
   .clk(clk),
   .rst(rst),
   .ce(mod_sel[3]),
   .we(ram_wen),
   .addr(ram_addr[2:0]),
   .din(ram_wdata),
   .dout(gpio_rdata),

   .gpio(LED_out[1])
   );
/*   
always @ (posedge clk or posedge rst )
if ( rst )
    mod_sel <= 4'b1;
else if (ram_cen )
    mod_sel <= {(ram_addr[31:28]==4'hd), (ram_addr[31:28]==4'he),(ram_addr[31:28]==4'h0),(ram_addr[31:28]==4'h4) };
else;
*/
always @(*)
if (ram_cen)
    mod_sel = {(ram_addr[31:28]==4'hd), (ram_addr[31:28]==4'he),(ram_addr[31:28]==4'h0),(ram_addr[31:28]==4'h4) };
else
    mod_sel = 4'h0;

always @(posedge clk or posedge rst)
    if(rst)
        mod_sel_d<=4'b1;
    else
        mod_sel_d<=mod_sel;

always @ ( * )
if (mod_sel_d[3])
    ram_rdata = gpio_rdata;
else if (mod_sel_d[2])
    ram_rdata = uart_rdata;
else if (mod_sel_d[1])
    ram_rdata = ram_rdata_rom;
else //if (mod_sel[0])
    ram_rdata = ram_rdata_ram;
/*
always @ (posedge clk or posedge rst )
if ( rst )
    tx_vld <= 1'b0;
else
    tx_vld <= ram_cen & ram_wen & (ram_addr==32'he0000004);
	
always @ (posedge clk or posedge rst )
if ( rst )
    tx_data <= 8'h0;
else if ( ram_cen & ram_wen & (ram_addr==32'he0000004) )
    tx_data <= ram_wdata[7:0];
else;
*/
	 led0_module U1
	 (
	     .CLK( clk ),
		  .RSTn( rst_n ),
		  .LED_Out( LED_out[0] )
	 );



endmodule
		

