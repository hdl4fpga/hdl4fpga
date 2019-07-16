-- AUTHOR=EMARD
-- LICENSE=GPL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_capture1shot is
	generic (
		deflicker              : boolean := true; -- complex deflickering calculation
		strobe                 : natural := 1     -- 2**n video frames frozen until auto re-arming trigger
	);
	port (
		input_clk              : in  std_logic;
		input_ena              : in  std_logic := '1'; -- for downsampling

		video_vton             : in  std_logic; -- video vertical ON = not(vertical_blank)
		trigger_freeze         : in  std_logic; -- user input
		trigger_shot           : in  std_logic; -- trigger level comparator

		storage_reset_addr     : out std_logic;
		storage_increment_addr : out std_logic;
		storage_mark_t0        : out std_logic;
		storage_write          : out std_logic;
		storage_addr           : in  std_logic_vector -- used for range
		-- "storage_addr" is used as input if deflicker = false
	);
end;

architecture beh of scopeio_capture1shot is
	signal last_wr_addr : unsigned(storage_addr'range);
	-- "C_samples_after_trigger" sets position
	-- of the triggering point in the storage buffer.
	-- By default it is set at center of the storage buffer
	-- > 2**(wr_addr'length-1) : record more data after trigger
	-- = 2**(wr_addr'length-1) : record same amount of data before and after trigger (default)
	-- < 2**(wr_addr'length-1) : record more data before trigger
	constant C_samples_after_trigger: integer range 0 to 2**(storage_addr'length)-1 := 2**(storage_addr'length-1); -- configure this
	-- calculate how many samples after the trigger:
	--constant C_samples_before_trigger: integer range 0 to 2**(storage_addr'length)-1 := 2**(storage_addr'length)-C_samples_after_trigger;
	constant C_wr_cntr_extra_bits : unsigned(0 to 1) := (others => '0');
	signal wr_cntr   : unsigned(0 to storage_addr'length+C_wr_cntr_extra_bits'length-1); -- counts down when trigger is armed, extra bits to adjust re-arming
	constant C_samples_after_trigger_unsigned : unsigned(0 to wr_cntr'length-2) := to_unsigned(C_samples_after_trigger, wr_cntr'length-1);
	constant C_rearm_wr_cntr_0: unsigned(storage_addr'range) := (others => '0'); -- default value for re-arming: full buffer length
	signal rearm_wr_cntr: unsigned(storage_addr'range) := C_rearm_wr_cntr_0; -- re-arming and deflickering
	signal sync_tf   : std_logic;
	signal sync_videofrm : std_logic;
	signal prev_sync_videofrm : std_logic;
	signal videofrm_without_trigger : unsigned(0 to strobe); -- counts video frames without trigger event before free shot triggering
	signal R_videofrm_until_trigger : unsigned(0 to strobe); -- nonzero if trigger is slower than video frame
	constant C_videofrm_0: unsigned(0 to strobe) := (others => '0'); -- first video frame without trigger
	constant C_videofrm_1: unsigned(0 to strobe) := (strobe => '1', others => '0'); -- first video frame without trigger
	constant C_videofrm_before_last: unsigned(0 to strobe) := (0 => '0', others => '1'); -- video frame before last without trigger
	signal prev_trigger_shot: std_logic; -- for rising edge detection
	signal R_ticks, R_prev_ticks, R_trigger_period: unsigned(storage_addr'range);
	signal S_trigger_edge: std_logic;
	signal S_rearm_condition: std_logic;
	signal R_storage_mark_t0: std_logic;
	signal R_trigger_captured: std_logic;
begin
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

	G_yes_deflicker: if deflicker generate
		-- predict value of "rearm_wr_cntr" in order to minimize flickering
		-- by overwriting waveform over the same values to the same locations in storage buffer.
		P_deflicker_predictor:
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
	end generate; -- G_yes_deflicker

	G_not_deflicker: if not deflicker generate
		-- similar as abuve but a LUT saver, traces will shake a bit
		rearm_wr_cntr <= unsigned(last_wr_addr);
		-- "rearm_wr_cntr" is valid for use only at trigger edge.

		G_strobe_0: if strobe = 0 generate
		S_rearm_condition <= '1' when videofrm_without_trigger(0) = '1' -- force re-arming at first frame without trigger
		                  or S_trigger_edge = '1'
		                  else '0';
		end generate;

		G_strobe_not_0: if strobe /= 0 generate
		S_rearm_condition <= '1' when videofrm_without_trigger(0 to 1) = "11" -- force re-arming at last frame without trigger
				  or (S_trigger_edge = '1' and R_videofrm_until_trigger /= C_videofrm_0) -- re-arm at trigger if trigger is slower than video frame
		                  -- or (S_trigger_edge = '1' and videofrm_without_trigger = C_videofrm_before_last) -- re-arm at trigger 1 frame before last frame
		                  else '0';
		end generate;
	end generate;

	P_rearm_and_capture:
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
						        -- NOTE: disable line which is updating "R_storage_mark_t0"
						        -- to check if trigger really hits the same data - then
						        -- the traces should be more-or-less X-stable.
							R_storage_mark_t0 <= '1';
							R_trigger_captured <= '1';
							R_videofrm_until_trigger <= videofrm_without_trigger;
							wr_cntr <= wr_cntr - 1; -- continue countdown
						end if;
					else -- regular countdown before and after trigger
						R_storage_mark_t0 <= '0';
						if input_ena = '1' then
							wr_cntr <= wr_cntr - 1;
						end if;
						-- at last trigger during writing, storage_addr will contain
						-- remainder value that can be used for deflickering
						-- in the next rearming. This is a LUT saver,
						-- traces will still shake a bit.
						if S_trigger_edge = '1' and input_ena = '1' then
							last_wr_addr <= unsigned(storage_addr);
						end if;
					end if;
				else -- wr_cntr(0)='1' storage is not armed (not recording data)
					R_storage_mark_t0 <= '0';
					R_trigger_captured <= '0';
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

	P_videoframe_counter:
	process(input_clk)
	begin
		if rising_edge(input_clk) then
			if R_trigger_captured = '1' then
				videofrm_without_trigger <= (others => '0');
			else
				if prev_sync_videofrm = '1' and sync_videofrm = '0' then
					if videofrm_without_trigger(0) = '0' then
						videofrm_without_trigger <= videofrm_without_trigger + 1;
					else
						videofrm_without_trigger <= (others => '1');
					end if;
				end if;
			end if;
		end if; -- rising_edge
	end process;

	-- output to storage module
	storage_reset_addr     <= wr_cntr(0);
	storage_increment_addr <= input_ena and not wr_cntr(1);
	--storage_mark_t0        <= '1' when S_trigger_edge = '1' and wr_cntr = '0' & C_samples_after_trigger_unsigned else '0';
	storage_mark_t0        <= R_storage_mark_t0; -- Same as above expr but with 1 clock latency. Latency compensated in storage with "align_to_grid".
	storage_write          <= '1' when input_ena = '1' and wr_cntr(C_wr_cntr_extra_bits'range) = C_wr_cntr_extra_bits else '0';
end;
