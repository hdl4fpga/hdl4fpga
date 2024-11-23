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
use hdl4fpga.scopeiopkg.all;

entity scopeio_capture is
	generic (
		max_pretrigger : natural := 1024);
	port (
		rgtr_clk     : in  std_logic;
		input_clk    : in  std_logic;
		downsampling : in  std_logic := '0';
		capture_req  : in  std_logic;
		capture_rdy  : buffer std_logic := '0';

		input_dv     : in  std_logic := '1';
		input_data   : in  std_logic_vector;
		time_offset  : in  std_logic_vector;

		video_clk    : in  std_logic;
		video_addr   : in  std_logic_vector;
		video_vton   : in  std_logic;
		video_frm    : in  std_logic := '1';
		video_data   : out std_logic_vector;
		video_dv     : out std_logic);
end;

architecture beh of scopeio_capture is

	constant bram_latency  : natural := 2;
	constant fifo_addrbits : natural := unsigned_num_bits(max_pretrigger-1);
	constant fifo_size     : natural := 2**fifo_addrbits;

	signal mem_data   : std_logic_vector(video_data'range);
	signal dlyd_data  : std_logic_vector(video_data'range);
	signal delay      : signed(time_offset'range);

begin
 
	delayed_b : block
		signal wr_ena  : std_logic;
		signal wr_addr : unsigned(unsigned_num_bits(max_pretrigger-1)-1 downto 1) := (others => '0'); -- Debug purpose
		signal rd_addr : unsigned(wr_addr'range) := (others => '0');
	begin
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if (capture_rdy xor capture_req)='1' then
					rd_addr <= rd_addr + 1;
				end if;
			end if;
		end process;

		wr_ena  <=(capture_rdy xor capture_req);
		wr_addr <= rd_addr;
			-- rd_addr when signed(delay) >= 0 else
			-- rd_addr + resize(unsigned(shift_right(signed(delay)+1, 1)), rd_addr'length) when downsampling='0' else
			-- rd_addr + resize(unsigned(shift_right(signed(delay),   0)), rd_addr'length);

		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_ena  => wr_ena,
			wr_addr => std_logic_vector(wr_addr),
			wr_data => input_data,

			rd_clk  => input_clk,
			rd_addr => std_logic_vector(rd_addr),
			rd_data => dlyd_data);

	end block;

	video_b : block
		signal wr_ena   : std_logic;
		signal wr_addr  : unsigned(video_addr'length downto 1);
		alias  rd_addr  : std_logic_vector(video_addr'length-1 downto 0) is video_addr;
		alias  wr_addr0 is wr_addr(wr_addr'left);
	begin
		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if (capture_rdy xor capture_req)='1' then
					if input_dv='0' then
						if wr_addr0='0' then
							wr_addr <= wr_addr + 1;
						else
							capture_rdy <= capture_req;
							wr_addr <= (others => '0');
						end if;
					end if;
				else
					wr_addr <= (others => '0');
				end if;
			end if;
		end process;

		wr_ena <= (capture_rdy xor capture_req);
		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_addr => std_logic_vector(wr_addr),
			wr_ena  => wr_ena,
			wr_data => dlyd_data,

			rd_clk  => video_clk,
			rd_addr => rd_addr,
			rd_data => mem_data);
		video_dv   <= video_frm;
		process (video_clk)
			variable xxx : unsigned(0 to 3*video_data'length/2-1);
		begin
			if rising_edge(video_clk) then
				xxx(0 to video_data'length-1) := unsigned(mem_data);
				xxx := xxx ror video_data'length/2;
				video_data <= std_logic_vector(xxx(0 to video_data'length-1));

			end if;
		end process;


	end block;

end;
