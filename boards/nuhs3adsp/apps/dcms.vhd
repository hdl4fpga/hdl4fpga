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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dcms is
	generic (
		ddr_mul : natural;
		ddr_div : natural;
		sys_per : real);
	port (
		sys_rst   : in  std_logic;
		sys_clk   : in  std_logic;
		input_clk : out std_logic;
		ddr_clk0  : out std_logic;
		ddr_clk90 : out std_logic;
		video_clk : out std_logic;
		mii_clk   : out std_logic;
		input_rst : out std_logic;
		ddr_rst   : out std_logic;
		mii_rst   : out std_logic;
		video_rst : out std_logic);
end;

architecture def of dcms is

	constant input : natural := 0; 
    constant mii   : natural := 1;
    constant video : natural := 2;
    constant ddr   : natural := 3;

	signal clks : std_logic_vector(0 to 3);
	signal lcks : std_logic_vector(clks'range);
begin

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 15,
		dfs_div => 2)
	port map(
		dcm_rst => sys_rst,
		dcm_clk => sys_clk,
		dfs_clk => clks(video),
		dcm_lck => lcks(video));

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst   => sys_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => clks(ddr),
		dfsdcm_clk90 => ddr_clk90,
		dfsdcm_lckd  => lcks(ddr));

	inputdcm_e : entity hdl4fpga.dcmisdbt
	port map (
		sys_rst => sys_rst,
		sys_clk => sys_clk,
		dfs_clk => clks(input),
		dcm_lck => lcks(input));

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => sys_per,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => sys_rst,
		dcm_clk => sys_clk,
		dfs_clk => clks(mii),
		dcm_lck => lcks(mii));

	rsts_b : block
		signal rsts : std_logic_vector(clks'range);
	begin

		input_rst <= rsts(input);
		mii_rst   <= rsts(mii);
		video_rst <= rsts(video);
		ddr_rst   <= rsts(ddr);

		rsts_g: for i in clks'range generate
			signal q : std_logic;
		begin
			process (clks(i), sys_rst)
			begin
				if sys_rst='1' then
					q <= '1';
				elsif rising_edge(clks(i)) then
					q <= not lcks(i);
				end if;
			end process;
			rsts(i) <= q;
		end generate;
	end block;

	input_clk <= clks(input);
	mii_clk   <= clks(mii);
	video_clk <= clks(video);
	ddr_clk0  <= clks(ddr);

end;



