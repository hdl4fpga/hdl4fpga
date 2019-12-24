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

entity scopeio_capture is
	generic (
		max_pretrigger : natural := 1024);
	port (
		input_clk    : in  std_logic;
		downsampling : in  std_logic := '0';
		capture_shot : in  std_logic;
		capture_a0   : in  std_logic;
		capture_end  : buffer std_logic;

		input_dv     : in  std_logic := '1';
		input_data   : in  std_logic_vector;
		time_offset  : in  std_logic_vector;

		video_clk    : in  std_logic;
		video_addr   : in  std_logic_vector;
		video_frm    : in  std_logic := '1';
		video_data   : out std_logic_vector;
		video_dv     : out std_logic);
end;

architecture beh of scopeio_capture is

	constant bram_latency : natural := 2;

	constant video_size : natural := 2**video_addr'length/2;

	signal y0         : std_logic_vector(0 to video_data'length/2-1);
	signal dv2        : std_logic;
	signal dv1        : std_logic;

	signal mem_raddr  : unsigned(video_addr'length-1 downto 1);
	signal mem_waddr  : std_logic_vector(video_addr'length+2-1 downto 1);
	signal mem_wena   : std_logic;
	signal wr_addr    : std_logic_vector(mem_raddr'range);
	signal wr_ena     : std_logic;
	signal mem_data   : std_logic_vector(video_data'range);
	signal fifo_data  : std_logic_vector(video_data'range);
	signal mem_raddr0 : std_logic;
	signal a0         : std_logic;
	signal hilw       : std_logic;

begin
 
	fifo_b : block

		signal addra   : unsigned(unsigned_num_bits(max_pretrigger-1)-1 downto 1); -- := (others => '0'); -- Debug purpose
		signal addrb   : unsigned(addra'range);

	begin

		addra_p : process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					addra <= addra + 1;
				end if;
			end if;
		end process;

		addrb <= 
			addra when signed(time_offset) >= 0 else
			addra + resize(unsigned(shift_right(signed(time_offset)+1, 1)), addrb'length) when downsampling='0' else
			addra + resize(unsigned(shift_right(signed(time_offset), 0)), addrb'length);

		fifo_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_ena  => input_dv,
			wr_addr => std_logic_vector(addra),
			wr_data => input_data,

			rd_clk  => input_clk,
			rd_addr => std_logic_vector(addrb),
			rd_data => fifo_data);

	end block;

	process (input_clk)
		variable waddr : unsigned(mem_waddr'range);
		function init_waddr(
			constant time_offset  : std_logic_vector;
			constant downsampling : std_logic;
			constant size         : natural)
			return std_logic_vector is
		begin
			if signed(time_offset) >= 0 then
				if downsampling='0' then
					waddr := resize(unsigned(2**size-shift_right(signed(time_offset),1)), waddr'length);
				else
					waddr := resize(unsigned(2**size-shift_right(signed(time_offset),0)), waddr'length);
				end if;
			else
				waddr := to_unsigned(2**mem_raddr'length, waddr'length);
			end if;
		end;
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				waddr := unsigned(mem_waddr) + 1;
				if waddr(waddr'left)='0' then
					mem_waddr <= unsigned(waddr);
				else
					if signed(time_offset) >= 0 then
						if downsampling='0' then
							waddr := resize(unsigned(2**mem_raddr'length-shift_right(signed(time_offset),1)), waddr'length);
						else
							waddr := resize(unsigned(2**mem_raddr'length-shift_right(signed(time_offset),0)), waddr'length);
						end if;
					else
						waddr := to_unsigned(2**mem_raddr'length, waddr'length);
					end if;
					mem_waddr(waddr'range) <= std_logic_vector(waddr);
					if capture_shot='1' then
						mem_waddr(mem_waddr'left) <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	capture_end <= mem_waddr(mem_waddr'left);
	mem_wena <= 
	   input_dv and mem_waddr(mem_waddr'left-1) when capture_end='0' else
	   input_dv and capture_shot;


	data_e : entity hdl4fpga.align
	generic map (
		n => wr_addr'length,
		d => (0 to wr_addr'length-1 => 2))
	port map (
		clk => input_clk,
		di  => mem_waddr(mem_raddr'range),
		do  => wr_addr);

	wrena_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => 2))
	port map (
		clk   => input_clk,
		di(0) => mem_wena,
		do(0) => wr_ena);

	mem_raddr_p : process (video_addr, time_offset, downsampling, capture_a0)
		variable vaddr : unsigned(video_addr'length-1 downto 0);
	begin
		vaddr := unsigned(video_addr);
		if downsampling='0' then
--			if signed(time_offset) >= 0 then
--				vaddr := vaddr + 1;
--			elsif time_offset(time_offset'right)='0' then
--				vaddr := vaddr + 1;
--			end if;
--			if capture_a0='1' then
--				vaddr := vaddr + 1;
--			end if;
			mem_raddr0 <= vaddr(0);
			mem_raddr  <= vaddr(mem_raddr'range);
		else
			mem_raddr0 <= '-';
			vaddr      := shift_left(vaddr, 1);
			mem_raddr  <= vaddr(mem_raddr'range);
		end if;

	end process;

	mem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => input_clk,
--		wr_addr => wr_addr,
		wr_addr => mem_waddr(mem_raddr'range),
--		wr_ena  => wr_ena,
		wr_ena  => mem_wena,
--		wr_data => fifo_data,
		wr_data => input_data,

		rd_clk  => video_clk,
		rd_addr => std_logic_vector(mem_raddr),
		rd_data => mem_data);

	process (downsampling, video_frm, video_clk)
		variable q : std_logic;
	begin
		if rising_edge(video_clk) then
			q := video_frm;
		end if;
		if downsampling='0' then
			dv1 <= q and video_frm;
		else
			dv1 <= video_frm;
		end if;
	end process;

	dv2_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => bram_latency))
	port map (
		clk   => video_clk,
		di(0) => video_frm,
		do(0) => video_dv);

	dv1_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => bram_latency))
	port map (
		clk   => video_clk,
		di(0) => dv1,
		do(0) => dv2);

	align_addr0_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => bram_latency))
	port map (
		clk => video_clk,
--		di(0) => video_addr(0),
		di(0) => mem_raddr0,
		do(0) => hilw);

	y0_p : process (video_clk)
	begin
		if rising_edge(video_clk) then
			y0 <= word2byte(mem_data, not hilw);
		end if;
	end process;

	video_data <= 
		word2byte(word2byte(mem_data, hilw) & y0, dv2) & word2byte(mem_data, not hilw) when downsampling='0' else
		mem_data;

end;
