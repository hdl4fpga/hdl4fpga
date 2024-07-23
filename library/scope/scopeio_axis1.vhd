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

entity scopeio_axis is
	generic (
		latency       : natural;
		layout        : string);
	port (
		clk           : in  std_logic;

		video_clk     : in  std_logic;
		hz_dv         : in  std_logic;
		hz_scale      : in  std_logic_vector;
		hz_offset     : in  std_logic_vector;
		hz_segment    : in  std_logic_vector;
		video_hcntr   : in  std_logic_vector;
		video_hzon    : in  std_logic;
		video_hzdot   : out std_logic;

		vt_dv         : in  std_logic;
		vt_scale      : in  std_logic_vector;
		vt_offset     : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		video_vton    : in  std_logic;
		video_vtdot   : out std_logic);

	constant num_of_segments : natural := hdo(layout)**".num_of_segments";
	constant hz_unit         : real    := 2.0*real'(hdo(layout)**".axis.horizontal.unit");
	constant vt_unit         : real    := hdo(layout)**".axis.vertical.unit";
	constant vt_width        : natural := hdo(layout)**".axis.vertical.width";
	constant axis_fontsize   : natural := hdo(layout)**".axis.fontsize";
	constant grid_width      : natural := hdo(layout)**".grid.width";
	constant grid_height     : natural := hdo(layout)**".grid.height";
	constant grid_unit       : natural := hdo(layout)**".grid.unit";

end;

architecture def of scopeio_axis is

	constant division_size : natural := grid_unit;
	constant font_size     : natural := axis_fontsize;

	constant division_bits : natural := unsigned_num_bits(division_size-1);
	constant font_bits     : natural := unsigned_num_bits(font_size-1);

	constant hz_width      : natural := grid_width;
	constant hztick_bits   : natural := 3;
	constant hzstep_bits   : natural := hztick_bits;

	constant vt_height     : natural := grid_height;
	constant vttick_bits   : natural := 3;
	constant vtstep_bits   : natural := division_bits;

	constant bcd_length    : natural := 4;

	signal rgtr_dv   : std_logic;
	signal rgtr_id   : std_logic_vector(8-1 downto 0);
	signal rgtr_data : std_logic_vector(0 to 4*8-1);
begin

	marks_e : entity hdl4fpga.scopeio_marks
	generic map (
		layout => layout)
	port map (
		rgtr_clk  => clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data);
	video_b : block

		signal char_code  : std_logic_vector(4-1 downto 0);
		signal char_row   : std_logic_vector(font_bits-1 downto 0);
		signal char_col   : std_logic_vector(font_bits-1 downto 0);
		signal char_dot   : std_logic;

		signal tick_req   : std_logic;
		signal tick_rdy   : std_logic;
		signal btof_req   : std_logic;
		signal btof_rdy   : std_logic;
		signal code_frm   : std_logic;
		signal code       : std_logic_vector(0 to bcd_length-1);

		signal hz_sel     : std_logic;
		signal hz_bcd     : std_logic_vector(char_code'range);
		signal hz_charrow : std_logic_vector(font_bits-1 downto 0);
		signal hz_charcol : std_logic_vector(font_bits-1 downto 0);
		signal hz_don     : std_logic;
		signal hz_on      : std_logic;

		signal vt_sel     : std_logic;
		signal vt_bcd     : std_logic_vector(char_code'range);
		signal vt_codefrm : std_logic;
		signal vt_charrow : std_logic_vector(font_bits-1 downto 0);
		signal vt_charcol : std_logic_vector(font_bits-1 downto 0);
		signal vt_on      : std_logic;
		signal vt_don     : std_logic;

		signal hz_taddr   : unsigned(unsigned_num_bits(num_of_segments*(hz_width-1))-1 downto hzstep_bits);
		signal vt_taddr   : unsigned(unsigned_num_bits((vt_height-1))+vttick_bits-1 downto division_bits);

		signal left       : std_logic;

		constant vt_signfcnds : natural_vector := get_significand1245(vt_unit);
		constant vtsignfcnd_length : natural   := unsigned_num_bits(max(vt_signfcnds));
		constant vt_shrs  : integer_vector     := get_shr1245(vt_unit);
		constant vt_pnts  : integer_vector     := get_characteristic1245(vt_unit);

		constant hz_signfcnds : natural_vector := get_significand1245(hz_unit);
		constant hzsignfcnd_length : natural   := unsigned_num_bits(max(hz_signfcnds));
		constant hz_shrs  : integer_vector     := get_shr1245(hz_unit);
		constant hz_pnts  : integer_vector     := get_characteristic1245(hz_unit);

		signal shr        : std_logic_vector(4-1 downto 0);
		signal pnt        : std_logic_vector(4-1 downto 0);
		signal wth        : std_logic_vector(4-1 downto 0);

	constant bin_digits      : natural := 3;
	constant signfcnd_length : natural := max(vtsignfcnd_length, hzsignfcnd_length);
	constant offset_length   : natural := max(vt_offset'length, hz_offset'length);
	signal bin               : signed(0 to bin_digits*((offset_length+signfcnd_length+bin_digits-1)/bin_digits));
	begin

		process (code_frm, clk)
			variable signfcnd : unsigned(max(vtsignfcnd_length, hzsignfcnd_length)-1 downto 0);
			variable start    : signed(0 to signfcnd'length);
			variable tick     : signed(0 to bin'length-1); -- to 2**bin'length-1;
			variable tick_no  : integer range -1 to max(2**vt_taddr'length/2**vttick_bits-1, 2**hz_taddr'length/2**hzstep_bits-1);
			variable addr     : natural range  0 to 2**max(vt_taddr'length,hz_taddr'length)-1;
			variable xxx : boolean := true;
			constant yyy : signed(vt_offset'range) := (others => '1');
		begin
			if rising_edge(clk) then
				if (to_bit(tick_req) xor to_bit(tick_rdy))='1' then
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
				elsif vt_dv='1' then
					hz_sel   <= '0';
					vt_sel   <= '1';
					addr     := 0;
					signfcnd := to_unsigned(vt_signfcnds(to_integer(unsigned(vt_scale(2-1 downto 0)))), signfcnd'length);
					tick     := -resize(mul(shift_right(signed(vt_offset), division_bits)-(vt_height/2/division_size-1), signfcnd), tick'length);
					tick_no  := 2**vt_taddr'length/2**vttick_bits-1;
					tick_req <= not to_stdulogic(to_bit(tick_rdy));
					left     <= '0';
					start    := -signed(resize(signfcnd, start'length));
					shr      <= std_logic_vector(to_signed(vt_shrs(to_integer(unsigned(vt_scale))), shr'length));
					pnt      <= std_logic_vector(to_signed(vt_pnts(to_integer(unsigned(vt_scale))), pnt'length));
					wth      <= std_logic_vector(to_unsigned(vt_width/font_size, wth'length));
				elsif hz_dv='1' then
					hz_sel   <= '1';
					vt_sel   <= '0';
					addr     := 0;
					signfcnd := to_unsigned(hz_signfcnds(to_integer(unsigned(hz_scale(2-1 downto 0)))), signfcnd'length);
					tick     := resize(mul(shift_right(signed(hz_offset), hztick_bits+font_bits), signfcnd), tick'length);
					tick_no  := 2**hz_taddr'length/2**hzstep_bits-1;
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
			clk      => clk,
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
				wr_clk  => clk,
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
				wr_clk  => clk,
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
