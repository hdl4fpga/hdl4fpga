--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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
use ieee.math_real.all;

entity ddr is
	generic (
		strobe : string := "EXTERNAL";
		std  : positive range 1 to 3 := 3;

		tCP  : real := 6.0;
		tWR  : real := 15.0;
		tRP  : real := 15.0;
		tRCD : real := 15.0;
		tRFC : real := 72.0;
		tMRD : real := 12.0;
		tREFI : real := 7.0e3;

		cl  : real    := 7.0;
		bl  : natural := 8;
		wr  : natural := 8;
		cwl : natural := 7;

		bank_bits  : natural :=  2;
		addr_bits  : natural := 13;
		data_bytes : natural :=  2;
		byte_bits  : natural :=  8);
	port (
		sys_rst   : in std_logic;
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;

		sys_ini : out std_logic;
		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic;
		sys_a  : in  std_logic_vector(addr_bits-1 downto 0);
		sys_di_rdy : out std_logic;
		sys_do_rdy : out std_logic;
		sys_ba : in  std_logic_vector(bank_bits-1 downto 0);
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic;
		sys_dm : in  std_logic_vector(2*data_bytes-1 downto 0) := (others => '0');
		sys_di : in  std_logic_vector(2*data_bytes*byte_bits-1 downto 0);
		sys_do : out std_logic_vector(2*data_bytes*byte_bits-1 downto 0);
		sys_ref : out std_logic;

		ddr_rst : out std_logic;
		ddr_cke : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we : out std_logic;
		ddr_ba : out std_logic_vector(bank_bits-1 downto 0);
		ddr_a  : out std_logic_vector(addr_bits-1 downto 0);
		ddr_dm : out std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		ddr_dqsz : out std_logic_vector(data_bytes-1 downto 0);
		ddr_dqsi : in std_logic_vector(data_bytes-1 downto 0);
		ddr_dqso : out std_logic_vector(data_bytes-1 downto 0);
		ddr_dqz : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_dqi : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_dqo : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_odt : out std_logic;

		ddr_st_dqs : out std_logic_vector(ddr_dm'range) := (others => '-');
		ddr_st_lp_dqs : in std_logic_vector(ddr_dm'range));

	constant debug_delay : time := 3.3 ns;
	constant t200u : real := 200.0e3;
	constant t500u : real := 500.0e3;
	constant t400n : real := 400.0;
	constant txpr  : real := 120.0;
	constant data_bits : natural := data_bytes*byte_bits;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr is
	constant debug : boolean := false;
	subtype byte is std_logic_vector(0 to byte_bits-1);
	type byte_vector is array (natural range <>) of byte;

	signal ddr_init_rdy : std_logic;
	signal ddr_init_ras : std_logic;
	signal ddr_init_cas : std_logic;
	signal ddr_init_we  : std_logic;
	signal ddr_init_a   : std_logic_vector(addr_bits-1 downto 0);
	signal ddr_init_b   : std_logic_vector(bank_bits-1 downto 0);
	signal ddr_init_cke : std_logic;
	signal ddr_init_cfg : std_logic;
	signal ddr_init_dll : std_logic;

	signal dll_timer_rdy : std_logic;

	signal ddr_mpu_rst : std_logic;
	signal ddr_mpu_req : std_logic;
	signal ddr_mpu_ref : std_logic;
	signal ddr_mpu_ras : std_logic;
	signal ddr_mpu_cas : std_logic;
	signal ddr_mpu_we  : std_logic;
	signal ddr_mpu_rwin : std_logic;
	signal ddr_mpu_drr : std_logic;
	signal ddr_mpu_drf : std_logic;
	signal ddr_mpu_rea : std_logic;
	signal ddr_mpu_dqz : std_logic_vector(ddr_dqsi'range);
	signal ddr_mpu_dqsz : std_logic_vector(ddr_dqsi'range);
	signal ddr_mpu_dqs : std_logic_vector(ddr_dqsi'range);
	signal ddr_win_dqs : std_logic_vector(ddr_dqsi'range);
	signal ddr_pgm_cmd : std_logic_vector(0 to 2);
	signal ddr_mpu_rdy : std_logic;
	signal ddr_wr_fifo_rst : std_logic;
	signal ddr_wr_fifo_req : std_logic;
	signal ddr_wr_fifo_ena_r : std_logic_vector(ddr_dqsi'range);
	signal ddr_wr_fifo_ena_f : std_logic_vector(ddr_dqsi'range);
	signal ddr_wr_dm_r : std_logic_vector(ddr_dm'range);
	signal ddr_wr_dm_f : std_logic_vector(ddr_dm'range);
	signal ddr_wr_dq_r : std_logic_vector(ddr_dqo'range);
	signal ddr_wr_dq_f : std_logic_vector(ddr_dqo'range);

	signal ddr_mpu_dmx_r : std_logic_vector(ddr_dm'range);
	signal ddr_mpu_dmx_f : std_logic_vector(ddr_dm'range);
	signal ddr_stw_sto : std_logic;
	signal ddr_io_dqz : std_logic_vector(ddr_dqz'range);
	signal ddr_io_dqsz : std_logic_vector(ddr_dqsi'range);
	signal ddr_st_hlf : std_logic;
	signal ddr_mpu_wri : std_logic;

	signal rst : std_logic;

	signal clk0 : std_logic;
	signal clk90 : std_logic;

	function casdb (
		constant cl  : real;
		constant std : positive range 1 to 3)
		return std_logic_vector is

		type castab is array (natural range <>) of std_logic_vector(0 to 2);

		constant cas1db : castab(0 to 3-1)  := ("010", "110", "011");
		constant cas2db : castab(3 to 8-1)  := ("011", "100", "101", "110", "111");
		constant cas3db : castab(5 to 12-1) := ("001", "010", "011", "100", "101", "110", "111");

		constant frac : real := cl-floor(cl);
	begin

		case std is
		when 1 =>
			assert 2.0 <= cl and cl <= 3.0
			report "Invalid DDR1 cas latency"
			severity FAILURE;

			if cl = 2.0 then
				return cas1db(0);
			elsif cl = 2.5 then
				return cas1db(1);
			else
				return cas1db(2);
			end if;

		when 2 =>
			assert 3.0 <= cl and cl <= 7.0
			report "Invalid DDR2 cas latency"
			severity FAILURE;
			
			return cas2db(natural(floor(cl)));

		when 3 =>
			assert 5.0 <= cl and cl <= 11.0
			report "Invalid DDR3 cas latency"
			severity FAILURE;
			
			return cas3db(natural(floor(cl)));
		end case;
	end;

	function bldb (
		constant bl  : natural;
		constant std : natural)
		return std_logic_vector is
		type bltab is array (natural range <>) of std_logic_vector(0 to 2);

		constant bl1db : bltab(0 to 2) := ("001", "010", "011");
		constant bl2db : bltab(2 to 3) := ("010", "011");
		constant bl3db : bltab(0 to 2) := ("000", "001", "010");
	begin
		case std is
		when 1 =>
			for i in bl1db'range loop
				if bl=2**(i+1) then
					return bl1db(i);
				end if;
			end loop;

		when 2 =>
			for i in bl2db'range loop
				if bl=2**i then
					return bl2db(i);
				end if;
			end loop;

		when 3 =>
			for i in bl3db'range loop
				if bl=2**(i+1) then
					return bl3db(i);
				end if;
			end loop;

		when others =>
			report "Invalid DDR version"
			severity FAILURE;

			return (0 to 2 => '-');
		end case;

		report "Invalid Burst Length"
		severity FAILURE;
		return (0 to 2 => '-');
	end;

	function wrdb (
		constant wr  : natural;
		constant std : positive range 2 to 3)
		return std_logic_vector is
		type wrtab is array (natural range <>) of std_logic_vector(0 to 2);

		constant wr2db  : wrtab(0 to 7-1) := ("001", "010", "011", "100", "101", "110", "111");
		constant wr2idx : hdl4fpga.std.natural_vector(wr2db'range) := (2, 3, 4, 5, 6, 7, 8);

		constant wr3db  : wrtab(0 to 6-1) := ("001", "010", "011", "100", "101", "110");
		constant wr3idx : hdl4fpga.std.natural_vector(wr3db'range) := (5, 6, 7, 8, 10, 12);

	begin
		case std is
		when 2 =>
			for i in wr2db'range loop
				if wr = wr2idx(i) then
					return wr2db(i);
				end if;
			end loop;

			report "Invalid DDR2 Write Recovery"
			severity FAILURE;

		when 3 =>
			for i in wr3db'range loop
				if wr = wr3idx(i) then
					return wr3db(i);
				end if;
			end loop;

			report "Invalid DDR3 Write Recovery"
			severity FAILURE;
		end case;

		return (0 to 2 => '-');
	end;

	function cwldb (
		constant cwl : natural;
		constant std : positive range 1 to 3)
		return std_logic_vector is
		type cwltab is array (natural range <>) of std_logic_vector(0 to 2);

		constant cwl3db  : cwltab(0 to 4-1) := ("000", "001", "010", "011");
		constant cwl3idx : hdl4fpga.std.natural_vector(cwl3db'range) := (5, 6, 7, 8);

	begin
		case std is
		when 3 =>
			for i in cwl3db'range loop
				if cwl = cwl3idx(i) then
					return cwl3db(i);
				end if;
			end loop;

			report "Invalid CAS Write Latency"
			severity FAILURE;
			return (0 to 2 => '-');

		when others =>
			report "Invalid DDR version"
			severity WARNING;

			return (0 to 2 => '-');
		end case;
	end;
	constant cas : std_logic_vector(0 to 2) := casdb(cl, std); 
begin

	clk0  <= sys_clk0;
	clk90 <= sys_clk90;

	process (clk0, sys_rst)
	begin
		if sys_rst='1' then
			rst <= '1';
		elsif rising_edge(clk0) then
			rst <= sys_rst;
		end if;
	end process;

	ddr_cs <= '0';
	ddr_io_ba_e : entity hdl4fpga.ddr_io_ba
	generic map (
		bank_bits => bank_bits,
		addr_bits => addr_bits)
	port map (
		sys_clk => clk0,
		sys_rst => rst,
		sys_ini => dll_timer_rdy,
		sys_cke => ddr_init_cke,
		sys_ras => ddr_mpu_ras,
		sys_cas => ddr_mpu_cas,
		sys_we  => ddr_mpu_we,
		sys_odt => dll_timer_rdy,
		sys_a   => sys_a,
		sys_b   => sys_ba,
		sys_ini_ras => ddr_init_ras,
		sys_ini_cas => ddr_init_cas,
		sys_ini_we  => ddr_init_we,
		sys_ini_a   => ddr_init_a,
		sys_ini_b   => ddr_init_b,

		ddr_odt => ddr_odt,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_cke => ddr_cke,
		ddr_we  => ddr_we,
		ddr_a   => ddr_a,
		ddr_b   => ddr_ba);

	ddr_timer_e : entity hdl4fpga.ddr_timer
	generic map (
		c200u => natural(t200u/tCP),
--		c200u => natural(2000.0/tCP),
		cDLL  => hdl4fpga.std.selecton(std=3, 512, 220),
		c500u => natural(hdl4fpga.std.selecton(std=2,t400n,t500u)/tCP),
--		c500u => natural(3000.0),
		cxpr  => natural(txpr/tCP),
		cREF  => natural(floor(tREFI/tCP)),
		std   => std)
	port map (
		ddr_timer_clk => clk0,
		ddr_timer_rst => rst,
		ddr_init_rst  => ddr_rst,
		ddr_init_cke  => ddr_init_cke,
		ddr_init_cfg  => ddr_init_cfg,
		dll_timer_req => ddr_init_dll,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => ddr_init_rdy,
		ref_timer_rdy => ddr_mpu_ref);

	ddr1_init_g : if std=1 generate
		ddr_init_du : entity hdl4fpga.ddr_init(ddr1)
		generic map (
			a    => addr_bits,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => natural(ceil(tMRD/tCp)),
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
			ddr_init_cl  => casdb (cl, std),
			ddr_init_bl  => bldb  (bl, std),

			ddr_init_clk => clk0,
			ddr_init_req => ddr_init_cfg,
			ddr_init_rdy => ddr_init_rdy,
			ddr_init_dll => ddr_init_dll,
			ddr_init_ras => ddr_init_ras,
			ddr_init_cas => ddr_init_cas,
			ddr_init_we  => ddr_init_we,
			ddr_init_a   => ddr_init_a,
			ddr_init_b   => ddr_init_b);
	end generate;

	ddr2_init_g : if std=2 generate
		ddr_init_du : entity hdl4fpga.ddr_init(ddr2)
		generic map (
			lat_length => 9,

			a => addr_bits,

			tRP  => natural(ceil(tRP/tCP)),
			tMRD => 2,
			tMOD => natural(ceil(12.0/tCP))+2,
			tRFC => natural(ceil(tRFC/tCP)))
		port map (
			ddr_init_cl  => casdb (cl, std),
			ddr_init_bl  => bldb  (bl, std),
			ddr_init_wr  => wrdb  (wr, std),

			ddr_init_clk => clk0,
			ddr_init_req => ddr_init_cfg,
			ddr_init_rdy => ddr_init_rdy,
			ddr_init_dll => ddr_init_dll,
			ddr_init_ras => ddr_init_ras,
			ddr_init_cas => ddr_init_cas,
			ddr_init_we  => ddr_init_we,
			ddr_init_a   => ddr_init_a,
			ddr_init_b   => ddr_init_b);
	end generate;

	process (clk0)
		variable q : std_logic;
	begin
		if rising_edge(clk0) then
--			ddr_mpu_rst <= not (ddr_init_rdy and dll_timer_rdy);
			ddr_mpu_rst <= q;
			q := not (ddr_init_rdy and dll_timer_rdy);
			sys_ini     <= ddr_init_rdy and dll_timer_rdy;
		end if;
	end process;

	ddr_mpu_req <= sys_cmd_req;
	sys_di_rdy  <= ddr_wr_fifo_req;
	ddr_mpu_e : entity hdl4fpga.ddr_mpu
	generic map (
		std  => std,
		tRCD => natural(ceil(tRCD/tCP)),
		tWR  => natural(ceil(tWR/tCP)),
		tRP  => natural(ceil(tRP/tCP)),
		tRFC => natural(ceil(tRFC/tCP)),
		ddr_mpu_bl => bldb(bl,std),
		ddr_mpu_cwl => cwldb(cwl, std),
		ddr_mpu_cl => casdb(cl, std))
	port map (
		ddr_mpu_rst => ddr_mpu_rst,
		ddr_mpu_clk => clk0,
		ddr_mpu_clk90 => clk90,
		ddr_mpu_cmd => ddr_pgm_cmd,
		ddr_mpu_rdy => ddr_mpu_rdy,
		ddr_mpu_act => sys_act,
		ddr_mpu_cas => ddr_mpu_cas,
		ddr_mpu_ras => ddr_mpu_ras,
		ddr_mpu_we  => ddr_mpu_we,

		ddr_mpu_rea => ddr_mpu_rea,
		ddr_mpu_wbl => ddr_wr_fifo_req,
		ddr_mpu_wri => ddr_mpu_wri,

		ddr_mpu_rwin => ddr_mpu_rwin,
		ddr_mpu_drr => ddr_mpu_drr,
		ddr_mpu_drf => ddr_mpu_drf,

		ddr_mpu_dwr => ddr_wr_fifo_ena_r,  
		ddr_mpu_dwf => ddr_wr_fifo_ena_f,  
		ddr_mpu_dqs => ddr_mpu_dqs,
		ddr_mpu_dqsz => ddr_mpu_dqsz,
		ddr_mpu_dqz => ddr_mpu_dqz);

	ddr_pgm_e : entity hdl4fpga.ddr_pgm
	port map (
		ddr_pgm_rst => ddr_mpu_rst,
		ddr_pgm_clk => clk0,
		sys_pgm_ref => sys_ref,
		ddr_pgm_cmd => ddr_pgm_cmd,
		ddr_pgm_cas => sys_cas,
		ddr_pgm_pre => sys_pre,
		ddr_pgm_ref => ddr_mpu_ref,
		ddr_pgm_start => ddr_mpu_req,
		ddr_pgm_rdy => sys_cmd_rdy,
		ddr_pgm_req => ddr_mpu_rdy,
		ddr_pgm_rw  => sys_rw);

	ddr_win_dqs <= ddr_st_lp_dqs;
	ddr_rd_fifo_e : entity hdl4fpga.ddr_rd_fifo
	generic map (
		data_delay => 2, --std,
		data_bytes => data_bytes,
		byte_bits  => byte_bits)
	port map (
		sys_clk => clk0,
		sys_do  => sys_do,
		sys_rdy => sys_do_rdy,
		sys_rea => ddr_mpu_rea,
		ddr_win_dq  => ddr_mpu_rwin,
		ddr_win_dqs => ddr_win_dqs,
		ddr_dqsi => ddr_dqsi,
		ddr_dqi => ddr_dqi);
		
	ddr_wr_fifo_rst <= not ddr_mpu_wri;
	ddr_wr_fifo_e : entity hdl4fpga.ddr_wr_fifo
	generic map (
		std => std,
		data_bytes => data_bytes,
		byte_bits  => byte_bits)
	port map (
		sys_clk => clk0,
		sys_di  => sys_di,
		sys_req => ddr_wr_fifo_req,
		sys_rst => ddr_wr_fifo_rst,
		sys_dm  => sys_dm,

		ddr_clk  => clk90,
		ddr_dm_r => ddr_wr_dm_r,
		ddr_dm_f => ddr_wr_dm_f,
		ddr_ena_r => ddr_wr_fifo_ena_r, 
		ddr_ena_f => ddr_wr_fifo_ena_f, 
		ddr_dq_r => ddr_wr_dq_r,
		ddr_dq_f => ddr_wr_dq_f);
		
	ddr_io_dq_e : entity hdl4fpga.ddr_io_dq
	generic map (
		data_bytes => data_bytes,
		byte_bits  => byte_bits)
	port map (
		ddr_io_clk => clk90,
		ddr_io_dq_r => ddr_wr_dq_r,
		ddr_io_dq_f => ddr_wr_dq_f,
		ddr_mpu_dqz => ddr_mpu_dqz,
		ddr_io_dqz  => ddr_io_dqz,
		ddr_io_dqo  => ddr_dqo);
	ddr_dqz <= ddr_io_dqz;

	ddr_io_dqs_e : entity hdl4fpga.ddr_io_dqs
	generic map (
		std => std,
		data_bytes => data_bytes)
	port map (
		ddr_io_clk => clk0,
		ddr_io_ena => ddr_mpu_dqs,
		ddr_mpu_dqsz => ddr_mpu_dqsz,
		ddr_io_dqsz => ddr_io_dqsz,
		ddr_io_dqso => ddr_dqso);
	ddr_dqsz <= ddr_io_dqsz;
	
	ddr_mpu_dmx_r <= ddr_wr_fifo_ena_r;
	ddr_mpu_dmx_f <= ddr_wr_fifo_ena_f;
	ddr_io_dm_e : entity hdl4fpga.ddr_io_dm
	generic map (
		strobe => strobe,
		data_bytes => data_bytes)
	port map (
		ddr_io_clk => clk90,
		ddr_mpu_st_r => ddr_mpu_drr,
		ddr_mpu_st_f => ddr_mpu_drf,
		ddr_mpu_dm_r => ddr_wr_dm_r,
		ddr_mpu_dm_f => ddr_wr_dm_f,
		ddr_mpu_dmx_r => ddr_mpu_dmx_r,
		ddr_mpu_dmx_f => ddr_mpu_dmx_f,
		ddr_io_dmo => ddr_dm);

	ddr_st_g : if strobe="EXTERNAL" generate
		signal st_dqs : std_logic;
	begin
		ddr_st_hlf <= setif(std=1 and cas(0)='1');
		ddr_st_e : entity hdl4fpga.ddr_stw
		port map (
			ddr_st_hlf => ddr_st_hlf,
			ddr_st_clk => sys_clk0,
			ddr_st_drr => ddr_mpu_drr,
			ddr_st_drf => ddr_mpu_drf,
			ddr_st_dqs => st_dqs);
		ddr_st_dqs <= (others => st_dqs);
	end generate;
end;
