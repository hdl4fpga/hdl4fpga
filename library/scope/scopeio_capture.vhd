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

	signal index   : signed(time_offset'length-1  downto 0);
	signal bound   : signed(time_offset'length-1  downto 0);
	signal base    : signed(video_addr'length-1 downto 0);
	signal rd_addr : signed(video_addr'length-1 downto 0);
	signal wr_addr : signed(video_addr'length-1 downto 0);

	signal running : std_logic;
	signal delay   : signed(time_offset'range);
	signal valid   : std_logic;
	signal dv2     : std_logic;
	signal dv1     : std_logic;


begin
 
	video_addr_p : process (input_clk)
		variable full : std_logic;
		variable pre  : std_logic;
		variable cntr : signed(time_offset'length downto 0) := (others => '1'); -- Debug purpose
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				if signed(time_offset) < 0 then
					-- Pre-trigger
					if capture_shot='1' then
						if full='0' then
							pre  := '0';
							cntr := to_signed(-video_size, cntr'length);
							base <= (others => '-');
						else
							pre  := '1';
							cntr := resize(-signed(time_offset)-video_size+1, cntr'length);
							base  <= wr_addr;
						end if;
						delay   <= signed(time_offset);
						bound   <= signed(resize(cntr, bound'length));
						running <= cntr(0);
					elsif full='0' then
						cntr    := cntr + 1;
						full    := setif(cntr+delay > 0);
						bound   <= to_signed(-video_size, bound'length);
						running <= '1';
					elsif pre='0' then
						cntr    := cntr + 1;
						full    := '1';
						bound   <= to_signed(-video_size, bound'length);
						running <= '1';
					elsif cntr(cntr'left)='1' then
						cntr    := cntr + 1;
						full    := '1';
						bound   <= signed(resize(cntr, bound'length));
						running <= cntr(cntr'left);
					end if;
				else
					-- Delayed trigger
					if capture_shot='1' then
						cntr  := resize(-signed(time_offset)-video_size+1, cntr'length);
						base  <= wr_addr;
						delay <= signed(time_offset);
					elsif cntr(cntr'left)='1' then
						cntr := cntr + 1;
					end if;
					bound   <= cntr(bound'range);
					running <= cntr(cntr'left);
				end if;
			end if;
		end if;
	end process;

	index <= signed(time_offset)+signed(resize(unsigned(video_addr), time_offset'length));

	video_valid_p : valid <=
		setif(index > -video_size and delay <= index and -video_size < delay-index) when not running='1' else
		setif(index > -video_size and delay <= index and -video_size < delay-index+bound);

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
--		di(0) => video_frm,
		di(0) => valid,
		do(0) => video_dv);

	dv1_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => bram_latency))
	port map (
		clk   => video_clk,
		di(0) => dv1,
		do(0) => dv2);

	capture_end <= not running;

	rd_addr <= base + index(rd_addr'range);
	storage_b : block
		signal addra : signed(video_addr'length-1 downto 1); -- := (others => '0'); -- Debug purpose
		signal wea   : std_logic;
		signal addrb : unsigned(addra'range);
		signal rd_data : std_logic_Vector(video_data'range);
		signal y0    : std_logic_Vector(0 to video_data'length/2-1);
		signal uplw  : std_logic;
	begin

		wr_addr <= 
			shift_left(resize(addra, wr_addr'length), 1) when downsampling='0' else
			shift_left(resize(addra, wr_addr'length), 0);

		addra_p : process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					addra <= addra + 1;
				end if;
			end if;
		end process;
		wea <= (running or capture_shot) and input_dv;

		addrb <= 
			resize(unsigned(rd_addr) srl 1, addrb'length) when downsampling='0' else
			resize(unsigned(rd_addr) srl 0, addrb'length);

		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_addr => std_logic_vector(addra),
			wr_ena  => wea,
			wr_data => input_data,

			rd_clk  => video_clk,
			rd_addr => std_logic_vector(addrb),
			rd_data => rd_data);

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
