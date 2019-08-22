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
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	generic (
		latency       : natural;
		hz_unit       : std_logic_vector;
		vt_unit       : std_logic_vector;
		layout        : display_layout);
	port (
		clk           : in  std_logic;

		axis_dv       : in  std_logic;
		axis_sel      : in  std_logic;
		axis_scale    : in  std_logic_vector;
		axis_base     : in  std_logic_vector;

		btof_binfrm   : buffer std_logic;
		btof_binirdy  : out std_logic;
		btof_bintrdy  : in  std_logic;
		btof_bindi    : out std_logic_vector;
		btof_binneg   : out std_logic;
		btof_binexp   : out std_logic;
		btof_bcdunit  : out std_logic_vector;
		btof_bcdwidth : out std_logic_vector;
		btof_bcdprec  : out std_logic_vector;
		btof_bcdsign  : out std_logic;
		btof_bcdalign : out std_logic;
		btof_bcdirdy  : buffer std_logic := '1';
		btof_bcdtrdy  : in  std_logic;
		btof_bcdend   : in  std_logic;
		btof_bcddo    : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_hcntr   : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;

		hz_offset     : in  std_logic_vector;
		video_hzon    : in  std_logic;
		video_hzdot   : out std_logic;

		vt_offset     : in  std_logic_vector;
		video_vton    : in  std_logic;
		video_vtdot   : out std_logic);

end;

