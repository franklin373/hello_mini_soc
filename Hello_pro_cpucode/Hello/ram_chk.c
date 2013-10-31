#if 0
#include "debug_frmwrk.h"
#include "lpc18xx_cgu.h"
#include "lpc18xx_scu.h"
#include "lpc18xx_libcfg.h"
#include "sdram_demo_board.h"
#endif
#include "Hello.h"
#define SDRAM_ADDR_BASE (0x40000000)
#define SDRAM_SIZE (0x800)



#define RAM_CHK_STR_SIZE (257)
unsigned char ram_chk_str[RAM_CHK_STR_SIZE];

#define RAM_CHK_FILL (0)
#define RAM_CHK_CHK (1)

void ram_chk_str_init()
{
	int i;

	for(i=0;i<RAM_CHK_STR_SIZE;i++){
		ram_chk_str[i]=(unsigned char)i;
	}
}
void ram_chk_iterator(int action)
{
	unsigned char *pRam;
	int str_index;

	if(action==RAM_CHK_FILL){
		output_str("ram_chk fill begin...\n");
	}else{
		output_str("ram_chk chk begin...\n");
	}
	for(pRam=(unsigned char *)SDRAM_ADDR_BASE,str_index=0;pRam<(unsigned char *)(SDRAM_ADDR_BASE+SDRAM_SIZE);++pRam){
		if(action==RAM_CHK_FILL){
			*pRam=ram_chk_str[str_index];
		}else{
			if(*pRam!=ram_chk_str[str_index]){
				output_str("pRam,*pRam,str_index,ram_chk_str[str_index]");
//				_DBH32((unsigned int)pRam);
				output_str(",");
//				_DBH32(*pRam);
				output_str(",");
//				_DBD32(str_index);
				output_str(",");
//				_DBH32(ram_chk_str[str_index]);
				output_str("\n");
				for(;;);
			}
		}
		str_index=(str_index!=RAM_CHK_STR_SIZE?str_index+1:0);
	}
	if(action==RAM_CHK_FILL){
		output_str("ram_chk fill end\n");
	}else{
		output_str("ram_chk chk end OK\n");
	}
}
void ram_chk()
{
	ram_chk_str_init();
	ram_chk_iterator(RAM_CHK_FILL);
	ram_chk_iterator(RAM_CHK_CHK);
}
int ram_test1()
{
	*(unsigned char *)(SDRAM_ADDR_BASE+0)=0xFF;
	*(unsigned char *)(SDRAM_ADDR_BASE+1)=0x75;
	*(unsigned char *)(SDRAM_ADDR_BASE+2)=0x3;
	*(unsigned char *)(SDRAM_ADDR_BASE+3)=0x4;
	return *(int *)(SDRAM_ADDR_BASE);
}

