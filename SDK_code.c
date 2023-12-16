
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <time.h>
#include "xtime_l.h"
#include <stdbool.h>
#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_io.h"
#include "xscugic.h"
#include "xil_cache.h"

#define MAT_SIZE 16
#define MAX_MAT_SIZE 16

//XAxiDma AxiDma;  //intsance of dma block

XScuGic IntcInstance;
static void matMulISR(void * callBackRef );
static void dmaReceiveISR(void * callBackRef );
u32 checkIdle(u32 baseAddress, u32 offset);
void multiply(int M1[MAT_SIZE][MAT_SIZE], int M2[MAT_SIZE][MAT_SIZE], int M3_SW[MAT_SIZE][MAT_SIZE]);
int done;

u32 DMA_input[2*MAT_SIZE*MAT_SIZE];
u32 DMA_output[MAT_SIZE*MAT_SIZE]; //store the output from the PL part
u32 status;


int main()
{
    init_platform();

    int M1[MAX_MAT_SIZE][MAX_MAT_SIZE];
	int M2[MAX_MAT_SIZE][MAX_MAT_SIZE];
	int M3_SW[MAX_MAT_SIZE][MAX_MAT_SIZE];      //software mat mul solution is stored here
	int M3_HW[MAX_MAT_SIZE][MAX_MAT_SIZE];		//hardware solution is stored
    int i,j;

    XTime tprocessorStart, tprocessorEnd, tFPGAStart, tFPGAEnd;
// getting the inputs from the user
//    printf("BUILDING with deafult optimization!");
//    printf("Enter the elements of Matrix 1 \n =================\n");
//    for (i=0; i<MAT_SIZE; i++)
//    	for(j=0;j<MAT_SIZE;j++)
//    	{
//    		printf("Enter the element of M1 [%d][%d]\n",i,j);
//    		scanf("%d",&M1[i][j]);
//    	}
//    printf("Enter the elements of Matrix 2 \n =================\n");
//    for (i=0; i<MAT_SIZE; i++)
//    	for(j=0;j<MAT_SIZE;j++)
//    	{
//    		printf("Enter the element of M2 [%d][%d]\n",i,j);
//    		scanf("%d",&M2[i][j]);
//    	}

    //pad the zero for all 16 values
    for (i=0; i<MAX_MAT_SIZE;i++){
    	for(j=0;j<MAX_MAT_SIZE;j++){
    		M1[i][j] = 0;
    		M2[i][j] = 0;
//    		M3_SW[i][j] = 0;
//    		M3_HW[i][j] = 0;
    	}
    }

    // getting random input
    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++){
    		M1[i][j] = ((int)rand()/(RAND_MAX/5));
    		M2[i][j] = ((int)rand()/(RAND_MAX/5));
    	}
    }
    // print the entered matrix
    printf("The entered matrix 1 is \n");
    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++)
    		printf("%d",M1[i][j]);
    	printf("\n");
    }
    printf("The entered matrix 2 is \n");
    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++)
    		printf("%d",M2[i][j]);
    	printf("\n");
    }
//------------------------------------------------------------------------------------
    // PS part
    XTime_GetTime(&tprocessorStart); //only the multiplication time
    multiply(M1,M2,M3_SW);
    XTime_GetTime(&tprocessorEnd);
//------------------------------------------------------------------------------------
    //PL part
	printf("\r\n********Main function******\r\n");


	//bool err_flag = false; //error flag fr the mismatch between the transmitted and recieved data
    //generate DMA input
	int id=0;
    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++){
    		DMA_input[id]=M1[i][j];   //i - row and j - column
    		id=id+1;
    	}
    }

    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++){
    		DMA_input[id]=M2[0][i];   //i - row and j - column
    		id=id+1;
    	}
    }
//---------------------DMA controller configuration intialization   ------------------------------------//

	XAxiDma AxiDma;  //instance of DMA block
	XAxiDma_Config *CfgPtr;
	CfgPtr = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID); //extracts the configuration setting of dma
	if (!CfgPtr)
	{
		printf("No configuration found for :%d\r\n",XPAR_AXI_DMA_0_DEVICE_ID);
		return -1;
	}
	else
		printf("DMA configuration found!..\r\n");


	status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (status != XST_SUCCESS)
	{
		printf("DMA initialization failed!\r\n");
		return -1;
	}
	printf("DMA initialization success!..\r\n");

