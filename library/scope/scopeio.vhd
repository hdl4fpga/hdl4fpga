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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.jso.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio is
	generic (
		videotiming_id : videotiming_ids;
		modeline       : natural_vector(0 to 9-1) := (others => 0);
		width          : natural         := 0;
		height         : natural         := 0;
		fps            : real            := 0.0;
		pclk           : real            := 0.0;
		layout         : string;
		max_delay      : natural         := 2**14;
		vt_steps       : real_vector     := (1 to 0 => 0.0);
		hz_step        : real            := 0.0;
		min_storage    : natural         := 256; -- samples, storage size will be equal or larger than this

		inputs         : natural;

		vt_gains       : natural_vector := (
			 0 => 2**17/(2**(0+0)*5**(0+0)),  1 => 2**17/(2**(1+0)*5**(0+0)),  2 => 2**17/(2**(2+0)*5**(0+0)),  3 => 2**17/(2**(0+0)*5**(1+0)),
			 4 => 2**17/(2**(0+1)*5**(0+1)),  5 => 2**17/(2**(1+1)*5**(0+1)),  6 => 2**17/(2**(2+1)*5**(0+1)),  7 => 2**17/(2**(0+1)*5**(1+1)),
			 8 => 2**17/(2**(0+2)*5**(0+2)),  9 => 2**17/(2**(1+2)*5**(0+2)), 10 => 2**17/(2**(2+2)*5**(0+2)), 11 => 2**17/(2**(0+2)*5**(1+2)),
			12 => 2**17/(2**(0+3)*5**(0+3)), 13 => 2**17/(2**(1+3)*5**(0+3)), 14 => 2**17/(2**(2+3)*5**(0+3)), 15 => 2**17/(2**(0+3)*5**(1+3)));

		hz_factors     : natural_vector := (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(1+0)*5**(0+0),  2 => 2**(2+0)*5**(0+0),  3 => 2**(0+0)*5**(1+0),
			 4 => 2**(0+1)*5**(0+1),  5 => 2**(1+1)*5**(0+1),  6 => 2**(2+1)*5**(0+1),  7 => 2**(0+1)*5**(1+1),
			 8 => 2**(0+2)*5**(0+2),  9 => 2**(1+2)*5**(0+2), 10 => 2**(2+2)*5**(0+2), 11 => 2**(0+2)*5**(1+2),
			12 => 2**(0+3)*5**(0+3), 13 => 2**(1+3)*5**(0+3), 14 => 2**(2+3)*5**(0+3), 15 => 2**(0+3)*5**(1+3));
		
		input_names      : tag_vector := (1 to 0 => notext));
	port (
		tp               : out std_logic_vector(1 to 32);
		sio_clk          : in  std_logic := '-';
		si_frm           : in  std_logic := '0';
		si_irdy          : in  std_logic := '0';
		si_data          : in  std_logic_vector;
		so_clk           : in  std_logic := '-';
		so_frm           : out std_logic;
		so_irdy          : out std_logic;
		so_trdy          : in  std_logic := '0';
		so_data          : out std_logic_vector;

		input_clk        : in  std_logic;
		input_ena        : in  std_logic := '1';
		input_data       : in  std_logic_vector;
		video_clk        : in  std_logic;
		extern_video     : in  std_logic := '0';
		extern_videohzsync : in  std_logic := '-';
		extern_videovtsync : in  std_logic := '-';
		extern_videoblankn : in  std_logic := '-';
		video_pixel      : out std_logic_vector;
		video_hsync      : out std_logic;
		video_vsync      : out std_logic;
		video_blank      : out std_logic;
		video_sync       : out std_logic);

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);

end;

