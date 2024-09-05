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
use hdl4fpga.hdo.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.sdram_param.all;
use hdl4fpga.sdram_db.all;

entity scopeiosdr is
	generic (
		sdram        : string := "";
		videotiming_id   : videotiming_ids;
		layout       : string;
		sdram_tcp    : real;
		mark         : sdram_chips;
		burst_length : natural := 0);
	port (
		tp            : out std_logic_vector(1 to 32);
		sio_clk       : in  std_logic := '-';
		si_frm        : in  std_logic := '0';
		si_irdy       : in  std_logic := '0';
		si_data       : in  std_logic_vector;
		so_clk        : in  std_logic := '-';
		so_frm        : out std_logic;
		so_irdy       : out std_logic;
		so_trdy       : in  std_logic := '0';
		so_data       : out std_logic_vector;

		input_clk     : in  std_logic;
		input_ena     : in  std_logic := '1';
		input_data    : in  std_logic_vector;

		ctlr_clk      : in  std_logic;
		ctlr_rst      : in  std_logic;
		ctlr_al       : in  std_logic_vector(3-1 downto 0) := (others => '0');
		ctlr_bl       : in  std_logic_vector(0 to 3-1);
		ctlr_cl       : in  std_logic_vector;
		ctlr_cwl      : in  std_logic_vector(0 to 3-1) := "000";
		ctlr_wrl      : in  std_logic_vector(0 to 3-1) := "101";
		ctlr_rtt      : in  std_logic_vector(0 to 3-1) := (others => '-');
		ctlr_cmd      : buffer std_logic_vector(0 to 3-1);
		ctlr_inirdy   : buffer std_logic;

		ctlrphy_wlreq : out std_logic;
		ctlrphy_wlrdy : in  std_logic := '-';
		ctlrphy_rlreq : out std_logic;
		ctlrphy_rlrdy : in  std_logic := '-';
		ctlrphy_irdy  : in  std_logic := '0';
		ctlrphy_trdy  : out std_logic := '0';
		ctlrphy_rw    : in  std_logic := '-';

		ctlrphy_ini   : in  std_logic := '1';
		ctlrphy_rst   : out std_logic;
		ctlrphy_cke   : out std_logic;
		ctlrphy_cs    : out std_logic;
		ctlrphy_ras   : buffer std_logic;
		ctlrphy_cas   : buffer std_logic;
		ctlrphy_we    : buffer std_logic;
		ctlrphy_odt   : out std_logic;
		ctlrphy_b     : out std_logic_vector(hdo(sdram)**".bank_size=1."-1 downto 0);
		ctlrphy_a     : out std_logic_vector(hdo(sdram)**".addr_size=1."-1 downto 0);
		ctlrphy_dqst  : out std_logic_vector(hdo(sdram)**".gear=1."-1 downto 0);
		ctlrphy_dqso  : out std_logic_vector(hdo(sdram)**".gear=1."-1 downto 0);
		ctlrphy_dmi   : in  std_logic_vector(hdo(sdram)**".gear=1."*hdo(sdram)**".word_size"/hdo(sdram)**".byte_size"-1 downto 0) := (others => '-');
		ctlrphy_dmo   : out std_logic_vector(hdo(sdram)**".gear=1."*hdo(sdram)**".word_size"/hdo(sdram)**".byte_size"-1 downto 0);
		ctlrphy_dqt   : out std_logic_vector(hdo(sdram)**".gear=1."-1 downto 0);
		ctlrphy_dqi   : in  std_logic_vector(hdo(sdram)**".gear=1."*hdo(sdram)**".word_size"-1 downto 0);
		ctlrphy_dqo   : out std_logic_vector(hdo(sdram)**".gear=1."*hdo(sdram)**".word_size"-1 downto 0);
		ctlrphy_dqv   : out std_logic_vector(hdo(sdram)**".gear=1."-1 downto 0);
		ctlrphy_sto   : out std_logic_vector(hdo(sdram)**".gear=1."-1 downto 0);
		ctlrphy_sti   : in  std_logic_vector(hdo(sdram)**".gear=1."*hdo(sdram)**".word_size"/hdo(sdram)**".byte_size"-1 downto 0);
		video_clk     : in  std_logic;
		video_pixel   : out std_logic_vector;
		video_hsync   : out std_logic;
		video_vsync   : out std_logic;
		video_vton    : buffer std_logic;
		video_hzon    : out std_logic;
		video_blank   : out std_logic;
		video_sync    : out std_logic;
		extern_video  : in  std_logic := '0';
		extern_videohzsync : in  std_logic := '-';
		extern_videovtsync : in  std_logic := '-';
		extern_videoblankn : in  std_logic := '-');

	constant gear          : natural := hdo(sdram)**".gear";
	constant bank_size     : natural := hdo(sdram)**".bank_size";
	constant addr_size     : natural := hdo(sdram)**".addr_size";
	constant coln_size     : natural := hdo(sdram)**".coln_size";
	constant word_size     : natural := hdo(sdram)**".word_size";
	constant byte_size     : natural := hdo(sdram)**".byte_size";
	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay=16384.";
	constant min_storage   : natural := hdo(layout)**".min_storage=256."; -- samples, storage size will be equal or larger than this
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant grid_height   : natural := hdo(layout)**".grid.height";
	constant grid_width    : natural := hdo(layout)**".grid.width";
	constant grid_unit     : natural := hdo(layout)**".grid.unit=32.";

	function to_naturalvector (
		constant object : string)
		return natural_vector is
		constant length : natural := hdo(object)**".length";
		variable retval : natural_vector(0 to length-1);
	begin
		for i in 0 to length-1 loop
			retval(i) := hdo(object)**("["&natural'image(i)&"]");
		end loop;
		return retval;
	end;

	constant time_factors : natural_vector := to_naturalvector(hdo(layout)**compact(".axis.horizontal.scales=" & 
			"[" &
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [0]
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [1]
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [2]
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [3]
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [4]
				natural'image(2**(1+0)*5**(0+0)) & "," & -- [5]
				natural'image(2**(2+0)*5**(0+0)) & "," & -- [6]
				natural'image(2**(0+0)*5**(1+0)) & "," & -- [7]
				natural'image(2**(0+1)*5**(0+1)) & "," & -- [8]
				natural'image(2**(1+1)*5**(0+1)) & "," & -- [9]
				natural'image(2**(2+1)*5**(0+1)) & "," & -- [10]
				natural'image(2**(0+1)*5**(1+1)) & "," & -- [11]
				natural'image(2**(0+2)*5**(0+2)) & "," & -- [12]
				natural'image(2**(1+2)*5**(0+2)) & "," & -- [13]
				natural'image(2**(2+2)*5**(0+2)) & "," & -- [14]
				natural'image(2**(0+2)*5**(1+2)) & "," & -- [15]
			"length : 16]."));
	constant vt_gains : natural_vector := to_naturalvector(hdo(layout)**compact(".axis.vertical.gains=" &
			"[" &
				natural'image(2**17/(2**(0+0)*5**(0+0))) & "," & -- [0]
				natural'image(2**17/(2**(1+0)*5**(0+0))) & "," & -- [1]
				natural'image(2**17/(2**(2+0)*5**(0+0))) & "," & -- [2]
				natural'image(2**17/(2**(0+0)*5**(1+0))) & "," & -- [3]
				natural'image(2**17/(2**(0+1)*5**(0+1))) & "," & -- [4]
				natural'image(2**17/(2**(1+1)*5**(0+1))) & "," & -- [5]
				natural'image(2**17/(2**(2+1)*5**(0+1))) & "," & -- [6]
				natural'image(2**17/(2**(0+1)*5**(1+1))) & "," & -- [7]
				natural'image(2**17/(2**(0+2)*5**(0+2))) & "," & -- [8]
				natural'image(2**17/(2**(1+2)*5**(0+2))) & "," & -- [9]
				natural'image(2**17/(2**(2+2)*5**(0+2))) & "," & -- [10]
				natural'image(2**17/(2**(0+2)*5**(1+2))) & "," & -- [11]
				natural'image(2**17/(2**(0+3)*5**(0+3))) & "," & -- [12]
				natural'image(2**17/(2**(1+3)*5**(0+3))) & "," & -- [13]
				natural'image(2**17/(2**(2+3)*5**(0+3))) & "," & -- [14]
				natural'image(2**17/(2**(0+3)*5**(1+3))) & "," & -- [15]
			"length : 16]."));
end;

architecture beh of scopeiosdr is

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);
	constant gainid_bits  : natural := unsigned_num_bits(vt_gains'length-1);

	signal rgtr_id        : std_logic_vector(8-1 downto 0);
	signal rgtr_dv        : std_logic;
	signal rgtr_data      : std_logic_vector(0 to 4*8-1);
	signal rgtr_revs      : std_logic_vector(rgtr_data'reverse_range);

	signal ampsample_dv   : std_logic;
	signal ampsample_data : std_logic_vector(0 to input_data'length-1);

	constant capture_bits : natural := unsigned_num_bits(max(resolve(layout&".num_of_segments")*grid_width,min_storage)-1);

	signal video_addr     : std_logic_vector(0 to capture_bits-1);
	signal video_frm      : std_logic;
	signal video_dv       : std_logic;
	signal video_data     : std_logic_vector(0 to 2*inputs*storage_word'length-1);


	signal time_offset    : std_logic_vector(hzoffset_bits-1 downto 0);
	signal time_scale     : std_logic_vector(4-1 downto 0);
	signal time_dv          : std_logic;

	signal trigger_freeze : std_logic;

	signal gain_ena       : std_logic;
	signal gain_dv        : std_logic;
	signal gain_cid       : std_logic_vector(0 to chanid_bits-1);
	signal gain_ids       : std_logic_vector(0 to inputs*gainid_bits-1);


	signal ctlr_frm       : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_alat      : std_logic_vector(2 downto 0);
	signal ctlr_blat      : std_logic_vector(2 downto 0);
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlr_do_dv     : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;

	signal ctlr_fch       : std_logic;
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

		constant vt          : string := hdo(layout)**".vt";
		constant vt_unit     : real := hdo(layout)**".axis.vertical.unit";
		constant sample_size : natural := input_data'length/inputs;
		signal chan_id       : std_logic_vector(0 to chanid_bits-1);
		signal gain_id       : std_logic_vector(0 to gainid_bits-1);
		signal output_ena    : std_logic_vector(0 to inputs-1);
	begin

		vtscale_e : entity hdl4fpga.scopeio_rgtrvtscale
		generic map (
			rgtr      => false)
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_revs,

			vtscale_ena => gain_ena,
			vtscale_dv  => gain_dv,
			vtchan_id  => chan_id,
			vtscale_id  => gain_id);
		
		process(sio_clk)
		begin
			if rising_edge(sio_clk) then
				if gain_ena='1' then
					gain_cid <= chan_id;
					if trigger_freeze='0' then
						gain_ids <= replace(gain_ids, chan_id, gain_id);
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

				constant k      : real := (real(grid_unit)*step)/unit;
				variable retval : natural_vector(0 to setif(gains'length >0, gains'length, df_gains'length)-1);

			begin
				retval := df_gains;
				if gains'length > 0 then
					retval := gains;
				end if;

				assert k < 1.0
					report "unit " & real'image(unit) & " : " & real'image(real(grid_unit)*step) & " unit should be increase"
					severity FAILURE;

				if k > 0.0 then
					for i in retval'range loop
						retval(i) := natural(real(retval(i))*k);
					end loop;
				end if;

				return retval;
			end;

			constant vt_step : real := hdo(vt)**("["&natural'image(i)&"].step");
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
		time_factors => time_factors)
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
		layout         => layout)
	port map (
		tp => tp,
		rgtr_clk       => sio_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_revs,

		time_scale     => time_scale,
		time_offset    => time_offset,
                                        
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
		video_hzon     => video_hzon,
		video_blank    => video_blank,
		video_sync     => video_sync);

	sdrctlr_b : block
		signal inirdy    : std_logic;
	begin
		sdrctlr_e : entity hdl4fpga.sdram_ctlr
		generic map (
			chip         => mark,
			tcp          => sdram_tcp,

			-- latencies    => phy_latencies,
			latencies => (others => 0),
			gear         => gear,
			bank_size    => bank_size,
			addr_size    => addr_size,
			word_size    => word_size,
			byte_size    => byte_size)
		port map (
			ctlr_alat    => ctlr_alat,
			ctlr_blat    => ctlr_blat,
			ctlr_al      => ctlr_al,
			ctlr_bl      => ctlr_bl,
			ctlr_cl      => ctlr_cl,

			ctlr_cwl     => ctlr_cwl,
			ctlr_wrl     => ctlr_wrl,
			ctlr_rtt     => ctlr_rtt,

			ctlr_rst     => ctlr_rst,
			ctlr_clk     => ctlr_clk,
			ctlr_inirdy  => inirdy,

			ctlr_frm     => ctlr_frm,
			ctlr_trdy    => ctlr_trdy,
			ctlr_fch     => ctlr_fch,
			ctlr_rw      => ctlr_rw,
			ctlr_b       => ctlr_b,
			ctlr_a       => ctlr_a,
			ctlr_cmd     => ctlr_cmd,
			ctlr_di_dv   => ctlr_di_dv,
			ctlr_di_req  => ctlr_di_req,
			ctlr_di      => ctlr_di,
			ctlr_dm      => (0 to gear*word_size/byte_size-1 => '0'),
			ctlr_do_dv   => ctlr_do_dv,
			ctlr_do      => ctlr_do,
			ctlr_refreq  => ctlr_refreq,
			phy_inirdy   => ctlrphy_ini,
			phy_frm      => ctlrphy_irdy,
			phy_trdy     => ctlrphy_trdy,
			phy_rw       => ctlrphy_rw,
			phy_wlrdy    => ctlrphy_wlrdy,
			phy_wlreq    => ctlrphy_wlreq,
			phy_rlrdy    => ctlrphy_rlrdy,
			phy_rlreq    => ctlrphy_rlreq,
			phy_rst      => ctlrphy_rst,
			phy_cke      => ctlrphy_cke,
			phy_cs       => ctlrphy_cs,
			phy_ras      => ctlrphy_ras,
			phy_cas      => ctlrphy_cas,
			phy_odt      => ctlrphy_odt,
			phy_we       => ctlrphy_we,
			phy_b        => ctlrphy_b,
			phy_a        => ctlrphy_a,
			phy_dmi      => ctlrphy_dmi,
			phy_dmo      => ctlrphy_dmo,

			phy_dqi      => ctlrphy_dqi,
			phy_dqt      => ctlrphy_dqt,
			phy_dqo      => ctlrphy_dqo,
			phy_sti      => ctlrphy_sti,
			phy_sto      => ctlrphy_sto,

			phy_dqv      => ctlrphy_dqv,
			phy_dqso     => ctlrphy_dqso,
			phy_dqst     => ctlrphy_dqst);

		inirdy_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 0 => 0))
		port map (
			clk => ctlr_clk,
			di(0) => inirdy,
			do(0) => ctlr_inirdy);

	end block;
end;
