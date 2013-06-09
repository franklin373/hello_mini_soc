module gpio_bus (
   clk,
   rst,
   ce,
   we,
   addr,
   din,
   dout,

   gpio
   );
   
    input              clk;
    input              rst;
    input              ce;
    input              we;
    input[2:0]         addr;
    input[31:0]        din;
    output[31:0]       dout;

    output gpio;



    reg dout;

    reg gpio;


    	
    always @ (posedge clk or posedge rst )
    if ( rst )
        gpio <= 1'h0;
    else if ( ce & we & (addr==3'h0) )
        gpio <= din[0];
    else;

    always @ ( * )
    if (ce & ~we & addr==3'h0)
        dout = gpio ? 32'h0:32'h1;

endmodule			

