-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.videopkg.all;

entity app_graphics is
	generic (
		debug        : boolean := false;
		profile      : natural;
		fifo_size    : natural := 8*8192;
		intrp_trans  : boolean := true;

		settings     : string;
		sdram_freq   : real;
		burst_length : natural := 0;
		dvid_fifo    : boolean := false);
	port (
		sin_clk       : in  std_logic;
		sin_frm       : in  std_logic;
		sin_irdy      : in  std_logic := '1';
		sin_trdy      : out std_logic := '1';
		sin_data      : in  std_logic_vector;
		sout_clk      : in  std_logic;
		sout_frm      : buffer std_logic;
		sout_irdy     : buffer std_logic;
		sout_trdy     : in  std_logic := '1';
		sout_end      : buffer std_logic;
		sout_data     : out std_logic_vector;

		video_clk     : in  std_logic := '0';
		video_shift_clk :  in std_logic := '-';
		video_hzsync  : buffer std_logic;
		video_vtsync  : buffer std_logic;
		video_blank   : buffer std_logic;
		video_pixel   : buffer std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
		dvid_crgb     : out std_logic_vector(4*settings**".video.gear=1"-1 downto 0);

		ctlr_clk      : in  std_logic;
		ctlr_rst      : in  std_logic;
		ctlr_al       : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.al=3"-1 downto 0) := (others => '0');
		ctlr_bl       : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.bl=3"-1 downto 0);
		ctlr_cl       : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.cl=3"-1 downto 0);
		ctlr_cwl      : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.cwl=3"-1 downto 0) := (others => '0');
		ctlr_rtt      : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.rtt=2"-1 downto 0) := (others => '0');
		ctlr_ods      : in std_logic_vector(hdo(string'(hdo(generation_db)**("."&string'(hdo(settings)**".sdram.chip_data.generation"))))**".length.ods=1"-1 downto 0) := (others => '0');

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
		ctlrphy_b     : out std_logic_vector(hdo(settings)**".sdram.chip_data.orgz.addr.ba=1"-1 downto 0);
		ctlrphy_a     : out std_logic_vector(hdo(settings)**".sdram.chip_data.orgz.addr.row=1"-1 downto 0);
		ctlrphy_dqst  : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"-1 downto 0);
		ctlrphy_dqso  : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"-1 downto 0);
		ctlrphy_dmi   : in  std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"*hdo(settings)**".sdram.chip_data.orgz.data.dm=1"-1 downto 0) := (others => '-');
		ctlrphy_dmo   : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"*hdo(settings)**".sdram.chip_data.orgz.data.dm=1"-1 downto 0);
		ctlrphy_dqt   : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"-1 downto 0);
		ctlrphy_dqi   : in  std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"*hdo(settings)**".sdram.chip_data.orgz.data.dq=1"-1 downto 0) := (others => '-');
		ctlrphy_dqo   : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"*hdo(settings)**".sdram.chip_data.orgz.data.dq=1"-1 downto 0);
		ctlrphy_dqv   : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"-1 downto 0);
		ctlrphy_sto   : out std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"-1 downto 0);
		ctlrphy_sti   : in  std_logic_vector(hdo(settings)**".sdram.phy_data.orgz.gear=1"*hdo(settings)**".sdram.chip_data.orgz.data.dm=1"-1 downto 0) := (others => '-');
		tp_sel        : in  std_logic_vector(0 to 4-1) := (others => '0');
		tp            : out std_logic_vector(1 to 32));

	constant fifodata_depth : natural := (fifo_size/(ctlrphy_dqi'length));

	constant chip_data      : string  := hdo(settings)**".sdram.chip_data";
	constant phy_data       : string  := hdo(settings)**".sdram.phy_data";
	constant video_settings : string  := hdo(settings)**".video";

	constant coln_size      : natural := hdo(chip_data)**".orgz.addr.col=1";
	constant gear           : natural := hdo(phy_data)**".orgz.gear=1";

	constant red_length     : natural := hdo(video_settings)**".pixel.R=8";
	constant green_length   : natural := hdo(video_settings)**".pixel.G=8";
	constant blue_length    : natural := hdo(video_settings)**".pixel.B=8";
	constant video_gear     : natural := hdo(video_settings)**(".gear=" & natural'image(dvid_crgb'length/4));
end;

architecture mix of app_graphics is

	type latencies is record
		ddro    : natural;
		dmaio   : natural;
		sodata  : natural;
		adapter : natural;
	end record;

	type latencies_vector is array (natural range <>) of latencies;
	constant latencies_tab : latencies_vector := (
		0 => (ddro => 2, dmaio => 3, sodata => 1, adapter => 1),  -- ULX3S BOARD
		1 => (ddro => 3, dmaio => 2, sodata => 0, adapter => 0),  -- NUHS3ADSP BOARD 200 MHz
		2 => (ddro => 3, dmaio => 3, sodata => 3, adapter => 3),  -- ULX4M BOARD
		3 => (ddro => 3, dmaio => 2, sodata => 1, adapter => 1)); -- NUHS3ADSP BOARD 166 MHz

	constant coln_bits    : natural := coln_size-(unsigned_num_bits(gear)-1);
	constant byte_size    : natural := ctlrphy_dqo'length/ctlrphy_dmo'length;
	signal dmactlr_addr   : std_logic_vector(ctlrphy_b'length+ctlrphy_a'length+coln_bits-1 downto 0);
	signal dmactlr_len    : std_logic_vector(dmactlr_addr'range);

	signal dmacfgio_req   : std_logic;
	signal dmacfgio_rdy   : std_logic;
	signal dmaio_req      : std_logic;
	signal dmaio_rdy      : std_logic;
	signal dmaio_ack      : std_logic_vector(0 to 8-1);
	signal dmaio_len      : std_logic_vector(dmactlr_len'range);
	signal dmaio_addr     : std_logic_vector(32-1 downto 0);
	signal dmaio_we       : std_logic;

	signal ctlr_frm       : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_alat      : std_logic_vector(2 downto 0);
	signal ctlr_blat      : std_logic_vector(2 downto 0);
	signal ctlr_b         : std_logic_vector(ctlrphy_b'length-1 downto 0);
	signal ctlr_a         : std_logic_vector(ctlrphy_a'length-1 downto 0);
	signal ctlr_di        : std_logic_vector(ctlrphy_dqi'range);
	signal ctlr_do        : std_logic_vector(ctlrphy_dqi'range);
	signal ctlr_do_dv     : std_logic_vector(ctlrphy_dmo'range);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;

	signal base_addr      : std_logic_vector(dmactlr_addr'range) := (others => '0');

	signal dmacfgvideo_req : std_logic := '0';
	signal dmacfgvideo_rdy : std_logic;
	signal dmavideo_req   : std_logic := '0';
	signal dmavideo_rdy   : std_logic;
	signal dmavideo_len   : std_logic_vector(dmactlr_len'range);
	signal dmavideo_addr  : std_logic_vector(dmactlr_addr'range);

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
	alias  dmavideo_do_dv : std_logic is dma_do_dv(0);
	alias  dmaio_do_dv    : std_logic is dma_do_dv(1);

	signal ctlr_fch       : std_logic;

begin

	sio_b : block

		constant siobyte_size : natural := 8;
		constant dataout_size : natural := 2*1024;

		constant rid_ack          : string := "0x01";
		constant rid_addr         : string := "0x16";
		constant rid_length       : string := "0x17";
		constant rid_data         : string := "0x18";
		constant rid_baddr        : string := "0x19";

		signal rgtr_frm           : std_logic;
		signal rgtr_irdy          : std_logic;
		signal rgtr_id            : std_logic_vector(8-1 downto 0);
		signal rgtr_len           : std_logic_vector(8-1 downto 0);
		signal rgtr_dv            : std_logic;
		signal rgtr_data          : std_logic_vector(0 to max(32,ctlr_di'length)-1);
		signal data_irdy          : std_logic;
		signal data_ptr           : std_logic_vector(8-1 downto 0);

		signal rgtr_dmaack        : std_logic_vector(dmaio_ack'range);
		signal rgtr_dmaaddr       : std_logic_vector(32-1 downto 0);
		signal rgtr_dmalen        : std_logic_vector(24-1 downto 0);
		signal sigrgtr_frm        : std_logic;

		signal rgtr0_irdy         : std_logic;
		signal rgtr0_data         : std_logic_vector(sout_data'range);

		signal dmasin_irdy        : std_logic;
		signal dmadata_irdy       : std_logic;
		signal dmadata_trdy       : std_logic;
		signal rgtr_dmadata       : std_logic_vector(ctlr_di'length-1 downto 0);
		signal datactlr_irdy      : std_logic;
		signal dmaaddr_irdy       : std_logic;
		signal dmaaddr_trdy       : std_logic;
		signal dmaio_trdy         : std_logic;
		signal dmaio_next         : std_logic;
		signal dmaioaddr_irdy     : std_logic;

		signal meta_data          : std_logic_vector(rgtr0_data'range);
		signal meta_avail         : std_logic;
		signal meta_irdy          : std_logic;
		signal meta_end           : std_logic;

		signal acktx_irdy         : std_logic;
		signal acktx_trdy         : std_logic;
		signal acktx_data         : std_logic_vector(rgtr_dmaack'range);

		signal debug_dmacfgio_req : std_logic;
		signal debug_dmacfgio_rdy : std_logic;
		signal debug_dmaio_req    : std_logic;
		signal debug_dmaio_rdy    : std_logic;

		constant word_bits        : natural := unsigned_num_bits(ctlrphy_dmo'length)-1;
		constant blword_bits      : natural := word_bits+unsigned_num_bits(setif(burst_length=0, gear, burst_length)/gear)-1;

		signal status             : std_logic_vector(0 to 8-1);
		alias  status_rw          : std_logic is status(status'right);

	begin

		siosin_e : entity hdl4fpga.sio_sin
		port map (
			clk   => sin_clk,
			frm   => sin_frm,
			irdy  => sin_irdy,
			data  => sin_data,
			rgtr_frm  => rgtr_frm,
			rgtr_irdy => rgtr_irdy);

    	siodecode_e : entity hdl4fpga.sio_decode
    	generic map (
    		rids => "["    & 
				"0x00"     & "," & 
    			rid_ack    & "," &
    			rid_addr   & "," &
    			rid_length & "," &
    			rid_data   & "," &
    			rid_baddr  & "]")
    	port map (
    		clk        => sin_clk,
    		frm        => rgtr_frm,
    		irdy       => rgtr_irdy,
    		trdy       => rgtr_trdy,
    		data       => sin_data,
    		rid_act    => rid_act,
    		length_act => '0',
    		pyl_act    => pyl_act,
    		pyl_frm    => pyl_frms,
    		pyl_irdy   => pyl_irdys);

		rgtr0_e : entity hdl4fpga.fifo
		generic map (
			debug => false,
			m     => 8)
		port map (
			src_clk  => sin_clk,
			src_frm  => rgtr0_frm,
			src_irdy => rgtr0_irdy,
			src_data => sin_data,
		
			dst_clk  => sout_clk,
			dst_irdy => meta_irdy,
			dst_trdy => sout_trdy,
			dst_data => rgtr0_data);

		ack_e : entity hdl4fpga.sio_rgtr
		port map (
			rgtr_clk  => sin_clk,
			rgtr_frm  => ,
			rgtr_irdy => ,
			rgtr_data => sin_data,
			data      => rgtr_ack);

		addr_e : entity hdl4fpga.sio_rgtr
		port map (
			rgtr_clk  => sin_clk,
			rgtr_frm  => ,
			rgtr_irdy => ,
			rgtr_data => sin_data,
			data      => rgtr_addr);

		length_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid       => rid_length)
		port map (
			rgtr_clk  => sin_clk,
			rgtr_frm  => ,
			rgtr_irdy => ,
			rgtr_data => sin_data,
			data      => rgtr_length);

		baddr_e : entity hdl4fpga.sio_rgtr
		port map (
			rgtr_clk  => sin_clk,
			rgtr_frm  => ,
			rgtr_irdy => ,
			rgtr_data => sin_data,
			data      => rgtr_baddr);

		dmadata_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => fifodata_depth,
			async_mode => true,
			latency    => latencies_tab(profile).dmaio,
			check_sov  => true,
			check_dov  => true)
		port map (
			mode(0)  => ,
			mode(1)  => ,

			src_clk  => sin_clk,
			src_irdy => dmadata_irdy,
			src_trdy => dmadata_trdy,
			src_data => rgtr_dmadata,

			dst_clk  => ctlr_clk,
			dst_irdy => ctlr_di_rdy,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		ctlr_di_dv <= ctlr_di_req;

		debug_dmacfgio_req <= dmacfgio_req xor  to_stdulogic(to_bit(dmacfgio_rdy));
		debug_dmacfgio_rdy <= dmacfgio_req xnor to_stdulogic(to_bit(dmacfgio_rdy));
		debug_dmaio_req    <= dmaio_req    xor  to_stdulogic(to_bit(dmaio_rdy));
		debug_dmaio_rdy    <= dmaio_req    xnor to_stdulogic(to_bit(dmaio_rdy));

		dmasin_irdy <= to_stdulogic(to_bit(dmaioaddr_irdy));
		sio_dmahdsk_e : entity hdl4fpga.sio_dmahdsk
		port map (
			dmacfg_clk  => sin_clk,
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
			signal siodmaio_data : std_logic_vector(sout_data'range);

			signal sodata_irdy   : std_logic;
			signal sodata_trdy   : std_logic;
			signal sodata_end    : std_logic;
			signal sodata_data   : std_logic_vector(sout_data'range);

		begin
			src_data <=
				dmaio_ack &
				std_logic_vector(resize(unsigned(dmaio_len), trans_length'length)) &
				dmaaddr_trdy & dmaioaddr_irdy & b"00000" & dmaio_addr(dmaio_addr'left);

				dst_irdy  => acktx_irdy,
				dst_trdy  => acktx_trdy,
				dst_data  => dst_data);

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

			process (sout_clk)
			begin
				if rising_edge(sout_clk) then
					if ctlr_inirdy='0' then
						sout_frm   <= '0';
						acktx_trdy <= '0';
					elsif sout_frm='0' then
						if acktx_irdy='1' then
							sout_frm <= meta_avail;
						end if;
						acktx_trdy <= '0';
					elsif acktx_trdy='1' then
						sout_frm   <= '0';
						acktx_trdy <= '0';
					elsif (sout_irdy and sout_trdy and sout_end)='1' then
						acktx_trdy <= '1';
					else
						acktx_trdy <= '0';
					end if;
				end if;
			end process;

			process (sout_frm, sout_clk)
				constant pfix_size   : natural := sio_dmaio'length/siobyte_size-2;
				variable pay_length  : unsigned(trans_length'range);
				variable data_length : unsigned(pay_length'range);
				variable hdr_length  : unsigned(pay_length'range);
			begin
				if rising_edge(sout_clk) then
					sio_dmaio <=
						reverse(reverse(std_logic_vector(resize(pay_length,16))),8) & reverse(
						rid_ack     & x"00" & acktx_data &
						rid_addr & x"00" & status, 8);

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

			siodmaio_irdy <= '0' when meta_end='0' else sout_trdy;
			siodma_e : entity hdl4fpga.sio_mux
			port map (
				mux_data => sio_dmaio,
				sio_clk  => sout_clk,
				sio_frm  => sout_frm,
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
					max_depth => (dataout_size/(ctlr_di'length/siobyte_size)),
					-- async_mode => false,
					latency   => 0,
					check_sov => false,
					check_dov => true)
				port map (
					mode(0)  => ctlr_inirdy,
					mode(1)  => ctlr_inirdy,
					src_clk  => ctlr_clk,
					src_irdy => dmaso_irdy,
					src_trdy => dmaso_trdy,
					src_data => dmaso_data,

					dst_clk  => sout_clk,
					-- dst_frm  => ctlr_inirdy,
					dst_irdy => fifo_irdy,
					dst_trdy => fifo_trdy,
					dst_data => fifo_data);

				process (sout_clk)
					variable byte_length : unsigned(fifo_length'range);
				begin
					if rising_edge(sout_clk) then
						byte_length := (others => '1');
						byte_length := byte_length srl (byte_length'length-(unsigned_num_bits(2**blword_bits*byte_size/sodata_data'length)-1));
						byte_length := byte_length or  (trans_length sll word_bits);
						fifo_length <= std_logic_vector(byte_length);
					end if;
				end process;

				process (sout_clk)
				begin
					if rising_edge(sout_clk) then
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
					sout_trdy;

				sodata_e : entity hdl4fpga.so_data
				port map (
					sio_clk   => sout_clk,
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

			sout_irdy <=
				meta_trdy     when     meta_end='0' else
				siodmaio_trdy when siodmaio_end='0' else
				'1'           when    status_rw='0' else
				sodata_irdy;

			sout_end  <=
				'0' when     meta_end='0' else
				'0' when siodmaio_end='0' else
				'1' when    status_rw='0' else
				sodata_end;
			sout_data <=
				meta_data     when     meta_end='0' else
				siodmaio_data when siodmaio_end='0' else
				reverse(sodata_data);

		end block;
	end block;

	adapter_b : block

		constant sync_lat  : natural := 4;
		constant dma_lat   : natural := latencies_tab(profile).adapter;

		signal hzcntr      : std_logic_vector(unsigned_num_bits(video_settings**".timings.hz.total"-1)-1 downto 0);
		signal vtcntr      : std_logic_vector(unsigned_num_bits(video_settings**".timings.vt.total"-1)-1 downto 0);
		signal hzsync      : std_logic;
		signal vtsync      : std_logic;
		signal hzon        : std_logic;
		signal vton        : std_logic;
		signal video_hzon  : std_logic;
		signal video_vton  : std_logic;

		signal graphics_di : std_logic_vector(ctlr_do'range);
		signal graphics_dv : std_logic;
		signal pixel       : std_logic_vector(video_pixel'range);

		signal ctlrvideo_irdy : std_logic;
		signal dma_rdy : std_logic;

		constant pixel_width : natural := pixel'length; -- Xilinx ISE's complaint

	begin

		sync_e : entity hdl4fpga.video_sync
		generic map (
			timings      => video_settings**".timings")
		port map (
			video_clk    => video_clk,
			video_hzcntr => hzcntr,
			video_vtcntr => vtcntr,
			video_hzsync => hzsync,
			video_vtsync => vtsync,
			video_hzon   => hzon,
			video_vton   => vton);

		dmao_dv_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 1-1 => dma_lat))
		port map (
			clk   => ctlr_clk,
			di(0) => dmavideo_do_dv,
			do(0) => graphics_dv);

		dmao_data_e : entity hdl4fpga.latency
		generic map (
			n => graphics_di'length,
			d => (0 to graphics_di'length-1 => dma_lat))
		port map (
			clk => ctlr_clk,
			di  => dma_do,
			do  => graphics_di);

		dmao_rdy_e : entity hdl4fpga.latency
		generic map (
			n => 1,
			d => (0 to 1-1 => dma_lat))
		port map (
			clk   => ctlr_clk,
			di(0) => dmavideo_rdy,
			do(0) => dma_rdy);

		graphics_e : entity hdl4fpga.graphics
		generic map (
			video_width => video_settings**".timings.hz.active")
		port map (
			ctlr_inirdy => ctlr_inirdy,
			ctlr_clk    => ctlr_clk,
			ctlr_di_dv  => graphics_dv,
			ctlr_di     => graphics_di,
			base_addr   => base_addr,
			dmacfg_clk  => sin_clk,
			dmacfg_req  => dmacfgvideo_req,
			dmacfg_rdy  => dmacfgvideo_rdy,
			dma_req     => dmavideo_req,
			dma_rdy     => dma_rdy,
			dma_len     => dmavideo_len,
			dma_addr    => dmavideo_addr,
			video_clk   => video_clk,
			video_hzon  => hzon,
			video_vton  => vton,
			video_pixel => pixel);

		topixel_e : entity hdl4fpga.latency
		generic map (
			n => pixel_width,
			d => (0 to pixel_width => sync_lat))
		port map (
			clk => video_clk,
			di  => pixel,
			do  => video_pixel);

		tosync_e : entity hdl4fpga.latency
		generic map (
			n => 4,
			d => (0 to 4-1 => sync_lat))
		port map (
			clk => video_clk,
			di(0) => hzon,
			di(1) => vton,
			di(2) => hzsync,
			di(3) => vtsync,
			do(0) => video_hzon,
			do(1) => video_vton,
			do(2) => video_hzsync,
			do(3) => video_vtsync);

		video_blank <= not video_hzon or not video_vton;

		-- HDMI/DVI VGA --
		----------------

		dvi_b : block
			signal dvid_blank : std_logic;
			signal dvid_rgb : std_logic_vector(0 to 3*8-1);

		begin

			dvid_blank <= video_blank;
			process (video_pixel)
				variable urgb  : unsigned(dvid_rgb'range);
				variable pixel : unsigned(0 to video_pixel'length-1);
			begin
				urgb := (others => '0');
				pixel := unsigned(video_pixel);

				urgb(0 to red_length-1) := pixel(0 to red_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll red_length;

				urgb(0 to green_length-1) := pixel(0 to green_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll green_length;

				urgb(0 to blue_length-1) := pixel(0 to blue_length-1);
				urgb  := urgb rol 8;
				pixel := pixel sll blue_length;

				dvid_rgb <= std_logic_vector(urgb);
			end process;

			dvi_e : entity hdl4fpga.dvi
			generic map (
				fifo_mode => false, --dvid_fifo,
				gear  => video_gear)
			port map (
				clk   => video_clk,
				rgb   => dvid_rgb,
				hsync => video_hzsync,
				vsync => video_vtsync,
				blank => dvid_blank,
				cclk  => video_shift_clk,
				chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
				chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
				chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
				chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

		end block;

	end block;

	dev_req    <= (0 => dmavideo_req,    1 => dmaio_req);
	dmacfg_req <= (0 => dmacfgvideo_req, 1 => dmacfgio_req);
	dev_len    <= to_stdlogicvector(to_bitvector(dmavideo_len  & dmaio_len(dmactlr_len'range)));
	dev_addr   <= to_stdlogicvector(to_bitvector(dmavideo_addr & dmaio_addr(dmactlr_addr'range)));
	dev_we     <= '0'           & to_stdulogic(to_bit(dmaio_we));
	(dmacfgvideo_rdy, dmacfgio_rdy) <= to_stdlogicvector(to_bitvector(dmacfg_rdy));
	(dmavideo_rdy,    dmaio_rdy)    <= to_stdlogicvector(to_bitvector(dev_rdy));

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
			bank_size    => ctlrphy_b'length,
			addr_size    => ctlrphy_a'length,
			coln_size    => coln_size)
		port map (
			devcfg_clk   => sin_clk,
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
			debug        => debug,
			chip_data    => chip_data,
			ctlr_tcp     => 1.0/sdram_freq,

			phy_data     => phy_data)
		port map (
			ctlr_alat    => ctlr_alat,
			ctlr_blat    => ctlr_blat,
			ctlr_al      => ctlr_al,
			ctlr_bl      => ctlr_bl,
			ctlr_cl      => ctlr_cl,

			ctlr_cwl     => ctlr_cwl,
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
			ctlr_dm      => (ctlrphy_dmi'range => '0'),
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
