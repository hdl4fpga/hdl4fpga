--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use  hdl4fpga.scopeiopkg.all;

architecture scopeio_axis of testbench is

	signal rst   : std_logic := '0';
	signal clk   : std_logic := '0';

	signal axis_dv       : std_logic;
	signal axis_sel      : std_logic;
	signal axis_scale    : std_logic_vector(4-1 downto 0);
	signal axis_base     : std_logic_vector(4-1 downto 0);

	signal btof_binfrm   : std_logic_vector(0 to 0);
	signal btof_binirdy  : std_logic_vector(0 to 0);
	signal btof_bintrdy  : std_logic_vector(0 to 0);
	signal btof_binexp   : std_logic_vector(0 to 0);
	signal btof_bindi    : std_logic_vector(4-1 downto 0);
	signal btof_bcdunit  : std_logic_vector(4-1 downto 0);
	signal btof_bcdneg   : std_logic;
	signal btof_bcdsign  : std_logic;
	signal btof_bcdalign : std_logic;
	signal btof_bcdfrm   : std_logic_vector(0 to 0);
	signal btof_bcdirdy  : std_logic;
	signal btof_bcdtrdy  : std_logic_vector(0 to 0);
	signal btof_bcdend   : std_logic;
	signal btof_bcddo    : std_logic_vector(4-1 downto 0);

	signal hz_offset     : std_logic_vector(12-1 downto 0);
	signal vt_offset     : std_logic_vector(9-1 downto 0);
	signal video_hcntr     : std_logic_vector(12-1 downto 0);
	signal video_vcntr     : std_logic_vector(12-1 downto 0);
begin

	rst <= '1', '0' after 20 ns;
	clk <= not clk  after 10 ns;

	process (rst, clk)
		variable dv : std_logic;
	begin
		if rst='1' then
			dv      := '0';
			axis_dv <= '0';
		elsif rising_edge(clk) then
			if dv='0' then
				dv      := '1';
				axis_dv <= '1';
			else
				axis_dv <= '0';
			end if;
		end if;
	end process;

	btof_e : entity hdl4fpga.scopeio_btof
	port map (
		clk       => clk,
		bin_frm   => btof_binfrm,
		bin_irdy  => btof_binirdy,
		bin_trdy  => btof_bintrdy,
		bin_di    => btof_bindi,
		bin_exp   => btof_binexp,
		bcd_width => b"1000",
		bcd_sign  => btof_bcdsign,
		bcd_neg   => btof_bcdneg,
		bcd_unit  => btof_bcdunit,
		bcd_align => btof_bcdalign,
		bcd_prec  => b"1111",
		bcd_frm   => btof_bcdfrm,
		bcd_irdy  => btof_bcdirdy,
		bcd_trdy  => btof_bcdtrdy,
		bcd_end   => btof_bcdend,
		bcd_do    => btof_bcddo);

	axis_e : entity hdl4fpga.scopeio_axis
	generic map (
		latency       => 4,
		axis_unit     => std_logic_vector(to_unsigned(25,5)),
		layout        => displaylayout_table(1))
	port map (
		clk           => clk,
		axis_dv       => axis_dv,
		axis_sel      => '1',
		axis_base     => x"0",
		axis_scale    => x"0",
		btof_binfrm   => btof_binfrm(0),
		btof_binirdy  => btof_binirdy(0),
		btof_bintrdy  => btof_bintrdy(0),
		btof_bindi => btof_bindi,
		btof_binexp => btof_binexp(0),
		btof_bcdunit  => btof_bcdunit,
		btof_bcdneg   => btof_bcdneg,
		btof_bcdsign  => btof_bcdsign,
		btof_bcdalign => btof_bcdalign,
		btof_bcdfrm   => btof_bcdfrm(0),
		btof_bcdirdy  => btof_bcdirdy,
		btof_bcdtrdy  => btof_bcdtrdy(0),
		btof_bcdend   => btof_bcdend,
		btof_bcddo    => btof_bcddo,

		video_clk    => '1',
		video_hcntr  => video_hcntr,
		video_vcntr  => video_vcntr,

		hz_offset    => hz_offset,
		video_hzon   => '0',

		vt_offset    => vt_offset,
		video_vton   => '0');

end;
