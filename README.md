Scope
=====

Scope is a FPGA applicaction to capture data and send it to DDR RAM. After capturing it, the data can be downloaded to a
computer throught the kit's ethernet interface by UDP. A *lfsr* is used to generate the data so that the consistency of
the downloaded data can be checked into the PC. The application was tested on five kits: four of them correspond to Xilinx's 
FPGA kits and one to Lattice Semiconductor's FPGA kit.
The application is ready to be synthesized by theirs rescpective tools. The project's location for each kit can be found on 
the table below. The steps to generate the programs along with the computer's network configuration to download the data is
described in the section *PC steps*.

The data downloaded by **scope** is stored in the file master.dat.Then, master.dat is check by **check** to verified
its consistency. A new data dump, named dump.dat, is downloaded and comparared against master.dat. if the files are equal
a new dump is downloaded and checked it again.

**Location of the FPGA Projects**

| Kit                                               | FPGA synthesis tool  | Location                                 |
| ------------------------------------------------- | -------------------- | ---------------------------------------- |
| Artix-7 35T Arty FPGA Evaluation Kit              | Vivado Design Suite  | hdl4fpga/arty/vivado/scope/scope.xpr     |
| LatticeECP3 Versa Development Kit                 | Lattice Diamond      | hdl4fpga/ecp3versa/diamond/ecp3versa.ldf |
| NU HORIZONS Spartan 3A DSP Reference Kit          | ISE Design Suite     | hdl4fpga/nuhs3adsp/ise/scope/scope.xise  |
| Spartan-3E Starter Board                          | ISE Design Suite     | hdl4fpga/s3estarter/ise/scope/scope.xise |
| Virtex-5 OpenSPARC FPGA Development Board : ML509 | ISE Design Suite     | hdl4fpga/ml509/ise/scope/scope.xise      |


PC steps
=========

| Step                      | Linux                                              | Windows        |
| ------------------------- | ------------------------------------------------- | --------------- |
| Program compiling 1)      | make linux                                     | make windows |
| Network Configuriation 2) | arp -s *your-kit-ip-address* 00:00:00:01:02:03 | netsh interface ipv4 add neighbors "Ethernet" *your-kit-ip-address* 00-00-00-01-02-03 |


1) *Windows* Requires GNU CC which can be download at http://www.mingw.org/ *

2) *"Ethernet" is the Windows' interface name in which the PC is connected to the same LAN where the kit is connected to.
Sometimes Windows changes it so check your ethernet's name and replace it by "Ethernet" if it is different.*

Dumping the data
----------------

| Kit                                               | Command                                              |
| ------------------------------------------------- | ---------------------------------------------------- |
| Artix-7 35T Arty FPGA Evaluation Kit              | hdl4fpga/arty/bin/memtest your-kit-ip-address        |
| LatticeECP3 Versa Development Kit                 | hdl4fpga/ecp3versa/bin/memtest your-kit-ip-address   |
| NU HORIZONS Spartan 3A DSP Reference Kit          | hdl4fpga/nuhs3adsp/bin/memtest your-kit-ip-address   |
| Spartan-3E Starter Board                          | hdl4fpga/s3estarter/bin/memtest your-kit-ip-address  |
| Virtex-5 OpenSPARC FPGA Development Board : ML509 | hdl4fpga/ml509/bin/memtest your-kit-ip-address       |

* Linux or Windows*

HDL4FPGA's DDR performance
--------------------------

Tested Kits

| Kit        | Family         | Manufacturer   | Device     | Grade | DRAM Clock | Transfer  | Module word |
| ---------- | :------------- | :------------- | :--------- | ----: | ---------: | --------: | ----------: |
| ARTY       | Artix-7        | Xilinx         | XC7A35T    | 1LI   |    525 MHz | 1050 MT/s |  16 bits    |
| ECP3VERSA  | ECP3           | Latticesemi    | LFE3-35EA  | 8     |    500 Mhz | 1000 MT/s |  16 bits    |
| NUHS3ADSP  | Spartan 3A DSP | Xilinx         | XC3SD1800A | 4     |    166 MHz |  333 MT/s |  16 bits    |
| S3EStarter | Spartan 3E     | Xilinx         | XC3S500E   | 4     |    150 MHz |  300 MT/s |  16 bits    |
| ML509      | Virtex 5       | Xilinx         | XC5LX110t  | 1     |    267 MHz |  533 MT/s |  72 bits    |

  * Fully constrain designs 
