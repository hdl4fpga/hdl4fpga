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
use hdl4fpga.videopkg.all;

entity demo_graphics is
	generic (
		debug        : boolean := false;
		profile      : natural;

		ddr_tcp      : natural;
		fpga         : natural;
		mark         : natural;
		sclk_phases  : natural;
		sclk_edges   : natural;
		data_phases  : natural;
		data_edges   : natural;
		cmmd_gear    : natural := 1;
		data_gear    : natural;
		bank_size    : natural;
		addr_size    : natural;
		coln_size    : natural;
		word_size    : natural;
		byte_size    : natural;

		timing_id    : videotiming_ids;
		red_length   : natural := 5;
		green_length : natural := 6;
		blue_length  : natural := 5;

		fifo_size    : natural := 8*8192);

	port (
		sio_clk      : in  std_logic;
		sin_frm      : in  std_logic;
		sin_irdy     : in  std_logic;
		sin_trdy     : out std_logic := '1';
		sin_data     : in  std_logic_vector;
		sout_frm     : buffer std_logic;
		sout_irdy    : buffer std_logic;
		sout_trdy    : in  std_logic;
		sout_end     : buffer std_logic;
		sout_data    : out std_logic_vector;

		video_clk    : in  std_logic;
		video_shift_clk :  in std_logic := '-';
		video_hzsync : buffer std_logic;
		video_vtsync : buffer std_logic;
		video_blank  : buffer std_logic;
		video_pixel  : buffer std_logic_vector;
		dvid_crgb    : out std_logic_vector(7 downto 0);

		dmacfg_clk   : in  std_logic;
		ctlr_clks    : in  std_logic_vector(0 to sclk_phases/sclk_edges-1);
		ctlr_rst     : in  std_logic;
		ctlr_bl      : in  std_logic_vector(0 to 3-1);
		ctlr_cl      : in  std_logic_vector(0 to 3-1);

		ctlrphy_rst  : out std_logic;
		ctlrphy_cke  : out std_logic;
		ctlrphy_cs   : out std_logic;
		ctlrphy_ras  : out std_logic;
		ctlrphy_cas  : out std_logic;
		ctlrphy_we   : out std_logic;
		ctlrphy_b    : out std_logic_vector(bank_size-1 downto 0);
		ctlrphy_a    : out std_logic_vector(addr_size-1 downto 0);
		ctlrphy_dsi  : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		ctlrphy_dst  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dso  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dmi  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dmt  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dmo  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dqi  : in  std_logic_vector(data_gear*word_size-1 downto 0);
		ctlrphy_dqt  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		ctlrphy_dqo  : out std_logic_vector(data_gear*word_size-1 downto 0);
		ctlrphy_sto  : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		ctlrphy_sti  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		tp           : out std_logic_vector(1 to 32));

	constant fifodata_depth : natural := (fifo_size/(ctlrphy_dqi'length));

end;

architecture mix of demo_graphics is

	signal dmactlr_addr   : std_logic_vector(bank_size+addr_size+coln_size-1 downto 0);
	signal dmactlr_len    : std_logic_vector(dmactlr_addr'range);

	signal dmacfgio_req   : std_logic;
	signal dmacfgio_rdy   : std_logic;
	signal dmaio_req      : std_logic := '0';
	signal dmaio_rdy      : std_logic;
	signal dmaio_ack      : std_logic_vector(8-1 downto 0);
	signal dmaio_len      : std_logic_vector(dmactlr_len'range);
	signal dmaio_addr     : std_logic_vector(32-1 downto 0);
	signal dmaio_we       : std_logic;

	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal dummy          : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm        : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;
	signal ctlr_dio_req   : std_logic;

    signal base_addr      : std_logic_vector(dmactlr_addr'range) := (others => '0');

	signal dmacfgvideo_req : std_logic;
	signal dmacfgvideo_rdy : std_logic;
	signal dmavideo_req   : std_logic;
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
	alias  dmavideo_gnt   : std_logic is dev_gnt(0);
	alias  dmaio_gnt      : std_logic is dev_gnt(1);

	signal ctlr_ras       : std_logic;
	signal ctlr_cas       : std_logic;

	alias ctlr_clk : std_logic is ctlr_clks(0);
begin

	sio_b : block

		constant fifo_depth   : natural := 4;
		constant fifo_gray    : boolean := false;

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
		signal rgtr_data      : std_logic_vector(0 to 32-1);
		signal data_frm       : std_logic;
		signal data_irdy      : std_logic;
		signal data_ptr       : std_logic_vector(8-1 downto 0);

		signal rgtr_ack       : std_logic_vector(dmaio_ack'range);
		signal rgtr_dmaaddr   : std_logic_vector(32-1 downto 0);
		signal rgtr_dmalen    : std_logic_vector(24-1 downto 0);
		signal sigrgtr_frm    : std_logic;

		signal metaram_irdy   : std_logic;
		signal metaram_data   : std_logic_vector(sout_data'range);

		signal dmasin_irdy    : std_logic;
		signal dmadata_irdy   : std_logic;
		signal dmadata_trdy   : std_logic;
		signal rgtr_dmadata   : std_logic_vector(ctlr_di'length-1 downto 0);
		signal datactlr_irdy  : std_logic;
		signal dmaack_irdy    : std_logic;
		signal dmaack_trdy    : std_logic;
		signal dmaaddr_irdy   : std_logic;
		signal dmaaddr_trdy   : std_logic;
		signal dmalen_irdy    : std_logic;
		signal dmalen_trdy    : std_logic;
		signal dmaio_trdy     : std_logic;
		signal dmaio_next     : std_logic;
		signal dmaioack_irdy  : std_logic;
		signal dmaiolen_irdy  : std_logic;
		signal dmaioaddr_irdy : std_logic;

		signal meta_data      : std_logic_vector(metaram_data'range);
		signal meta_trdy      : std_logic;
		signal meta_end       : std_logic;

		signal sio_dmaio      : std_logic_vector(0 to (2+(2+1)+(2+4))*8-1);
		signal siodmaio_irdy  : std_logic;
		signal siodmaio_trdy  : std_logic;
		signal siodmaio_end   : std_logic;
		signal siodmaio_data  : std_logic_vector(sout_data'range);

		signal acktx_irdy     : std_logic;
		signal acktx_trdy     : std_logic;
		signal acktx_data     : std_logic_vector(rgtr_ack'range);

		signal sodata_frm     : std_logic;
		signal sodata_irdy    : std_logic;
		signal sodata_trdy    : std_logic;
		signal sodata_end     : std_logic;
		signal sodata_data    : std_logic_vector(sout_data'range);

		signal debug_dmacfgio_req : std_logic;
		signal debug_dmacfgio_rdy : std_logic;
		signal debug_dmaio_req    : std_logic;
		signal debug_dmaio_rdy    : std_logic;

		constant octect       : natural := 8;
		constant word_bits    : natural := unsigned_num_bits(ctlr_di'length/octect-1);

		signal sout_req       : bit;
		signal sout_rdy       : bit;

		signal payload_size   : std_logic_vector(0 to 16-1) := x"0000";

	begin

		siosin_e : entity hdl4fpga.sio_sin
		port map (
			sin_clk   => sio_clk,
			sin_frm   => sin_frm,
			sin_irdy  => sin_irdy,
			sin_data  => sin_data,
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

		metaram_irdy <= rgtr_irdy and setif(rgtr_id=x"00");
		metaram_data <= std_logic_vector(resize(unsigned(rgtr_data), metaram_data'length));
		metaram_e : entity hdl4fpga.sio_ram
		generic map (
			mem_size => 64*8)
		port map (
			si_clk   => sio_clk,
			si_frm   => rgtr_frm,
			si_irdy  => metaram_irdy,
			si_data  => metaram_data,

			so_clk   => sio_clk,
			so_frm   => sout_frm,
			so_irdy  => sout_trdy,
			so_trdy  => meta_trdy,
			so_end   => meta_end,
			so_data  => meta_data);

		acktx_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => 4,
			latency    => 2,
			async_mode => true,
			check_sov  => true,
			check_dov  => true,
			gray_code  => fifo_gray)
		port map (
			src_clk    => dmacfg_clk,
			src_irdy   => dmaio_next,
			src_trdy   => open, --dmaioack_irdy,
			src_data   => dmaio_ack,

			dst_frm    => ctlr_inirdy,
			dst_clk    => sio_clk,
			dst_irdy   => acktx_irdy,
			dst_trdy   => acktx_trdy,
			dst_data   => acktx_data);

		process (sio_clk)
		begin
			if rising_edge(sio_clk) then
				if (sout_rdy xor sout_req)='0' then
					if acktx_irdy='1' then
						sout_rdy <= not sout_req;
					end if;
					acktx_trdy <= '0';
				elsif (sout_irdy and sout_trdy and sout_end)='1' then
					sout_rdy   <= sout_req;
					acktx_trdy <= '1';
				else
					acktx_trdy <= '0';
				end if;
			end if;
		end process;

		process (sio_clk)
		begin
			if rising_edge(sio_clk) then
				sio_dmaio <=
--					reverse(reverse(x"00" & x"09"),8) &	-- UDP Length
					reverse(reverse(payload_size),8) &	-- UDP Length
					reverse(x"01" & x"00" & reverse(acktx_data) &
					rid_dmaaddr & x"03" & dmalen_trdy & dmaaddr_trdy & dmaiolen_irdy & dmaioaddr_irdy & x"0000" & x"000", 8);
				payload_size <= std_logic_vector(unsigned'(x"0009") + resize(shift_left(unsigned(dmaio_len)+1,2), payload_size'length));
			end if;
		end process;

		siodmaio_irdy <= '0' when meta_end='0' else sout_trdy;
		siodma_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => sio_dmaio,
			sio_clk  => sio_clk,
			sio_frm  => sout_frm,
			sio_irdy => siodmaio_irdy,
			sio_trdy => siodmaio_trdy,
			so_end   => siodmaio_end,
			so_data  => siodmaio_data);


		sout_frm  <= to_stdulogic(sout_req xor sout_rdy);
		sout_irdy <= meta_trdy     when meta_end='0' else
		             siodmaio_trdy when siodmaio_end='0' else
		             sodata_irdy;
		sout_end  <= '0' when meta_end='0'     else
					 '0' when siodmaio_end='0' else
					 sodata_end;
		sout_data <= meta_data     when meta_end='0'     else
		             siodmaio_data when siodmaio_end='0' else
		             sodata_data;

		dmaack_irdy <= setif(rgtr_id=rid_ack) and rgtr_dv and rgtr_irdy;
		rgtr_ack <= reverse(std_logic_vector(resize(unsigned(rgtr_data), rgtr_ack'length)),8);
		ackrx_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => fifo_depth,
			latency    => setif(profile=0, 0, 1),
			async_mode => true,
			check_sov  => true,
			check_dov  => true,
			gray_code  => fifo_gray)
		port map (
			src_clk    => sio_clk,
			src_irdy   => dmaack_irdy,
			src_trdy   => dmaack_trdy,
			src_data   => rgtr_ack,

			dst_frm    => ctlr_inirdy,
			dst_clk    => dmacfg_clk,
			dst_irdy   => dmaioack_irdy,
			dst_trdy   => dmaio_next,
			dst_data   => dmaio_ack);

		dmaaddr_irdy <= setif(rgtr_id=rid_dmaaddr) and rgtr_dv and rgtr_irdy;
		rgtr_dmaaddr <= reverse(std_logic_vector(resize(unsigned(rgtr_data), rgtr_dmaaddr'length)),8);
		dmaaddr_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => fifo_depth,
			latency    => setif(profile=0, 0, 1),
			async_mode => true,
			check_sov  => true,
			check_dov  => true,
			gray_code  => fifo_gray)
		port map (
			src_clk    => sio_clk,
			src_irdy   => dmaaddr_irdy,
			src_trdy   => dmaaddr_trdy,
			src_data   => rgtr_dmaaddr,

			dst_frm    => ctlr_inirdy,
			dst_clk    => dmacfg_clk,
			dst_irdy   => dmaioaddr_irdy,
			dst_trdy   => dmaio_next,
			dst_data   => dmaio_addr);
		dmaio_we <= not dmaio_addr(dmaio_addr'left);

		dmalen_irdy <= setif(rgtr_id=rid_dmalen) and rgtr_dv and rgtr_irdy;
		rgtr_dmalen <= std_logic_vector(resize(unsigned(reverse(rgtr_data, 8)), rgtr_dmalen'length));
		dmalen_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => fifo_depth,
			latency    => setif(profile=0, 0, 1),
			async_mode => true,
			check_sov  => true,
			check_dov  => true,
			gray_code  => fifo_gray)
		port map (
			src_clk    => sio_clk,
			src_irdy   => dmalen_irdy,
			src_trdy   => dmalen_trdy,
			src_data   => rgtr_dmalen(dmaio_len'range),

			dst_frm    => ctlr_inirdy,
			dst_clk    => dmacfg_clk,
			dst_irdy   => dmaiolen_irdy,
			dst_trdy   => dmaio_next,
			dst_data   => dmaio_len);
		dmaio_next <= dmaio_trdy;

		dmadata_irdy <= data_irdy and setif(rgtr_id=rid_dmadata) and setif(data_ptr(word_bits-1 downto 0)=(word_bits-1 downto 0 => '0'));
		rgtr_dmadata <= reverse(std_logic_vector(resize(unsigned(rgtr_data), rgtr_dmadata'length)),8);
		dmadata_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => fifodata_depth,
			async_mode => true,
			latency    => setif(profile=0, 3, 2),
			check_sov  => true,
			check_dov  => true,
			gray_code  => false)
		port map (
			src_clk    => sio_clk,
			src_irdy   => dmadata_irdy,
			src_trdy   => dmadata_trdy,
			src_data   => rgtr_dmadata,

			dst_frm    => ctlr_inirdy,
			dst_clk    => ctlr_clk,
			dst_trdy   => ctlr_di_req,
			dst_data   => ctlr_di);
		ctlr_di_dv <= ctlr_di_req;

		base_addr_e : entity hdl4fpga.sio_rgtr
		generic map (
			rid  => x"19")
		port map (
			rgtr_clk  => sio_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => base_addr);

		debug_dmacfgio_req <= dmacfgio_req xor  to_stdulogic(to_bit(dmacfgio_rdy));
		debug_dmacfgio_rdy <= dmacfgio_req xnor to_stdulogic(to_bit(dmacfgio_rdy));
		debug_dmaio_req    <= dmaio_req    xor  to_stdulogic(to_bit(dmaio_rdy));
		debug_dmaio_rdy    <= dmaio_req    xnor to_stdulogic(to_bit(dmaio_rdy));

		dmasin_irdy <= to_stdulogic(to_bit(dmaiolen_irdy and dmaioaddr_irdy));
		sio_dmahdsk_e : entity hdl4fpga.sio_dmahdsk
		port map (
			dmacfg_clk  => dmacfg_clk,
			dmaio_irdy  => dmasin_irdy,
			dmaio_trdy  => dmaio_trdy,

			dmacfg_req  => dmacfgio_req,
			dmacfg_rdy  => dmacfgio_rdy,

			ctlr_clk    => ctlr_clk,
			ctlr_inirdy => ctlr_inirdy,

			dma_req     => dmaio_req,
			dma_rdy     => dmaio_rdy);

		sodata_b : block

			signal ctlrio_irdy : std_logic;
			signal trans_req    : bit;
			signal trans_rdy    : bit;
			signal len_req      : bit;
			signal len_rdy      : bit;
			signal fifo_req     : bit;
			signal fifo_rdy     : bit;

			signal fifo_frm    : std_logic;
			signal fifo_irdy   : std_logic;
			signal fifo_trdy   : std_logic;
			signal fifo_data   : std_logic_vector(ctlr_do'range);
			signal fifo_length : std_logic_vector(16-1 downto 0);

			signal dmaout_irdy : std_logic;
			signal dmaout_data : std_logic_vector(ctlr_do'range);

			signal gnt_lat : std_logic;
		begin

			process (dmaio_gnt, ctlr_cl, ctlr_cas, ctlr_do_dv, ctlr_clk)
				variable q   : std_logic_vector(0 to 3+8-1);
				variable lat : std_logic;
			begin
				if rising_edge(ctlr_clk) then
					q := std_logic_vector(unsigned(q) srl 1);
				end if;
				q(0) := dmaio_gnt and ctlr_cas;
				lat  := word2byte(q(3 to 8+3-1), ctlr_cl);
				ctlrio_irdy <= ctlr_do_dv(0) and lat;
				gnt_lat     <= lat;
			end process;

			process (ctlr_clk)
				variable gnt : std_logic;
			begin
				if rising_edge(ctlr_clk) then
					if dmaio_gnt='1' then
						gnt := ctlr_rw;
					elsif gnt_lat='0' then
						if gnt='1' then
							trans_req <= not trans_rdy;
						end if;
						gnt := '0';
					end if;
				end if;
			end process;

			buffdv_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 to 0 => 3))
			port map (
				clk   => ctlr_clk,
				di(0) => ctlrio_irdy,
				do(0) => dmaout_irdy);

			buffdo_e : entity hdl4fpga.align
			generic map (
				n => ctlr_do'length,
				d => (0 to ctlr_do'length-1 => 3))
			port map (
				clk => ctlr_clk,
				di  => ctlr_do,
				do  => dmaout_data);

			dmadataout_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => (2*4*1*256/(ctlr_di'length/8)),
				async_mode => true,
				latency    => 2,
				gray_code  => false,
				check_sov  => false, --true,
				check_dov  => true)
			port map (
				src_clk  => ctlr_clk,
				src_irdy => dmaout_irdy,
				src_data => dmaout_data,

				dst_frm  => ctlr_inirdy,
				dst_clk  => sio_clk,
				dst_irdy => fifo_irdy,
				dst_trdy => fifo_trdy,
				dst_data => fifo_data);

			process (dmacfg_clk)
				variable length : unsigned(fifo_length'range);
			begin
				if rising_edge(dmacfg_clk) then
					if dmaioaddr_irdy='1' then
						if dmaiolen_irdy='1' then
							if dmaio_next='1' then
								if dmaio_we='0' then
									length := resize(unsigned(dmaio_len), length'length);
									for i in 1 to unsigned_num_bits(fifo_data'length/sodata_data'length)-1 loop
										length(length'left) := '1';
										length := length rol 1;
									end loop;
									fifo_length <= std_logic_vector(length);
									len_req     <= not len_rdy;
								end if;
							end if;
						end if;
					end if;
				end if;
			end process;

			process (sio_clk)
			begin
				if rising_edge(sio_clk) then
					if (trans_req xor trans_rdy)='1' and (len_req xor len_rdy)='1' then
						fifo_req  <= not fifo_rdy;
						if sodata_trdy='1' and sodata_end='1' then
							trans_rdy <= trans_req;
							fifo_rdy  <= fifo_req;
							len_rdy   <= len_req;
						end if;
					end if;
				end if;
			end process;
			fifo_frm <= to_stdulogic(fifo_req xor fifo_rdy);

			sodata_trdy <= '0' when siodmaio_end='0' else sout_trdy;
			sodata_e : entity hdl4fpga.so_data
			port map (
				sio_clk   => sio_clk,
				si_frm    => fifo_frm,
				si_irdy   => fifo_irdy,
				si_trdy   => fifo_trdy,
				si_data   => fifo_data,
				si_length => fifo_length,

				so_frm    => sodata_frm,
				so_irdy   => sodata_irdy,
				so_trdy   => sodata_trdy,
				si_end    => sodata_end,
				so_data   => sodata_data);

		end block;

	end block;

	adapter_b : block

		constant glat     : natural := 1;
		constant sync_lat : natural := 4;

		signal hzcntr      : std_logic_vector(unsigned_num_bits(modeline_tab(timing_id)(3)-1)-1 downto 0);
		signal vtcntr      : std_logic_vector(unsigned_num_bits(modeline_tab(timing_id)(7)-1)-1 downto 0);
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

		constant pixel_width : natural := pixel'length; -- Xilinx ISE's complain

	begin

		sync_e : entity hdl4fpga.video_sync
		generic map (
			timing_id => timing_id)
		port map (
			video_clk     => video_clk,
			video_hzcntr  => hzcntr,
			video_vtcntr  => vtcntr,
			video_hzsync  => hzsync,
			video_vtsync  => vtsync,
			video_hzon    => hzon,
			video_vton    => vton);

		process (dmavideo_gnt, ctlr_cl, ctlr_cas, ctlr_do_dv, ctlr_clk)
			variable q : std_logic_vector(0 to 3+8-1);
		begin
			if rising_edge(ctlr_clk) then
				q := std_logic_vector(unsigned(q) srl 1);
			end if;
			q(0) := dmavideo_gnt and ctlr_cas;
			ctlrvideo_irdy <= ctlr_do_dv(0) and word2byte(q(3 to 8+3-1), ctlr_cl);
		end process;

		graphicsdv_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => glat))
		port map (
			clk   => ctlr_clk,
			di(0) => ctlrvideo_irdy,
			do(0) => graphics_dv);

		graphicsdi_e : entity hdl4fpga.align
		generic map (
			n => ctlr_do'length,
			d => (0 to ctlr_do'length-1 => glat))
		port map (
			clk => ctlr_clk,
			di  => ctlr_do,
			do  => graphics_di);

		graphics_e : entity hdl4fpga.graphics
		generic map (
			video_width => modeline_tab(timing_id)(0))
		port map (
			ctlr_inirdy  => ctlr_inirdy,
			ctlr_clk     => ctlr_clk,
			ctlr_di_dv   => graphics_dv,
			ctlr_di      => graphics_di,
			base_addr    => base_addr,
			dmacfg_clk   => dmacfg_clk,
			dmacfg_req   => dmacfgvideo_req,
			dmacfg_rdy   => dmacfgvideo_rdy,
			dma_req      => dmavideo_req,
			dma_rdy      => dmavideo_rdy,
			dma_len      => dmavideo_len,
			dma_addr     => dmavideo_addr,
			video_clk    => video_clk,
			video_hzon   => hzon,
			video_vton   => vton,
			video_pixel  => pixel);

		topixel_e : entity hdl4fpga.align
		generic map (
			n => pixel_width,
			d => (0 to pixel_width => sync_lat))
		port map (
			clk => video_clk,
			di  => pixel,
			do  => video_pixel);

		tosync_e : entity hdl4fpga.align
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
		------------------

		dvi_b : block

			constant subpixel_length : natural := hdl4fpga.std.min(hdl4fpga.std.min(red_length, green_length), blue_length);

			signal dvid_blank : std_logic;
			signal in_red     : unsigned(0 to subpixel_length-1);
			signal in_green   : unsigned(0 to subpixel_length-1);
			signal in_blue    : unsigned(0 to subpixel_length-1);

		begin

			dvid_blank <= video_blank;

			process (video_pixel)
				variable pixel : unsigned(0 to video_pixel'length-1);
			begin
				pixel    := unsigned(video_pixel);
				in_red   <= pixel(in_red'range);
				pixel    := pixel sll red_length;
				in_green <= pixel(in_green'range);
				pixel    := pixel sll green_length;
				in_blue  <= pixel(in_blue'range);
			end process;

			vga2dvid_e : entity hdl4fpga.vga2dvid
			generic map (
				C_shift_clock_synchronizer => '0',
				C_ddr     => '1',
				C_depth   => subpixel_length)
			port map (
				clk_pixel => video_clk,
				clk_shift => video_shift_clk,
				in_red    => std_logic_vector(in_red),
				in_green  => std_logic_vector(in_green),
				in_blue   => std_logic_vector(in_blue),
				in_hsync  => video_hzsync,
				in_vsync  => video_vtsync,
				in_blank  => dvid_blank,
				out_clock => dvid_crgb(7 downto 6),
				out_red   => dvid_crgb(5 downto 4),
				out_green => dvid_crgb(3 downto 2),
				out_blue  => dvid_crgb(1 downto 0));

		end block;

	end block;

	dmacfg_req <= (0 => dmacfgvideo_req, 1 => dmacfgio_req);
	(0 => dmacfgvideo_rdy, 1 => dmacfgio_rdy) <= to_stdlogicvector(to_bitvector(dmacfg_rdy));

	dev_req <= (0 => dmavideo_req, 1 => dmaio_req);
	(0 => dmavideo_rdy, 1 => dmaio_rdy) <= to_stdlogicvector(to_bitvector(dev_rdy));
	dev_len  <= dmavideo_len  & dmaio_len(dmactlr_len'range);
	dev_addr <= dmavideo_addr & dmaio_addr(dmactlr_addr'range);
	dev_we   <= '0'           & dmaio_we;

	dmactlr_e : entity hdl4fpga.dmactlr
	generic map (
		fpga        => fpga,
		mark        => mark,
		tcp         => ddr_tcp,

		data_gear   => data_gear,
		bank_size   => bank_size,
		addr_size   => addr_size,
		coln_size   => coln_size)
	port map (
		devcfg_clk  => dmacfg_clk,
		devcfg_req  => dmacfg_req,
		devcfg_rdy  => dmacfg_rdy,
		dev_len     => dev_len,
		dev_addr    => dev_addr,
		dev_we      => dev_we,

		dev_req     => dev_req,
		dev_gnt     => dev_gnt,
		dev_rdy     => dev_rdy,

		ctlr_clk    => ctlr_clk,

		ctlr_inirdy => ctlr_inirdy,
		ctlr_refreq => ctlr_refreq,

		ctlr_irdy   => ctlr_irdy,
		ctlr_trdy   => ctlr_trdy,
		ctlr_ras    => ctlr_ras,
		ctlr_cas    => ctlr_cas,
		ctlr_rw     => ctlr_rw,
		ctlr_b      => ctlr_b,
		ctlr_a      => ctlr_a,
		ctlr_dio_req => ctlr_dio_req,
		ctlr_act    => ctlr_act);

	ctlr_dm <= (others => '0');
	ddrctlr_e : entity hdl4fpga.ddr_ctlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => ddr_tcp,

		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		data_phases  => data_phases,
		data_edges   => data_edges,
		data_gear    => data_gear,
		word_size    => word_size,
		byte_size    => byte_size)
	port map (
		ctlr_bl      => ctlr_bl,
		ctlr_cl      => ctlr_cl,

		ctlr_cwl     => "000",
		ctlr_wr      => "101",
		ctlr_rtt     => "--",

		ctlr_rst     => ctlr_rst,
		ctlr_clks    => ctlr_clks,
		ctlr_inirdy  => ctlr_inirdy,

		ctlr_irdy    => ctlr_irdy,
		ctlr_trdy    => ctlr_trdy,
		ctlr_rw      => ctlr_rw,
		ctlr_b       => ctlr_b,
		ctlr_a       => ctlr_a,
		ctlr_ras     => ctlr_ras,
		ctlr_cas     => ctlr_cas,
		ctlr_di_dv   => ctlr_di_dv,
		ctlr_di_req  => ctlr_di_req,
		ctlr_act     => ctlr_act,
		ctlr_di      => ctlr_di,
		ctlr_dm      => ctlr_dm,
		ctlr_do_dv   => ctlr_do_dv,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,
		ctlr_dio_req => ctlr_dio_req,

		phy_rst      => ctlrphy_rst,
		phy_cke      => ctlrphy_cke,
		phy_cs       => ctlrphy_cs,
		phy_ras      => ctlrphy_ras,
		phy_cas      => ctlrphy_cas,
		phy_we       => ctlrphy_we,
		phy_b        => ctlrphy_b,
		phy_a        => ctlrphy_a,
		phy_dmi      => ctlrphy_dmi,
		phy_dmt      => ctlrphy_dmt,
		phy_dmo      => ctlrphy_dmo,

		phy_dqi      => ctlrphy_dqi,
		phy_dqt      => ctlrphy_dqt,
		phy_dqo      => ctlrphy_dqo,
		phy_sti      => ctlrphy_sti,
		phy_sto      => ctlrphy_sto,

		phy_dqsi     => ctlrphy_dsi,
		phy_dqso     => ctlrphy_dso,
		phy_dqst     => ctlrphy_dst);

end;
