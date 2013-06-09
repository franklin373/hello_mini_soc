module hello_soc_top (
   clk_50m,
   rst_n,
   RxD,
   
   TxD,
   LED_out
   );
   
input              clk_50m;
input              rst_n;
input              RxD;

output             TxD;
output     [1:0]        LED_out;

wire               clk;
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

reg   [31:0]       ram_rdata;
reg   [3:0]        mod_sel;
reg                tx_vld;
reg   [7:0]        tx_data;

  pll u_pll
   (// Clock in ports
    .inclk0            (clk_50m),      // IN
    // Clock out ports
    .c0           (clk));    // OUT

assign rst = ~rst_n;

arm9_compatiable_code u_arm9(
          .clk                 (    clk                   ),
          .cpu_en              (    1'b1                  ),
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

`ifdef NEVER_DEFINED		
ram u_ram (

         .clka                  (    clk                                 ),
	     .ena                   (    ram_cen & (ram_addr[31:28]==4'h4)   ),
	     .wea                   (    ram_wen ? ram_flag : 4'h0           ),
	     .addra                 (    ram_addr[10:2]                      ),
	     .dina                  (    ram_wdata                           ),
	     
	     .douta                 (    ram_rdata_ram                       )
	);		  
`else
ram u_ram (
	     .address                 (    ram_addr[10:2]                      ),
	     .byteena                   (    ram_flag            ),
         .clock                  (    clk                                 ),
	     .data                  (    ram_wdata                           ),
	     .wren                   (    ram_wen & (ram_addr[31:28]==4'h4)   ),
	     .q                 (    ram_rdata_ram                       )
	);		  
`endif
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
   .addr(ram_addr[2:0]),
   .din(ram_wdata),
   .dout(uart_rdata),

   .RxD(RxD),
   .TxD(TxD),
   );

gpio_bus u_gpio(
   .clk(clk),
   .rst(rst),
   .ce(mod_sel[2]),
   .we(ram_wen),
   .addr(ram_addr[2:0]),
   .din(ram_wdata),
   .dout(gpio_rdata),

   .gpio(LED_out[1]),
   );
   
always @ (posedge clk or posedge rst )
if ( rst )
    mod_sel <= 4'b1;
else if (ram_cen /*& ~ram_wen*/)
    mod_sel <= {(ram_addr[31:28]==4'hd), (ram_addr[31:28]==4'he),(ram_addr[31:28]==4'h0),(ram_addr[31:28]==4'h4) };
else;
	
always @ ( * )
if (mod_sel[3])
    ram_rdata = gpio_rdata;
else if (mod_sel[2])
    ram_rdata = uart_rdata;
else if (mod_sel[1])
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
		

