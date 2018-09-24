library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio is
	generic (
		inputs      : natural := 1;
		vlayout_id  : natural := 0;

		vt_from     : real_vector := (0 to 0 => 0.0);
		vt_step     : real_vector := (0 to 0 => 0.0);
		vt_scale    : std_logic_vector := (0 to 0 => '0');
		vt_gain     : natural_vector := (0 to 0 => 2**17);
		vt_factsyms : std_logic_vector := (0 to 0 => '0');
		vt_untsyms  : std_logic_vector := (0 to 0 => '0');

		hz_from     : real_vector := (0 to 0 => 0.0);
		hz_step     : real_vector := (0 to 0 => 0.0);
		hz_scale    : std_logic_vector := (0 to 0 => '0');
		hz_gain     : natural_vector := (0 to 0 => 2**18);
		hz_factsyms : std_logic_vector := (0 to 0 => '0');
		hz_untsyms  : std_logic_vector := (0 to 0 => '0'));
	port (
		si_clk      : in  std_logic := '-';
		si_dv       : in  std_logic := '0';
		si_data     : in  std_logic_vector;
		so_clk      : in  std_logic := '-';
		so_dv       : out std_logic := '0';
		so_data     : out std_logic_vector;
		ipcfg_req   : in  std_logic;
		input_clk   : in  std_logic;
		input_ena   : in  std_logic := '1';
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_rgb   : out std_logic_vector;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);
end;

