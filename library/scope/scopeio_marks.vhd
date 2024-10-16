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
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_marks is
	generic (
		layout    : string);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector;
		rgtr_data : in  std_logic_vector;
		video_clk : in  std_logic;
		vt_pos    : in  std_logic_vector;
		vt_mark   : out std_logic_vector;
		hz_pos    : in  std_logic_vector;
		hz_mark   : out std_logic_vector;
		export_vtoffset  : out std_logic_vector;
		export_hzoffset  : out std_logic_vector);

	constant bin_digits      : natural := 3;

	constant inputs          : natural := hdo(layout)**".inputs";
	constant max_delay       : natural := hdo(layout)**".max_delay=16384.";
	constant num_of_segments : natural := hdo(layout)**".num_of_segments";
	constant hz_unit         : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit         : real    := hdo(layout)**".axis.vertical.unit";
	constant vt_width        : natural := hdo(layout)**".axis.vertical.width";
	constant font_size       : natural := hdo(layout)**".axis.fontsize=8.";
	constant grid_width      : natural := hdo(layout)**".grid.width";
	constant grid_height     : natural := hdo(layout)**".grid.height";
	constant grid_unit       : natural := hdo(layout)**".grid.unit=32.";

	constant font_bits       : natural := unsigned_num_bits(font_size-1);
	constant vt_bias         : natural := (grid_height/2)/grid_unit-1;

	constant hzwidth_bits    : natural := unsigned_num_bits(num_of_segments*grid_width-1);
	constant vtheight_bits   : natural := unsigned_num_bits(grid_height-1);

	constant bcd_length      : natural := 4;

	constant chanid_bits     : natural := unsigned_num_bits(inputs-1);
	constant vt_sfcnds       : natural_vector := get_significand1245(vt_unit);
	constant vt_shts         : integer_vector := get_shr1245(vt_unit);
	constant vt_pnts         : integer_vector := get_characteristic1245(vt_unit);
	constant vt_pfxs         : string         := get_prefix1235(vt_unit);

	constant hzoffset_bits   : natural := unsigned_num_bits(max_delay-1);
	constant hz_sfcnds       : natural_vector := get_significand1245(hz_unit);
	constant hz_shts         : integer_vector := get_shr1245(hz_unit);
	constant hz_pnts         : integer_vector := get_characteristic1245(hz_unit);
	constant hz_pfxs         : string         := get_prefix1235(hz_unit);

	constant sfcnd_length    : natural := max(unsigned_num_bits(max(vt_sfcnds)), unsigned_num_bits(2*max(hz_sfcnds)));

end;

