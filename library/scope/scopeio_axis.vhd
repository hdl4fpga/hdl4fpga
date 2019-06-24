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
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	generic (
		latency     : natural;
		axis_unit   : std_logic_vector;
		vt_height   : natural;
		division_size : natural);
	port (
		clk         : in  std_logic;

		axis_dv     : in  std_logic;
		axis_sel    : in  std_logic;
		axis_scale  : in  std_logic_vector;
		axis_base   : in  std_logic_vector;

		wu_frm      : out std_logic;
		wu_irdy     : out std_logic;
		wu_trdy     : in  std_logic;
		wu_unit     : out std_logic_vector;
		wu_neg      : out std_logic;
		wu_sign     : out std_logic;
		wu_align    : out std_logic;
		wu_value    : out std_logic_vector;
		wu_format   : in  std_logic_vector;

		video_clk   : in  std_logic;
		video_hcntr : in  std_logic_vector;
		video_vcntr : in  std_logic_vector;

		hz_offset   : in  std_logic_vector;
		video_hzon  : in  std_logic;
		video_hzdot : out std_logic;

		vt_offset   : in  std_logic_vector;
		video_vton  : in  std_logic;
		video_vtdot : out std_logic);

end;

architecture def of scopeio_axis is

	constant division_bits : natural := unsigned_num_bits(division_size-1);
	constant vtheight_bits : natural := unsigned_num_bits((vt_height-1)-1);

	signal vt_taddr    : std_logic_vector((vtheight_bits+1)-1 downto vt_offset'length);

	signal hz_taddr    : std_logic_vector(13-1 downto 6);

	function scale_1245 (
		constant val   : std_logic_vector;
		constant scale : std_logic_vector)
		return std_logic_vector is
		variable sel  : std_logic_vector(scale'length-1 downto 0);
		variable by1  : signed(val'range);
		variable by2  : signed(val'range);
		variable by4  : signed(val'range);
		variable rval : signed(val'range);
	begin
		by1 := shift_left(signed(val), 0);
		by2 := shift_left(signed(val), 1);
		by4 := shift_left(signed(val), 2);
		sel := scale;
		case sel(2-1 downto 0) is
		when "00" =>
			rval := by1;
		when "01" =>
			rval := by2;
		when "10" =>
			rval := by4;
		when "11" =>
			rval := by4 + by1;
		when others =>
			rval := (others => '-');
		end case;
		return std_logic_vector(rval);
	end;
		
	function mul (
		constant op1 : signed;
		constant op2 : unsigned)
		return signed is
		variable muld : signed(op1'length-1 downto 0);
		variable mulr : unsigned(op2'length-1 downto 0);
		variable rval : signed(0 to muld'length+mulr'length-1);
	begin
		muld := op1;
		mulr := op2;
		rval := (others => '0');
		for i in mulr'reverse_range loop
			rval := shift_right(rval, 1);
			if mulr(i)='1' then
				rval(0 to muld'length) := rval(0 to muld'length) + muld;
			end if;
		end loop;
		return rval;
	end;

begin

	ticks_b : block
		signal frm   : std_logic := '0';
		signal irdy  : std_logic;
		signal trdy  : std_logic;

		signal value : std_logic_vector(3*4-1 downto 0);
		signal base  : std_logic_vector(value'range);
		signal step  : std_logic_vector(value'range);

		signal last  : std_logic_vector(8-1 downto 0);
		signal updn  : std_logic;
	begin

		process(clk)
		begin
			if rising_edge(clk) then
				if frm='0' then
					if axis_dv='1' then
						frm <= '1';
					end if;
				elsif trdy='1' then
					frm  <= '0';
				end if;
			end if;
		end process;
		irdy <= frm;

		process (clk)
			variable cntr : unsigned(max(hz_taddr'length, vt_taddr'length) downto 0);
		begin
			if rising_edge(clk) then
				if frm='0' then
					cntr := (others => '0');
				elsif wu_trdy='1' then
					cntr := cntr + 1;
				end if;
				hz_taddr <= std_logic_vector(cntr(hz_taddr'length-1 downto 0));
				vt_taddr <= std_logic_vector(cntr(vt_taddr'length-1 downto 0));
			end if;
		end process;

		process (axis_base, axis_sel)
			variable aux : signed(base'range);
		begin
			aux  := (others => '0');
			aux  := resize(mul(signed(neg(axis_base, axis_sel)), unsigned(axis_unit)), aux'length);
			if axis_sel='1' then
				aux := shift_left(aux, vt_offset'length-division_bits);
				aux := aux + mul(to_signed(((vt_height-1)/2)/division_size-1,4), unsigned(axis_unit));
			else
				aux  := shift_left(aux, 9-6);
			end if;
			base <= std_logic_vector(aux);
		end process;

		last <= 
			x"7f" when axis_sel='0' else 
			std_logic_vector(to_unsigned((2*(vt_height-1))/division_size-1,last'length)); 

		updn <= axis_sel;
		step <= std_logic_vector(resize(unsigned(axis_unit), base'length));
		ticks_e : entity hdl4fpga.scopeio_ticks
		port map (
			clk      => clk,
			frm      => frm,
			irdy     => irdy,
			trdy     => trdy,
			last     => last,
			base     => base,
			step     => step,
			updn     => updn,
			wu_frm   => wu_frm,
			wu_irdy  => wu_irdy,
			wu_trdy  => wu_trdy,
			wu_value => value);

		wu_align <= not axis_sel;
		wu_neg   <= value(value'left);
		wu_sign  <= value(value'left) or axis_sel;
		wu_value <= scale_1245(neg(value, value(value'left)), axis_scale) & x"f";

	end block;

	video_b : block
--		attribute ram_style : string;
--		attribute ram_style of cgarom_e : label is "distributed";

		signal char_code : std_logic_vector(4-1 downto 0);
		signal char_row  : std_logic_vector(3-1 downto 0);
		signal char_col  : std_logic_vector(3-1 downto 0);
		signal char_dot  : std_logic;

		signal hz_bcd   : std_logic_vector(char_code'range);
		signal hz_crow  : std_logic_vector(3-1 downto 0);
		signal hz_ccol  : std_logic_vector(3-1 downto 0);
		signal hz_don   : std_logic;
		signal hz_on    : std_logic;

		signal vt_bcd   : std_logic_vector(char_code'range);
		signal vt_crow  : std_logic_vector(3-1 downto 0);
		signal vt_ccol  : std_logic_vector(3-1 downto 0);
		signal vt_on    : std_logic;
		signal vt_don   : std_logic;

	begin

		hz_b : block
--			attribute ram_style : string;
--			attribute ram_style of hzmem_e : label is "distributed";

			signal x      : unsigned(hz_taddr'left downto 0);
			signal tick   : std_logic_vector(wu_format'range);

			signal wr_ena : std_logic;
			signal vaddr  : std_logic_vector(x'range);
			signal vdata  : std_logic_vector(tick'range);
			signal vcol   : std_logic_vector(6-1 downto 3);
		begin 

			x <= resize(unsigned(video_hcntr), x'length) + unsigned(hz_offset);

			hzvaddr_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(x);
				end if;
			end process;

			wr_ena <= wu_trdy and not axis_sel;
			hzmem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**hz_taddr'length*wu_format'length-1 => '1'))
			port map (
				wr_clk  => clk,
				wr_ena  => wr_ena,
				wr_addr => hz_taddr,
				wr_data => wu_format,

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
				n => hz_crow'length,
				d => (hz_crow'range => 2))
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
			signal tick   : std_logic_vector(wu_format'range);

			signal wr_ena : std_logic;
			signal vaddr  : std_logic_vector(y'range);
			signal vdata  : std_logic_vector(tick'range);
			signal vcol  : std_logic_vector(6-1 downto 3);
			signal vton   : std_logic;
		begin 
			y <= resize(unsigned(video_vcntr), y'length) + unsigned(vt_offset);
			vtvaddr_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					vaddr <= std_logic_vector(y);
				end if;
			end process;

			wr_ena <= wu_trdy and axis_sel;
			vt_mem_e : entity hdl4fpga.dpram
			generic map (
				bitrom => (0 to 2**vt_taddr'length*wu_format'length-1 => '1'))
			port map (
				wr_clk  => clk,
				wr_ena  => wr_ena,
				wr_addr => vt_taddr,
				wr_data => wu_format,

				rd_addr => vaddr(vt_taddr'range),
				rd_data => vdata);

			vttick_p : process (video_clk)
			begin
				if rising_edge(video_clk) then
					tick  <= vdata;
				end if;
			end process;

			col_e : entity hdl4fpga.align
			generic map (
				n => hz_crow'length,
				d => (hz_crow'range => 2))
			port map (
				clk => video_clk,
				di  => video_hcntr(vcol'range),
				do  => vcol);

			crow_e : entity hdl4fpga.align
			generic map (
				n => vt_crow'length,
				d => (vt_crow'range => 2))
			port map (
				clk => video_clk,
				di  => std_logic_vector(y(vt_crow'range)),
				do  => vt_crow);

			ccol_e : entity hdl4fpga.align
			generic map (
				n => hz_ccol'length,
				d => (hz_ccol'range => 2))
			port map (
				clk => video_clk,
				di  => video_hcntr(vt_ccol'range),
				do  => vt_ccol);

			vton <= video_vton and setif(y(division_bits-1 downto 3)=(division_bits-1 downto 3 => '1')); --y(n-1); -- and y(n-2);
			on_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => vton,
				do(0) => vt_on);

			vt_bcd <= word2byte(std_logic_vector(unsigned(tick) rol 2*char_code'length), vcol, char_code'length);

		end block;

		char_code <= word2byte(vt_bcd  & hz_bcd,  hz_on);
		char_row  <= word2byte(vt_crow & hz_crow, hz_on); 
		char_col  <= word2byte(vt_ccol & hz_ccol, hz_on); 

		cgarom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => psf1digit8x8,
			font_height => 2**3,
			font_width  => 2**3)
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
