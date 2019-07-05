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

entity scopeio is
	generic (
		vlayout_id  : natural;
		axis_unit   : std_logic_vector := std_logic_vector(to_unsigned(25,5)); -- 25.0 each 128 samples

		C_experimental_trigger : boolean := false;

		inputs      : natural;
		vt_gains    : natural_vector := (
			 0 => 2**17/(2**(0+0)*5**(0+0)),  1 => 2**17/(2**(1+0)*5**(0+0)),  2 => 2**17/(2**(2+0)*5**(0+0)),  3 => 2**17/(2**(0+0)*5**(1+0)),
			 4 => 2**17/(2**(0+1)*5**(0+1)),  5 => 2**17/(2**(1+1)*5**(0+1)),  6 => 2**17/(2**(2+1)*5**(0+1)),  7 => 2**17/(2**(0+1)*5**(1+1)),
			 8 => 2**17/(2**(0+2)*5**(0+2)),  9 => 2**17/(2**(1+2)*5**(0+2)), 10 => 2**17/(2**(2+2)*5**(0+2)), 11 => 2**17/(2**(0+2)*5**(1+2)),
			12 => 2**17/(2**(0+3)*5**(0+3)), 13 => 2**17/(2**(1+3)*5**(0+3)), 14 => 2**17/(2**(2+3)*5**(0+3)), 15 => 2**17/(2**(0+3)*5**(1+3)));
		vt_factsyms : std_logic_vector := (0 to 0 => '0');
		vt_untsyms  : std_logic_vector := (0 to 0 => '0');

		hz_factors  : natural_vector := (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(1+0)*5**(0+0),  2 => 2**(2+0)*5**(0+0),  3 => 2**(0+0)*5**(1+0),
			 4 => 2**(0+1)*5**(0+1),  5 => 2**(1+1)*5**(0+1),  6 => 2**(2+1)*5**(0+1),  7 => 2**(0+1)*5**(1+1),
			 8 => 2**(0+2)*5**(0+2),  9 => 2**(1+2)*5**(0+2), 10 => 2**(2+2)*5**(0+2), 11 => 2**(0+2)*5**(1+2),
			12 => 2**(0+3)*5**(0+3), 13 => 2**(1+3)*5**(0+3), 14 => 2**(2+3)*5**(0+3), 15 => 2**(0+3)*5**(1+3));
		
		hz_factsyms : std_logic_vector := (0 to 0 => '0');
		hz_untsyms  : std_logic_vector := (0 to 0 => '0');

		max_pixelsize  : natural := 24;
		default_tracesfg : std_logic_vector := b"1_1_1";
		default_gridfg   : std_logic_vector := b"1_0_0";
		default_gridbg   : std_logic_vector := b"0_0_0";
		default_hzfg     : std_logic_vector := b"1_1_1";
		default_hzbg     : std_logic_vector := b"0_0_1";
		default_vtfg     : std_logic_vector := b"1_1_1";
		default_vtbg     : std_logic_vector := b"0_0_1";
		default_textbg   : std_logic_vector := b"0_0_0";
		default_sgmntbg  : std_logic_vector := b"0_1_1";
		default_bg       : std_logic_vector := b"1_1_1");
	port (
		si_clk      : in  std_logic := '-';
		si_frm      : in  std_logic := '0';
		si_irdy     : in  std_logic := '0';
		si_data     : in  std_logic_vector;
		so_clk      : in  std_logic := '-';
		so_frm      : out std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic := '0';
		so_data     : out std_logic_vector;

		input_clk   : in  std_logic;
		input_ena   : in  std_logic := '1';
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_pixel : out std_logic_vector;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);

	constant chanid_size  : natural := unsigned_num_bits(inputs-1);

end;