architecture def of scopeio_marks is
	signal vtscale_ena  : std_logic;
	signal vt_scalecid  : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_cid       : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid   : std_logic_vector(4-1 downto 0);
	signal tbl_scaleid  : std_logic_vector(vt_scaleid'range);

	signal vtoffset_ena : std_logic;
	signal vt_offsetcid : std_logic_vector(vt_cid'range);
	signal vt_offset    : std_logic_vector((5+8)-1 downto 0);
	signal tbl_offset   : std_logic_vector(vt_offset'range);

	signal hz_ena       : std_logic;
	signal hz_scaleid   : std_logic_vector(4-1 downto 0);
	signal hz_offset    : std_logic_vector(hzoffset_bits-1 downto 0);

	constant offset_length : natural := max(vt_offset'length, hz_offset'length);

	signal btod_bin     : signed(0 to bin_digits*((offset_length+sfcnd_length+bin_digits-1)/bin_digits));

	signal mark_req     : bit;
	signal mark_rdy     : bit;
	signal mark_cnt     : natural range 0 to max(2**vtheight_bits/grid_unit, 2**hzwidth_bits/grid_unit)-1;
	signal mark_from    : signed(0 to btod_bin'length-1);
	signal mark_step    : signed(0 to sfcnd_length);


	signal btod_sht     : signed(4-1 downto 0);
	signal btod_dec     : signed(4-1 downto 0);
	signal btod_left    : std_logic;
	signal btod_req     : std_logic;
	signal btod_rdy     : std_logic;
	signal btod_width   : std_logic_vector(4-1 downto 0);

	signal code_frm     : std_logic;
	signal code_data    : std_logic_vector(bcd_length-1 downto 0);

	constant vtmark_bits : natural := unsigned_num_bits(8-1);
	constant vtaddr_bits : natural := unsigned_num_bits(2**vtheight_bits/(1*grid_unit)-1);
	constant hzmark_bits : natural := unsigned_num_bits(8-1);
	constant hzaddr_bits : natural := unsigned_num_bits(2**hzwidth_bits/(2*grid_unit)-1);

	signal hzmark_we     : std_logic;
	signal vtmark_we     : std_logic;
	signal mark_addr     : std_logic_vector(max(vtaddr_bits, hzaddr_bits)-1 downto 0);
	signal mark_data     : std_logic_vector(0 to 8*bcd_length-1);

	type mark_events is (hz_event, vt_event);
	signal mark_event   : mark_events;

begin

	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_ena    => hz_ena,
		hz_scale  => hz_scaleid,
		hz_offset => hz_offset);

	vtscale_e : entity hdl4fpga.scopeio_rgtrvtscale
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vtscale_ena => vtscale_ena,
		vtchan_id   => vt_scalecid,
		vtscale_id  => vt_scaleid);

	vtoffset_e : entity hdl4fpga.scopeio_rgtrvtoffset
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtoffset_ena,
		vt_chanid => vt_offsetcid,
		vt_offset => vt_offset);

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => vt_offsetcid,
		wr_data => vt_offset,
		rd_addr => vt_scalecid,
		rd_data => tbl_offset);

	vtscales_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vt_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vt_offsetcid,
		rd_data => tbl_scaleid);

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (mark_req xor mark_rdy)='0' then
				if vtscale_ena='1' then
					export_vtoffset <= tbl_offset;
				elsif vtoffset_ena='1' then
					export_vtoffset <= vt_offset;
				end if;
				if hz_ena='1' then
					export_hzoffset <= hz_offset;
				end if;
			end if;
		end if;
	end process;

	process (rgtr_clk, rgtr_dv)
		variable sfcnd   : unsigned(sfcnd_length-1 downto 0);
		variable scaleid : natural range 0 to vt_shts'length-1;
		variable timeid  : natural range 0 to hz_shts'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (mark_req xor mark_rdy)='0' then
				if (vtoffset_ena or vtscale_ena)='1' then
					if vtscale_ena='1' then
						scaleid := to_integer(unsigned(vt_scaleid));
					else
						scaleid := to_integer(unsigned(tbl_scaleid));
					end if;
					sfcnd      := to_unsigned(vt_sfcnds(scaleid mod 4), sfcnd'length);
					btod_sht   <= to_signed(vt_shts(scaleid), btod_sht'length);
					btod_dec   <= to_signed(vt_pnts(scaleid), btod_dec'length);
					btod_left  <= '0';
					btod_width <= std_logic_vector(to_unsigned(vt_width/font_size, btod_width'length));
					mark_event <= vt_event;
					mark_cnt   <= 2**vtheight_bits/(grid_unit)-1;
					if vtoffset_ena='1' then
						mark_from <= -resize(mul(shift_right(signed(vt_offset),  vt_pos'right)-vt_bias, sfcnd), mark_from'length);
					else
						mark_from <= -resize(mul(shift_right(signed(tbl_offset), vt_pos'right)-vt_bias, sfcnd), mark_from'length);
					end if;
					mark_step  <= -signed(resize(sfcnd, mark_step'length));
					mark_req   <= not mark_rdy;
				elsif hz_ena='1' then
					timeid     := to_integer(unsigned(hz_scaleid));
					sfcnd      := to_unsigned(hz_sfcnds(timeid mod 4), sfcnd'length);
					btod_sht   <= to_signed(hz_shts(timeid), btod_sht'length);
					btod_dec   <= to_signed(hz_pnts(timeid), btod_dec'length);
					btod_left  <= '1';
					btod_width <= x"8";
					mark_event <= hz_event;
					mark_cnt   <= 2**hzwidth_bits/(2*grid_unit)-1;
					mark_from  <= resize(shift_left(mul(shift_right(signed(hz_offset), hz_pos'right), sfcnd),1),mark_from'length);
					mark_step  <= signed(resize(2*sfcnd, mark_step'length));
					mark_req   <= not mark_rdy;
				end if;
			end if;
		end if;
	end process;

	process (rgtr_clk)
		type states is (s_init, s_run);
		variable state     : states;
		variable mark_cntr : integer range -1 to 2**mark_addr'length-1;
		variable mark_val  : signed(0 to btod_bin'length-1);
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_init =>
				if (mark_rdy xor mark_req)='1' then
					mark_val  := mark_from;
					mark_cntr := mark_cnt;
					mark_addr <= not std_logic_vector(to_unsigned(mark_cntr, mark_addr'length));
					if mark_val(0)='0' then
						btod_bin <= mark_val;
					else
						btod_bin <= '1' & (-signed(mark_val(1 to mark_val'right)));
					end if;
					btod_req <= not to_stdulogic(to_bit(btod_rdy));
					state := s_run;
				end if;
			when s_run =>
				if (to_bit(btod_req) xor to_bit(btod_rdy))='0' then
					if mark_cntr < 0 then
						mark_rdy <= mark_req;
						state := s_init;
					else
						mark_addr <= not std_logic_vector(to_unsigned(mark_cntr, mark_addr'length));
						if mark_val(0)='0' then
							btod_bin <= mark_val;
						else
							btod_bin <= '1' & (-signed(mark_val(1 to mark_val'right)));
						end if;
						mark_val  := mark_val  + mark_step;
						mark_cntr := mark_cntr - 1;
						btod_req <= not to_stdulogic(to_bit(btod_rdy));
					end if;
				end if;
			end case;
		end if;
	end process;

	btod_e : entity hdl4fpga.btof
	generic map (
		tab      => x"0123456789fbcdef")
	port map (
		clk      => rgtr_clk,
		btof_req => btod_req,
		btof_rdy => btod_rdy,
		left     => btod_left,
		width    => btod_width,
		sht      => std_logic_vector(btod_sht),
		dec      => std_logic_vector(btod_dec),
		exp      => b"000",
		neg      => btod_bin(btod_bin'left),
		bin      => std_logic_vector(btod_bin(1 to btod_bin'right)),
		code_frm => code_frm,
		code     => code_data);

	process (rgtr_clk, btod_req)
		variable shr : unsigned(mark_data'length-1 downto 0);
	begin
		if rising_edge(rgtr_clk) then
			if code_frm='1' then
				shr := shr rol code_data'length;
				shr(code_data'range) := unsigned(code_data);
			end if;
			case mark_event is
			when hz_event =>
				vtmark_we <= '0';
				hzmark_we <= (btod_rdy xor btod_req);
				mark_data <= std_logic_vector(shr);
			when vt_event =>
				vtmark_we <= (btod_rdy xor btod_req);
				hzmark_we <= '0';
				mark_data <= std_logic_vector(shift_left(shr, mark_data'length-bcd_length*vt_width/font_size));
			end case;
		end if;
	end process;

	hzmem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => (0 to 2**hzaddr_bits*hz_mark'length-1 => '1'),
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => hzmark_we,
		wr_addr => mark_addr(hzaddr_bits-1 downto 0),
		wr_data => mark_data,

		rd_clk  => video_clk,
		rd_addr => hz_pos,
		rd_data => hz_mark);

	vt_mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => (0 to 2**vtaddr_bits*vt_mark'length-1 => '1'),
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtmark_we,
		wr_addr => mark_addr(vtaddr_bits-1 downto 0),
		wr_data => mark_data,

		rd_clk  => video_clk,
		rd_addr => vt_pos,
		rd_data => vt_mark);

end;