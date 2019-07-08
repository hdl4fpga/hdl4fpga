--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--   EMARD                                                                    --
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

entity scopeio_capture1shot is
	port (
		input_clk     : in  std_logic;
		capture_req   : in  std_logic;
		capture_rdy   : out std_logic;
		input_ena     : in  std_logic := '1';
		input_data    : in  std_logic_vector;
		input_delay   : in  std_logic_vector; --FIXME: horizontal scrolling dosen't belong to storage module
		video_vton    : in  std_logic;
		trigger_freeze: in  std_logic;
		trigger_shot  : in  std_logic;

		captured_clk  : in  std_logic;
		captured_addr : in  std_logic_vector;
		captured_data : out std_logic_vector;
		captured_vld  : out std_logic);
end;

architecture beh of scopeio_capture1shot is
	constant C_trigger_deflicker : boolean := true; -- complex deflickering calculation

	signal t0_addr      : unsigned(captured_addr'range);
	signal scrolled_addr: unsigned(captured_addr'range);
	signal rd_addr      : unsigned(captured_addr'range);
	signal wr_addr      : unsigned(captured_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(input_data'range);

	--8<-----------------------------------------------
	-- ***** EMARD added for 1-shot function *****
	signal last_wr_addr : unsigned(captured_addr'range);
	-- "C_samples_after_trigger" sets position
	-- of the triggering point in the storage buffer.
	-- By default it is set at center of the storage buffer
	-- > 2**(wr_addr'length-1) : record more data after trigger
	-- = 2**(wr_addr'length-1) : record same amount of data before and after trigger (default)
	-- < 2**(wr_addr'length-1) : record more data before trigger
	constant C_samples_after_trigger: integer range 0 to 2**(wr_addr'length)-1 := 2**(wr_addr'length-1); -- configure this
	-- calculate how many samples after the trigger:
	--constant C_samples_before_trigger: integer range 0 to 2**(wr_addr'length)-1 := 2**(wr_addr'length)-C_samples_after_trigger;
	constant C_wr_cntr_extra_bits : unsigned(0 to 1) := (others => '0');
	signal wr_cntr   : unsigned(0 to wr_addr'length+C_wr_cntr_extra_bits'length-1); -- counts down when trigger is armed, extra bits to adjust re-arming
	constant C_samples_after_trigger_unsigned : unsigned(0 to wr_cntr'length-2) := to_unsigned(C_samples_after_trigger, wr_cntr'length-1);
	constant C_rearm_wr_cntr_0: unsigned(wr_addr'range) := (others => '0'); -- default value for re-arming: full buffer length
	signal rearm_wr_cntr: unsigned(wr_addr'range) := C_rearm_wr_cntr_0; -- re-arming and deflickering
	signal sync_tf   : std_logic;
	signal sync_videofrm : std_logic;
	signal prev_sync_videofrm : std_logic;
	constant C_auto_trigger_wait: natural := 0; -- 2**n video frames frozen until auto re-arming trigger
	signal videofrm_without_trigger : unsigned(0 to C_auto_trigger_wait); -- counts video frames without trigger event before free shot triggering
	signal prev_trigger_shot: std_logic; -- for rising edge detection
	signal R_ticks, R_prev_ticks, R_trigger_period: unsigned(wr_addr'range);
	signal S_trigger_edge: std_logic;
	signal S_rearm_condition: std_logic;
	--8<---------------------------------------------------------------------
begin
	process(input_clk)
	begin
		if rising_edge(input_clk) then
			if wr_cntr(0) = '1' then -- storage is not armed
				wr_addr <= (others => '0'); -- reset address
			else
				if input_ena = '1' and wr_cntr(1) = '0' then -- runs address only when recording
					wr_addr <= wr_addr + 1;
				end if;
			end if;
		end if;
	end process;

	process(input_clk)
	begin
		if rising_edge(input_clk) then
			sync_tf <= trigger_freeze;
			prev_sync_videofrm <= sync_videofrm;
			sync_videofrm <= video_vton;
			prev_trigger_shot <= trigger_shot;
		end if;
	end process;
	S_trigger_edge <= '1' when prev_trigger_shot = '0' and trigger_shot = '1' else '0';

	G_yes_trigger_deflicker: if C_trigger_deflicker generate
		-- predict value of "rearm_wr_cntr" in order to minimize flickering
		-- by overwriting waveform over the same values to the same locations in storage buffer.
		process(input_clk)
		begin
			if rising_edge(input_clk) then
				if input_ena = '1' then
					-- runs always to measure the period between triggers
					R_ticks <= R_ticks + 1;
				end if;
				if S_trigger_edge = '1' then -- if rising edge of "trigger_shot"
					--8<------- it works somehow when "if" code is deleted, but not as good :)
					if rearm_wr_cntr(0) = '0' then
						rearm_wr_cntr <= rearm_wr_cntr + R_trigger_period;
					else -- high bit set, we have remainder in lower bits
						rearm_wr_cntr <= to_unsigned(C_samples_after_trigger-1, rearm_wr_cntr'length); -- use C_samples_after_trigger-1 if decrementing rearm_wr_cntr
					end if;
					--8<-------
					R_trigger_period <= R_ticks - R_prev_ticks; -- measures trigger period
					R_prev_ticks <= R_ticks;
				else -- not trigger edge, update rearm_wr_cntr as time passes
					-- more LUTs for less flickering
					if input_ena = '1' then
						if rearm_wr_cntr = C_rearm_wr_cntr_0 then -- C_rearm_wr_cntr_0 = 0
							rearm_wr_cntr <= R_trigger_period - 1; -- wraparound over the mesured period
						else
							rearm_wr_cntr <= rearm_wr_cntr - 1; -- decrement as time passes
						end if;
					end if;
				end if;
				-- TODO: if too many frames pass without trigger,
				-- revert to default value:
				-- rearm_wr_cntr <= C_rearm_wr_cntr_0;
				-- this has the fastest possible visual response
				-- for signal that doesn't trigger
			end if;
		end process;
		-- "rearm_wr_cntr" is constantly updated to a valid value
		-- so trigger can be re-armed at any time
		S_rearm_condition <= videofrm_without_trigger(0);
	end generate; -- G_yes_trigger_deflicker

	G_not_trigger_deflicker: if not C_trigger_deflicker generate
		-- similar as abuve but a LUT saver, traces will shake a bit
		rearm_wr_cntr <= unsigned(last_wr_addr);
		-- "rearm_wr_cntr" is valid for use only at trigger edge.
		S_rearm_condition <= videofrm_without_trigger(0) or S_trigger_edge;
	end generate;

	process(input_clk)
	begin
		if rising_edge(input_clk) then
				if wr_cntr(0) = '0' then -- storage is armed: it is (or soon will be) recording data to memory
					if wr_cntr(1 to wr_cntr'length-1) = C_samples_after_trigger_unsigned then
						-- stop countdown, wait for rising edge of "trigger_shot" signal
						if S_trigger_edge = '1' then -- wait for the edge not level
							-- to reduce flicker of the trace displayed,
						        -- re-arming of the trigger should be
						        -- precisely timed, prediced in advance to
						        -- minimize changing of "t0_addr" here
						        -- NOTE: disable line which is updating "t0_addr"
						        -- to check if trigger really hits the same data - then
						        -- the traces should be more-or-less X-stable.
							t0_addr <= unsigned(wr_addr); -- mark triggering point in the buffer
							wr_cntr <= wr_cntr - 1; -- continue countdown
						end if;
					else -- regular countdown before and after trigger
						if input_ena = '1' then
							wr_cntr <= wr_cntr - 1;
						end if;
						-- at last trigger during writing,_wr_addr will contain
						-- remainder value that can be used for deflickering
						-- in the next rearming. This is a LUT saver,
						-- traces will still shake a bit.
						if S_trigger_edge = '1' and input_ena = '1' then
							last_wr_addr <= wr_addr;
						end if;
					end if;
					-- reset frame counter for temporary
					-- freezing display after the trigger
					videofrm_without_trigger <= (others => '0');
				else -- wr_cntr(0)='1' storage is not armed (not recording data)
					-- count configurable number of video frames
					-- before re-arming the trigger
					if prev_sync_videofrm = '1' and sync_videofrm = '0' then
						if videofrm_without_trigger(0) = '0' then
							videofrm_without_trigger <= videofrm_without_trigger + 1;
						end if;
					end if;
					-- in auto trig mode, wait a frame or more
					-- for user to view temporary frozen display and then re-arm
					if sync_tf = '0' then -- if not frozen
						-- re-arm, initialize counter for at least full buffer length countdown
						-- or more as required for deflickering
						if S_rearm_condition = '1' then -- use this if not decrementing rearm_wr_addr
							wr_cntr <= "01" & rearm_wr_cntr;
						end if;
					end if; -- re-arming the storage
				end if; -- storage is (not) armed
		end if; -- rising_edge
	end process;

	wr_ena  <= '1' when input_ena = '1' and wr_cntr(C_wr_cntr_extra_bits'range) = C_wr_cntr_extra_bits else '0';

	-- "input_delay" is horizontal scrolling offset, requested by display system
	-- Latency is allowed so we offload arithmetic stage with register:
	P_horizontal_scroll:
	process(input_clk)
	begin
		if rising_edge(input_clk) then
			scrolled_addr <= t0_addr + resize(unsigned(input_delay),scrolled_addr'length);
		end if; -- rising_edge
	end process;

	-- "scrolled_addr" is triggering point scrolled by "input_delay".
	-- "captured_addr" is addr for drawing traces, requested by display system
	-- No latency is allowed for "captured_addr" so combinatorial logic here:
	rd_addr <= scrolled_addr + unsigned(captured_addr);

	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => input_clk,
		addra => std_logic_vector(wr_addr),
		wea   => wr_ena,
		dia   => input_data,
		doa   => null_data,

		clkb  => captured_clk,
		addrb => std_logic_vector(rd_addr),
		dib   => null_data,
		dob   => captured_data);

end;