architecture beh of scopeio is


	constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant gainid_size : natural := unsigned_num_bits(vt_gains'length-1);

	signal video_hzsync       : std_logic;
	signal video_vtsync       : std_logic;
	signal video_vton         : std_logic;
	signal video_hzon         : std_logic;
	signal video_hzl          : std_logic;
	signal video_vld          : std_logic;
	signal video_vtcntr       : std_logic_vector(11-1 downto 0);
	signal video_hzcntr       : std_logic_vector(11-1 downto 0);

	signal video_io           : std_logic_vector(0 to 3-1);
	
	signal rgtr_id            : std_logic_vector(8-1 downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_data          : std_logic_vector(32-1 downto 0);

	signal ampsample_ena      : std_logic;
	signal ampsample_data     : std_logic_vector(0 to input_data'length-1);
	signal triggersample_ena  : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);


	signal resizedsample_ena  : std_logic;
	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_ena     : std_logic;
	signal downsample_data    : std_logic_vector(resizedsample_data'range);

	constant storage_size : natural := unsigned_num_bits(layout.num_of_segments*grid_width(layout)-1);
	signal storage_addr : std_logic_vector(0 to storage_size-1);
	signal storage_bsel   : std_logic_vector(0 to layout.num_of_segments-1);

	signal capture_addr   : std_logic_vector(storage_addr'range);
	signal scrolled_capture_addr   : std_logic_vector(storage_addr'range);
	signal trigger_shot   : std_logic;

	signal storage_data   : std_logic_vector(0 to inputs*storage_word'length-1);
	signal scope_color    : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_color    : std_logic_vector(video_pixel'length-1 downto 0);

	signal hz_segment     : std_logic_vector(13-1 downto 0);
	signal hz_offset      : std_logic_vector(hz_segment'range);
	signal hz_scale       : std_logic_vector(4-1 downto 0);
	signal hz_dv          : std_logic;
	signal vt_dv          : std_logic;
	signal vt_offsets     : std_logic_vector(inputs*(5+8)-1 downto 0);
	signal vt_chanid      : std_logic_vector(chanid_maxsize-1 downto 0);

	signal palette_dv     : std_logic;
	signal palette_id     : std_logic_vector(0 to unsigned_num_bits(max_inputs+9-1)-1);
	signal palette_color  : std_logic_vector(max_pixelsize-1 downto 0);

	signal gain_dv        : std_logic;
	signal gain_ids       : std_logic_vector(0 to inputs*gainid_size-1);

	signal trigger_dv     : std_logic;
	signal trigger_chanid : std_logic_vector(chanid_size-1 downto 0);
	signal trigger_edge   : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_level  : std_logic_vector(storage_word'range);

	signal pointer_dv     : std_logic;
	signal pointer_x      : std_logic_vector(video_hzcntr'range);
	signal pointer_y      : std_logic_vector(video_vtcntr'range);

	signal wu_frm         : std_logic;
	signal wu_irdy        : std_logic;
	signal wu_trdy        : std_logic;
	signal wu_unit        : std_logic_vector(4-1 downto 0);
	signal wu_neg         : std_logic;
	signal wu_sign        : std_logic;
	signal wu_align       : std_logic;
	signal wu_value       : std_logic_vector(4*4-1 downto 0);
	signal wu_format      : std_logic_vector(8*4-1 downto 0);

	signal scaler_sync    : std_logic;
begin

	assert inputs < max_inputs
		report "inputs greater than max_inputs"
		severity failure;

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	port map (
		sin_clk   => si_clk,
		sin_frm   => si_frm,
		sin_irdy  => si_irdy,
		sin_data  => si_data,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data);

	scopeio_rtgr_e : entity hdl4fpga.scopeio_rgtr
	generic map (
		inputs         => inputs)
	port map (
		clk            => si_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		hz_dv          => hz_dv,
		hz_scale       => hz_scale,
		hz_offset      => hz_offset,
		vt_dv          => vt_dv,
		vt_offsets     => vt_offsets,
		vt_chanid      => vt_chanid,
	
		pointer_dv     => pointer_dv,
		pointer_y      => pointer_y,
		pointer_x      => pointer_x,

		palette_dv     => palette_dv,
		palette_id     => palette_id,
		palette_color  => palette_color,

		gain_dv        => gain_dv,
		gain_ids       => gain_ids,

		trigger_dv     => trigger_dv,
		trigger_freeze => trigger_freeze,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge);
	
	amp_b : block
		constant sample_size : natural := input_data'length/inputs;
		signal output_ena    : std_logic_vector(0 to inputs-1);
	begin
		amp_g : for i in 0 to inputs-1 generate
			subtype sample_range is natural range i*sample_size to (i+1)*sample_size-1;

			signal input_sample : std_logic_vector(0 to sample_size-1);
			signal gain_id      : std_logic_vector(gainid_size-1 downto 0);
			signal gain_value   : std_logic_vector(18-1 downto 0);
		begin

			gain_id <= word2byte(gain_ids, i, gainid_size);
			input_sample <= word2byte(input_data, i, sample_size);
			amp_e : entity hdl4fpga.scopeio_amp
			generic map (
				gains => vt_gains)
			port map (
				input_clk     => input_clk,
				input_ena     => input_ena,
				input_sample  => input_sample,
				gain_id       => gain_id,
				output_ena    => output_ena(i),
				output_sample => ampsample_data(sample_range));

		end generate;

		ampsample_ena <= output_ena(0);
	end block;

	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	generic map (
		inputs => inputs)
	port map (
		input_clk      => input_clk,
		input_ena      => ampsample_ena,
		input_data     => ampsample_data,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge,
		trigger_shot   => trigger_shot,
		output_ena     => triggersample_ena,
		output_data    => triggersample_data);

	resize_p : process (triggersample_data)
		variable aux1 : unsigned(storage_word'length*inputs-1 downto 0);
		variable aux2 : unsigned(triggersample_data'length-1  downto 0);
	begin
		aux1 := (others => '-');
		aux2 := unsigned(triggersample_data);
		for i in 0 to inputs-1 loop
			aux1(storage_word'range) := aux2(storage_word'range);
			aux1 := aux1 rol storage_word'length;
			aux2 := aux2 rol triggersample_data'length/inputs;
		end loop;
		resizedsample_data <= std_logic_vector(aux1);
	end process;
	resizedsample_ena <= triggersample_ena;

	scaler_sync <= trigger_shot and not video_vton;
	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		factors => hz_factors)
	port map (
		factor_id    => hz_scale,
		scaler_sync  => scaler_sync,
		input_clk    => input_clk,
		input_dv     => resizedsample_ena,
		input_data   => resizedsample_data,
		output_dv    => downsample_ena,
		output_data  => downsample_data);

	G_not_experimental_trigger: if not C_experimental_trigger generate
	-- signals in MHz range: ok
	-- signals in kHz range: discontinuity around T=0
	storage_b : block

		signal wr_clk    : std_logic;
		signal wr_ena    : std_logic;
		signal wr_addr   : std_logic_vector(storage_addr'range);
		signal wr_cntr   : signed(0 to wr_addr'length+1);
		signal wr_data   : std_logic_vector(0 to storage_word'length*inputs-1);
		signal rd_clk    : std_logic;
		signal rd_addr   : std_logic_vector(wr_addr'range);
		signal rd_data   : std_logic_vector(wr_data'range);
		signal free_shot : std_logic;
		signal sync_tf   : std_logic;
		signal trigger_addr : std_logic_vector(storage_addr'range);
		signal hz_delay  : signed(hz_offset'length-1 downto 0);
		signal sync_videofrm : std_logic;
		signal prev_sync_videofrm : std_logic;
		constant C_auto_trigger_wait: natural := 0; -- wait 2**n video frames until free shot triggering
		signal videofrm_without_trigger : unsigned(0 to C_auto_trigger_wait); -- counts video frames without trigger event before free shot triggering

	begin

		wr_clk  <= input_clk;
		wr_ena  <= (not wr_cntr(0) or free_shot) and not sync_tf;
		wr_data <= downsample_data;

		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
				sync_tf <= trigger_freeze;
				sync_videofrm <= video_vton;
			end if;
		end process;

		hz_delay <= signed(hz_offset);
		rd_clk   <= video_clk;
		gen_addr_p : process (wr_clk)
		begin
			if rising_edge(wr_clk) then

--              ----------------
--				-- CALIBRATON --
--              ----------------
--
--				wr_data <= ('0','0', '0', '0', others => '1');
--				if wr_addr=std_logic_vector(to_unsigned(0,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1600,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1601,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				end if;
--				wr_data  <= std_logic_vector(resize(unsigned(wr_addr),wr_data'length));

				free_shot <= '0';
				if sync_videofrm='0' and trigger_shot='0' then
					free_shot <= '1';
				end if;

				if sync_tf='1' or wr_cntr(0)='0' then
					capture_addr <= std_logic_vector(signed(trigger_addr));
					if downsample_ena='1' then
						wr_cntr <= wr_cntr - 1;
					end if;
				elsif sync_videofrm='0' and trigger_shot='1' then -- here is wr_cntr(0)='1'
					capture_addr <= std_logic_vector(signed(wr_addr));
					wr_cntr      <= resize(hz_delay, wr_cntr'length) + (2**wr_addr'length-1);
					trigger_addr <= wr_addr;
				end if;
				if downsample_ena='1' then
					wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
				end if;
			end if;

		end process;

--		mem_e : entity hdl4fpga.bram(bram_true2p_2clk)    -- Tested for portabilty
		mem_e : entity hdl4fpga.bram(inference)           -- It's syntetized with less delay and smaller resources but it lacks testing:w for portabilty
		port map (
			clka  => wr_clk,
			addra => wr_addr,
			wea   => wr_ena,
			dia   => wr_data,
			doa   => rd_data,

			clkb  => rd_clk,
			addrb => storage_addr,
			dib   => rd_data,
			dob   => storage_data);

	end block;
	end generate; -- not experimental trigger

	G_yes_1shot_trigger: if C_experimental_trigger generate
	-- contains EMARD's experimental 1-shot trigger

	-- storage is a circular buffer and it must have
	-- discontinuity somewhere. This code keeps
	-- the discontinuity away from triggering point T=0.

	-- 1-shot trigger armed:
	-- record first part of the buffer (configurable size)
	-- then wait for trigger, keep recording.
	-- After trigger, do some more recording for the last
	-- part of the buffer and stop (freeze display, dis-arm trigger).
	-- When stopped, wait configurable number of video frames
	-- for the user to be able to see waveform and then
	-- re-arm 1-shot trigger.

	-- NOTE: during the period when 1-shot trigger is armed,
        -- storage continuously records data while waiting for trigger.
        -- Same memory currently recorded is at the same time displayed,
	-- so the traces may flicker or become dotted or dashed.
	-- This is considered as normal for now but can be improved.
	-- When display is frozen, it will display correct waveform.

	-- Triggering point T=0 can be placed at configurable position
	-- in the buffer.

	-- one-shot trigger states:
	-- state 0: decrement counter without recording while counter < buffer_length
	-- state 1: start recording before trigger (decrementing counter until counter = C_samples_after_trigger)
	-- state 2: keep recording indefinitely until trigger event (don't decrement counter while waiting for trigger)
	-- state 3: record after trigger, decrement counter until it wraps around to -1 and stop
	-- state 4: wait for re-arm (counter is at -1)
	--          re-armed by event, initializing counter to buffer length

	-- auto trigger is special case of 1-shot trigger
	-- which is re-armed at frame blank.
	-- optionally, N stable frames can be configured until next re-armong

	-- NOTE: flicker reduction:
	-- rearming time should be calculated precisely in advance
	-- so that when new storage recording run starts, it should overwrite
	-- new data exactly at the same buffer locations over the old data.
	-- For repeatable signals, old and new data are similar so this will
	-- reduce flickering if done right.

	-- TODO:
	-- [ ] external trigger, external re-arm

	storage_1shot_trig_b : block
		constant C_trigger_deflicker : boolean := true; -- complex deflickering calculation
		constant C_align_to_grid: integer := -1; -- aligns triggered edge of a squarewave with the grid

		signal wr_clk    : std_logic;
		signal wr_ena    : std_logic;
		signal wr_addr   : std_logic_vector(storage_addr'range); -- running only during write
		signal last_wr_addr: unsigned(wr_addr'range);
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
		signal wr_data   : std_logic_vector(0 to storage_word'length*inputs-1);
		signal rd_clk    : std_logic;
		signal rd_addr   : std_logic_vector(wr_addr'range);
		signal rd_data   : std_logic_vector(wr_data'range);
		signal sync_tf   : std_logic;
		signal sync_videofrm : std_logic;
		signal prev_sync_videofrm : std_logic;
		constant C_auto_trigger_wait: natural := 0; -- 2**n video frames frozen until auto re-arming trigger
		signal videofrm_without_trigger : unsigned(0 to C_auto_trigger_wait); -- counts video frames without trigger event before free shot triggering
		signal prev_trigger_shot: std_logic; -- for rising edge detection
		signal R_ticks, R_prev_ticks, R_trigger_period: unsigned(wr_addr'range);
		signal S_trigger_edge: std_logic;
		signal S_rearm_condition: std_logic;

	begin
		-- for BRAM memory
		wr_clk  <= input_clk;
		-- armed trigger needs to write storage only for
		-- last 1 full buffer run during wr_cntr(C_wr_cntr_extra_bits'range) = 0
		wr_ena  <= '1' when downsample_ena = '1' and wr_cntr(C_wr_cntr_extra_bits'range) = C_wr_cntr_extra_bits else '0';
		wr_data <= downsample_data;
		rd_clk  <= video_clk;

		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
				if wr_cntr(0) = '1' then -- storage is not armed
					wr_addr <= (others => '0'); -- reset address
				else
					if downsample_ena = '1' and wr_cntr(1) = '0' then -- runs address only when recording
						wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
					end if;
				end if;
			end if;
		end process;

		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
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
		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
				if downsample_ena = '1' then
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
					if downsample_ena = '1' then
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

		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
				if wr_cntr(0) = '0' then -- storage is armed: it is (or soon will be) recording data to memory
					if wr_cntr(1 to wr_cntr'length-1) = C_samples_after_trigger_unsigned then
						-- stop countdown, wait for rising edge of "trigger_shot" signal
						if S_trigger_edge = '1' then -- wait for the edge not level
							-- to reduce flicker of the trace displayed,
						        -- re-arming of the trigger should be
						        -- precisely timed, prediced in advance to
						        -- minimize changing of "capture_addr" here
						        -- NOTE: disable line which is updating "capture_addr"
						        -- to check if trigger really hits the same data - then
						        -- the traces should be more-or-less X-stable.
							capture_addr <= std_logic_vector(signed(wr_addr) + to_signed(C_align_to_grid, wr_addr'length)); -- mark triggering point in the buffer
							wr_cntr <= wr_cntr - 1; -- continue countdown
						end if;
					else -- regular countdown before and after trigger
						if downsample_ena = '1' then
							wr_cntr <= wr_cntr - 1;
						end if;
						-- at last trigger during writing,_wr_addr will contain
						-- remainder value that can be used for deflickering
						-- in the next rearming. This is a LUT saver,
						-- traces will still shake a bit.
						if S_trigger_edge = '1' and downsample_ena = '1' then
							last_wr_addr <= unsigned(wr_addr);
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

--		mem_e : entity hdl4fpga.bram(bram_true2p_2clk)    -- Tested for portabilty
		mem_e : entity hdl4fpga.bram(inference)           -- It's syntetized with less delay and smaller resources but it lacks testing:w for portabilty
		port map (
			clka  => wr_clk,
			addra => wr_addr,
			wea   => wr_ena,
			dia   => wr_data,
			doa   => rd_data,

			clkb  => rd_clk,
			addrb => storage_addr,
			dib   => rd_data,
			dob   => storage_data);

	end block;
	end generate; -- 1shot trigger

	-- allows horizontal scrolling of the waveform
	storage_horizontal_scroll_b: block
	begin
		process(input_clk)
		begin
			if rising_edge(input_clk) then
				scrolled_capture_addr <= std_logic_vector(signed(hz_offset(capture_addr'reverse_range)) + signed(capture_addr));
			end if;
		end process;
	end block;

	video_b : block

		constant storageaddr_latency : natural := 1;
		constant storagebram_latency : natural := 2;
		constant input_latency       : natural := storageaddr_latency+storagebram_latency;
		constant mainrgtrin_latency  : natural := 1;
		constant mainrgtrout_latency : natural := 1;
		constant mainrgtrio_latency  : natural := mainrgtrin_latency+mainrgtrout_latency;
		constant sgmntrgtrio_latency : natural := 2;
		constant segmment_latency    : natural := 5;
		constant palette_latency     : natural := 3;
		constant vgaio_latency       : natural := input_latency+mainrgtrio_latency+sgmntrgtrio_latency+segmment_latency+palette_latency;

		constant hztick_bits         : natural := unsigned_num_bits(8*axis_fontsize(layout)-1);

		signal trigger_dot   : std_logic;
		signal traces_dots   : std_logic_vector(0 to inputs-1);
		signal grid_dot      : std_logic;
		signal grid_bgon     : std_logic;
		signal hz_dot        : std_logic;
		signal hz_bgon       : std_logic;
		signal vt_dot        : std_logic;
		signal vt_bgon       : std_logic;
		signal text_bgon     : std_logic;
		signal sgmntbox_on   : std_logic;
		signal sgmntbox_bgon : std_logic;
		signal pointer_dot   : std_logic;
	begin
		formatu_e : entity hdl4fpga.scopeio_formatu
		port map (
			clk    => si_clk,
			frm    => wu_frm,
			irdy   => wu_irdy,
			trdy   => wu_trdy,
			float  => wu_value,
			width  => b"1000",
			sign   => wu_sign,
			neg    => wu_neg,
			unit   => wu_unit,
			align  => wu_align,
			prec   => b"1111",
			format => wu_format);

		video_e : entity hdl4fpga.video_sync
		generic map (
			mode => video_description(vlayout_id).mode_id)
		port map (
			video_clk    => video_clk,
			video_hzsync => video_hzsync,
			video_vtsync => video_vtsync,
			video_hzcntr => video_hzcntr,
			video_vtcntr => video_vtcntr,
			video_hzon   => video_hzon,
			video_vton   => video_vton);

		video_vld <= video_hzon and video_vton;

		vgaio_e : entity hdl4fpga.align
		generic map (
			n => video_io'length,
			d => (video_io'range => vgaio_latency))
		port map (
			clk   => video_clk,
			di(0) => video_hzsync,
			di(1) => video_vtsync,
			di(2) => video_vld,
			do    => video_io);

		graphics_b : block

			signal mainbox_xdiv     : std_logic_vector(0 to 2-1);
			signal mainbox_ydiv     : std_logic_vector(0 to 4-1);
			signal mainbox_xedge    : std_logic;
			signal mainbox_yedge    : std_logic;
			signal mainbox_nexty    : std_logic;
			signal mainbox_eox      : std_logic;
			signal mainbox_xon      : std_logic;
			signal mainbox_yon      : std_logic;

		begin

			mainlayout_e : entity hdl4fpga.videobox_layout
			generic map (
				x_edges => main_xedges(layout),
				y_edges => main_yedges(layout))
			port map (
				video_clk  => video_clk,
				video_x    => video_hzcntr,
				video_y    => video_vtcntr,
				video_xon  => video_hzon,
				video_yon  => video_vton,
				box_xedge  => mainbox_xedge,
				box_yedge  => mainbox_yedge,
				box_eox    => mainbox_eox,
				box_xon    => mainbox_xon,
				box_yon    => mainbox_yon,
				box_xdiv   => mainbox_xdiv,
				box_nexty  => mainbox_nexty,
				box_ydiv   => mainbox_ydiv);

			process (video_clk)
			begin
				if rising_edge(video_clk) then
					sgmntbox_on  <= '0';
					storage_bsel <= (others => '0');
					for i in 0 to layout.num_of_segments-1 loop
						if main_boxon(box_id => i, x_div => mainbox_xdiv, y_div => mainbox_ydiv, layout => layout)='1' then
							sgmntbox_on     <= mainbox_xon;
							storage_bsel(i) <= '1';
						end if;
					end loop;
				end if;
			end process;

			sgmntbox_b : block

				constant mainboxx_size : natural := unsigned_num_bits(sgmnt_width(layout)-1);
				constant mainboxy_size : natural := unsigned_num_bits(sgmnt_height(layout)-1);

				signal mainbox_x      : std_logic_vector(mainboxx_size-1 downto 0);
				signal mainbox_y      : std_logic_vector(mainboxy_size-1 downto 0);

				signal sgmntbox_y     : std_logic_vector(mainbox_y'range);
				signal sgmntbox_x     : std_logic_vector(mainbox_x'range);

				signal mainbox_vyon   : std_logic;
				signal mainbox_vxon   : std_logic;
				signal mainbox_vx     : std_logic_vector(mainboxx_size-1 downto 0);
				signal mainbox_vy     : std_logic_vector(mainboxy_size-1 downto 0);
				signal sgmntbox_xedge : std_logic;
				signal sgmntbox_yedge : std_logic;
				signal sgmntbox_xdiv  : std_logic_vector(0 to 3-1);
				signal sgmntbox_ydiv  : std_logic_vector(0 to 3-1);
				signal sgmntbox_xon   : std_logic;
				signal sgmntbox_yon   : std_logic;
				signal sgmntbox_eox   : std_logic;

				signal grid_on        : std_logic;
				signal hz_on          : std_logic;
				signal vt_on          : std_logic;
				signal text_on        : std_logic;

			begin

				mainbox_b : block
					signal xon   : std_logic;
					signal yon   : std_logic;
					signal eox   : std_logic;
					signal xedge : std_logic;
					signal yedge : std_logic;
					signal nexty : std_logic;
					signal x      : std_logic_vector(mainboxx_size-1 downto 0);
					signal y      : std_logic_vector(mainboxy_size-1 downto 0);
				begin 

					rgtrin_p : process (video_clk)
					begin
						if rising_edge(video_clk) then
							yon   <= mainbox_yon;
							eox   <= mainbox_eox;
							xedge <= mainbox_xedge;
							yedge <= mainbox_yedge;
							nexty <= mainbox_nexty;
						end if;
					end process;
				
					xon <= sgmntbox_on;
					videobox_e : entity hdl4fpga.videobox
					port map (
						video_clk => video_clk,
						video_xon => xon,
						video_yon => yon,
						video_eox => eox,
						box_xedge => xedge,
						box_yedge => yedge,
						box_x     => x,
						box_y     => y);

					rgtrout_p : process (video_clk)
						variable init_layout : std_logic;
					begin
						if rising_edge(video_clk) then
							mainbox_vxon <= xon;
							mainbox_vyon <= yon and not nexty;
							mainbox_vyon <= yon and not init_layout;
							mainbox_vx   <= x;
							mainbox_vy   <= y;
							init_layout := nexty;
						end if;
					end process;

				end block;

				sgmntlayout_b : block
				begin

					layout_e : entity hdl4fpga.videobox_layout
					generic map (
						x_edges   => sgmnt_xedges(layout),
						y_edges   => sgmnt_yedges(layout))
					port map (
						video_clk => video_clk,
						video_xon => mainbox_vxon,
						video_yon => mainbox_vyon,
						video_x   => mainbox_vx,
						video_y   => mainbox_vy,
						box_xon   => sgmntbox_xon,
						box_yon   => sgmntbox_yon,
						box_eox   => sgmntbox_eox,
						box_xedge => sgmntbox_xedge,
						box_yedge => sgmntbox_yedge,
						box_xdiv  => sgmntbox_xdiv,
						box_ydiv  => sgmntbox_ydiv);
				end block;

				sgmntbox_b : block
					signal xon   : std_logic;
					signal yon   : std_logic;
					signal eox   : std_logic;
					signal xedge : std_logic;
					signal yedge : std_logic;
					signal xdiv  : std_logic_vector(sgmntbox_xdiv'range);
					signal ydiv  : std_logic_vector(sgmntbox_ydiv'range);
					signal x     : std_logic_vector(sgmntbox_x'range);
					signal y     : std_logic_vector(sgmntbox_y'range);
					signal box_on : std_logic;
				begin

					rgtrin_p : process (video_clk)
					begin
						if rising_edge(video_clk) then
							xon   <= sgmntbox_xon;
							yon   <= sgmntbox_yon;
							eox   <= sgmntbox_eox;
							xedge <= sgmntbox_xedge;
							yedge <= sgmntbox_yedge;
							xdiv  <= sgmntbox_xdiv;
							ydiv  <= sgmntbox_ydiv;
						end if;
					end process;

					box_e : entity hdl4fpga.videobox
					port map (
						video_clk => video_clk,
						video_xon => xon,
						video_yon => yon,
						video_eox => eox,
						box_xedge => xedge,
						box_yedge => yedge,
						box_x     => x,
						box_y     => y);

					box_on <= xon and yon;
					rgtrout_p: process (video_clk)
						constant font_bits : natural := unsigned_num_bits(axis_fontsize(layout)-1);
						variable vt_mask : unsigned(x'range);
						variable hz_mask : unsigned(y'range);
					begin
						if rising_edge(video_clk) then
							vt_mask := unsigned(x) srl font_bits;
							if vtaxis_width(layout)=0  then
								if vtaxis_tickrotate(layout)=ccw90 or vtaxis_tickrotate(layout)=ccw270 then
									vt_on <= setif(vt_mask=(vt_mask'range => '0')) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								else
									vt_on <= setif(vt_mask < 6) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								end if;
							else
								vt_on <= sgmnt_boxon(box_id => vtaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							end if;
							hz_mask := unsigned(y) srl font_bits;
							if hzaxis_height(layout)=0  then
								hz_on <= setif((hz_mask'range => '0')=hz_mask) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							else
								hz_on <= sgmnt_boxon(box_id => hzaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							end if;
							grid_on    <= sgmnt_boxon(box_id => grid_boxid,   x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							text_on    <= sgmnt_boxon(box_id => text_boxid,   x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							sgmntbox_x <= x;
							sgmntbox_y <= y;
						end if;
					end process;
				end block;

				storage_addr_p : process (video_clk)
					variable base : unsigned(0 to storage_addr'length-1);
				begin
					if rising_edge(video_clk) then
						base := (others => '0');
						for i in 0 to layout.num_of_segments-1 loop
							if storage_bsel(i)='1' then
								base := base or to_unsigned((grid_width(layout)-grid_width(layout) mod grid_divisionsize(layout))*i, base'length);
							end if;
						end loop;
                                            
						storage_addr <= std_logic_vector(base + resize(unsigned(sgmntbox_x), storage_addr'length) + unsigned(scrolled_capture_addr));
						hz_segment   <= std_logic_vector(base + resize(unsigned(hz_offset(axisx_backscale+hztick_bits-1 downto 0)), hz_segment'length));
                                                           
					end if;
				end process;

				scopeio_segment_e : entity hdl4fpga.scopeio_segment
				generic map (
					input_latency => input_latency,
					latency       => segmment_latency+input_latency,
					inputs        => inputs,
					axis_unit     => axis_unit,
					layout        => layout)
				port map (
					in_clk        => si_clk,

					wu_frm        => wu_frm ,
					wu_irdy       => wu_irdy,
					wu_trdy       => wu_trdy,
					wu_unit       => wu_unit,
					wu_neg        => wu_neg,
					wu_sign       => wu_sign,
					wu_align      => wu_align,
					wu_value      => wu_value,
					wu_format     => wu_format,

					hz_dv         => hz_dv,
					hz_scale      => hz_scale,
					hz_base       => hz_offset(hz_offset'left downto axisx_backscale+hztick_bits),
					hz_offset     => hz_segment,

					gain_dv       => gain_dv,
					gain_ids      => gain_ids,
					vt_dv         => vt_dv,
					vt_chanid     => vt_chanid,
					vt_offsets    => vt_offsets,

					video_clk     => video_clk,
					x             => sgmntbox_x,
					y             => sgmntbox_y,

					hz_on         => hz_on,
					vt_on         => vt_on,
					grid_on       => grid_on,

					samples       => storage_data,
					trigger_level => trigger_level,
					grid_dot      => grid_dot,
					hz_dot        => hz_dot,
					vt_dot        => vt_dot,
					trigger_dot   => trigger_dot,
					traces_dots   => traces_dots);

				bg_e : entity hdl4fpga.align
				generic map (
					n => 5,
					d => (
						0 to 4-1 => input_latency+segmment_latency,
						4        => input_latency+segmment_latency+mainrgtrout_latency+sgmntrgtrio_latency))
				port map (
					clk => video_clk,
					di(0) => grid_on,
					di(1) => hz_on,
					di(2) => vt_on,
					di(3) => text_on,
					di(4) => sgmntbox_on,
					do(0) => grid_bgon,
					do(1) => hz_bgon,
					do(2) => vt_bgon,
					do(3) => text_bgon,
					do(4) => sgmntbox_bgon);

			end block;

		end block;

		scopeio_palette_e : entity hdl4fpga.scopeio_palette
		generic map (
			default_tracesfg => default_tracesfg,
			default_gridfg   => default_gridfg, 
			default_gridbg   => default_gridbg, 
			default_hzfg     => default_hzfg,
			default_hzbg     => default_hzbg, 
			default_vtfg     => default_vtfg,
			default_vtbg     => default_vtbg, 
			default_textbg   => default_textbg, 
			default_sgmntbg  => default_sgmntbg, 
			default_bg       => default_bg)
		port map (
			wr_clk           => si_clk,
			wr_dv            => palette_dv,
			wr_palette       => palette_id,
			wr_color         => palette_color,
			video_clk        => video_clk,
			traces_dots      => traces_dots, 
			trigger_dot      => trigger_dot,
			trigger_chanid   => trigger_chanid,
			grid_dot         => grid_dot,
			grid_bgon        => grid_bgon,
			hz_dot           => hz_dot,
			hz_bgon          => hz_bgon,
			vt_dot           => vt_dot,
			vt_bgon          => vt_bgon,
			text_bgon        => text_bgon,
			sgmnt_bgon       => sgmntbox_bgon,
			video_color      => scope_color);

		scopeio_pointer_e : entity hdl4fpga.scopeio_pointer
		generic map (
			latency => vgaio_latency)
		port map (
			video_clk    => video_clk,
			pointer_x    => pointer_x,
			pointer_y    => pointer_y,
			video_hzcntr => video_hzcntr,
			video_vtcntr => video_vtcntr,
			video_dot    => pointer_dot);

		video_color <= scope_color or (video_color'range => pointer_dot);
	end block;


	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
