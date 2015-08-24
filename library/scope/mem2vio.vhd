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

entity mem2vio is
	generic (
		page_num  : natural := 6;
		page_size : natural := 9;
		data_size : natural := 16);
	port (
		video_clk : in  std_logic;

		mem_addr : out std_logic_vector(page_num*page_size-1 downto 0);
		mem_di   : in  std_logic_vector(page_num*2*data_size-1 downto 0);

		video_col : in  std_logic_vector;
		video_row : in  std_logic_vector;
		video_do  : out std_logic_vector(0 to 2*data_size-1));

	subtype dword is std_logic_vector(2*data_size-1 downto 0);
	type dword_vector is array (natural range <>) of dword;
	subtype aword is std_logic_vector(page_size-1 downto 0);
	type aword_vector is array (natural range <>) of aword;
	subtype vword is std_logic_vector(data_size-1 downto 0);
	type vword_vector is array (natural range <>) of vword;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of mem2vio is
	constant chan_num : natural := 2;
	constant page_seg : natural := 2;
	constant vrow_start : natural := 15;
	constant vrow_size : natural := video_row'length;

	signal vchn_do : vword_vector(0 to chan_num-1) := (others => (others => '0'));
	signal vchn_di : vword_vector(0 to 2**vrow_size-1) := (others => (others => '0'));
	signal vaddr : std_logic_vector(video_col'length-1 downto 0);
	signal mem_data : dword_vector(0 to page_num-1);
	signal mem_address : aword_vector(0 to page_num-1);

	signal pg_sel  : std_logic_vector(0 to page_seg-1);
	signal pg_bnd  : std_logic_vector(0 to chan_num-1);
	signal vaddr0  : std_logic;
begin
	process (mem_di)
		variable data : std_logic_vector(mem_di'range);
	begin
		mem_data <= (others => (others => '0'));
		data := mem_di;
		for i in mem_data'range loop
			mem_data(i) <= data(dword'range);
			data := data srl 2*data_size;
		end loop;
	end process;

	process (mem_address)
		variable addr : std_logic_vector(mem_addr'range);
	begin
		addr := (others => '-');
		for i in mem_address'reverse_range loop
			addr := addr sll page_size;
			addr(aword'range) := mem_address(i);
		end loop;
		mem_addr <= addr;
	end process;

	vaddr <= video_col;
	process (video_clk)
	begin
		if rising_edge(video_clk) then
			for i in mem_address'range loop
				mem_address(i)(aword'left-1 downto 0) <= vaddr(8 downto 1);
				case i mod 3 is
				when 0 =>
					mem_address(i)(aword'left) <= not vaddr(9);
				when 1 =>
					mem_address(i)(aword'left) <= not vaddr(10);
				when others =>
					mem_address(i)(aword'left) <= vaddr(9);
				end case;
			end loop;
		end if;
	end process;

	pg_sel_dly_e : entity hdl4fpga.align
	generic map (		
		n => 3,			
		d => (
			0 to 3-1 => 3))	-- Compensate the BLOCK RAM delay
	port map (
		clk   => video_clk,
		di(0 to 2-1) => pg_bnd,
		di(2) => vaddr(0),
		do(0 to 2-1) => pg_sel,
		do(2) => vaddr0);

	channels_g : for l in 0 to page_seg-1 generate
		signal mux_vchn_di : std_logic_vector(2**vrow_size*vword'length-1 downto 0) := (others => '0');
		signal mux_channel_sel : std_logic_vector(0 to 2-1);
	begin
		
		pg_bnd(l) <= not vaddr(10) and not vaddr(9) when l=0 else not vaddr(10);
		mux_channel_sel <= pg_sel(l) & not vaddr0;
		segment_g : for k in 0 to 2**(vrow_size-1)-1 generate
			signal mux_channel_di  : std_logic_vector(page_seg*dword'length-1 downto 0);
			signal mux_channel_do  : std_logic_vector(data_size-1 downto 0);
		begin
			process (video_clk)
			begin
				if rising_edge(video_clk) then
					mux_channel_di <= mem_data((3*k+l) mod 6) & mem_data((3*k+l+1) mod 6);
				end if;
			end process;
	
			mux_channel_e : entity hdl4fpga.muxw
			generic map (
				addr_size => 2,
				data_size => data_size)
			port map (
				sel => mux_channel_sel,
				di  => mux_channel_di,
				do  => mux_channel_do);

			process (video_clk)
				constant i : natural := (vrow_start-(2*k+l)) mod 2**vrow_size;
			begin
				if rising_edge(video_clk) then
					vchn_di(i) <= mux_channel_do(vword'range);
				end if;
			end process;

		end generate;

		vword2bit_vector_e : process (vchn_di)
			variable data : std_logic_vector(mux_vchn_di'range) := (others => '-');
		begin
			data := (others => '-');
			for i in vchn_di'range loop
				data := (data sll vword'length);
				data(vword'range) := vchn_di(i);
			end loop;
			for i in 0 to l-1 loop
				data := data sll vword'length;
				data(vword'range) := to_unsigned(1,vword'length);
			end loop;
			mux_vchn_di <= data;
		end process;
		mux2_e : entity hdl4fpga.muxw
		generic map (
			addr_size => video_row'length,
			data_size => vword'length)
		port map (
			sel => video_row,
			di  => mux_vchn_di,
			do  => vchn_do(l));
	end generate;

	vword2bit_vector_e : process (vchn_do)
		variable data : std_logic_vector(video_do'length-1 downto 0) := (others => '-');
	begin
		video_do <= (others => '-');
		data := (others => '-');
		for i in vchn_do'range loop
			data := data sll data_size;
			data(vword'range) := vchn_do(i);
		end loop;
		video_do <= data;
	end process;
end;