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
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity alt_sdrdqphy is
	generic (
		dqs_delay  : time := 1.65*1.25 ns;
		dqi_delay  : time := 1.65*1.25 ns;

		loopback   : boolean := false;
		bypass     : boolean := false;
		bufio      : boolean;
		device     : fpga_devices;
		taps       : natural;
		data_gear  : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		tp_sel     : in  std_logic := '-';
		tp_delay   : out std_logic_vector(1 to 8);

		rst        : in  std_logic;
		iod_clk    : in  std_logic;
		clk0       : in  std_logic := '-';
		clk90      : in  std_logic := '-';
		clk0x2     : in  std_logic := '-';
		clk90x2    : in  std_logic := '-';

		sys_wlreq  : in  std_logic := '-';
		sys_wlrdy  : out std_logic;

		sys_rlreq  : in  std_logic;
		sys_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		read_brst  : out std_logic;
		write_rdy  : in  std_logic;
		write_req  : buffer std_logic;

		parallelterminationcontrol : in	std_logic_vector (15 downto 0);
		seriesterminationcontrol   : in std_logic_vector (15 downto 0);
		dll_delayctrlout           : in  std_logic_vector (6 downto 0); 
		sys_dmt    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sto    : out std_logic_vector(data_gear-1 downto 0);
		sys_dmi    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_dqi    : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqso   : buffer std_logic_vector(data_gear-1 downto 0);
		sys_dqst   : in  std_logic_vector(data_gear-1 downto 0);
		sto_synced : buffer std_logic;

		sdram_sti  : in  std_logic := '-';
		sdram_sto  : out std_logic;
		sdram_dm   : inout std_logic;
		sdram_dq   : inout std_logic_vector(byte_size-1 downto 0);
		sdram_dqs  : inout std_logic);

end;

architecture intel of alt_sdrdqphy is
	component altdq_dqs2
		port (
			reset_n_core_clock_in         : in    std_logic                     := '0';             --  memory_interface.export
			extra_write_data_out          : out   std_logic;                                        --                  .export
			read_write_data_io            : inout std_logic_vector(7 downto 0)  := (others => '0'); --                  .export
			strobe_io                     : inout std_logic                     := '0';             --                  .export
			write_strobe_clock_in         : in    std_logic                     := '0';             --                  .export
			write_data_in                 : in    std_logic_vector(31 downto 0) := (others => '0'); --    data_interface.export
			extra_write_data_in           : in    std_logic_vector(3 downto 0)  := (others => '0'); --                  .export
			write_oe_in                   : in    std_logic_vector(15 downto 0) := (others => '0'); --                  .export
			read_data_out                 : out   std_logic_vector(31 downto 0);                    --                  .export
			output_strobe_ena             : in    std_logic_vector(1 downto 0)  := (others => '0'); --                  .export
			parallelterminationcontrol_in : in    std_logic_vector(15 downto 0) := (others => '0'); --              Misc.export
			seriesterminationcontrol_in   : in    std_logic_vector(15 downto 0) := (others => '0'); --                  .export
			dll_delayctrl_in              : in    std_logic_vector(6 downto 0)  := (others => '0'); --                  .export
			capture_strobe_out            : out   std_logic;                                        --     Capture_clock.clk
			fr_clock_in                   : in    std_logic                     := '0';             --          fr_clock.clk
			core_clock_in                 : in    std_logic                     := '0';             --        core_clock.clk
			hr_clock_in                   : in    std_logic                     := '0';             --          hr_clock.clk
			lfifo_rdata_en_full           : in    std_logic_vector(1 downto 0)  := (others => '0'); -- hard_fifo_control.export
			lfifo_rd_latency              : in    std_logic_vector(4 downto 0)  := (others => '0'); --                  .export
			lfifo_reset_n                 : in    std_logic                     := '0';             --                  .export
			vfifo_qvld                    : in    std_logic_vector(1 downto 0)  := (others => '0'); --                  .export
			vfifo_inc_wr_ptr              : in    std_logic_vector(1 downto 0)  := (others => '0'); --                  .export
			vfifo_reset_n                 : in    std_logic                     := '0';             --                  .export
			rfifo_reset_n                 : in    std_logic                     := '0'              --                  .export
		);
	end component;

	signal write_oe_in         : std_logic_vector(15 downto 0);
	signal lfifo_rdata_en_full : std_logic_vector( 1 downto 0);

begin

	lfifo_rdata_en_full <= (others => sys_sti(0));
	write_oe_in         <= (others => sys_dqt(0));

	dqs_i : altdq_dqs2
	port map (
		extra_write_data_out          => sdram_dm,
		read_write_data_io            => sdram_dq,
		strobe_io                     => sdram_dqs,
		write_strobe_clock_in         => clk0x2,
		write_data_in                 => sys_dqi,
		extra_write_data_in           => sys_dmi,
		write_oe_in                   => write_oe_in,
		read_data_out                 => sys_dqo,
		output_strobe_ena             => lfifo_rdata_en_full,
		parallelterminationcontrol_in => parallelterminationcontrol,
		seriesterminationcontrol_in   => seriesterminationcontrol,
		dll_delayctrl_in              => dll_delayctrlout,
		capture_strobe_out            => sys_dqso(0),
		fr_clock_in                   => clk0x2,
		core_clock_in                 => iod_clk,
		hr_clock_in                   => clk0,
		lfifo_rdata_en_full           => lfifo_rdata_en_full,
		lfifo_rd_latency              => (others => '0'),
		lfifo_reset_n                 => '0',
		vfifo_qvld                    => lfifo_rdata_en_full,
		vfifo_inc_wr_ptr              => (others => '0'),
		vfifo_reset_n                 => '0',
		rfifo_reset_n                 => '0');

end;