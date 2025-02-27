-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

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
		trigger_mode : in  std_logic_vector(0 to 2-1) := "00";
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
	constant bram_latency : natural := 2;
	signal dlyd_dv    : std_logic;
	signal dlyd_data  : std_logic_vector(video_data'range);
	signal delay      : signed(time_offset'range);
	signal odd        : std_logic := '0';

begin
 
	delay <= 
		shift_right(signed(time_offset)+bram_latency,1) when downsampling='0' else
		shift_right(signed(time_offset)+bram_latency,0);

	delayed_b : block
		signal wr_addr : signed(unsigned_num_bits(max_pretrigger-1)-1 downto 0) := (others => '0'); -- Debug purpose
		signal rd_addr : signed(wr_addr'range);
	begin

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					wr_addr <= wr_addr + 1;
					if signed(time_offset) < 0  then
					    rd_addr <= wr_addr + resize(delay, rd_addr'length);
					else 
						rd_addr <= wr_addr;
					end if;
				end if;
			end if;
		end process;

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
			d => (0 to 0 => bram_latency+1))
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
		signal frm_req : std_logic;
		signal frm_rdy : std_logic;
	begin

    	process (input_clk)
    		constant fifo_length : natural := 2**rd_addr'length;
    		variable discard : signed(time_offset'range);
    	begin
    		if rising_edge(input_clk) then
    			if (capture_rdy xor capture_req)='1' then
    				if dlyd_dv='1' then
						if wraddr_msb='1' then
							frm_req <= not frm_rdy;
    						capture_rdy <= capture_req;
						elsif discard <= 0 then
							wr_addr <= wr_addr + 1;
						end if;
    					if discard >= 0 then
							discard := discard-1;
    					end if;
    				end if;
    			else
					if downsampling='0' then
						discard := delay;
					else
						discard := delay;
					end if;

					case trigger_mode is
					when "00" => -- NORM+FREE
						if (frm_req xor frm_rdy)='0' then
							if video_vton='0' then
								if trigger_shot='1' then
									wr_addr <= (others => '0');
									capture_req <= not capture_rdy;
								end if;
							else
								wr_addr <= (others => '0');
								capture_req <= not capture_rdy;
							end if;
						end if;
						odd <= dlyd_dv;
					when "01" => -- NORM
						if (frm_req xor frm_rdy)='0' then
							if trigger_shot='1' then
								wr_addr <= (others => '0');
								capture_req <= not capture_rdy;
							end if;
    					end if;
						odd <= dlyd_dv;
					when others =>
					end case;
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
					if videoaddr_lsb/=(timeoffset_lsb xor odd) then
						shr(0 to video_data'length-1) := unsigned(rd_data);
					end if;
					shr := shr rol video_data'length/2;
					video_data <= std_logic_vector(shr(video_data'length/2 to 3*video_data'length/2-1));
				else
					video_data <= rd_data;
				end if;
			end if;
		end process;

		process (video_clk)
			type states is (s_idle, s_videooff, s_videoon);
			variable state : states;
		begin
			if rising_edge(video_clk) then
				case state is
				when s_idle =>
					if (frm_rdy xor frm_req)='1' then
						if video_vton='0' then
							state := s_videooff;
						end if;
					end if;
				when s_videooff =>
					if video_vton='1' then
						state := s_videoon;
					end if;
				when s_videoon =>
					if video_vton='0' then
						frm_rdy <= frm_req;
						state := s_idle;
					end if;
				end case;
			end if;
		end process;

		lat_e : entity hdl4fpga.latency 
		generic map (
			n => 1,
			d => (0 to 0 => bram_latency+2))
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


