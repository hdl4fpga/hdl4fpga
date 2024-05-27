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

entity scopeio_tds is
	generic (
		inputs           : natural;
		time_factors     : natural_vector;
		storageword_size : natural);
	port (
		rgtr_clk         : in  std_logic;
		rgtr_dv          : in  std_logic;
		rgtr_id          : in  std_logic_vector(8-1 downto 0);
		rgtr_data        : in  std_logic_vector;

		input_clk        : in  std_logic;
		input_dv         : in  std_logic;
		input_data       : in  std_logic_vector;
		time_scale       : in  std_logic_vector;
		time_offset      : in  std_logic_vector;
		trigger_freeze   : buffer std_logic;
		video_clk        : in  std_logic;
		video_vton       : in  std_logic;
		video_frm        : in  std_logic;
		video_addr       : in  std_logic_vector;
		video_dv         : out std_logic;
		video_data       : out std_logic_vector);

	constant chanid_bits : natural := unsigned_num_bits(inputs-1);

end;

architecture mix of scopeio_tds is

	subtype storage_word is std_logic_vector(storageword_size-1 downto 0);

	signal triggersample_dv   : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);
	signal trigger_shot       : std_logic;

	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_oshot   : std_logic;
	signal downsample_ishot   : std_logic;
	signal downsample_a0      : std_logic;
	signal downsample_dv      : std_logic;
	signal downsampling       : std_logic;
	signal downsample_data    : std_logic_vector(0 to 2*resizedsample_data'length-1);

	signal capture_shot       : std_logic;
	signal capture_end        : std_logic;

	signal trigger_dv         : std_logic;
	signal trigger_mode       : std_logic_vector(0 to 2-1);
	signal trigger_slope      : std_logic;
	signal trigger_oneshot    : std_logic;
	signal trigger_chanid     : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_level      : std_logic_vector(storage_word'range);

begin

	scopeio_rtgrtrigger_e : entity hdl4fpga.scopeio_rgtrtrigger
	port map (
		rgtr_clk        => rgtr_clk,
		rgtr_dv         => rgtr_dv,
		rgtr_id         => rgtr_id,
		rgtr_data       => rgtr_data,

		trigger_dv      => trigger_dv,
		trigger_freeze  => trigger_freeze,
		trigger_chanid  => trigger_chanid,
		trigger_level   => trigger_level,
		trigger_oneshot => trigger_oneshot,
		trigger_slope   => trigger_slope);
		
	trigger_mode(0) <= trigger_freeze;
	trigger_mode(1) <= trigger_oneshot;

	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	generic map (
		inputs => inputs)
	port map (
		input_clk      => input_clk,
		input_dv       => input_dv,
		input_data     => input_data,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_slope  => trigger_slope,
--		trigger_chanid => "0",             -- Debug purpose
--		trigger_level  => b"11_1110",      -- Debug purpose
--		trigger_slope  => '1',             -- Debug purpose
		trigger_shot   => trigger_shot,
		output_dv      => triggersample_dv,
		output_data    => triggersample_data);

	scopeio_resize_e : entity hdl4fpga.scopeio_resize
	generic map (
		inputs => inputs)
	port map (
		input_data  => triggersample_data,
		output_data => resizedsample_data);

	triggers_modes_b : block
		signal noshot : std_logic;
		signal vton   : std_logic;
		signal vtoff  : std_logic;
		signal edge   : std_logic;
	begin
		process (video_clk)
		begin
			if rising_edge(video_clk) then
				if video_vton='1' then
					vton <= '1';
				elsif vtoff='1' then
					vton <= '0';
				end if;
			end if;
		end process;

--		process (input_clk)
--		begin
--			if rising_edge(input_clk) then
--				if downsample_dv='1' then
--					if vtoff='1' then
--						if downsample_oshot='1' then
--							noshot <= '0';
--						end if;
--					elsif edge='0' then
--						if downsample_oshot='1' then
--							noshot <= '0';
--						end if;
--					else
--						noshot <= not downsample_oshot and capture_end;
--					end if;
--
--					if vton='0' then
--						vtoff <= '0';
--					elsif vton='1' then
--						vtoff <= '1';
--					end if;
--					edge <= vtoff;
--				end if;
--			end if;
--		end process;

		process (input_clk)
		begin
			if rising_edge(input_clk) then
				if triggersample_dv='1' then
					if vtoff='1' then
						if trigger_shot='1' then
							noshot <= '0';
						end if;
					elsif edge='0' then
						if trigger_shot='1' then
							noshot <= '0';
						end if;
					elsif noshot='0' then
						noshot <= not trigger_shot and capture_end;
					end if;

					if vton='0' then
						vtoff <= '0';
					elsif vton='1' then
						vtoff <= '1';
					end if;
					edge <= vtoff;
				end if;
			end if;
		end process;

		process (input_clk, capture_end, trigger_mode, downsample_oshot, noshot)
			variable req  : std_logic;
			variable rdy  : std_logic;
			variable shot : std_logic;
		begin
			sm : if rising_edge(input_clk) then
				case trigger_mode is
				when "11" =>
					if trigger_dv='1' then
						req  := '1';
						rdy  := '0';
						shot := '0';
					elsif rdy='1' then
						if capture_end='0' then
							req  := '0';
							rdy  := '0';
							shot :='0';
						end if;
					elsif req='1' then
						if capture_end='1' then
							if downsample_oshot='1' then
								rdy  := '1';
								shot := '1';
							end if;
						end if;
					end if;
				when others =>
					req := '0';
				end case;
			end if;

			case trigger_mode is
			when "00" => -- Normal + Free
				if downsample_oshot='1' then
					capture_shot <= capture_end;
				elsif noshot='1' then
					capture_shot <= capture_end;
				else
					capture_shot <= '0';
				end if;
			when "01" => -- Normal
				if downsample_oshot='1' then
					capture_shot <= capture_end;
				else
					capture_shot <= '0';
				end if;
			when "10" => -- Freeze
				capture_shot <= '0';
			when "11" => -- One shot
				if shot='0' then
					capture_shot <= '0';
				elsif downsample_oshot='1' then
					capture_shot <= capture_end;
				else
					capture_shot <= '0';
				end if;
			when others =>
				capture_shot <= '-';
			end case;
				
		end process;

	end block;

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		inputs  => inputs,
		factors => time_factors)
	port map (
		factor_id     => time_scale,
--		factor_id     => b"0000",  --Debug purpose
		input_clk     => input_clk,
		input_dv      => triggersample_dv,
		input_shot    => downsample_ishot,
		input_data    => resizedsample_data,
		downsampling  => downsampling,
		output_dv     => downsample_dv,
		output_shot   => downsample_oshot,
		output_shota0 => downsample_a0,
		output_data   => downsample_data);

	downsample_ishot <= capture_end and trigger_shot;
	scopeio_capture_e : entity hdl4fpga.scopeio_capture
	port map (
		rgtr_clk     => rgtr_clk,
		input_clk    => input_clk,
		capture_shot => capture_shot,
		capture_a0   => downsample_a0,
		capture_end  => capture_end,
		input_dv     => downsample_dv,
		input_data   => downsample_data,
		time_offset  => time_offset,
--		input_delay  => b"00_0000_0000_0000",  --Debug purpose

		downsampling => downsampling,
		video_clk    => video_clk,
		video_frm    => video_frm,
		video_vton   => video_vton,
		video_addr   => video_addr,
		video_dv     => video_dv,
		video_data   => video_data);

end;