// because we are using the ACP port sch that we don't need it
//	Xil_DCacheFlushRange((u32)DMA_input, sizeof(u32)*2*MAT_SIZE*MAT_SIZE);   //write back the data in the DDR memory & removing cache range
//	Xil_DCacheFlushRange((u32)DMA_output, sizeof(u32)*MAT_SIZE*MAT_SIZE);

    status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
    printf("Status before data transfer %lu\n", status);
    printf("\r------------Starting the Data transfer------------->>>>>>>>>\r\n");


    XAxiDma_IntrEnable(&AxiDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA); //enable the inrrupt for completion of the dma

    //--------------interrupt controller configuration---------------------------------//
    XScuGic_Config *IntcConfig;
    IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    status = XScuGic_CfgInitialize(&IntcInstance, IntcConfig, IntcConfig->CpuBaseAddress);
     if (status != XST_SUCCESS){
    	 printf("Interrupt controller initialization failed!");
    	 return -1;
     }
     else
    	 printf("Interrupt controller initialized successfully!\n");


     //interrupt 1
     XScuGic_SetPriorityTriggerType(&IntcInstance, XPAR_FABRIC_MATMULADS_0_O_INTR_INTR,0xA0,3); //edge triggered interrupt find the name @xparamers.h
     status = XScuGic_Connect(&IntcInstance,XPAR_FABRIC_MATMULADS_0_O_INTR_INTR,(Xil_InterruptHandler)matMulISR,(void *)&AxiDma); //ISr is called
     if (status != XST_SUCCESS){
    	 printf("interrupt 1 connection failed!");
    	 return -1;
     }
     else
    	 printf("interrupt 1 connection success..!\n");
     XScuGic_Enable(&IntcInstance,XPAR_FABRIC_MATMULADS_0_O_INTR_INTR); //enabling the interrupt

     //interrupt 2
     XScuGic_SetPriorityTriggerType(&IntcInstance, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,0xA1,3); //edge triggered interrupt find the name @xparamers.h
     status = XScuGic_Connect(&IntcInstance,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR,(Xil_InterruptHandler)dmaReceiveISR,(void *)&AxiDma);
     if (status != XST_SUCCESS){
    	 printf("interrupt 2 connection failed!");
    	 return -1;
     }
     else
    	 printf("interrupt 2 connection success..!\n");

     XScuGic_Enable(&IntcInstance,XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR); //enabling the interrupt

     //interrupt controller routine
     Xil_ExceptionInit();
     Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, (void*)&IntcInstance);
     Xil_ExceptionEnable();



    XTime_GetTime(&tFPGAStart); //only the multiplication time
//---------------------------------initialize dma------------------------------------------//
    status = XAxiDma_SimpleTransfer(&AxiDma, (u32)DMA_input, sizeof(u32)*(MAT_SIZE+1)*MAT_SIZE, XAXIDMA_DMA_TO_DEVICE);
	if (status != XST_SUCCESS)
	{
		printf("Writing first 17 rows of (matrix A and matrix B[0]) data to IP via DMA failed...!\r\n");
		return -1;
	}
	else
		printf("Sending the First 17 rows of data to IP successful!\n");
    status = XAxiDma_SimpleTransfer(&AxiDma, (u32)DMA_output, sizeof(u32)*MAT_SIZE*MAT_SIZE, XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS)
    {
    	printf("Reading data from IP via DMA failed....!\r\n");
    	return -1;
    }


//------------------only for pooling mode -----------------------------------------//
//    status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
//	while(status !=2)
//	{
//		status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
//	}
//		status= checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x34);
//	while(status !=2)
//	{
//		status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x34);
//	}

//-----------------interrupt mode waiting------------------------------------------//
    while(done<16){
    	//...here
    	if (done==1)
    		printf("first cycle completed!");

    }

    printf("DMA transfer success!--\n");
    XTime_GetTime(&tFPGAEnd);

//receive the output and store in the matrix
	id=0;
    for (i=0; i<MAT_SIZE;i++){
    	for(j=0;j<MAT_SIZE;j++){
    		M3_HW[i][j] = DMA_output[id];   //i - row and j - column
    		id=id+1;
    	}
    }

//	printf("our received resultaant matrix from the PL part");
//    for (i=0; i<MAT_SIZE*MAT_SIZE;i++){
//    		printf("%lu \n",DMA_output[i]);   //i - row and j - column
//
//    }
     printf("\n...Comparing the software matrix multiplier outputs with hardware matrix multiplier\r\n");

     printf("The resultant matrix from software is \n");
	   for (i=0; i<MAT_SIZE;i++){
		for(j=0;j<MAT_SIZE;j++)
			printf(" %d ",M3_SW[i][j]);
		printf("\n");
	   }

	//   change this to check the M3_SWult from
	    for (i=0; i<MAT_SIZE;i++){
	    	for(j=0;j<MAT_SIZE;j++){
	    		if((M3_HW[i][j]-M3_SW[i][j])!= 0){
	    			printf("Non-optimized Matrix mul error at the row %d and column %d\n",i+1,j+1);
	    			printf("Hardware output %d and software output %d", M3_HW[i][j],M3_SW[i][j]);
	    			break;
	    		}
	    	}
	    }
