### FPGA 

| Kit                                               | FPGA synthesis tool  | Project location location                |
| ------------------------------------------------- | -------------------- | ---------------------------------------- |
| Artix-7 35T Arty FPGA Evaluation Kit              | Vivado Design Suite  | hdl4fpga/arty/vivado/scope/scope.xpr     |
| LatticeECP3 Versa Development Kit                 | Lattice Diamond      | hdl4fpga/ecp3versa/diamond/ecp3versa.ldf |
| NU HORIZONS Spartan 3A DSP Reference Kit          | ISE Design Suite     | hdl4fpga/nuhs3adsp/ise/scope/scope.xise  |
| Spartan-3E Starter Board                          | ISE Design Suite     | hdl4fpga/s3estarter/ise/scope/scope.xise |
| Virtex-5 OpenSPARC FPGA Development Board : ML509 | ISE Design Suite     | hdl4fpga/ml509/ise/scope/scope.xise      |

### Software

### Linux

#### Compiling

make linux

#### Configuring 

arp -s your-kit-ip-address 00:00:00:01:02:03

### Windows


#### Compiling

Requires GNU CC which can be download at http://www.mingw.org/

make windows

#### Configuring 

netsh interface ipv4 add neighbors "Ethernet" your-kit-ip-address 00-00-00-01-02-03

### Linux or Windows

#### Dumping the data 

| Kit                                               | Command                                              |
| ------------------------------------------------- | ---------------------------------------------------- |
| Artix-7 35T Arty FPGA Evaluation Kit              | hdl4fpga/arty/bin/memtest your-kit-ip-address        |
| LatticeECP3 Versa Development Kit                 | hdl4fpga/ecp3versa/bin/memtest your-kit-ip-address   |
| NU HORIZONS Spartan 3A DSP Reference Kit          | hdl4fpga/nuhs3adsp/bin/memtest your-kit-ip-address   |
| Spartan-3E Starter Board                          | hdl4fpga/s3estarter/bin/memtest your-kit-ip-address  |
| Virtex-5 OpenSPARC FPGA Development Board : ML509 | hdl4fpga/ml509/bin/memtest your-kit-ip-address       |

### HDL4FPGA's DDR performance table.

Tested Kits

| Kit        | Family         | Manufacturer   | Device     | Grade | DRAM Clock | Transfer  |
| ---------- | :------------- | :------------- | :--------- | ----: | ---------: | --------: |
| ARTY       | Artix-7        | Xilinx         | XC7A35T    | 1LI   |    525 MHz | 1050 MT/s |
| ECP3VERSA  | ECP3           | Latticesemi    | LFE3-35EA  | 8     |    500 Mhz | 1000 MT/s |
| NUHS3ADSP  | Spartan 3A DSP | Xilinx         | XC3SD1800A | 4     |    166 MHz |  333 MT/s |
| S3EStarter | Spartan 3E     | Xilinx         | XC3S500E   | 4     |    150 MHz |  300 MT/s |
| ML509      | Virtex 5       | Xilinx         | XC5LX110t  | 1     |    267 MHz |  533 MT/s |

  * Fully constrain designs 
