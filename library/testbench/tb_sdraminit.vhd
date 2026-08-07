-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

architecture tb_sdraminit of testbench is
	constant ctlr_tcp : real := 1.0/100.0e6;
	signal sdram_init_a : std_logic_vector(14-1 downto 0);
	signal sdram_init_b : std_logic_vector(3-1 downto 0);
	signal sdram_init_clk : std_logic := '0';
	signal sdram_init_req : std_logic := '0';
	signal sdram_init_rdy : std_logic := '0';
begin

	sdram_init_clk <= not sdram_init_clk after (natural(ctlr_tcp*1.0e9)/2) * 1 ns;
	dut : entity work.sdram_init
	generic map (
		debug => false,
		ctlr_tcp => ctlr_tcp,
		sdramtmng_data => "{tWR : 25.0e-9, tRCD  : 15.0e-9, tRP : 15.00e-9, tMRD : 15.0e-9,  tRFC :  66.0e-9,  tREFI : 7.8125e-6}",
		gear => 4,
		generation => "sdr",
		generation_data => 
			"sdr : {" &
			"    al   : { '000' : 0 }," &
			"    bl   : { '000' : 0, '001' : 1, '010' : 2, '011' : 4 }," &
			"    cl   : { '001' : 1, '010' : 2, '011' : 3 }," &
			"    tmng : { tPreRST : 100.0e-6, cDLL : 200, tCAS : 15.0e-9}}")
	port map (
		sdram_init_clk => sdram_init_clk,
		init_rst => sdram_init_req,
		init_cfg => sdram_init_rdy,
		sdram_init_cl  => "1111",
		sdram_init_a => sdram_init_a,
		sdram_init_b => sdram_init_b);

end;
