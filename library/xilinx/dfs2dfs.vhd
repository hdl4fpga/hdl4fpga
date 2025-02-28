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

entity dfs2dfs is
	generic (
		dcm_per  : real := 20.0;
		dfs1_mul : natural := 10;
		dfs1_div : natural := 3;
		dfs2_mul : natural := 10;
		dfs2_div : natural := 3);
	port ( 
		dcm_rst : in  std_logic; 
		dcm_clk : in  std_logic; 
		dfs_clk : out std_logic; 
		dcm_lck : out std_logic);
end;

architecture behavioral of dfs2dfs is
	signal dfs_lck : std_logic;
    signal dfs_clkfb  : std_logic;

	signal dcm1_rst : std_logic;
	signal dcm_clkin : std_logic;
	signal dcm_clkfb : std_logic;
	signal dcm_clk0  : std_logic;
	signal dcm_clkfx : std_logic;

	constant n1 : natural := 16;
constant n2 : natural := 16;
begin
   
	dcm1_u : dcm
	generic map(
		clk_feedback => "1X",
		clkdv_divide => 2.0,
		clkfx_divide => dfs1_div,
		clkfx_multiply => dfs1_mul,
		clkin_divide_by_2 => FALSE,
		clkin_period => dcm_per,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => TRUE,
		factory_jf => x"c080",
		phase_shift => 0,
		startup_wait => FALSE)
	port map (
		dssen  => '0',
		psclk  => '0',
		psen   => '0',
		psincdec =>'0',

		rst   => dcm_rst,
		clkin  => dcm_clk,
		clkfb  => dfs_clkfb,
		clk0   => dfs_clkfb,
		clkfx => dcm_clkin,
		locked => dfs_lck);

	process (dfs_lck, dcm_clk)
		variable srl16 : std_logic_vector(0 to 8-1) := (others => '1');
	begin
		if dfs_lck='0' then
			dcm1_rst <= '1';
		elsif rising_edge(dcm_clk) then
			srl16 := srl16(1 to srl16'right) &  not dfs_lck;
			dcm1_rst <= srl16(0) or not dfs_lck;
		end if;
	end process;

	dcm_sp_inst2 : dcm
	generic map(
		clk_feedback   => "1X",
		clkdv_divide   => 2.0,
		clkfx_divide => dfs2_div,
		clkfx_multiply => dfs2_mul,
		clkin_divide_by_2 => FALSE,
		clkin_period   => (dcm_per*real(dfs1_div))/real(dfs1_mul),
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "LOW",
		dll_frequency_mode => "LOW",
		duty_cycle_correction => true,
		factory_jf     => x"c080",
		phase_shift    => 0,
		startup_wait   => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',
		rst      => dcm1_rst,
		clkin    => dcm_clkin,
		clkfb    => dcm_clkfb,
		clkfx    => dcm_clkfx,
		locked   => dcm_lck);

	dcm_clkfb_bufg : bufg
	port map (
		i => dcm_clkin,
		o => dcm_clkfb);

	dcm_clkfx_bufg : bufg
	port map (
		i => dcm_clkfx,
		o => dfs_clk);

end;






