module rxtx_bus (
   clk,
   rst,
   ce,
   we,
   addr,
   din,
   dout,

   RxD,
   TxD
   );
   
    input              clk;
    input              rst;
    input              ce;
    input              we;
    input[2:0]         addr;
    input[31:0]        din;
    output[31:0]       dout;

    input RxD;
    output TxD;


    reg                tx_vld;
    reg   [7:0]        tx_data;

    reg dout;


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

    always @ (posedge clk or posedge rst )
    if ( rst )
        tx_vld <= 1'b0;
    else 
        tx_vld <= ce & we & (addr==3'h4);
    	
    always @ (posedge clk or posedge rst )
    if ( rst )
        tx_data <= 8'h0;
    else if ( ce & we & (addr==3'h4) )
        tx_data <= din[7:0];
    else;

    always @ ( * )
    if (ce & ~we & addr==3'h0)
        dout = txrdy ? 32'h0:32'h1;

endmodule			
