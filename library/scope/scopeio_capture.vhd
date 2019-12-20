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
	port (
		input_clk    : in  std_logic;
		downsampling : in  std_logic := '0';
		capture_shot : in  std_logic;
		capture_end  : out std_logic;

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
	constant delay_size   : natural := 2**time_offset'length;

	signal rd_addr : signed(video_addr'length-1 downto 0);
	signal wr_addr : signed(video_addr'length-1 downto 0);

	signal running : std_logic;
	signal delay   : signed(time_offset'range);
	signal valid   : std_logic;
	signal dv2     : std_logic;
	signal dv1     : std_logic;


begin
 
	capture_end <= not running;

	storage_b : block
		signal mem_wraddr : std_logic_vector(video_addr'length-1 downto 1);
		signal rd_data    : std_logic_Vector(video_data'range);
		signal y0         : std_logic_vector(0 to video_data'length/2-1);
		signal uplw       : std_logic;
	begin

		fifo_b : block
			signal addra : signed(video_addr'length-1 downto 1); -- := (others => '0'); -- Debug purpose
			signal addrb : unsigned(addra'range);
			signal wea   : std_logic;
		begin
			addra_p : process (input_clk)
			begin
				if rising_edge(input_clk) then
					if input_dv='1' then
						addra <= addra + 1;
					end if;
				end if;
			end process;

			addrb <= addra - time_offset when time_offset < 0 else addra;
			wr_addr <= std_logic_vector(
				shift_left(resize(addrb, wr_addr'length), 1) when downsampling='0' else
				shift_left(resize(addrb, wr_addr'length), 0));

			process (input_clk)
			begin
				if rising_edge(input_clk) then
				end if;
			end process;

			fifo_e : entity hdl4fpga.dpram
			generic map (
				synchronous_rdaddr => true,
				synchronous_rddata => true)
			port map (
				wr_clk  => input_clk,
				wr_addr => std_logic_vector(addra),
				wr_ena  => wea,
				wr_data => input_data,

				rd_clk  => input_clk,
				rd_addr => rd_addr,
				rd_data => rd_data);
		end block;

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if mem_waddr(mem_waddr'left)='0' then
					mem_waddr <= mem_waddr + 1;
				elsif caputre_shot='1' then
					mem_waddr <= (others => '0');
				end if;
			end if;
		end process;
		running <= not mem_waddr(mem_waddr'left);
		wea     <= not mem_waddr(mem_waddr'left) and input_dv;

		mem_raddr <= std_logic_vector(
			resize(unsigned(video_addr) srl 1, addrb'length) when downsampling='0' else
			resize(unsigned(video_addr) srl 0, addrb'length));

		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_addr => mem_waddr,
			wr_ena  => mem_we,
			wr_data => mem_wdata,

			rd_clk  => video_clk,
			rd_addr => mem_raddr,
			rd_data => rd_data);

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
			di(0) => rd_addr(0),
			do(0) => uplw);


		y0_p : process (video_clk)
		begin
			if rising_edge(video_clk) then
				y0 <= word2byte(rd_data, uplw);
			end if;
		end process;

		video_data <= 
			word2byte(word2byte(rd_data, uplw) & y0, dv2) & word2byte(rd_data, uplw) when downsampling='0' else
			rd_data;

	end block;

end;
