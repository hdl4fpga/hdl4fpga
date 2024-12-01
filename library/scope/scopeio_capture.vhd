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
		input_clk    : in  std_logic;
		downsampling : in  std_logic := '0';

		input_dv     : in  std_logic := '1';
		input_data   : in  std_logic_vector;
		capture_req  : buffer std_logic := '0';
		capture_rdy  : buffer std_logic := '0';
		trigger_shot : in  std_logic;
		time_offset  : in  std_logic_vector;

		video_clk    : in  std_logic;
		video_addr   : in  std_logic_vector;
		video_vton   : in  std_logic;
		video_frm    : in  std_logic := '1';
		video_data   : out std_logic_vector;
		video_dv     : out std_logic);
end;

architecture delayfifo of scopeio_capture is
	signal dlyd_dv    : std_logic;
	signal dlyd_data  : std_logic_vector(video_data'range);
	signal delay      : signed(time_offset'range);

begin
 
	delayed_b : block
		signal wr_addr : signed(unsigned_num_bits(max_pretrigger-1)-1 downto 0) := (others => '0'); -- Debug purpose
		signal rd_addr : signed(wr_addr'range);
	begin

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					wr_addr <= wr_addr + 1;
				end if;
			end if;
		end process;

		delay <= 
			shift_right(signed(time_offset),1) when downsampling='0' else
			shift_right(signed(time_offset),0);

		rd_addr <= wr_addr + resize(delay, rd_addr'length) when signed(time_offset) < 0 else wr_addr;

		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_ena  => input_dv,
			wr_addr => std_logic_vector(wr_addr),
			wr_data => input_data,

			rd_clk  => input_clk,
			rd_addr => std_logic_vector(rd_addr),
			rd_data => dlyd_data);

		lat_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 0 => 2))
		port map (
			clk   => input_clk,
			di(0) => input_dv,
			do(0) => dlyd_dv);

	end block;

	video_b : block
		signal wr_ena  : std_logic;
		signal wr_addr : signed(video_addr'length   downto 1) := (others => '1');
		signal rd_addr : unsigned(video_addr'length-1 downto 1);
		signal rd_data : std_logic_vector(video_data'range);
		signal video_offset : signed(wr_addr'range);
		alias  wraddr_msb  is wr_addr(wr_addr'left);
	begin

    	process (input_clk)
    		constant fifo_length : natural := 2**rd_addr'length;
    		variable delay : signed(time_offset'range);
    	begin
    		if rising_edge(input_clk) then
    			if (capture_rdy xor capture_req)='1' then
    				if input_dv='1' then
						if wraddr_msb='1' then
    						capture_rdy <= capture_req;
						elsif delay <= 0 then
							wr_addr <= wr_addr + 1;
						end if;
    					if delay >= 0 then
							delay := delay-1;
    					end if;
    				end if;
    			elsif video_vton='0' then
    				if trigger_shot='1' then
						if downsampling='0' then
							delay := shift_right(signed(time_offset),1);
						else
							delay := shift_right(signed(time_offset),0);
						end if;
						wr_addr <= (others => '0');
    					capture_req <= not capture_rdy;
    				end if;
    			end if;
    		end if;
    	end process;

		wr_ena  <= dlyd_dv and not wraddr_msb;
		mem_e : entity hdl4fpga.dpram
		generic map (
			synchronous_rdaddr => true,
			synchronous_rddata => true)
		port map (
			wr_clk  => input_clk,
			wr_addr => std_logic_vector(wr_addr(rd_addr'range)),
			wr_ena  => wr_ena,
			wr_data => dlyd_data,

			rd_clk  => video_clk,
			rd_addr => std_logic_vector(rd_addr),
			rd_data => rd_data);

		rd_addr <= 
			resize(shift_right(unsigned(video_addr), 1), rd_addr'length) when downsampling='0' else
			resize(shift_right(unsigned(video_addr), 0), rd_addr'length);

		process (video_clk)
			variable shr : unsigned(0 to 3*video_data'length/2-1);
			alias videoaddr_lsb  is video_addr(video_addr'right);
			alias timeoffset_lsb is time_offset(time_offset'right);
		begin
			if rising_edge(video_clk) then
				if downsampling='0' then
					if videoaddr_lsb/=timeoffset_lsb then
						shr(0 to video_data'length-1) := unsigned(rd_data);
					end if;
					shr := shr rol video_data'length/2;
					video_data <= std_logic_vector(shr(video_data'length/2 to 3*video_data'length/2-1));
				else
					video_data <= rd_data;
				end if;
			end if;
		end process;

		lat_e : entity hdl4fpga.latency 
		generic map (
			n => 1,
			d => (0 to 0 => 4))
		port map (
			clk   => video_clk,
			di(0) => video_frm,
			do(0) => video_dv);

	end block;

end;

architecture no_delayfifo of scopeio_capture is
	signal wr_ena       : std_logic;
	signal wr_addr      : signed(video_addr'length-1 downto 1) := to_signed(0, video_addr'length-1);
	signal wr_data      : std_logic_vector(input_data'range);
	signal rd_addr      : signed(video_addr'length-1 downto 1);
	signal rd_data      : std_logic_vector(video_data'range);
	signal video_offset : signed(wr_addr'range);
begin

	process (input_clk)
		constant fifo_length : natural := 2**rd_addr'length;
		variable delay  : signed(time_offset'range);
		variable offset : signed(video_offset'range);
		alias delay_lsbs is delay(video_addr'length-1 downto 0);
		alias delay_msbs is delay(delay'left downto delay_lsbs'left+1);
	begin
		if rising_edge(input_clk) then
			if (capture_rdy xor capture_req)='1' then
				if input_dv='1' then
					if delay <= 0 then
						video_offset <= offset;
						capture_rdy <= capture_req;
					else
						if delay >= fifo_length then
							offset := wr_addr;
						end if;
						delay := delay-1;
					end if;
				end if;
			elsif video_vton='0' then
				if trigger_shot='1' then
					delay := signed(time_offset);
					if downsampling='0' then 
						offset := wr_addr+resize(shift_right(delay,1) ,wr_addr'length);
					else
						offset := wr_addr+resize(shift_right(delay,0) ,wr_addr'length);
					end if;
					delay := delay + (fifo_length-1);
					capture_req  <= not capture_rdy;
				end if;
				offset := wr_addr;
			end if;
		end if;
	end process;

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				wr_addr <= wr_addr + 1;
			end if;
		end if;
	end process;

	wr_ena  <= input_dv and (capture_rdy xor capture_req);
	wr_data <= input_data;
	mem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => input_clk,
		wr_addr => std_logic_vector(wr_addr(rd_addr'range)),
		wr_ena  => wr_ena,
		wr_data => wr_data,

		rd_clk  => video_clk,
		rd_addr => std_logic_vector(rd_addr),
		rd_data => rd_data);

	rd_addr <= 
		signed(resize(shift_right(unsigned(video_addr), 1), rd_addr'length))+video_offset(rd_addr'range) when downsampling='0' else
		signed(resize(shift_right(unsigned(video_addr), 0), rd_addr'length))+video_offset(rd_addr'range);

	process (video_clk)
		alias  videoaddr_lsb is video_addr(video_addr'right);
		variable shr : unsigned(0 to 3*video_data'length/2-1);
	begin
		if rising_edge(video_clk) then
			if downsampling='0' then
				if videoaddr_lsb='0' then
					shr(0 to video_data'length-1) := unsigned(rd_data);
				end if;
				shr := shr rol video_data'length/2;
				video_data <= std_logic_vector(shr(video_data'length/2 to 3*video_data'length/2-1));
			else
				video_data <= rd_data;
			end if;
		end if;
	end process;

	lat_e : entity hdl4fpga.latency 
	generic map (
		n => 1,
		d => (0 to 0 => 4))
	port map (
		clk   => video_clk,
		di(0) => video_frm,
		do(0) => video_dv);


end;