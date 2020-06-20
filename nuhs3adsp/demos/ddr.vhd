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
use hdl4fpga.ddr_db.all;
use hdl4fpga.scopeiopkg.all;

library unisim;
use unisim.vcomponents.all;

architecture ddr of nuhs3adsp is

	signal sys_rst : std_logic;
	signal sys_clk : std_logic;

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant sys_per      : real    := 50.0;

	constant fpga         : natural := spartan3;
	constant mark         : natural := m6t;


	constant sclk_phases  : natural := 4;
	constant sclk_edges   : natural := 2;
	constant cmmd_gear    : natural := 1;
	constant data_phases  : natural := 2;
	constant data_edges   : natural := 2;
	constant bank_size    : natural := ddr_ba'length;
	constant addr_size    : natural := ddr_a'length;
	constant coln_size    : natural := 10;
	constant data_gear    : natural := 2;
	constant word_size    : natural := ddr_dq'length;
	constant byte_size    : natural := 8;

	signal ddrsys_lckd    : std_logic;
	signal ddrsys_rst     : std_logic;

	constant clk0         : natural := 0;
	constant clk90        : natural := 1;
	signal ddrsys_clks    : std_logic_vector(0 to 2-1);

	signal dmactlr_len    : std_logic_vector(25-1 downto 2);
	signal dmactlr_addr   : std_logic_vector(25-1 downto 2);

	signal ctlr_irdy      : std_logic;
	signal ctlr_trdy      : std_logic;
	signal ctlr_rw        : std_logic;
	signal ctlr_act       : std_logic;
	signal ctlr_inirdy    : std_logic;
	signal ctlr_refreq    : std_logic;
	signal ctlr_b         : std_logic_vector(bank_size-1 downto 0);
	signal ctlr_a         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_r         : std_logic_vector(addr_size-1 downto 0);
	signal ctlr_di        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_do        : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlr_dm        : std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
	signal ctlr_do_dv     : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ctlr_di_dv     : std_logic;
	signal ctlr_di_req    : std_logic;
	signal ctlr_dio_req   : std_logic;

	signal ddrphy_rst     : std_logic;
	signal ddrphy_cke     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_we      : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(cmmd_gear-1 downto 0);
	signal ddrphy_b       : std_logic_vector(cmmd_gear*ddr_ba'length-1 downto 0);
	signal ddrphy_a       : std_logic_vector(cmmd_gear*ddr_a'length-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddrphy_sti     : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddr_st_dqs_open : std_logic;

	signal ddr_clk        : std_logic_vector(0 downto 0);
	signal ddr_dqst       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso       : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt        : std_logic_vector(ddr_dq'range);
	signal ddr_dqo        : std_logic_vector(ddr_dq'range);

	signal mii_clk        : std_logic;

	signal dmaicfg_req    : std_logic;
	signal dmaicfg_rdy    : std_logic;
	signal dmai_req       : std_logic := '0';
	signal dmai_rdy       : std_logic;
	signal dmai_len       : std_logic_vector(dmactlr_len'range);
	signal dmai_addr      : std_logic_vector(dmactlr_addr'range);
	signal dmai_dv        : std_logic;

	signal dmaocfg_req    : std_logic;
	signal dmaocfg_rdy    : std_logic;
	signal dmao_req       : std_logic;
	signal dmao_rdy       : std_logic;
	signal dmao_len       : std_logic_vector(dmactlr_len'range);
	signal dmao_addr      : std_logic_vector(dmactlr_addr'range);
	signal dmao_dv        : std_logic;

	signal dmacfg_req     : std_logic_vector(0 to 2-1);
	signal dmacfg_rdy     : std_logic_vector(0 to 2-1); 
	signal dev_len        : std_logic_vector(0 to 2*dmactlr_len'length-1);
	signal dev_addr       : std_logic_vector(0 to 2*dmactlr_addr'length-1);
	signal dev_we         : std_logic_vector(0 to 2-1);

	signal dev_req : std_logic_vector(0 to 2-1);
	signal dev_rdy : std_logic_vector(0 to 2-1); 

	signal ctlr_ras : std_logic;
	signal ctlr_cas : std_logic;

	type ddr_params is record
		dcm_mul : natural;
		dcm_div : natural;
		cas     : std_logic_vector(0 to 3-1);
	end record;

	type ddr_vector is array (natural range <>) of ddr_params;

	constant ddr166MHz : natural := 0;
	constant ddr200MHz : natural := 1;

	type ddrparams_vector is array (natural range <>) of ddr_params;
	constant ddr_tab : ddrparams_vector := (
		ddr166MHz => (dcm_mul => 25, dcm_div => 3, cas => "010"),
		ddr200MHz => (dcm_mul => 10, dcm_div => 1, cas => "011"));

--	constant ddr_mode : natural := ddr133MHz;
	constant ddr_mode : natural := ddr200MHz;

	constant ddr_mul      : natural := ddr_tab(ddr_mode).dcm_mul; 
	constant ddr_div      : natural := ddr_tab(ddr_mode).dcm_div; 

	constant tcp          : natural := (natural(sys_per)*ddr_div*1000)/(ddr_mul); -- 1 ns /1ps

	alias dmacfg_clk : std_logic is sys_clk;
	alias ctlr_clk : std_logic is ddrsys_clks(clk0);

	constant uart_xtal : natural := natural(5.0*10.0**9/real(sys_per*4.0));
	alias si_clk : std_logic is mii_rxc;

	constant baudrate  : natural := 1000000;
--	constant baudrate  : natural := 115200;

begin

	sys_rst <= not hd_t_clock;
	clkin_ibufg : ibufg
	port map (
		I => xtal ,
		O => sys_clk);

	mii_dfs_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 50.0,
		dfs_mul => 5,
		dfs_div => 4)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => mii_clk);

	ddrdcm_e : entity hdl4fpga.dfsdcm
	generic map (
		dcm_per => sys_per,
		dfs_mul => ddr_mul,
		dfs_div => ddr_div)
	port map (
		dfsdcm_rst   => sys_rst,
		dfsdcm_clkin => sys_clk,
		dfsdcm_clk0  => ctlr_clk,
		dfsdcm_clk90 => ddrsys_clks(clk90),
		dfsdcm_lckd  => ddrsys_lckd);
	ddrsys_rst <= not ddrsys_lckd;

	scopeio_export_b : block

		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(8-1 downto 0);

		signal rgtr_id     : std_logic_vector(8-1 downto 0);
		signal rgtr_dv     : std_logic;
		signal rgtr_data   : std_logic_vector(32-1 downto 0);

		signal data_ena    : std_logic;
		signal data_ptr    : std_logic_vector(8-1 downto 0);
		signal dmadata_ena : std_logic;
		signal fifo_rst    : std_logic;
		signal src_frm     : std_logic;

		signal desser8_frm : std_logic;
		signal des8_trdy   : std_logic;
		signal des8_data   : std_logic_vector(uart_rxd'range);
		signal ser4_irdy   : std_logic;
		signal ser4_data   : std_logic_vector(mii_rxd'length-1 downto 0);

		signal stream_frm  : std_logic;
		signal stream_irdy : std_logic;
		signal stream_data : std_logic_vector(uart_rxd'range);
		signal stream_ddat : std_logic_vector(uart_rxd'range);

		signal si_frm      : std_logic;
		signal si_irdy     : std_logic;
		signal si_data     : std_logic_vector(mii_rxd'range);

		signal ipcfg_req : std_logic;
		signal fifoo_frm  : std_logic;
		signal fifoo_irdy : std_logic;
		signal fifoo_trdy : std_logic;
		signal fifoo_data : std_logic_vector(ctlr_do'range);

		signal uart_trdy   : std_logic;
		signal uart_txdv   : std_logic;
		signal uart_txd    : std_logic_vector(8-1 downto 0);

	begin

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => si_clk,
			uart_sin  => rs232_rd,
			uart_rxdv => uart_rxdv,
			uart_rxd  => uart_rxd);

		scopeio_istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
		generic map (
			istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
			istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
		port map (
			stream_clk  => si_clk,
			stream_dv   => uart_rxdv,
			stream_data => uart_rxd,

			chaini_data => stream_ddat,

			chaino_frm  => stream_frm,  
			chaino_irdy => stream_irdy,
			chaino_data => stream_data);

		process(stream_frm, stream_irdy, des8_trdy, si_clk)
			variable frm  : std_logic;
			variable edge : std_logic;
		begin
			if rising_edge(si_clk) then
				if frm='0' then
					if stream_irdy='1' then
						frm := stream_frm;
					end if;
				elsif des8_trdy='0' then
					if edge='1' then
						frm := stream_frm;
					end if;
				end if;
				edge := des8_trdy;
			end if;
			desser8_frm <= setif(frm='0', stream_frm and stream_irdy, stream_frm or des8_trdy);
		end process;

		des8_data <= reverse(reverse(stream_data), ser4_data'length);

		desser4_e : entity hdl4fpga.desser(mux)
		port map (
			desser_clk => si_clk,
			desser_frm => desser8_frm,
			des_irdy   => stream_irdy,
			des_trdy   => des8_trdy,
			des_data   => des8_data,

			ser_irdy   => ser4_irdy,
			ser_data   => ser4_data);

		ipcfg_req <= not sw1;
		udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
		port map (
			ipcfg_req   => ipcfg_req,

			phy_rxc     => mii_rxc,
			phy_rx_dv   => mii_rxdv,
			phy_rx_d    => mii_rxd,

			phy_txc     => mii_txc,
			phy_tx_en   => mii_txen,
			phy_tx_d    => mii_txd,
			ipcfg_vld   => led7,
		
			chaini_sel  => '0',
			chaini_frm  => stream_frm,
			chaini_irdy => ser4_irdy,
			chaini_data => ser4_data,

			chaino_frm  => si_frm,
			chaino_irdy => si_irdy,
			chaino_data => si_data);
	
		scopeio_sin_e : entity hdl4fpga.scopeio_sin
		port map (
			sin_clk   => si_clk,
			sin_frm   => si_frm,
			sin_irdy  => si_irdy,
			sin_data  => si_data,
			data_ptr  => data_ptr,
			data_ena  => data_ena,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data);

		dmaaddr_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmaaddr)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => fifo_rst,
			data      => dmai_addr);

		dmalen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => rid_dmalen)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmai_dv,
			data      => dmai_len);

		dmadata_ena <= data_ena and setif(rgtr_id=rid_dmadata) and setif(data_ptr(2-1 downto 0)=(2-1 downto 0 => '0'));

		src_frm <= not fifo_rst;
		dmadata_e : entity hdl4fpga.fifo
		generic map (
			size      => (8*2048)/ctlr_di'length,
			gray_code => false)
		port map (
			src_clk  => si_clk,
			src_frm  => src_frm,
			src_irdy => dmadata_ena,
			src_data => rgtr_data,

			dst_clk  => ctlr_clk,
			dst_irdy => ctlr_di_dv,
			dst_trdy => ctlr_di_req,
			dst_data => ctlr_di);

		dmaicfg_p : process (si_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(si_clk) then
				if ctlr_inirdy='0' then
					dmaicfg_req <= '0';
				elsif dmaicfg_req='0' then
					if dmai_dv='1' then
						dmaicfg_req <= '1';
					end if;
				elsif io_rdy='1' then
					dmaicfg_req <= '0';
				end if;
				io_rdy := dmai_rdy;
			end if;
		end process;

		dmaoaddr_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => x"19")
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			data      => dmao_addr);

		dmaolen_e : entity hdl4fpga.scopeio_rgtr
		generic map (
			rid  => x"20")
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,
			dv        => dmao_dv,
			data      => dmao_len);

		dmaodata_e : entity hdl4fpga.fifo
		generic map (
			size      => 2048/(ctlr_do'length*8),
			synchronous_rddata => true,
			gray_code => false,
			check_dov => true)
		port map (
			src_clk  => ctlr_clk,
			src_irdy => ctlr_do_dv(0),
			src_data => ctlr_do,

			dst_clk  => si_clk,
			dst_frm  => fifoo_frm,
			dst_irdy => fifoo_irdy,
			dst_trdy => fifoo_trdy,
			dst_data => fifoo_data);

		dmaocfg_p : process (si_clk)
			variable io_rdy : std_logic;
		begin
			if rising_edge(si_clk) then
				if ctlr_inirdy='0' then
					dmaocfg_req <= '0';
					fifoo_frm   <= '0';
				elsif dmaocfg_req='0' then
					if dmao_dv='1' then
						dmaocfg_req <= '1';
						fifoo_frm   <= '1';
					end if;
				elsif io_rdy='1' then
					dmaocfg_req <= '0';
					fifoo_frm   <= fifoo_irdy;
				end if;
				io_rdy := dmao_rdy;
			end if;
		end process;

		uartdesser_e : entity hdl4fpga.desser
		port map (
			desser_clk => si_clk,
			desser_frm => fifoo_frm,
			des_irdy   => fifoo_irdy,
			des_trdy   => fifoo_trdy,
			des_data   => fifoo_data,

			ser_irdy   => uart_txdv,
			ser_trdy   => uart_trdy,
			ser_data   => uart_txd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => si_clk,
			uart_sout => rs232_td,
			uart_trdy => uart_trdy,
			uart_txdv => uart_txdv,
			uart_txd  => uart_txd);

	end block;

	process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			dmao_req <= dmaocfg_rdy;
			dmai_req <= dmaicfg_rdy;
		end if;
	end process;

	dmacfg_req <= (0 => dmaocfg_req, 1 => dmaicfg_req);
	(0 => dmaocfg_rdy, 1 => dmaicfg_rdy) <= dmacfg_rdy;

	dev_req <= (0 => dmao_req, 1 => dmai_req);
	(0 => dmao_rdy, 1 => dmai_rdy) <= dev_rdy;
	dev_len    <= dmao_len  & dmai_len;
	dev_addr   <= dmao_addr & dmai_addr;
	dev_we     <= "1"       & "0";

	dmactlr_e : entity hdl4fpga.dmactlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => tcp,

		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		coln_size   => coln_size)
	port map (
		devcfg_clk  => dmacfg_clk,
		devcfg_req  => dmacfg_req,
		devcfg_rdy  => dmacfg_rdy,
		dev_len     => dev_len,
		dev_addr    => dev_addr,
		dev_we      => dev_we,

		dev_req     => dev_req,
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
		ctlr_r      => ctlr_r,
		ctlr_dio_req => ctlr_dio_req,
		ctlr_act    => ctlr_act);

	ddrctlr_e : entity hdl4fpga.ddr_ctlr
	generic map (
		fpga         => fpga,
		mark         => mark,
		tcp          => tcp,

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
		ctlr_bl      => "001",
--		ctlr_cl      => "010",	-- 2   133 Mhz
--		ctlr_cl      => "110",	-- 2.5 166 Mhz
		ctlr_cl      => "011",	-- 3   200 Mhz

		ctlr_cwl     => "000",
		ctlr_wr      => "101",
		ctlr_rtt     => "--",

		ctlr_rst     => ddrsys_rst,
		ctlr_clks    => ddrsys_clks,
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
		ctlr_dm      => (ctlr_dm'range => '0'),
		ctlr_do_dv   => ctlr_do_dv,
		ctlr_do      => ctlr_do,
		ctlr_refreq  => ctlr_refreq,
		ctlr_dio_req => ctlr_dio_req,

		phy_rst      => ddrphy_rst,
		phy_cke      => ddrphy_cke(0),
		phy_cs       => ddrphy_cs(0),
		phy_ras      => ddrphy_ras(0),
		phy_cas      => ddrphy_cas(0),
		phy_we       => ddrphy_we(0),
		phy_b        => ddrphy_b,
		phy_a        => ddrphy_a,
		phy_odt      => ddrphy_odt(0),
		phy_dmi      => ddrphy_dmi,
		phy_dmt      => ddrphy_dmt,
		phy_dmo      => ddrphy_dmo,
                               
		phy_dqi      => ddrphy_dqi,
		phy_dqt      => ddrphy_dqt,
		phy_dqo      => ddrphy_dqo,
		phy_sti      => ddrphy_sto,
		phy_sto      => ddrphy_sti,
                                
		phy_dqsi     => ddrphy_dqsi,
		phy_dqso     => ddrphy_dqso,
		phy_dqst     => ddrphy_dqst);

	ddrphy_e : entity hdl4fpga.xcs3_ddrphy
	generic map (
		gate_delay  => 2,
		loopback    => true,
		rgtr_dout   => false,
		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		cmmd_gear   => cmmd_gear,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size)
	port map (
		sys_clks    => ddrsys_clks,
		sys_rst     => ddrsys_rst,

		phy_cke     => ddrphy_cke,
		phy_cs      => ddrphy_cs,
		phy_ras     => ddrphy_ras,
		phy_cas     => ddrphy_cas,
		phy_we      => ddrphy_we,
		phy_b       => ddrphy_b,
		phy_a       => ddrphy_a,
		phy_dqsi    => ddrphy_dqso,
		phy_dqst    => ddrphy_dqst,
		phy_dqso    => ddrphy_dqsi,
		phy_dmi     => ddrphy_dmo,
		phy_dmt     => ddrphy_dmt,
		phy_dmo     => ddrphy_dmi,
		phy_dqi     => ddrphy_dqo,
		phy_dqt     => ddrphy_dqt,
		phy_dqo     => ddrphy_dqi,
		phy_odt     => ddrphy_odt,
		phy_sti     => ddrphy_sti,
		phy_sto     => ddrphy_sto,

		ddr_sto(0) => ddr_st_dqs,
		ddr_sto(1) => ddr_st_dqs_open,
		ddr_sti(0) => ddr_st_lp_dqs,
		ddr_sti(1) => ddr_st_lp_dqs,
		ddr_clk     => ddr_clk,
		ddr_cke     => ddr_cke,
		ddr_cs      => ddr_cs,
		ddr_ras     => ddr_ras,
		ddr_cas     => ddr_cas,
		ddr_we      => ddr_we,
		ddr_b       => ddr_ba,
		ddr_a       => ddr_a,

		ddr_dm      => ddr_dm,
		ddr_dqt     => ddr_dqt,
		ddr_dqi     => ddr_dq,
		ddr_dqo     => ddr_dqo,
		ddr_dqst    => ddr_dqst,
		ddr_dqsi    => ddr_dqs,
		ddr_dqso    => ddr_dqso);

	ddr_dqs_g : for i in ddr_dqs'range generate
		ddr_dqs(i) <= ddr_dqso(i) when ddr_dqst(i)='0' else 'Z';
	end generate;

	process (ddr_dqt, ddr_dqo)
	begin
		for i in ddr_dq'range loop
			ddr_dq(i) <= 'Z';
			if ddr_dqt(i)='0' then
				ddr_dq(i) <= ddr_dqo(i);
			end if;
		end loop;
	end process;

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => ddr_ckp,
		ob => ddr_ckn);

	-- VGA --
	---------

	red    <= (others => 'Z');
	green  <= (others => 'Z');
	blue   <= (others => 'Z');
	blankn <= 'Z';
	hsync  <= 'Z';
	vsync  <= 'Z';
	sync   <= 'Z';
	psave  <= 'Z';
	clk_videodac <= 'Z';

	adc_clkab <= 'Z';


	mii_refclk <= mii_clk;	

	hd_t_data <= 'Z';

	process (si_clk)
		variable t : std_logic;
		variable e : std_logic;
		variable i : std_logic;
	begin
		if rising_edge(si_clk) then
			if i='1' and e='0' then
				t := not t;
			end if;
			e := i;
			i := dmai_dv;
			i := dmai_rdy;

			led18 <= t;
			led16 <= not t;
		end if;
	end process;

	process (ctlr_clk)
		variable t : std_logic;
		variable e : std_logic;
		variable i : std_logic;
	begin
		if rising_edge(ctlr_clk) then
			i := dmao_rdy;
			if i='1' and e='0' then
				t := not t;
			end if;
			e := i;
			led13 <= t;
			led15 <= not t;
		end if;
	end process;

	-- LEDs --
	----------
		
--	led18 <= '0';
--	led16 <= '0';
--	led15 <= '0';
--	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
--	led7  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= '1';
	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