architecture beh of scopeio is

	type square is record
		x      : natural;
		y      : natural;
		width  : natural;
		height : natural;
	end record;

	type video_layout is record 
		mode        : natural;
		scr_width   : natural;
		num_of_seg  : natural;
		sgmnt       : square;
	end record;

	type vlayout_vector is array (natural range <>) of video_layout;

	constant vlayout_tab : vlayout_vector(0 to 1) := (
		0 => (mode => 7, scr_width => 1920, num_of_seg => 4, sgmnt => (x => 320, y => 270, width => 50*32, height => 256)),
		1 => (mode => 1, scr_width =>  800, num_of_seg => 2, sgmnt => (x => 320, y => 300, width => 15*32, height => 256)));

	signal video_hs         : std_logic;
	signal video_vs         : std_logic;
	signal video_frm        : std_logic;
	signal video_hon        : std_logic;
	signal video_hzl        : std_logic;
	signal video_vld        : std_logic;
	signal video_vcntr      : std_logic_vector(11-1 downto 0);
	signal video_hcntr      : std_logic_vector(11-1 downto 0);

	signal video_io         : std_logic_vector(0 to 3-1);
	
	signal udpso_clk  : std_logic;
	signal udpso_dv   : std_logic;
	signal udpso_data : std_logic_vector(si_data'range);

	constant amp_rid     : natural := 1;
	constant trigger_rid : natural := 2;
	constant hzscale_rid : natural := 3;

	subtype amp_rgtr     is natural range 18-1 downto  1;
	subtype trigger_rgtr is natural range 32-1 downto 18;
	subtype hzscale_rgtr is natural range 40-1 downto 32;

	constant rgtr_map : natural_vector := (
		amp_rid     => 18,
		trigger_rid => 14,
		hzscale_rid => 8);

	signal rgtr_data          : std_logic_vector(hzscale_rgtr'high downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_id            : std_logic_vector(8-1 downto 0);

	signal downsample_ena     : std_logic;
	signal downsample_data    : std_logic_vector(input_data'range);
	signal ampsample_ena      : std_logic;
	signal ampsample_data     : std_logic_vector(input_data'range);
	signal triggersample_ena  : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);
	signal trigger_level      : std_logic_vector(0 to 0);
	signal trigger_req        : std_logic;
	signal capture_rdy        : std_logic;
	signal capture_req        : std_logic;

	constant storage_size : natural := unsigned_num_bits(
		vlayout_tab(vlayout_id).num_of_seg*vlayout_tab(vlayout_id).sgmnt.width-1);
	signal storage_addr : std_logic_vector(0 to storage_size-1);
	signal storage_base : std_logic_vector(storage_addr'range);

	subtype storage_word is std_logic_vector(0 to 9-1);
	signal storage_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal storage_bsel : std_logic_vector(0 to vlayout_tab(vlayout_id).num_of_seg-1);
	signal video_pixel  : std_logic_vector(video_rgb'range);

	signal hz_req : std_logic;
	signal hz_rdy : std_logic;
	signal hz_sel : std_logic_vector(6-1 downto 0);

	signal vt_req : std_logic;
	signal vt_rdy : std_logic;
	signal vt_sel : std_logic_vector(6-1 downto 0);

begin

	miiip_e : entity hdl4fpga.scopeio_miiudp
	port map (
		mii_rxc  => si_clk,
		mii_rxdv => si_dv,
		mii_rxd  => si_data,

		mii_req  => ipcfg_req,
		mii_txc  => so_clk,
		mii_txdv => so_dv,
		mii_txd  => so_data,

		so_clk   => udpso_clk,
		so_dv    => udpso_dv,
		so_data  => udpso_data);

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	port map (
		sin_clk   => udpso_clk,
		sin_dv    => udpso_dv,
		sin_data  => udpso_data,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data);

	rgtrmap_b : block
		constant rgtrid_selhz : std_logic_vector := x"10";
		constant rgtrid_selvt : std_logic_vector := x"11";
	begin
		process(si_clk)
		begin
			if rising_edge(si_clk) then
				if rgtr_dv='1' then
					case rgtr_id is
					when rgtrid_selhz =>
						hz_req <= '1';
						hz_sel <= rgtr_data(6-1 downto  0);
					when rgtrid_selvt =>
						vt_req <= '1';
						vt_sel <= rgtr_data(6-1 downto  0);
					when others =>
					end case;
				else
					if hz_rdy='1' then
						hz_req <= '0';
					end if;
					if vt_rdy='1' then
						vt_req <= '0';
					end if;
				end if;
			end if;
		end process;

	end block;

--	downsampler_e : entity hdl4fpga.scopeio_downsampler
--	port map (
--		input_clk   => input_clk,
--		input_ena   => input_ena,
--		input_data  => input_data,
--		factor_data => rgtr_data(hzscale_rgtr),
--		output_ena  => downsample_ena,
--		output_data => downsample_data);
	downsample_data <= input_data;
	downsample_ena  <= input_ena;

	amp_b : block
		subtype amp_chnl is natural range 10-1 downto  0;
		subtype amp_sel  is natural range 18-1 downto 10;

		constant sample_length : natural := input_data'length/inputs;
		signal output_ena : std_logic_vector(0 to inputs-1);
	begin
		amp_g : for i in 0 to inputs-1 generate
			subtype sample_range is natural range i*sample_length to (i+1)*sample_length-1;

			function to_bitrom (
				value : natural_vector;
				size  : natural)
				return std_logic_vector is
				variable retval : unsigned(0 to value'length*size-1);
			begin
				for i in value'range loop
					retval(0 to size-1) := to_unsigned(value(i), size);
					retval := retval rol size;
				end loop;
				return std_logic_vector(retval);
			end;

			signal gain_addr  : std_logic_vector(unsigned_num_bits(vt_gain'length-1)-1 downto 0);
			signal gain_value : std_logic_vector(18-1 downto 0);
		begin

			mult_e : entity hdl4fpga.rom 
			generic map (
				bitrom => to_bitrom(vt_gain,18))
			port map (
				clk  => input_clk,
				addr => gain_addr,
				data => gain_value);

			process (so_clk)
			begin
				if rising_edge(so_clk) then
					if to_integer(unsigned(rgtr_data(amp_chnl)))=i then
						gain_addr <= rgtr_data(amp_chnl)(gain_addr'range);
					end if;
				end if;
			end process;

			amp_e : entity hdl4fpga.scopeio_amp
			port map (
				input_clk     => input_clk,
				input_ena     => downsample_ena,
				input_sample  => downsample_data(sample_range),
				gain_value    => gain_value,
				output_ena    => output_ena(i),
				output_sample => ampsample_data(sample_range));

		end generate;

		ampsample_ena <= output_ena(0);
--				ampsample_ena <= downsample_ena;
--				ampsample_data <= downsample_data;
	end block;

--	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
--	generic map (
--		inputs => inputs)
--	port map (
--		input_clk     => input_clk,
--		input_ena     => ampsample_ena,
--		input_data    => ampsample_data,
--		trigger_req   => trigger_req,
--		trigger_rgtr  => rgtr_data(trigger_rgtr),
--		trigger_level => trigger_level,
--		capture_rdy   => capture_rdy,
--		capture_req   => capture_req,
--		output_data   => triggersample_data);

	triggersample_ena  <= ampsample_ena;
	triggersample_data <= ampsample_data;

--	storage_b : block
--
--
--		signal mem_full : std_logic;
--		signal mem_clk  : std_logic;
--
--		signal wr_clk   : std_logic;
--		signal wr_ena   : std_logic;
--		signal wr_addr  : std_logic_vector(storage_addr'range);
--		signal wr_data  : std_logic_vector(0 to storage_word'length*inputs-1);
--		signal rd_clk   : std_logic;
--		signal rd_addr  : std_logic_vector(wr_addr'range);
--		signal rd_data  : std_logic_vector(wr_data'range);
--
--	begin
--
--		resize_p : process (triggersample_data)
--			variable aux1 : unsigned(0 to wr_data'length-1);
--			variable aux2 : unsigned(0 to triggersample_data'length-1);
--		begin
--			aux1 := (others => '-');
--			aux2 := unsigned(triggersample_data);
--			for i in 0 to inputs-1 loop
--				aux1(storage_word'range) := aux2(storage_word'range);
--				aux1 := aux1 rol storage_word'length;
--				aux2 := aux2 rol triggersample_data'length/inputs;
--			end loop;
----			wr_data <= std_logic_vector(aux1);
--		end process;
--
--		capture_rdy <= mem_full;
--		wr_clk      <= input_clk;
--		wr_ena      <= '1'; --capture_req;
--		wr_data     <= triggersample_data;
--
--		rd_clk <= video_clk;
--		gen_addr_p : process (wr_clk)
--			variable aux : unsigned(0 to wr_addr'length) := (others => '0');
--		begin
--			if rising_edge(wr_clk) then
--				if wr_ena='0' then
--					aux := (others => '0');
--				else
--					aux := aux + 1;
--				end if;
----				wr_data <= ('0','0', '0', '0', others => '1');
----				if wr_addr=std_logic_vector(to_unsigned(0,wr_addr'length)) then
----					wr_data <= ('0', '0', '1', others => '0');
----				elsif wr_addr=std_logic_vector(to_unsigned(1,wr_addr'length)) then
----					wr_data <= ('0', '0', '1', others => '0');
----				elsif wr_addr=std_logic_vector(to_unsigned(1600,wr_addr'length)) then
----					wr_data <= ('0', '0', '1', others => '0');
----				elsif wr_addr=std_logic_vector(to_unsigned(1601,wr_addr'length)) then
----					wr_data <= ('0', '0', '1', others => '0');
----				end if;
----				wr_data  <= std_logic_vector(resize(aux,wr_data'length));
--				wr_addr  <= std_logic_vector(aux(1 to wr_addr'length));
--				mem_full <= aux(0);
--			end if;
--		end process;
--
--		rd_addr_e : entity hdl4fpga.align
--		generic map (
--			n => rd_addr'length,
--			d => (rd_addr'range => 1))
--		port map (
--			clk => rd_clk,
--			di  => storage_addr,
--			do  => rd_addr);
--
--		mem_e : entity hdl4fpga.dpram 
--		port map (
--			wr_clk  => wr_clk,
--			wr_ena  => wr_ena,
--			wr_addr => wr_addr,
--			wr_data => wr_data,
--			rd_addr => rd_addr,
--			rd_data => rd_data);
--
--		rd_data_e : entity hdl4fpga.align
--		generic map (
--			n => rd_data'length,
--			d => (rd_data'range => 1))
--		port map (
--			clk => rd_clk,
--			di  => rd_data,
--			do  => storage_data);
--
--	end block;

	 video_b : block

		constant vgaio_latency : natural := storage_data'length+4+4;

		signal trigger_dot : std_logic;
		signal traces_dots : std_logic_vector(0 to inputs-1);
		signal grid_dot    : std_logic;
		signal hz_dot    : std_logic;
		signal vt_dot    : std_logic;
	begin
		video_e : entity hdl4fpga.video_vga
		generic map (
			mode => vlayout_tab(vlayout_id).mode,
			n    => 11)
		port map (
			clk   => video_clk,
			hsync => video_hs,
			vsync => video_vs,
			hcntr => video_hcntr,
			vcntr => video_vcntr,
			don   => video_hon,
			frm   => video_frm,
			nhl   => video_hzl);

		video_vld <= video_hon and video_frm;

		vgaio_e : entity hdl4fpga.align
		generic map (
			n => video_io'length,
			d => (video_io'range => vgaio_latency))
		port map (
			clk   => video_clk,
			di(0) => video_hs,
			di(1) => video_vs,
			di(2) => video_vld,
			do    => video_io);

		graphics_b : block

			function to_naturalvector (
				constant vlayout : video_layout;
				constant param   : natural range 0 to 3)
				return natural_vector is
				variable rval : natural_vector(0 to vlayout.num_of_seg-1);
			begin
				for i in 0 to vlayout.num_of_seg-1 loop
					case param is
					when 0 =>
						rval(i) := 0;
					when 1 => 
						rval(i) := vlayout.sgmnt.y*i;
					when 2 => 
						rval(i) := vlayout.scr_width;
					when 3 => 
						rval(i) := vlayout.sgmnt.y-1;
					end case;
				end loop;
				return rval;
			end;

			signal win_don : std_logic_vector(0 to vlayout_tab(vlayout_id).num_of_seg-1);
			signal win_frm : std_logic_vector(0 to vlayout_tab(vlayout_id).num_of_seg-1);
			signal phon   : std_logic;
			signal pfrm   : std_logic;

		begin

			win_mngr_e : entity hdl4fpga.win_mngr
			generic map (
				x     => to_naturalvector(vlayout_tab(vlayout_id), 0),
				y     => to_naturalvector(vlayout_tab(vlayout_id), 1),
				width => to_naturalvector(vlayout_tab(vlayout_id), 2),
				height=> to_naturalvector(vlayout_tab(vlayout_id), 3))
			port map (
				video_clk  => video_clk,
				video_x    => video_hcntr,
				video_y    => video_vcntr,
				video_don  => video_hon,
				video_frm  => video_frm,
				win_don    => win_don,
				win_frm    => win_frm);

			phon <= not setif(win_don=(win_don'range => '0'));
			pfrm <= not setif(win_frm=(win_frm'range => '0'));

			sgmnt_b : block
				constant sgmnt : square := vlayout_tab(vlayout_id).sgmnt;

				signal pwin_y : std_logic_vector(unsigned_num_bits(sgmnt.y-1)-1 downto 0);
				signal pwin_x : std_logic_vector(unsigned_num_bits(vlayout_tab(vlayout_id).scr_width-1)-1 downto 0);
				signal p_hzl  : std_logic;

				signal win_x  : std_logic_vector(unsigned_num_bits(vlayout_tab(vlayout_id).sgmnt.width-1)-1  downto 0);
				signal win_y  : std_logic_vector(unsigned_num_bits(vlayout_tab(vlayout_id).sgmnt.height-1)-1  downto 0);
				signal x      : std_logic_vector(win_x'range);
				signal y      : std_logic_vector(win_y'range);
				signal cfrm   : std_logic_vector(0 to 3-1);
				signal cdon   : std_logic_vector(cfrm'range);
				signal wena   : std_logic;
				signal wfrm   : std_logic;
				signal w_hzl  : std_logic;
				signal grid_on : std_logic;
				signal hz_on  : std_logic;
				signal vt_on  : std_logic;
			begin

				latency_phzl_e : entity hdl4fpga.align
				generic map (
					n => 1,
					d => (0 => 2))
				port map (
					clk   => video_clk,
					di(0) => video_hzl,
					do(0) => p_hzl);

				parent_e : entity hdl4fpga.win
				port map (
					video_clk => video_clk,
					video_hzl => p_hzl,
					win_frm   => pfrm,
					win_ena   => phon,
					win_x     => pwin_x,
					win_y     => pwin_y);

				mngr_e : entity hdl4fpga.win_mngr
				generic map (
					x      => natural_vector'(0 => sgmnt.x-1,      1 => sgmnt.x-8*5-2,  2 => sgmnt.x-1),
					y      => natural_vector'(0 => 0,              1 => 0,              2 => sgmnt.height+2),
					width  => natural_vector'(0 => sgmnt.width+1,  1 => 8*5,            2 => sgmnt.width+1),
					height => natural_vector'(0 => sgmnt.height+1, 1 => sgmnt.height+1, 2 => 8))
				port map (
					video_clk  => video_clk,
					video_x    => pwin_x,
					video_y    => pwin_y,
					video_don  => phon,
					video_frm  => pfrm,
					win_don    => cdon,
					win_frm    => cfrm);

				wena <= not setif(cdon=(cdon'range => '0'));
				wfrm <= not setif(cfrm=(cfrm'range => '0'));

				latency_whzl_e : entity hdl4fpga.align
				generic map (
					n => 1,
					d => (0 => 2))
				port map (
					clk   => video_clk,
					di(0) => p_hzl,
					do(0) => w_hzl);

				win_e : entity hdl4fpga.win
				port map (
					video_clk => video_clk,
					video_hzl => w_hzl,
					win_frm   => wfrm,
					win_ena   => wena,
					win_x     => win_x,
					win_y     => win_y);

				winfrm_lat_e : entity hdl4fpga.align
				generic map (
					n => win_frm'length,
					d => (win_frm'range => 2))
				port map (
					clk => video_clk,
					di  => win_frm,
					do  => storage_bsel);

				storage_addr_p : process (storage_bsel)
					variable base : std_logic_vector(storage_base'range);
				begin
					base := (base'range => '0');
					for i in storage_bsel'range loop
						base := base or wirebus(
							std_logic_vector(to_unsigned(vlayout_tab(vlayout_id).sgmnt.width*i, storage_addr'length)),
							(0 => storage_bsel(i)));
					end loop;
					storage_base <= std_logic_vector(base);
				end process;
				storage_addr <= std_logic_vector(unsigned(win_x) + unsigned(storage_base));

				latency_b : block
				begin
					latency_on_e : entity hdl4fpga.align
					generic map (
						n => cdon'length,
						d => (cdon'range => 2))
					port map (
						clk   => video_clk,
						di    => cdon,
						do(0) => grid_on,
						do(1) => hz_on,
						do(2) => vt_on);

					latency_x_e : entity hdl4fpga.align
					generic map (
						n => win_x'length,
						d => (win_x'range => 2))
					port map (
						clk => video_clk,
						di  => win_x,
						do  => x);

					latency_y_e : entity hdl4fpga.align
					generic map (
						n => win_y'length,
						d => (win_y'range => 1))
					port map (
						clk => video_clk,
						di  => win_y,
						do  => y);

				end block;

				scopeio_segment_e : entity hdl4fpga.scopeio_segment
				generic map (
					latency       => storage_data'length+4,
					inputs        => inputs)
				port map (
					in_clk        => si_clk,
					hz_req        => hz_req,
					hz_rdy        => hz_rdy,
					hz_sel        => hz_sel,
					hz_on         => hz_on,

					vt_req        => vt_req,
					vt_rdy        => vt_rdy,
					vt_sel        => hz_sel,
					vt_on         => vt_on,

					video_clk     => video_clk,
					grid_on       => grid_on,
					x             => x,
					y             => y,
					samples       => storage_data,
					trigger_level => trigger_level,
					grid_dot      => grid_dot,
					hz_dot        => hz_dot,
					vt_dot        => vt_dot,
					trigger_dot   => trigger_dot,
					traces_dots   => traces_dots);
			end block;

		end block;

		scopeio_palette_e : entity hdl4fpga.scopeio_palette
		port map (
			traces_fg   => std_logic_vector'("010"),
			traces_dots => traces_dots, 
			grid_fg     => std_logic_vector'("100"), 
			grid_bg     => std_logic_vector'("000"), 
			grid_dot    => grid_dot,
			hz_fg       => std_logic_vector'("100"),
			hz_dot      => hz_dot,
			vt_fg       => std_logic_vector'("100"),
			vt_dot      => vt_dot,
			video_rgb   => video_pixel);
	end block;

	video_rgb   <= (video_rgb'range => video_io(2)) and video_pixel;
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
