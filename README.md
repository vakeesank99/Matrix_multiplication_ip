# Matrix_multiplication_SoC
This is matrix multiplication ip for vivado 2018.3 design flow using zybo board. you can find both verilog and SDK files here.
The block digram of the matrix multiplication ip is given below. you can get idea of the files in [here](https://github.com/vakeesank99/Matrix_multiplication_ip/tree/main/IP%20files).
![](https://github.com/vakeesank99/Matrix_multiplication_ip/blob/main/block_diagram_for_ip.png) 
using the IP files try to package the ip with the axi stream master and slave interfaces and connect it in the main block diagram like below. 
![](https://github.com/vakeesank99/Matrix_multiplication_ip/blob/main/overall_block_diagram.png)
all other ips you have to import from the vivado ip catlog. after that validate design -> create HDL wrapper -> generate bit stream -> launch SDK or vitis IDE. after all these process import the [C_code](https://github.com/vakeesank99/Matrix_multiplication_ip/blob/main/SDK_code.c) to your project.
I give some useful tutorials here to foloow and clear your doubt about custom IP creation and DMA initialization.
[Reconfigurable Embedded Systems with Xilinx Zynq APSoC](https://www.youtube.com/watch?v=ahws--oNpBc&list=PLXHMvqUANAFOviU0J8HSp0E91lLJInzX1) by [Kizheppatt Vipin](https://github.com/vipinkmenon)
[ECE270: Embedded Logic Design (ELD), IIIT Delhi](https://www.youtube.com/watch?v=MOqFfnEImFw&list=PL579fbjB-a0u7ilbp5173Ulm-RJelsHtR)