architecture beh of scopeio is

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant gainid_bits : natural := unsigned_num_bits(vt_gains'length-1);

	signal rgtr_id            : std_logic_vector(8-1 downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_data          : std_logic_vector(0 to 4*8-1);
	signal rgtr_revs          : std_logic_vector(rgtr_data'reverse_range);

	signal ampsample_dv       : std_logic;
	signal ampsample_data     : std_logic_vector(0 to input_data'length-1);

	constant capture_bits     : natural := unsigned_num_bits(max(resolve(layout&".num_of_segments")*grid_width(layout),min_storage)-1);

	signal video_addr         : std_logic_vector(0 to capture_bits-1);
	signal video_frm          : std_logic;
	signal video_dv           : std_logic;
	signal video_data         : std_logic_vector(0 to 2*inputs*storage_word'length-1);

	signal video_vton         : std_logic;

	signal time_offset        : std_logic_vector(hzoffset_bits-1 downto 0);
	signal time_scale         : std_logic_vector(4-1 downto 0);
	signal time_dv              : std_logic;

	signal trigger_freeze     : std_logic;

	signal gain_ena           : std_logic;
	signal gain_dv            : std_logic;
	signal gain_cid           : std_logic_vector(0 to chanid_bits-1);
	signal gain_ids           : std_logic_vector(0 to inputs*gainid_bits-1);


begin

	assert inputs < max_inputs
		report "inputs greater than max_inputs"
		severity failure;

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => sio_clk,
		sin_frm   => si_frm,
		sin_irdy  => si_irdy,
		sin_data  => si_data,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_data);
	rgtr_revs <= reverse(rgtr_data,8);

	amp_b : block

		constant vt_unit     : real := jso(layout)**".axis.vertical.unit";
		constant sample_size : natural := input_data'length/inputs;
		signal chan_id       : std_logic_vector(0 to chanid_bits-1);
		signal gain_id       : std_logic_vector(0 to gainid_bits-1);
		signal output_ena    : std_logic_vector(0 to inputs-1);
	begin

		scopeio_rgtrgain_e : entity hdl4fpga.scopeio_rgtrgain
		generic map (
			rgtr      => false)
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_revs,

			gain_ena  => gain_ena,
			gain_dv   => gain_dv,
			chan_id   => chan_id,
			gain_id   => gain_id);
		
		process(sio_clk)
		begin
			if rising_edge(sio_clk) then
				if gain_ena='1' then
					gain_cid <= chan_id;
					if trigger_freeze='0' then
						gain_ids <= byte2word(gain_ids, chan_id, gain_id);
					end if;
				end if;
			end if;
		end process;

		amp_g : for i in 0 to inputs-1 generate

			function init_gains(
				constant gains : natural_vector;
				constant unit  : real;
				constant step  : real)
				return natural_vector is
				constant df_gains  : natural_vector := (
					 0 => 2**17/(2**(0+0)*5**(0+0)),  1 => 2**17/(2**(1+0)*5**(0+0)),  2 => 2**17/(2**(2+0)*5**(0+0)),  3 => 2**17/(2**(0+0)*5**(1+0)),
					 4 => 2**17/(2**(0+1)*5**(0+1)),  5 => 2**17/(2**(1+1)*5**(0+1)),  6 => 2**17/(2**(2+1)*5**(0+1)),  7 => 2**17/(2**(0+1)*5**(1+1)),
					 8 => 2**17/(2**(0+2)*5**(0+2)),  9 => 2**17/(2**(1+2)*5**(0+2)), 10 => 2**17/(2**(2+2)*5**(0+2)), 11 => 2**17/(2**(0+2)*5**(1+2)),
					12 => 2**17/(2**(0+3)*5**(0+3)), 13 => 2**17/(2**(1+3)*5**(0+3)), 14 => 2**17/(2**(2+3)*5**(0+3)), 15 => 2**17/(2**(0+3)*5**(1+3)));

				constant k      : real := (32.0*step)/unit;
				variable retval : natural_vector(0 to setif(gains'length >0, gains'length, df_gains'length)-1);

			begin
				retval := df_gains;
				if gains'length > 0 then
					retval := gains;
				end if;

				assert k < 1.0
				report "unit " & real'image(unit) & " : " & real'image(32.0*step) & " unit should be increase"
				-- report real'image(k) & "   unit should be increase"
				severity FAILURE;

				if k > 0.0 then
					for i in retval'range loop
						retval(i) := natural(real(retval(i))*k);
					end loop;
				end if;

				return retval;
			end;

			constant vt_step : real := vt_steps(i); -- diamond 3.7 workaround to avoid step => vt_steps(i)
			constant gains  : natural_vector(vt_gains'range) := init_gains (
				gains => vt_gains,
				unit  => vt_unit,
				step  => vt_step);

			subtype sample_range is natural range i*sample_size to (i+1)*sample_size-1;

			signal input_sample : std_logic_vector(0 to sample_size-1);
			signal gain_id      : std_logic_vector(gainid_bits-1 downto 0);
		begin

			gain_id <= multiplex(gain_ids, i, gainid_bits);
			input_sample <= multiplex(input_data, i, sample_size);
			amp_e : entity hdl4fpga.scopeio_amp
			generic map (
				gains => gains)
			port map (
				input_clk     => input_clk,
				input_dv      => input_ena,
				input_sample  => input_sample,
				gain_id       => gain_id,
				output_dv     => output_ena(i),
				output_sample => ampsample_data(sample_range));

		end generate;

		ampsample_dv <= output_ena(0);
	end block;

	scopeio_tds_e : scopeio_tds
	generic map  (
		inputs       => inputs,
		storageword_size => storage_word'length,
		time_factors => hz_factors)
	port map (
		rgtr_clk     => sio_clk,
		rgtr_dv      => rgtr_dv,
		rgtr_id      => rgtr_id,
		rgtr_data    => rgtr_revs,

		input_clk    => input_clk,
		input_dv     => ampsample_dv,
		input_data   => ampsample_data,
		time_scale   => time_scale,
		time_offset  => time_offset,
		trigger_freeze => trigger_freeze,

		video_clk    => video_clk,
		video_addr   => video_addr,  
		video_vton   => video_vton,  
		video_frm    => video_frm,  
		video_dv     => video_dv,  
		video_data   => video_data);

	scopeio_video_e : entity hdl4fpga.scopeio_video
	generic map (
		timing_id      => videotiming_id,
		modeline       => modeline,
		width          => width,
		height         => height,
		fps            => fps,
		pclk           => pclk,
		layout         => layout,
		inputs         => inputs,
		input_names    => input_names)
	port map (
		tp => tp,
		rgtr_clk       => sio_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_revs,

		time_scale     => time_scale,
		time_offset    => time_offset,
                                        
		gain_ena       => gain_ena,
		gain_dv        => gain_dv,
		gain_cid       => gain_cid,
		gain_ids       => gain_ids,

		video_addr     => video_addr,
		video_frm      => video_frm,
		video_data     => video_data,
		video_dv       => video_dv,

		video_clk      => video_clk,
		video_pixel    => video_pixel,
		extern_video   => extern_video,
		extern_videohzsync => extern_videohzsync,
		extern_videovtsync => extern_videovtsync,
		extern_videoblankn => extern_videoblankn,
		video_hsync    => video_hsync,
		video_vsync    => video_vsync,
		video_vton     => video_vton,
		video_hzon     => open,
		video_blank    => video_blank,
		video_sync     => video_sync);

end;
