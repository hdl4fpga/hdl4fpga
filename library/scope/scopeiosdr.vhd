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
		profile      : natural;
		sdram        : string := "";
		timing_id   : videotiming_ids;
		layout       : string;
		sdram_tcp    : real;
		mark         : sdram_chips;
		fifo_size    : natural := 8*8192;
		video_gear   : natural := 2;
		intrp_trans  : boolean := true;
		red_length   : natural := 8;
		green_length : natural := 8;
		blue_length  : natural := 8;
		burst_length : natural := 0);
	port (
		tp            : out std_logic_vector(1 to 32);
		sio_clk       : in  std_logic := '-';
		si_frm        : in  std_logic := '0';
		si_irdy       : in  std_logic := '0';
		si_data       : in  std_logic_vector;
		so_clk        : in  std_logic := '-';
		so_frm        : buffer std_logic;
		so_irdy       : buffer std_logic;
		so_trdy       : in  std_logic := '0';
		so_end        : buffer std_logic := '0';
		so_data       : out std_logic_vector;

		input_clk     : in  std_logic;
		input_ena     : in  std_logic := '1';
		input_dv      : in  std_logic_vector(0 to hdo(layout)**".inputs=0.");
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
		video_shift_clk :  in std_logic := '-';
		video_pixel   : buffer std_logic_vector;
		video_hsync   : buffer std_logic;
		video_vsync   : buffer std_logic;
		video_vton    : buffer std_logic;
		video_hzon    : out std_logic;
		video_blank   : buffer std_logic;
		video_sync    : out std_logic;
		dvid_crgb     : out std_logic_vector(4*video_gear-1 downto 0);
		extern_video  : in  std_logic := '0';
		extern_videohzsync : in  std_logic := '-';
		extern_videovtsync : in  std_logic := '-';
		extern_videoblankn : in  std_logic := '-');

	type latencies is record
		ddro    : natural;
		dmaio   : natural;
		sodata  : natural;
		adapter : natural;
	end record;

	type latencies_vector is array (natural range <>) of latencies;
	constant latencies_tab : latencies_vector := (
--		0 => (ddro => 0, dmaio => 0, sodata => 0, adapter => 0),  -- ULX3S BOARD
--		1 => (ddro => 0, dmaio => 0, sodata => 0, adapter => 0),  -- NUHS3ADSP BOARD 200 MHz
--		2 => (ddro => 0, dmaio => 0, sodata => 0, adapter => 0),  -- ULX4M BOARD
--		3 => (ddro => 0, dmaio => 0, sodata => 0, adapter => 0)); -- NUHS3ADSP BOARD 166 MHz
		0 => (ddro => 2, dmaio => 3, sodata => 1, adapter => 1),  -- ULX3S BOARD
		1 => (ddro => 3, dmaio => 2, sodata => 0, adapter => 0),  -- NUHS3ADSP BOARD 200 MHz
		2 => (ddro => 3, dmaio => 3, sodata => 3, adapter => 3),  -- ULX4M BOARD
		3 => (ddro => 3, dmaio => 2, sodata => 1, adapter => 1)); -- NUHS3ADSP BOARD 166 MHz

	constant fifodata_depth : natural := (fifo_size/(ctlrphy_dqi'length));
	constant gear          : natural := hdo(sdram)**".gear";
	constant bank_size     : natural := hdo(sdram)**".bank_size";
	constant addr_size     : natural := hdo(sdram)**".addr_size";
	constant coln_size     : natural := hdo(sdram)**".coln_size";
	constant coln_bits     : natural := coln_size-(unsigned_num_bits(gear)-1);
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

	constant rid_ack      : std_logic_vector := x"01";
	constant rid_dmaaddr  : std_logic_vector := x"16";
	constant rid_dmalen   : std_logic_vector := x"17";
	constant rid_dmadata  : std_logic_vector := x"18";

	signal rgtr_frm       : std_logic;
	signal rgtr_irdy      : std_logic;
	signal rgtr_idv       : std_logic;
	signal rgtr_id        : std_logic_vector(8-1 downto 0);
	signal rgtr_lv        : std_logic;
	signal rgtr_len       : std_logic_vector(8-1 downto 0);
	signal rgtr_dv        : std_logic;
	signal rgtr_data      : std_logic_vector(0 to max(32,ctlrphy_dqi'length)-1);
	-- signal rgtr_revs      : std_logic_vector(rgtr_data'length-1 downto 0);	-- Xilinx ISE does'nt allow to use reverse_range
	signal rgtr_revs      : std_logic_vector(rgtr_data'reverse_range);
	signal data_frm       : std_logic;
	signal data_irdy      : std_logic;
	signal data_ptr       : std_logic_vector(8-1 downto 0);

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
		data_frm  => data_frm,
		data_ptr  => data_ptr,
		data_irdy => data_irdy,
		rgtr_frm  => rgtr_frm,
		rgtr_irdy => rgtr_irdy,
		rgtr_idv  => rgtr_idv,
		rgtr_id   => rgtr_id,
		rgtr_lv   => rgtr_lv,
		rgtr_len  => rgtr_len,
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
		timing_id      => timing_id,
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

	dviadapter_b : block
		signal dvid_blank : std_logic;
		signal rgb : std_logic_vector(0 to 3*8-1) := (others => '0');

	begin

		dvid_blank <= video_blank;
		process (video_pixel)
			variable urgb  : unsigned(0 to 3*8-1);
			variable pixel : unsigned(0 to video_pixel'length-1);
		begin
			pixel := unsigned(video_pixel);

			urgb(0 to red_length-1)  := pixel(0 to red_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll red_length;

			urgb(0 to green_length-1) := pixel(0 to green_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll green_length;

			urgb(0 to blue_length-1) := pixel(0 to blue_length-1);
			urgb  := urgb rol 8;
			pixel := pixel sll blue_length;

			rgb <= std_logic_vector(urgb);
		end process;

		dvi_e : entity hdl4fpga.dvi
		generic map (
			fifo_mode => false, --dvid_fifo,
			gear  => video_gear)
		port map (
			clk   => video_clk,
			rgb   => rgb,
			hsync => video_hsync,
			vsync => video_vsync,
			blank => dvid_blank,
			cclk  => video_shift_clk,
			chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
			chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
			chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
			chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

	end block;

	capture_b : block

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
		signal dmactlr_addr   : std_logic_vector(bank_size+addr_size+coln_bits-1 downto 0);
		signal dmactlr_len    : std_logic_vector(dmactlr_addr'range);
		signal base_addr      : std_logic_vector(dmactlr_addr'range) := (others => '0');

		signal dmacfgio_req   : std_logic;
		signal dmacfgio_rdy   : std_logic;
		signal dmaio_req      : std_logic;
		signal dmaio_rdy      : std_logic;
		signal dmaio_ack      : std_logic_vector(0 to 8-1);
		signal dmaio_len      : std_logic_vector(dmactlr_len'range);
		signal dmaio_addr     : std_logic_vector(32-1 downto 0);
		signal dmaio_we       : std_logic;

		signal dmacfgcapture_req : std_logic;
		signal dmacfgcapture_rdy : std_logic;
		signal dmacapture_req   : std_logic;
		signal dmacapture_rdy   : std_logic;
		signal dmacapture_len   : std_logic_vector(dmactlr_len'range);
		signal dmacapture_addr  : std_logic_vector(dmactlr_addr'range);

		signal dmacfg_req     : std_logic_vector(0 to 2-1);
		signal dmacfg_rdy     : std_logic_vector(0 to 2-1);
		signal dev_len        : std_logic_vector(0 to 2*dmactlr_len'length-1);
		signal dev_addr       : std_logic_vector(0 to 2*dmactlr_addr'length-1);
		signal dev_we         : std_logic_vector(0 to 2-1);

		signal dev_gnt        : std_logic_vector(0 to 2-1);
		signal dev_req        : std_logic_vector(dev_gnt'range);
		signal dev_rdy        : std_logic_vector(dev_gnt'range);
		signal dma_do         : std_logic_vector(ctlr_do'range);
		signal dma_do_dv      : std_logic_vector(dev_gnt'range);
		signal dma_di_dv      : std_logic_vector(dev_gnt'range);
		alias  dmacapture_do_dv : std_logic is dma_do_dv(0);
		alias  dmaio_do_dv    : std_logic is dma_do_dv(1);

	begin
		sio_b : block

			constant siobyte_size : natural := 8;
			constant dataout_size : natural := 2*1024;

			signal rgtr_dmaack    : std_logic_vector(dmaio_ack'range);
			signal rgtr_dmaaddr   : std_logic_vector(32-1 downto 0);
			signal rgtr_dmalen    : std_logic_vector(24-1 downto 0);
			signal sigrgtr_frm    : std_logic;

			signal metaram_irdy   : std_logic;
			signal metaram_data   : std_logic_vector(so_data'range);

			signal dmasin_irdy    : std_logic;
			signal dmadata_irdy   : std_logic;
			signal dmadata_trdy   : std_logic;
			signal rgtr_dmadata   : std_logic_vector(ctlr_di'length-1 downto 0);
			signal datactlr_irdy  : std_logic;
			signal dmaaddr_irdy   : std_logic;
			signal dmaaddr_trdy   : std_logic;
			signal dmaio_trdy     : std_logic;
			signal dmaio_next     : std_logic;
			signal dmaioaddr_irdy : std_logic;

			signal meta_data      : std_logic_vector(metaram_data'range);
			signal meta_avail     : std_logic;
			signal meta_trdy      : std_logic;
			signal meta_end       : std_logic;

			signal acktx_irdy     : std_logic;
			signal acktx_trdy     : std_logic;
			signal acktx_data     : std_logic_vector(rgtr_dmaack'range);

			signal debug_dmacfgio_req : std_logic;
			signal debug_dmacfgio_rdy : std_logic;
			signal debug_dmaio_req    : std_logic;
			signal debug_dmaio_rdy    : std_logic;

			constant word_bits    : natural := unsigned_num_bits(ctlr_di'length/byte_size)-1;
			constant blword_bits  : natural := word_bits+unsigned_num_bits(setif(burst_length=0, gear, burst_length)/gear)-1;

			signal status         : std_logic_vector(0 to 8-1);
			alias  status_rw      : std_logic is status(status'right);

			signal tp_meta        : std_logic_vector(tp'range);
		begin

			metaram_irdy <= rgtr_irdy and setif(rgtr_id=x"00");
			metaram_data <= std_logic_vector(resize(unsigned(rgtr_data), metaram_data'length));
			metafifo_e : entity hdl4fpga.txn_buffer
			generic map (
				debug => false,
				m => 8)
			port map (
				tp => tp_meta,
				src_clk  => sio_clk,
				src_frm  => rgtr_frm,
				src_irdy => metaram_irdy,
				src_data => metaram_data,

				avail    => meta_avail,
				dst_clk  => sio_clk,
				dst_frm  => so_frm,
				dst_irdy => so_trdy,
				dst_trdy => meta_trdy,
				dst_end  => meta_end,
				dst_data => meta_data);


			rx_b : block
				signal ctlr_di_rdy: std_logic;
			begin

				dmaaddr_irdy <= setif(rgtr_id=rid_dmaaddr) and rgtr_dv and rgtr_irdy;
				rgtr_dmaaddr <= reverse(std_logic_vector(resize(unsigned(rgtr_data), rgtr_dmaaddr'length)),8);
				fifo_b : block
					signal src_data : std_logic_vector(0 to rgtr_dmaaddr'length+rgtr_dmalen'length+rgtr_dmaack'length-1);
					signal dst_data : std_logic_vector(src_data'range);

				begin

					rgtr_ack_e : entity hdl4fpga.sio_rgtr
					generic map (
						rid       => rid_ack)
					port map (
						rgtr_clk  => sio_clk,
						rgtr_dv   => rgtr_dv,
						rgtr_id   => rgtr_id,
						rgtr_data => rgtr_revs(rgtr_dmaack'length-1 downto 0),
						data      => rgtr_dmaack);

					rgtr_dmalen_e : entity hdl4fpga.sio_rgtr
					generic map (
						rid       => rid_dmalen)
					port map (
						rgtr_clk  => sio_clk,
						rgtr_dv   => rgtr_dv,
						rgtr_id   => rgtr_id,
						rgtr_data => rgtr_revs(rgtr_dmalen'range),
						data      => rgtr_dmalen);

					src_data <= rgtr_dmaaddr & rgtr_dmalen & rgtr_dmaack;
					dmafifo_e : entity hdl4fpga.fifo
					generic map (
						max_depth  => 4,
						latency    => 0,
						check_sov  => false,
						check_dov  => false)
					port map (
						src_clk    => sio_clk,
						src_irdy   => dmaaddr_irdy,
						src_trdy   => dmaaddr_trdy,
						src_data   => src_data,

						dst_clk    => sio_clk,
						dst_frm    => ctlr_inirdy,
						dst_irdy   => dmaioaddr_irdy,
						dst_trdy   => dmaio_next,
						dst_data   => dst_data);


					process(dst_data)
						variable aux : unsigned(dst_data'range);
					begin
						aux := unsigned(dst_data);
						aux(1 to rgtr_dmaaddr'length-1) := shift_right(aux(1 to rgtr_dmaaddr'length-1), word_bits);
						dmaio_addr <= std_logic_vector(resize(aux(0 to rgtr_dmaaddr'length-1), dmaio_addr'length));
						aux := aux sll rgtr_dmaaddr'length;
						aux(0 to rgtr_dmalen'length-1) := shift_right(aux(0 to rgtr_dmalen'length-1),  word_bits);
						dmaio_len <= std_logic_vector(resize(aux(0 to rgtr_dmalen'length-1), dmaio_len'length));
						aux := aux sll rgtr_dmalen'length;
						dmaio_ack <= std_logic_vector(resize(aux(0 to rgtr_dmaack'length-1), dmaio_ack'length));
					end process;

				end block;
				dmaio_we   <= not dmaio_addr(dmaio_addr'left);
				dmaio_next <= dmaio_trdy;

				dmadata_irdy <= data_irdy and setif(rgtr_id=rid_dmadata) and setif(data_ptr(word_bits-1 downto 0)=(word_bits-1 downto 0 => '0'));
				rgtr_dmadata <= reverse(std_logic_vector(resize(unsigned(rgtr_data), rgtr_dmadata'length)),8);


				stream_e : entity hdl4fpga.sdram_stream is
				generic map (
					buffer_size => 1024)
				port map (
					stream_clk  => input_clk,
					stream_frm  => '-',
					stream_irdy => '-',
					stream_trdy => open,
					stream_data => input_data,
					base_addr   => (others => '-'),
					dmacfg_clk  => sio_clk,
					dmacfg_req  => dmacfgcapture_req
					dmacfg_rdy  => dmacfgcapture_rdy
					dma_req     => dmacapture_req,
					dma_rdy     => dmacapture_rdy,
					dma_len     => dmacapture_len,
					dma_addr    => dmacapture_addr,
					ctlr_inirdy => ctlr_inirdy
					ctlr_clk    => ctlr_clk,
					ctlr_do_dv  => '-',
					ctlr_do     => input_do);

				dmadata_e : entity hdl4fpga.fifo
				generic map (
					max_depth  => fifodata_depth,
					async_mode => true,
					latency    => latencies_tab(profile).dmaio,
					check_sov  => true,
					check_dov  => true)
				port map (
					src_clk    => input_clk,
					src_frm    => ctlr_inirdy,
					src_irdy   => caputure_irdy,
					src_trdy   => caputure_trdy,
					src_data   => caputure_data,

					dst_clk    => ctlr_clk,
					dst_irdy   => ctlr_di_rdy,
					dst_trdy   => ctlr_di_req,
					dst_data   => ctlr_di);
				ctlr_di_dv <= ctlr_di_req;
				ctlr_di <= input_do when 

				base_addr_e : entity hdl4fpga.sio_rgtr
				generic map (
					rid  => x"19")
				port map (
					rgtr_clk  => sio_clk,
					rgtr_dv   => rgtr_dv,
					rgtr_id   => rgtr_id,
					rgtr_data => rgtr_data,
					data      => base_addr);

			end block;

			debug_dmacfgio_req <= dmacfgio_req xor  to_stdulogic(to_bit(dmacfgio_rdy));
			debug_dmacfgio_rdy <= dmacfgio_req xnor to_stdulogic(to_bit(dmacfgio_rdy));
			debug_dmaio_req    <= dmaio_req    xor  to_stdulogic(to_bit(dmaio_rdy));
			debug_dmaio_rdy    <= dmaio_req    xnor to_stdulogic(to_bit(dmaio_rdy));

			dmasin_irdy <= to_stdulogic(to_bit(dmaioaddr_irdy));
			sio_dmahdsk_e : entity hdl4fpga.sio_dmahdsk
			port map (
				dmacfg_clk  => sio_clk,
				ctlr_inirdy => ctlr_inirdy,
				dmaio_irdy  => dmasin_irdy,
				dmaio_trdy  => dmaio_trdy,

				dmacfg_req  => dmacfgio_req,
				dmacfg_rdy  => dmacfgio_rdy,


				ctlr_clk    => ctlr_clk,
				dma_req     => dmaio_req,
				dma_rdy     => dmaio_rdy);

			tx_b : block
				signal trans_length  : unsigned(unsigned_num_bits(dataout_size-1)-1 downto 0);

				signal src_data      : std_logic_vector(0 to dmaio_ack'length+trans_length'length+status'length-1);
				signal dst_data      : std_logic_vector(src_data'range);

				signal sio_dmaio     : std_logic_vector(0 to (2+((2+1)+(2+1)))*8-1);
				signal siodmaio_irdy : std_logic;
				signal siodmaio_trdy : std_logic;
				signal siodmaio_end  : std_logic;
				signal siodmaio_data : std_logic_vector(so_data'range);

				signal sodata_irdy   : std_logic;
				signal sodata_trdy   : std_logic;
				signal sodata_end    : std_logic;
				signal sodata_data   : std_logic_vector(so_data'range);

			begin
				src_data <=
					dmaio_ack &
					std_logic_vector(resize(unsigned(dmaio_len), trans_length'length)) &
					dmaaddr_trdy & dmaioaddr_irdy & b"00000" & dmaio_addr(dmaio_addr'left);

				acktx_e : entity hdl4fpga.fifo
				generic map (
					max_depth  => 4,
					latency    => 1,
					check_sov  => true,
					check_dov  => true)
				port map (
					src_clk    => sio_clk,
					src_irdy   => dmaio_next,
					src_trdy   => open, --tp(6),
					src_data   => src_data,

					dst_clk    => sio_clk,
					dst_frm    => ctlr_inirdy,
					dst_irdy   => acktx_irdy,
					dst_trdy   => acktx_trdy,
					dst_data   => dst_data);

				process (dst_data)
					variable aux : unsigned(dst_data'range);
				begin
					aux := unsigned(dst_data);
					acktx_data   <= std_logic_vector(aux(0 to acktx_data'length-1));
					aux := aux sll acktx_data'length;
					trans_length <= aux(0 to trans_length'length-1);
					aux := aux sll trans_length'length;
					status <= std_logic_vector(aux(0 to status'length-1));
				end process;

				process (sio_clk)
				begin
					if rising_edge(sio_clk) then
						if ctlr_inirdy='0' then
							so_frm   <= '0';
							acktx_trdy <= '0';
						elsif so_frm='0' then
							if acktx_irdy='1' then
								so_frm <= meta_avail;
							end if;
							acktx_trdy <= '0';
						elsif acktx_trdy='1' then
							so_frm   <= '0';
							acktx_trdy <= '0';
						elsif (so_irdy and so_trdy and so_end)='1' then
							acktx_trdy <= '1';
						else
							acktx_trdy <= '0';
						end if;
					end if;
				end process;

				process (so_frm, sio_clk)
					constant pfix_size   : natural := sio_dmaio'length/siobyte_size-2;
					variable pay_length  : unsigned(trans_length'range);
					variable data_length : unsigned(pay_length'range);
					variable hdr_length  : unsigned(pay_length'range);
				begin
					if rising_edge(sio_clk) then
						sio_dmaio <=
							reverse(reverse(std_logic_vector(resize(pay_length,16))),8) & reverse(
							rid_ack     & x"00" & acktx_data &
							rid_dmaaddr & x"00" & status, 8);

							if status_rw='1' then
								pay_length := hdr_length + data_length;
							else
								pay_length := to_unsigned(pfix_size, pay_length'length);
							end if;

							hdr_length  := shift_right(unsigned(trans_length), blword_bits-word_bits);
							hdr_length  := hdr_length srl (unsigned_num_bits(256-1)-blword_bits);
							hdr_length  := hdr_length + 1;
							hdr_length  := hdr_length sll 1;

							data_length := shift_right(unsigned(trans_length), blword_bits-word_bits); 
							data_length := data_length sll blword_bits;
							data_length := data_length + (pfix_size + 2**blword_bits);

					end if;
				end process;

				siodmaio_irdy <= '0' when meta_end='0' else so_trdy;
				siodma_e : entity hdl4fpga.sio_mux
				port map (
					mux_data => sio_dmaio,
					sio_clk  => sio_clk,
					sio_frm  => so_frm,
					sio_irdy => siodmaio_irdy,
					sio_trdy => siodmaio_trdy,
					so_end   => siodmaio_end,
					so_data  => siodmaio_data);

				sodata_b : block
					constant dma_lat   : natural := latencies_tab(profile).sodata;

					signal fifo_req    : bit;
					signal fifo_rdy    : bit;

					signal fifo_frm    : std_logic;
					signal fifo_irdy   : std_logic;
					signal fifo_trdy   : std_logic;
					signal fifo_data   : std_logic_vector(ctlr_do'reverse_range);
					signal fifo_length : std_logic_vector(trans_length'range);

					signal dmaso_irdy  : std_logic;
					signal dmaso_trdy  : std_logic;
					signal dmaso_data  : std_logic_vector(ctlr_do'range);

				begin

					dmao_dv_e : entity hdl4fpga.latency
					generic map (
						n => 1,
						d => (0 to 1-1 => dma_lat))
					port map (
						clk   => ctlr_clk,
						di(0) => dmaio_do_dv,
						do(0) => dmaso_irdy);

					dmao_data_e : entity hdl4fpga.latency
					generic map (
						n => dmaso_data'length,
						d => (0 to dmaso_data'length-1 => dma_lat))
					port map (
						clk => ctlr_clk,
						di  => dma_do,
						do  => dmaso_data);

					dmadataout_e : entity hdl4fpga.fifo
					generic map (
						max_depth  => (dataout_size/(ctlr_di'length/siobyte_size)),
						-- async_mode => false,
						latency    => 0,
						check_sov  => false,
						check_dov  => true)
					port map (
						src_clk  => ctlr_clk,
						src_irdy => dmaso_irdy,
						src_trdy => dmaso_trdy,
						src_data => dmaso_data,

						dst_clk  => sio_clk,
						dst_frm  => ctlr_inirdy,
						dst_irdy => fifo_irdy,
						dst_trdy => fifo_trdy,
						dst_data => fifo_data);

					process (sio_clk)
						variable byte_length : unsigned(fifo_length'range);
					begin
						if rising_edge(sio_clk) then
							byte_length := (others => '1');
							byte_length := byte_length srl (byte_length'length-(unsigned_num_bits(2**blword_bits*byte_size/sodata_data'length)-1));
							byte_length := byte_length or  (trans_length sll word_bits);
							fifo_length <= std_logic_vector(byte_length);
						end if;
					end process;

					process (sio_clk)
					begin
						if rising_edge(sio_clk) then
							if acktx_irdy='1' then
								if status_rw='1' then
									fifo_req <= not fifo_rdy;
									if acktx_trdy='1' then
										fifo_rdy  <= fifo_req;
									end if;
								end if;
							end if;
						end if;
					end process;
					fifo_frm <= to_stdulogic(fifo_req xor fifo_rdy);

					sodata_trdy <=
						'0' when siodmaio_end='0' else
						'0' when    status_rw='0' else
						so_trdy;

					sodata_e : entity hdl4fpga.so_data
					port map (
						sio_clk   => sio_clk,
						si_frm    => fifo_frm,
						si_irdy   => fifo_irdy,
						si_trdy   => fifo_trdy,
						si_data   => fifo_data,
						si_length => fifo_length,

						so_irdy   => sodata_irdy,
						so_trdy   => sodata_trdy,
						so_end    => sodata_end,
						so_data   => sodata_data);

				tp(1 to 8) <= (acktx_irdy, acktx_trdy, meta_end, siodmaio_end, status_rw, fifo_frm, dmaso_irdy, dmaso_trdy);
				end block;

				so_irdy <=
					meta_trdy     when     meta_end='0' else
					siodmaio_trdy when siodmaio_end='0' else
					'1'           when    status_rw='0' else
					sodata_irdy;

				so_end  <=
					'0' when     meta_end='0' else
					'0' when siodmaio_end='0' else
					'1' when    status_rw='0' else
					sodata_end;
				so_data <=
					meta_data     when     meta_end='0' else
					siodmaio_data when siodmaio_end='0' else
					reverse(sodata_data);
			end block;
		end block;

		dev_req    <= (0 => dmacapture_req,    1 => dmaio_req);
		dmacfg_req <= (0 => dmacfgcapture_req, 1 => dmacfgio_req);
		dev_len    <= to_stdlogicvector(to_bitvector(dmacapture_len  & dmaio_len(dmactlr_len'range)));
		dev_addr   <= to_stdlogicvector(to_bitvector(dmacapture_addr & dmaio_addr(dmactlr_addr'range)));
		dev_we     <= '1'           & to_stdulogic(to_bit(dmaio_we));
		(dmacfgcapture_rdy, dmacfgio_rdy) <= to_stdlogicvector(to_bitvector(dmacfg_rdy));
		(dmacapture_rdy,    dmaio_rdy)    <= to_stdlogicvector(to_bitvector(dev_rdy));

		dmactlr_b : block
			constant buffdo_lat : natural := latencies_tab(profile).ddro;
			signal   dev_do_dv  : std_logic_vector(dev_gnt'range);
			signal   gnt_dv     : std_logic_vector(dev_gnt'range);
			signal   dma_rdy    : std_logic_vector(dev_rdy'range);
			signal   burst_ref  : std_logic;
		begin
			burst_ref <= ctlr_refreq when intrp_trans else '0';
			dmactlr_e : entity hdl4fpga.dmactlr
			generic map (
				burst_length => burst_length,
				data_gear    => gear,
				bank_size    => bank_size,
				addr_size    => addr_size,
				coln_size    => coln_size)
			port map (
				devcfg_clk   => sio_clk,
				devcfg_req   => dmacfg_req,
				devcfg_rdy   => dmacfg_rdy,
				dev_len      => dev_len,
				dev_addr     => dev_addr,
				dev_we       => dev_we,

				dev_req      => dev_req,
				dev_gnt      => dev_gnt,
				dev_rdy      => dma_rdy,

				ctlr_clk     => ctlr_clk,
				ctlr_cl      => ctlr_cl,

				ctlr_inirdy  => ctlr_inirdy,
				ctlr_refreq  => burst_ref,
				-- ctlr_refreq  => ctlr_refreq,

				ctlr_frm     => ctlr_frm,
				ctlr_trdy    => ctlr_trdy,
				ctlr_fch     => ctlr_fch,
				ctlr_cmd     => ctlr_cmd,
				ctlr_rw      => ctlr_rw,
				ctlr_alat    => ctlr_alat,
				ctlr_blat    => ctlr_blat,
				ctlr_b       => ctlr_b,
				ctlr_a       => ctlr_a);

			gntlat_e : entity hdl4fpga.latency
			generic map (
				n => dev_gnt'length,               -- Latency value depends on DRAM CAS latency.
				d => (0 to dev_gnt'length-1 => 4)) -- It should be dynamic. A fix value of 4 seems to work.
			port map (                             -- A wrong value jams transfer between host and fpga.
				clk => ctlr_clk,
				di  => dev_gnt,
				do  => gnt_dv);
			dev_do_dv <= (dev_gnt'range => ctlr_do_dv(0)) and gnt_dv;

			dmadv_e : entity hdl4fpga.latency
			generic map (
				n => 2,
				d => (0 to 2-1 => buffdo_lat))
			port map (
				clk   => ctlr_clk,
				di => dev_do_dv,
				do => dma_do_dv);

			dma_rdy_e : entity hdl4fpga.latency
			generic map (
				n => 2,
				d => (0 to 2-1 => buffdo_lat))
			port map (
				clk   => ctlr_clk,
				di => dma_rdy,
				do => dev_rdy);

			dmado_e : entity hdl4fpga.latency
			generic map (
				n => ctlr_do'length,
				d => (0 to ctlr_do'length-1 => buffdo_lat))
			port map (
				clk => ctlr_clk,
				di  => ctlr_do,
				do  => dma_do);

		end block;

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
	end block;
end;