architecture def of scopeio_axis is

	constant division_size : natural := grid_divisionsize(layout);
	constant font_size     : natural := axis_fontsize(layout);

	constant division_bits : natural := unsigned_num_bits(division_size-1);
	constant font_bits     : natural := unsigned_num_bits(font_size-1);

	constant hz_width      : natural := grid_width(layout);
	constant hztick_bits   : natural := unsigned_num_bits(8*font_size-1);
	constant hzstep_bits   : natural := hztick_bits;
	constant hzwidth_bits  : natural := unsigned_num_bits(2**hzstep_bits*((hz_width +2**hzstep_bits-1)/2**hzstep_bits)+2**hzstep_bits);

	constant vt_height     : natural := grid_height(layout);
	constant vttick_bits   : natural := unsigned_num_bits(8*font_size-1);
	constant vtstep_bits   : natural := setif(vtaxis_tickrotate(layout)=ccw0, division_bits, vttick_bits);
	constant vtheight_bits : natural := unsigned_num_bits(2**vtstep_bits*((vt_height+2**vtstep_bits-1)/2**vtstep_bits)+2**vtstep_bits);

	signal binvalue : signed(3*4-1 downto 0);
	signal bcdvalue : unsigned(8*btof_bcddo'length-1 downto 0);

	signal hz_start : signed(binvalue'range);
	signal hz_stop  : unsigned(binvalue'range);
	signal hz_step  : signed(binvalue'range);
	signal hz_taddr : unsigned(13-1 downto hzstep_bits);
	signal hz_align : std_logic;
	signal hz_sign  : std_logic;
	signal hz_ena   : std_logic;
	signal hz_tv    : std_logic;

	signal vt_start : signed(binvalue'range);
	signal vt_stop  : unsigned(binvalue'range);
	signal vt_step  : signed(binvalue'range);
	signal vt_taddr : unsigned(vtheight_bits-1 downto vtstep_bits);
	signal vt_align : std_logic;
	signal vt_sign  : std_logic;
	signal vt_ena   : std_logic;
	signal vt_tv    : std_logic;

begin

	ticks_b : block

		signal scale    : std_logic_vector(axis_scale'range);
		signal init     : std_logic := '1';
		signal ena      : std_logic;
		signal start    : signed(binvalue'range);
		signal stop     : unsigned(binvalue'range);
		signal step     : signed(binvalue'range);
		signal iterator : unsigned(stop'range);
		signal complete : std_logic;

		signal taddr  : unsigned(max(vt_taddr'length, hz_taddr'length)-1 downto 0);
	begin

		start <= hz_start when vt_ena='0' else vt_start;
		stop  <= hz_stop  when vt_ena='0' else vt_stop;
		step  <= hz_step  when vt_ena='0' else vt_step;

		init_p : process (clk)
		begin
			if rising_edge(clk) then
				if axis_dv='1' then
					init   <= '0';
					hz_ena <= not axis_sel;
					vt_ena <=     axis_sel;
					scale  <= axis_scale;
				elsif complete='1' then
					init  <= '1';
				end if;
			end if;
		end process;

		ena <= btof_binfrm and btof_bcdirdy and btof_bcdtrdy and btof_bcdend;
		iterator_e : process(clk)
		begin
			if rising_edge(clk) then
				if init='1' then
					iterator <= (others => '0');
					binvalue <= start;
				elsif ena='1' then
					if iterator  < unsigned(stop) then
						iterator <= iterator + 1;
						binvalue <= binvalue + step;
					end if;
				end if;
			end if;
		end process;
		complete <= not setif(iterator < stop) and ena;

		frm_p : process (clk)
		begin
			if rising_edge(clk) then
				if btof_binfrm='1' then
					if btof_bcdtrdy <= '1' then
						if btof_bcdend='1' then
							btof_binfrm  <= '0';
							btof_binirdy <= '0';
						end if;
					end if;
				elsif axis_dv='1' then
					btof_binfrm  <= '1';
					btof_binirdy <= '1';
				elsif init='0' then
					btof_binfrm  <= '1';
					btof_binirdy <= '1';
				end if;
			end if;
		end process;

		btof_binneg   <= binvalue(binvalue'left);
		btof_bcdprec  <= b"1110";
		btof_bcdunit  <= b"1111";
		btof_bcdwidth <= b"1000";
		btof_bcdalign <= hz_align when vt_ena='0' else vt_align;
		btof_bcdsign  <= hz_sign  when vt_ena='0' else vt_sign;

		bindi_p : process (clk)
			variable sel : unsigned(0 to unsigned_num_bits(binvalue'length/btof_bindi'length)-1) := (others => '0');
		begin
			if rising_edge(clk) then
				if btof_binfrm='0' then
					sel := (others => '0');
				elsif btof_bintrdy='1' then
					sel := sel + 1;
				end if;

				btof_bindi <= word2byte(
					std_logic_vector(scale_1245(neg(binvalue, binvalue(binvalue'left)), scale) & x"f"),
					std_logic_vector(sel), 
					btof_bindi'length);
				btof_binexp <= setif(sel >= binvalue'length/btof_bindi'length);

			end if;
		end process;

		taddr_p : process (clk)
		begin
			if rising_edge(clk) then
				if init='1' then
					taddr <= (others => '1');
				elsif ena='1' then
					taddr <= taddr + 1;
				end if;
				hz_taddr <= taddr(hz_taddr'length-1 downto 0);
				vt_taddr <= taddr(vt_taddr'length-1 downto 0);
			end if;
		end process;

		bcdvalue_p : process (clk)
			variable value : unsigned(bcdvalue'range);
		begin
			if rising_edge(clk) then
				if btof_bcdtrdy='1' then
					value    := value sll btof_bcddo'length;
					value(btof_bcddo'length-1 downto 0) := unsigned(btof_bcddo);
				end if;
				bcdvalue <= value;
				hz_tv <= btof_bcdend and btof_bcdtrdy and hz_ena;
				vt_tv <= btof_bcdend and btof_bcdtrdy and vt_ena;
			end if;
		end process;

	end block;

	video_b : block

		signal char_code : std_logic_vector(4-1 downto 0);
		signal char_row  : std_logic_vector(font_bits-1 downto 0);
		signal char_col  : std_logic_vector(font_bits-1 downto 0);
		signal char_dot  : std_logic;

		signal hz_bcd   : std_logic_vector(char_code'range);
		signal hz_crow  : std_logic_vector(font_bits-1 downto 0);
		signal hz_ccol  : std_logic_vector(font_bits-1 downto 0);
		signal hz_don   : std_logic;
		signal hz_on    : std_logic;

		signal vt_bcd   : std_logic_vector(char_code'range);
		signal vt_crow  : std_logic_vector(font_bits-1 downto 0);
		signal vt_ccol  : std_logic_vector(font_bits-1 downto 0);
		signal vt_on    : std_logic;
		signal vt_don   : std_logic;

	begin

		hz_b : block

			signal x        : unsigned(hz_taddr'left downto 0);
			signal tick     : std_logic_vector(bcdvalue'range);

			signal vaddr    : std_logic_vector(x'range);
			signal vdata    : std_logic_vector(tick'range);
			signal vcol     : std_logic_vector(hztick_bits-1 downto font_bits);

		begin 

			hz_start <= 
				mul(to_signed(1,1), unsigned(hz_unit)) +
				shift_left(
					resize(mul(signed(axis_base), unsigned(hz_unit)), hz_start'length),
					axisx_backscale+hztick_bits-hz_taddr'right);
			hz_stop  <= resize(unsigned'(x"7e"), hz_stop'length);
			hz_step  <= signed(resize(unsigned(hz_unit), hz_step'length));
			hz_align <= '1';
			hz_sign  <= '0';

			x <= resize(unsigned(video_hcntr) + unsigned(hz_offset), x'length);

			hzvaddr_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(x);
				end if;
			end process;

			hzmem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**hz_taddr'length*bcdvalue'length-1 => '1'))
			port map (
				wr_clk  => clk,
				wr_ena  => hz_tv,
				wr_addr => std_logic_vector(hz_taddr),
				wr_data => std_logic_vector(bcdvalue),

				rd_addr => vaddr(hz_taddr'range),
				rd_data => vdata);

			hztick_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					tick  <= vdata;
				end if;
			end process;

			col_e : entity hdl4fpga.align
			generic map (
				n => vcol'length,
				d => (vcol'range => 2))
			port map (
				clk => video_clk,
				di  => std_logic_vector(x(vcol'range)),
				do  => vcol);

			crow_e : entity hdl4fpga.align
			generic map (
				n => hz_crow'length,
				d => (hz_crow'range => 2))
			port map (
				clk => video_clk,
				di  => video_vcntr(hz_crow'range),
				do  => hz_crow);

			ccol_e : entity hdl4fpga.align
			generic map (
				n => hz_ccol'length,
				d => (hz_ccol'range => 2))
			port map (
				clk => video_clk,
				di  => std_logic_vector(x(hz_ccol'range)),
				do  => hz_ccol);

			on_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => video_hzon,
				do(0) => hz_on);

			hz_bcd <= word2byte(tick, vcol, char_code'length);
		end block;

		vt_b : block

			signal y      : unsigned(vt_taddr'left downto 0);
			signal tick   : std_logic_vector(bcdvalue'range);

			signal vaddr  : std_logic_vector(y'range);
			signal vdata  : std_logic_vector(tick'range);
			signal vcol   : std_logic_vector(vttick_bits-1 downto font_bits);
			signal vton   : std_logic;

			signal rot_vcol   : std_logic_vector(vcol'range);
			signal rot_crow   : std_logic_vector(vt_crow'range);
			signal rot_ccol   : std_logic_vector(vt_ccol'range);

		begin 

			vt_start <= 
				mul(to_signed((vt_height/2)/2**vtstep_bits,5), unsigned(vt_unit)) +
				shift_left(
					resize(mul(-signed(axis_base), unsigned(vt_unit)), vt_start'length),
					vt_offset'length-vt_taddr'right);
			vt_stop  <= to_unsigned(2**vtheight_bits/2**vtstep_bits-1, vt_stop'length); 
			vt_step  <= -signed(resize(unsigned(vt_unit), vt_step'length));
			vt_align <= setif(vtaxis_tickrotate(layout)=ccw90);
			vt_sign  <= '1';

			y <= resize(unsigned(video_vcntr), y'length) + unsigned(vt_offset);
			vtvaddr_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(y);
				end if;
			end process;

			vt_mem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**vt_taddr'length*bcdvalue'length-1 => '1'))
			port map (
				wr_clk  => clk,
				wr_ena  => vt_tv,
				wr_addr => std_logic_vector(vt_taddr),
				wr_data => std_logic_vector(bcdvalue),

				rd_addr => vaddr(vt_taddr'range),
				rd_data => vdata);

			vttick_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					tick  <= vdata;
				end if;
			end process;

			rot_vcol <= 
				video_hcntr(vcol'range) when vtaxis_tickrotate(layout)=ccw0 else
				vaddr(vcol'range) when vtaxis_tickrotate(layout)=ccw270 else
				not vaddr(vcol'range);

			col_e : entity hdl4fpga.align
			generic map (
				n => vcol'length,
				d => (vcol'range => 2))
			port map (
				clk => video_clk,
				di  => rot_vcol,
				do  => vcol);

			rot_crow <= 
				std_logic_vector(y(vt_crow'range)) when vtaxis_tickrotate(layout)=ccw0 else
				not video_hcntr(vt_ccol'range) when vtaxis_tickrotate(layout)=ccw270 else
				video_hcntr(vt_ccol'range);

			crow_e : entity hdl4fpga.align
			generic map (
				n => vt_crow'length,
				d => (vt_crow'range => 2))
			port map (
				clk => video_clk,
				di  => rot_crow,
				do  => vt_crow);

			rot_ccol <= 
				video_hcntr(vt_ccol'range) when vtaxis_tickrotate(layout)=ccw0 else
				std_logic_vector(y(vt_crow'range)) when vtaxis_tickrotate(layout)=ccw270 else
				not std_logic_vector(y(vt_crow'range));

			ccol_e : entity hdl4fpga.align
			generic map (
				n => hz_ccol'length,
				d => (hz_ccol'range => 2))
			port map (
				clk => video_clk,
				di  => rot_ccol, --video_hcntr(vt_ccol'range),
				do  => vt_ccol);

			vton <= 
				video_vton and setif(y(division_bits-1 downto font_bits)=(division_bits-1 downto font_bits => '1')) when vtaxis_tickrotate(layout)=ccw0 else
				video_vton;

			on_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => vton,
				do(0) => vt_on);

			vt_bcd <= 
				word2byte(std_logic_vector(unsigned(tick) rol 2*char_code'length), vcol, char_code'length) when vtaxis_tickrotate(layout)=ccw0 else
				word2byte(std_logic_vector(unsigned(tick) rol 0*char_code'length), vcol, char_code'length);

		end block;

		char_code <= word2byte(vt_bcd  & hz_bcd,  not vt_on);
		char_row  <= word2byte(vt_crow & hz_crow, not vt_on); 
		char_col  <= word2byte(vt_ccol & hz_ccol, not vt_on); 

		cgarom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => setif(font_size=8, psf1digit8x8, psf1bcd4x4),
			font_height => 2**font_bits,
			font_width  => 2**font_bits)
		port map (
			clk       => video_clk,
			char_col  => char_col,
			char_row  => char_row,
			char_code => char_code,
			char_dot  => char_dot);

		cgalat_e : entity hdl4fpga.align
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

			lat_e : entity hdl4fpga.align
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
