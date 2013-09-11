library verilog;
use verilog.vl_types.all;
entity sram_sync32_async16 is
    port(
        iRst            : in     vl_logic;
        iClock          : in     vl_logic;
        iSync32_address : in     vl_logic_vector(8 downto 0);
        iSync32_byteena : in     vl_logic_vector(3 downto 0);
        iSync32_data    : in     vl_logic_vector(31 downto 0);
        iSync32_wren    : in     vl_logic;
        iSync32_ce      : in     vl_logic;
        oSync32_q       : out    vl_logic_vector(31 downto 0);
        oSync32_wait    : out    vl_logic;
        oAsync16_address: out    vl_logic_vector(8 downto 0);
        oAsync16_byteena_n: out    vl_logic_vector(1 downto 0);
        oAsync16_data   : out    vl_logic_vector(15 downto 0);
        oAsync16_data_oe_tri: out    vl_logic;
        oAsync16_wren_n : out    vl_logic;
        oAsync16_ce_n   : out    vl_logic;
        oAsync16_oe_n   : out    vl_logic;
        iAsync16_q      : in     vl_logic_vector(15 downto 0)
    );
end sram_sync32_async16;