//       for (j=0; j<FIFO_DEPTH; j++)
//       {
//       	if(DMA_input[j] != DMA_output[j])
//       	{
//       		err_flag =true;
//       		break;
//       	}
//       }
//       if (err_flag)
//       	printf("Data mismatch found at %d. trasnmitted data %d received data %d\r\n",j,DMA_input[j],DMA_output[j]);
//       else
//       	printf("DMA ran successfully!");

//----------------------Timing comparision----------------------------
    printf("\n--------------TIME COMPARISION-------------------------\n");

    printf("PS took %.2f us. to calculate the product \n", 1.0*(tprocessorEnd-tprocessorStart));
    printf("PL took %.2f us. to calculate the product \n", 1.0*(tFPGAEnd-tFPGAStart));

    cleanup_platform();
    return 0;
}

//-----------------------interrupt routin1-----------------------------------------------------//
static void matMulISR(void *callBackRef){
	static int i = 17; //make  sure it's intialize only once so put static bn!
	XScuGic_Disable(&IntcInstance, XPAR_FABRIC_MATMULADS_0_O_INTR_INTR); //disable the interrupt

    status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4);
    while (status == 0){
        status = checkIdle(XPAR_AXI_DMA_0_BASEADDR,0x4); //kind poling to wait until  DMA idle state otherwise exsiting data gone!
    }
	if (i< 32){
		status = XAxiDma_SimpleTransfer((XAxiDma *)callBackRef, (u32)&DMA_input[i*16], sizeof(u32)*MAT_SIZE, XAXIDMA_DMA_TO_DEVICE); //callbackref is the pointer to dma
		i++;
	}
	XScuGic_Enable(&IntcInstance, XPAR_FABRIC_MATMULADS_0_O_INTR_INTR); // before return re enable

}

//-----------------------interrupt routin2-----------------------------------------------------//
static void dmaReceiveISR(void * callBackRef ){
//	XScuGic_Disable(&IntcInstance, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR); //disable the interrupt
    XAxiDma_IntrDisable((XAxiDma *)callBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA); //enable the inrrupt for completion of the dma
    XAxiDma_IntrAckIrq((XAxiDma *)callBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA); //cler the flag
    done = done + 1;
    XAxiDma_IntrEnable((XAxiDma *)callBackRef, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA); //enable the inrrupt for completion of the dma
}

//---------------------------check the DMA idle state------------------------------------------//
u32 checkIdle(u32 baseAddress, u32 offset)
{
	u32 status;
	status= (XAxiDma_ReadReg(baseAddress, offset)) & XAXIDMA_IDLE_MASK;
	return status;
}

//----------------------------classical matrix multiplication----------------------------------//
void multiply(int M1[MAT_SIZE][MAT_SIZE], int M2[MAT_SIZE][MAT_SIZE], int M3_SW[MAT_SIZE][MAT_SIZE])
{
	int i,j,k;
	for(i=0; i<MAT_SIZE; i++){
		for(j=0;j<MAT_SIZE;j++){
			M3_SW[i][j]=0;
			for(k=0;k<MAT_SIZE;k++)
				M3_SW[i][j]+=M1[i][k]*M2[k][j];
		}
	}

}
//---------------------------------DMA initialization-------------------------------------------//
//int init_DMA()
//{
//	XAxiDma_Config *CfgPtr;
//	int status;
//	CfgPtr = XAxiDma_LookupConfig(XPAR_AXI_DMA_0_DEVICE_ID); //extracts the configuration setting of dma
//	if (!CfgPtr)
//	{
//		printf("No config found for %d\r\n",XPAR_AXI_DMA_0_DEVICE_ID);
//		return XST_FAILURE;
//	}
//	status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
//	if (status != XST_SUCCESS)
//	{
//		printf("DMA intilization Failed return status: %d\r\n",status);
//		return XST_FAILURE;
//	}
//	if(XAxiDma_HasSg(&AxiDma))
//	{
//		printf("Device configured as SG model\r\n");
//		return XST_FAILURE;
//	}
//	return XST_SUCCESS;
//}
