#include "xil_printf.h"
#include "xbram.h"
#include <stdio.h>
#include <stdlib.h>

#define BRAM_DEVICE_ID XPAR_AXI_BRAM_CTRL_0_DEVICE_ID
#define BASEADDRESS XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define HIGHADDRESS XPAR_AXI_BRAM_CTRL_0_S_AXI_HIGHADDR

XBram Bram;

int memdepth = 256;

u32 pattern[256];
u32 rdata1[256];
u32 rdata2[256];
u32 Start_Address1;
u32 Start_Address2;


void pattern_generate(void);

void pattern_generate(void)
{
	for(int i=0; i<memdepth; i++){
		pattern[i] = (u32)rand();
	}
}

int main(void)
{

	int Result;
	int error;
	pattern_generate();

	XBram_Config *ConfigPtr;

	ConfigPtr = XBram_LookupConfig(BRAM_DEVICE_ID);
	if (NULL == ConfigPtr) {
		return XST_FAILURE;
	}

	Result = XBram_CfgInitialize(&Bram, ConfigPtr,
			ConfigPtr -> CtrlBaseAddress);
	if (Result != XST_SUCCESS) {
		return XST_FAILURE;
	}

	while(1){

		error = 0;

		xil_printf("Enter start address1, start adrress2 : \n\r");
		scanf("%lx %lx", &Start_Address1, &Start_Address2);

		if ((Start_Address1 < BASEADDRESS) ||
			((Start_Address1 + (memdepth*4)) > Start_Address2) ||
			((Start_Address2 + (memdepth*4) - 1) > HIGHADDRESS) ||
			((Start_Address1 & 0x3) != 0) ||
			((Start_Address2 & 0x3) != 0)){
			xil_printf("Invalid Memory Range\n\r");
			continue;
		}


		for(int RegOffset=0; RegOffset<memdepth; RegOffset++) {
			XBram_WriteReg(Start_Address1, (RegOffset * 4), pattern[RegOffset]);
			XBram_WriteReg(Start_Address2, (RegOffset * 4), pattern[RegOffset]);
		}


		for(int RegOffset=0; RegOffset<memdepth; RegOffset++) {
			rdata1[RegOffset] = XBram_ReadReg(Start_Address1, (RegOffset * 4));
			rdata2[RegOffset] = XBram_ReadReg(Start_Address2, (RegOffset * 4));
		}

		for(int i=0; i<memdepth; i++){
			if (rdata1[i] != pattern[i]){
				xil_printf("FAIL ON DATA1 at index %d\n\r", i);
				error = 1;
			}
			if (rdata2[i] != pattern[i]){
				xil_printf("FAIL ON DATA2 at index %d\n\r", i);
				error = 1;
			}
		}
		if (error == 0){
			xil_printf("PASS\n\r");
		}
	}


}
