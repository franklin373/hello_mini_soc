`timescale 1 ns/1 ns
`define DEL 2
module tb;

//parameter BINFILE = "D:/keil/Hello/Obj/hello.bin";
//parameter BINFILE = "../cpucode/hello.bin";
parameter BINFILE = "../../Hello_pro_cpucode/Hello/Obj/hello.bin";

reg clk = 1'b0;
always clk = #5 ~clk;

reg rst = 1'b1;
initial #10 rst = 1'b0;

reg [7:0] rom [8191:0];

integer fd,fx;
initial begin
  int i;

  for(i=0;i<8192;i=i+1)
    rom[i]=0;
  
  fd = $fopen(BINFILE,"rb");
  fx = $fread(rom,fd);
  $fclose(fd);

  //now will generate mif file
  fd=$fopen("../../hello_altera/rom_init.mif","w");
  $fdisplay(fd,"WIDTH=32;");
  $fdisplay(fd,"DEPTH=2048;");
  $fdisplay(fd,"");
  $fdisplay(fd,"ADDRESS_RADIX=HEX;");
  $fdisplay(fd,"DATA_RADIX=HEX;");
  $fdisplay(fd,"");
  $fdisplay(fd,"CONTENT BEGIN");
  for(i=0;i<2048;i=i+1)
    $fdisplay(fd," %8h : %2h%2h%2h%2h;",i,rom[4*i+3],rom[4*i+2],rom[4*i+1],rom[4*i]);
  $fdisplay(fd,"");
  $fdisplay(fd,"END;");
  $fdisplay(fd,"");
  $fdisplay(fd,"%% End of file %%");
end

wire        rom_en;
wire [31:0] rom_addr;
reg  [31:0] rom_data;
always @ (posedge clk)
if (rom_en)
    rom_data <= #`DEL {rom[rom_addr+3],rom[rom_addr+2],rom[rom_addr+1],rom[rom_addr]};
else;


wire        ram_cen;
wire        ram_wen;
wire [3:0]  ram_flag;
wire [31:0] ram_addr;
wire [31:0] ram_wdata;

reg [31:0] ram [511:0];

reg [31:0] ram_rdata;

always @ (posedge clk )
if ( ram_cen & ~ram_wen )
    if (ram_addr==32'he0000000)
	    ram_rdata <= #`DEL 32'h0;
	else if (ram_addr[31:28]==4'h0)
	    ram_rdata <= #`DEL  {rom[ram_addr+3],rom[ram_addr+2],rom[ram_addr+1],rom[ram_addr]};
    else if (ram_addr[31:28]==4'h4)
	    ram_rdata <= #`DEL ram[ram_addr[27:2]];
	else;
else;


always @ (posedge clk )
if (ram_cen & ram_wen & (ram_addr[31:28]==4'h4))
    ram[ram_addr[27:2]] <= #`DEL { (ram_flag[3] ? ram_wdata[31:24]:ram[ram_addr[27:2]][31:24]),(ram_flag[2] ? ram_wdata[23:16]:ram[ram_addr[27:2]][23:16]),(ram_flag[1] ? ram_wdata[15:8]:ram[ram_addr[27:2]][15:8]),(ram_flag[0] ? ram_wdata[7:0]:ram[ram_addr[27:2]][7:0])};
else;


always @ (posedge clk)
if (ram_cen & ram_wen & (ram_addr==32'he0000004) )
    $write("%s",ram_wdata[7:0]);
else;

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

misc u_misc(
            .clk        (clk),
            .rom_addr   (rom_addr),
            .rom_en     (rom_en)
        );

endmodule
