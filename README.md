#### Linux

make linux

arp -s your-kit-ip-address 00:00:00:01:02:03

Dumping the data 

* Latticesemi
	* LatticeECP3 Versa Development Kit
	ecp3versa/bin/memtest

* Xilinx
	* Artix-7 35T Arty FPGA Evaluation Kit
	arty/bin/memtest
	* Virtex-5 OpenSPARC FPGA Development Board : ML509 
	ml509/bin/memtest
	* NU HORIZONS Spartan 3A DSP Reference Kit
	nuhs3adsp/bin/memtest

#### Windows

make windows

netsh interface ipv4 add neighbors "Ethernet" your-kit-ip-address 00-00-00-01-02-03

ml509/bin/memtest.bat
ecp3versa/bin/memtest.bat
nuhs3adsp/bin/memtest.bat
ecp3versa/bin/memtest.bat

HDL4FPGA's DDR performance table.

Tested Kits

| Kit        | Family         | Manufacturer   | Device     | Grade | DRAM Clock | Transfer  |
| ---------- | :------------- | :------------- | :--------- | ----: | ---------: | --------: |
| ARTY       | Artix-7        | Xilinx         | XC7A35T    | 1LI   |    525 MHz | 1050 MT/s |
| ECP3VERSA  | ECP3           | Latticesemi    | LFE3-35EA  | 8     |    500 Mhz | 1000 MT/s |
| ML509      | Virtex 5       | Xilinx         | XC5LX110t  | 1     |    267 MHz |  533 MT/s |
| NUHS3ADSP  | Spartan 3A DSP | Xilinx         | XC3SD1800A | 4     |    166 MHz |  333 MT/s |
| S3EStarter | Spartan 3E     | Xilinx         | XC3S500E   | 4     |    150 MHz |  300 MT/s |

  * Fully constrain designs 
