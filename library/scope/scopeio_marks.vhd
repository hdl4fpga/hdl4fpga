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
use hdl4fpga.cgafonts.all;

entity scopeio_marks is
	generic (
		latency       : natural;
		layout        : string);
	port (

		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;


	constant num_of_segments : natural := hdo(layout)**".num_of_segments";
	constant hz_unit         : real    := 2.0*real'(hdo(layout)**".axis.horizontal.unit");
	constant vt_unit         : real    := hdo(layout)**".axis.vertical.unit";
	constant vt_width        : natural := hdo(layout)**".axis.vertical.width";
	constant axis_fontsize   : natural := hdo(layout)**".axis.fontsize";
	constant grid_width      : natural := hdo(layout)**".grid.width";
	constant grid_height     : natural := hdo(layout)**".grid.height";
	constant grid_unit       : natural := hdo(layout)**".grid.unit";

	constant vt_sfcnds     : natural_vector := get_significand1245(vt_unit);
	constant vt_shts       : integer_vector := get_shr1245(vt_unit);
	constant vt_pnts       : integer_vector := get_characteristic1245(vt_unit);
	constant vt_pfxs       : string         := get_prefix1235(vt_unit);

	constant hz_sfcnds     : natural_vector := get_significand1245(hz_unit);
	constant hz_shts       : integer_vector := get_shr1245(hz_unit);
	constant hz_pnts       : integer_vector := get_characteristic1245(hz_unit);
	constant hz_pfxs       : string         := get_prefix1235(hz_unit);

end;

architecture def of scopeio_marks is
	subtype iterators is integer range -1 to max(2**vt_taddr'length/2**vttick_bits-1, 2**hz_taddr'length/2**hzstep_bits-1);
	signal vtscale_ena    : std_logic;
	signal vtl_scalecid   : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_cid         : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid     : std_logic_vector(4-1 downto 0);
	signal tbl_scaleid    : std_logic_vector(vt_scaleid'range);

	signal vtoffset_ena   : std_logic;
	signal vtl_offsetcid  : std_logic_vector(vt_cid'range);
	signal vtl_offset     : std_logic_vector((5+8)-1 downto 0);
	signal tbl_offset     : std_logic_vector(vtl_offset'range);
	signal vt_offset      : signed(vtl_offset'range);
	signal tick_no  : integer range -1 to max(2**vt_taddr'length/2**vttick_bits-1, 2**hz_taddr'length/2**hzstep_bits-1);
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
		wr_addr => vtl_offsetcid,
		wr_data => vtl_offset,
		rd_addr => vtl_scalecid,
		rd_data => tbl_offset);

	vtgains_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vtl_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vtl_offsetcid,
		rd_data => tbl_scaleid);

	process (rgtr_clk)
		variable signfcnd : unsigned(max(vtsignfcnd_length, hzsignfcnd_length)-1 downto 0);
		variable start    : signed(0 to signfcnd'length);
		variable tick     : signed(0 to bin'length-1); -- to 2**bin'length-1;
		variable tick_no  : integer range -1 to max(2**vt_taddr'length/2**vttick_bits-1, 2**hz_taddr'length/2**hzstep_bits-1);
		variable addr     : natural range  0 to 2**max(vt_taddr'length,hz_taddr'length)-1;
	begin
		if rising_edge(rgtr_clk) then
			if (tick_req xor tick_rdy)='0' then
				if (vtoffset_ena or vtscale_ena)='1' then
					tick_total <= 2**vt_taddr'length/2**vttick_bits-1;
					tick_req  <= not tick_rdy;
				elsif hz_ena='1' then
					tick_total <= 2**hz_taddr'length/2**hzstep_bits-1;
					tick_req  <= not tick_rdy;
				end if;
			end if;
		end if;
	end process;

	process (rgtr_clk)
		variable signfcnd : unsigned(max(vtsignfcnd_length, hzsignfcnd_length)-1 downto 0);
		variable start    : signed(0 to signfcnd'length);
		variable tick     : signed(0 to bin'length-1); -- to 2**bin'length-1;
		variable addr     : natural range  0 to 2**max(vt_taddr'length,hz_taddr'length)-1;
		variable xxx : boolean := true;
		constant yyy : signed(vt_offset'range) := (others => '1');
		type states is (s_init, s_run);
		variable state : states;
		variable i : iterator;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_init =>
				if (tick_rdy xor tick_req)='1' then
					state := s_run;
				end if;
			when s_run =>
				if i < 0 then
					tick_rdy <= tick_req;
					state := s_init;
				else
					mark := mark + to_integer(start);
					i := i - 1;
				end if;
			end case;
				if (to_bit(btof_req) xor to_bit(btof_rdy))='0' then
					if tick_no >= 0 then
						if tick < 0 then
							bin <= '1' & (-tick(1 to bin'length-1));
						else
							bin <= '0' &  tick(1 to bin'length-1);
						end if;
						tick     := tick    + to_integer(start);
						tick_no  := tick_no - 1;
						btof_req <= not to_stdulogic(to_bit(btof_rdy));
					else
						tick_rdy <= to_stdulogic(to_bit(tick_req));
					end if;
				end if;
				if code_frm='1' then
					addr := addr + 1;
				end if;
				xxx := false;
			elsif vt_ena='1' then
				hz_sel   <= '0';
				vt_sel   <= '1';
				addr     := 0;
				signfcnd := to_unsigned(vt_signfcnds(to_integer(unsigned(vt_scale(2-1 downto 0)))), signfcnd'length);
				tick     := -resize(mul(shift_right(signed(vt_offset), division_bits)-(vt_height/2/division_size-1), signfcnd), tick'length);
				tick_req <= not to_stdulogic(to_bit(tick_rdy));
				left     <= '0';
				start    := -signed(resize(signfcnd, start'length));
				shr      <= std_logic_vector(to_signed(vt_shrs(to_integer(unsigned(vt_scale))), shr'length));
				pnt      <= std_logic_vector(to_signed(vt_pnts(to_integer(unsigned(vt_scale))), pnt'length));
				wth      <= std_logic_vector(to_unsigned(vt_width/font_size, wth'length));
			elsif hz_ena='1' then
				hz_sel   <= '1';
				vt_sel   <= '0';
				addr     := 0;
				signfcnd := to_unsigned(hz_signfcnds(to_integer(unsigned(hz_scale(2-1 downto 0)))), signfcnd'length);
				tick     := resize(mul(shift_right(signed(hz_offset), hztick_bits+font_bits), signfcnd), tick'length);
				tick_req <= not to_stdulogic(to_bit(tick_rdy));
				left     <= '1';
				start    := signed(resize(signfcnd, start'length));
				shr      <= std_logic_vector(to_signed(hz_shrs(to_integer(unsigned(hz_scale))), shr'length));
				pnt      <= std_logic_vector(to_signed(hz_pnts(to_integer(unsigned(hz_scale))), pnt'length));
				wth      <= x"8";
			else
				hz_sel   <= '0';
				vt_sel   <= '0';
				addr     := 0;
				tick_no  := -1;
				left     <= '-';
				shr      <= (others => '-');
				pnt      <= (others => '-');
			end if;
			hz_taddr <= to_unsigned(addr, hz_taddr'length);
			vt_taddr <= to_unsigned(addr, vt_taddr'length);
		end if;
	end process;

		btof_e : entity hdl4fpga.btof
		generic map (
			tab      => x"0123456789fbcdef")
		port map (
			clk      => rgtr_clk,
			btof_req => btof_req,
			btof_rdy => btof_rdy,
			left     => left,
			width    => wth,
			sht      => shr,
			dec      => pnt,
			exp      => b"000",
			neg      => bin(bin'left),
			bin      => std_logic_vector(bin(bin'left+1 to bin'right)),
			code_frm => code_frm,
			code     => code);

		hz_b : block

			signal x      : unsigned(hz_taddr'left downto 0);
			signal tick   : std_logic_vector(bcd_length-1 downto 0);

			signal disp   : unsigned(x'range);
			signal we_ena : std_logic;
			signal vaddr  : std_logic_vector(x'range);
			signal vdata  : std_logic_vector(tick'range);

		begin 

			we_ena <= code_frm when hz_sel='1' else '0';
			mem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**hz_taddr'length*bcd_length-1 => '1'))
			port map (
				wr_clk  => rgtr_clk,
				wr_ena  => we_ena,
				wr_addr => std_logic_vector(hz_taddr),
				wr_data => code,

				rd_addr => vaddr(hz_taddr'range),
				rd_data => vdata);

			process (video_clk)
			begin
				if rising_edge(video_clk) then
					disp <= resize(unsigned(hz_segment) + unsigned(hz_offset(hztick_bits+font_bits-1 downto 0)), x'length);
				end if;
			end process;
			x <= resize(unsigned(video_hcntr) + disp, x'length);

			process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(x);
					tick  <= vdata;
				end if;
			end process;

   			charrow_e : entity hdl4fpga.latency
   			generic map (
   				n => hz_charrow'length,
   				d => (hz_charrow'range => 2))
   			port map (
   				clk => video_clk,
   				di  => video_vcntr(hz_charrow'range),
   				do  => hz_charrow);

   			charcol_e : entity hdl4fpga.latency
   			generic map (
   				n => hz_charcol'length,
   				d => (hz_charcol'range => 2))
   			port map (
   				clk => video_clk,
   				di  => std_logic_vector(x(hz_charcol'range)),
   				do  => hz_charcol);

   			charon_e : entity hdl4fpga.latency
   			generic map (
   				n => 1,
   				d => (0 to 0 => 2))
   			port map (
   				clk   => video_clk,
   				di(0) => video_hzon,
   				do(0) => hz_on);

			byte_g : if hztick_bits > font_bits generate
				signal vcol : std_logic_vector(hztick_bits-1 downto font_bits);
			begin
    			col_e : entity hdl4fpga.latency
    			generic map (
    				n => vcol'length,
    				d => (vcol'range => 2))
    			port map (
    				clk => video_clk,
    				di  => std_logic_vector(x(vcol'range)),
    				do  => vcol);

    			hz_bcd <= multiplex(tick, vcol, char_code'length);
			end generate;

			bcd_g :if hztick_bits <= font_bits generate
    			hz_bcd <= tick;
			end generate;

		end block;

		vt_b : block

			signal y      : unsigned(unsigned_num_bits((vt_height-1))-1 downto 0);
			signal tick   : std_logic_vector(bcd_length-1 downto 0);

			signal we_ena : std_logic;
			signal vaddr  : std_logic_vector(vt_taddr'range);
			signal vdata  : std_logic_vector(tick'range);
			signal vton   : std_logic;

		begin 

			we_ena <= code_frm when vt_sel='1' else '0';
			vt_mem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**vt_taddr'length*bcd_length-1 => '1'))
			port map (
				wr_clk  => rgtr_clk,
				wr_ena  => we_ena,
				wr_addr => std_logic_vector(vt_taddr),
				wr_data => code,

				rd_addr => vaddr,
				rd_data => vdata);

			y <= resize(unsigned(video_vcntr) + unsigned(vt_offset(division_bits-1 downto 0)), y'length);
			process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(mul(y(y'left downto division_bits),(vt_width/font_size))+ unsigned(video_hcntr(vttick_bits+font_bits-1 downto font_bits)));
					tick  <= vdata;
				end if;
			end process;
			vton <= video_vton and setif(y(division_bits-1 downto font_bits)=(division_bits-1 downto font_bits => '1'));

			charcol_e : entity hdl4fpga.latency
			generic map (
				n => font_bits,
				d => (0 to font_bits-1 => 2))
			port map (
				clk   => video_clk,
				di => video_hcntr(font_bits-1 downto 0),
				do => vt_charcol);

			charrow_e : entity hdl4fpga.latency
			generic map (
				n => font_bits,
				d => (0 to font_bits-1 => 2))
			port map (
				clk   => video_clk,
				di => std_logic_vector(y(font_bits-1 downto 0)),
				do => vt_charrow);

			charon_e : entity hdl4fpga.latency
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => vton,
				do(0) => vt_on);

			vt_bcd <= tick;

		end block;

		char_code <= multiplex(vt_bcd     & hz_bcd,     not vt_on);
		char_row  <= multiplex(vt_charrow & hz_charrow, not vt_on); 
		char_col  <= multiplex(vt_charcol & hz_charcol, not vt_on); 

		cgarom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => setif(font_size=8, psf1bcd8x8, psf1bcd4x4),
			font_height => 2**font_bits,
			font_width  => 2**font_bits)
		port map (
			clk       => video_clk,
			char_col  => char_col,
			char_row  => char_row,
			char_code => char_code,
			char_dot  => char_dot);

		cgalat_e : entity hdl4fpga.latency
		generic map (
			n => 2,
			d => (0 to 1 => 2))
		port map (
			clk   => video_clk,
			di(0) => hz_on,
			di(1) => vt_on,
			do(0) => hz_don,
			do(1) => vt_don);

		latency_b : block
			signal dots : std_logic_vector(0 to 2-1);
		begin
			dots(0) <= char_dot and hz_don;
			dots(1) <= char_dot and vt_don;

			lat_e : entity hdl4fpga.latency
			generic map (
				n => dots'length,
				d => (dots'range => latency-4))
			port map (
				clk   => video_clk,
				di    => dots,
				do(0) => video_hzdot,
				do(1) => video_vtdot);
		end block;
	end block;

end;
