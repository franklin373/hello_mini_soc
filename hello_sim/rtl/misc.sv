program automatic misc(clk,rom_addr,rom_en);
    input clk;
    input [31:0] rom_addr;
    input rom_en;

    `include "../rtl/utils/shift_reg32.sv"
    `include "../rtl/utils/lastN_SumPeaceCnt.sv"
    `include "../rtl/utils/addr_hook.sv"
    
`ifdef NOT_DEFINE
    function void cmd_hook(input bit[31:0] addr);
        static int dup_num;
        static bit[31:0] addr_last;

        if(addr_last == addr) begin
            ++dup_num;
        end else begin
            dup_num=0;
            addr_last=addr;
        end
        if(dup_num>=30) begin
            $finish;
        end
    endfunction
`endif
    initial begin
        addr_hook hook=new ();
        
        while (1) begin
            @(posedge clk);
            if(rom_en==1'b1)begin
                static int unsigned rom_addr_last;

                if(rom_addr!=rom_addr_last+4)begin
                    $write("%h\n",rom_addr_last);
                    $write("%h...",rom_addr);
                end
                rom_addr_last=rom_addr;
            end
            if(rom_en)begin
                hook.hook(rom_addr);
            end
        end
    end
endprogram
