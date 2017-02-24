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

use std.textio.all;

entity scope is
	generic (
		FPGA            : natural;
		DDR_CMMDGEAR    : natural;
		DDR_TCP         : natural;
		DDR_SCLKPHASES  : natural;
		DDR_SCLKEDGES   : natural;
		DDR_DATAPHASES  : natural :=  1;
		DDR_DATAEDGES   : natural :=  1;
		DDR_CMNDPHASES  : natural :=  2;
		DDR_MARK        : natural;
		DDR_STROBE      : string := "NONE";
		DDR_BANKSIZE    : natural :=  3;
		DDR_ADDRSIZE    : natural := 13;
		DDR_CLMNSIZE    : natural :=  6;
		DDR_DATAGEAR    : natural := 16;
		DDR_WORDSIZE    : natural := 16;
		DDR_BYTESIZE    : natural :=  8;
		DDR_TESTCORE    : boolean := FALSE;
		PAGE_SIZE       : natural := 9;
		NIBBLE_SIZE     : natural := 4;
		MAC_DESTADDR    : std_logic_vector(0 to 48-1) := x"ffffffffffff");

	port (
		ddrs_rst : in std_logic;

		input_rst  : in  std_logic := '0';
		input_clk  : in  std_logic;
		input_req  : out std_logic;
		input_rdy  : in  std_logic := '1';
		input_data : in  std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);

		ddrs_clks  : in std_logic_vector(0 to ddr_sclkphases/ddr_sclkedges-1);
		ddrs_rtt   : in std_logic_vector;
		ddrs_bl    : in std_logic_vector(3-1 downto 0) := "000";
		ddrs_cl    : in std_logic_vector(3-1 downto 0) := "010";
		ddrs_cwl   : in std_logic_vector(3-1 downto 0) := "000";
		ddrs_wr    : in std_logic_vector(3-1 downto 0) := "101";
		ddrs_ini   : out std_logic;
		ddrs_act   : out std_logic;
		ddrs_cmd_rdy : out std_logic;

		ddr_wlreq  : out std_logic;
		ddr_wlrdy  : in  std_logic := '-';
		ddr_rlreq  : out std_logic;
		ddr_rlrdy  : in  std_logic := '-';
		ddr_rlcal  : in  std_logic := '0';
		ddr_rlseq  : out std_logic := '0';
		ddr_phyini : in std_logic := '1';
		ddr_phyrw  : in std_logic := '-';
		ddr_phycmd_req : in std_logic := '0';

		ddr_rst   : out std_logic;
		ddr_cke   : out std_logic;
		ddr_cs    : out std_logic;
		ddr_ras   : out std_logic;
		ddr_cas   : out std_logic;
		ddr_we    : out std_logic;
		ddr_b     : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_a     : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_dmi   : in  std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmo   : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmt   : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqsi  : in  std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqst  : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqso  : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqt   : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqi   : in  std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
		ddr_dqo   : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
		ddr_odt   : out std_logic;
		ddr_sto   : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_sti   : in  std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);

		mii_rst   : in std_logic := '0';
		mii_rxc   : in std_logic;
		mii_rxdv  : in std_logic;
		mii_rxd   : in std_logic_vector;
		mii_txc   : in std_logic;
		mii_txen  : out std_logic;
		mii_txd   : out std_logic_vector);

end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_db.all;

architecture def of scope is
	signal ddrs_clk180  : std_logic;

	signal ddr_lp_clk   : std_logic;

	signal ddr_ini      : std_logic;
	signal ddr_cmd_req  : std_logic;
	signal ddr_rw       : std_logic;

	signal ddrs_ref_req : std_logic;
	signal ddrs_cmd_req : std_logic;
	signal ddrs_ba      : std_logic_vector(0 to DDR_BANKSIZE-1);
	signal ddrs_a       : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddrs_rowa    : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddrs_cola    : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddr_act      : std_logic;
	signal ddrs_cas     : std_logic;
	signal ddrs_pre     : std_logic;
	signal ddrs_rw      : std_logic;

	signal ddrs_di_rdy  : std_logic;
	signal ddrs_di_req  : std_logic;
	signal ddrs_di      : std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
	signal ddrs_do_rdy  : std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
	signal ddrs_do      : std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);

	signal miirx_req    : std_logic;
	signal miirx_rdy    : std_logic;
	signal miitx_req    : std_logic;
	signal miitx_rdy    : std_logic;
	signal miidma_req   : std_logic;
	signal miidma_rdy   : std_logic;
	signal miidma_txen  : std_logic;
	signal miidma_txd   : std_logic_vector(mii_txd'length-1 downto 0);

begin

	miirx_udp_e : entity hdl4fpga.miirx_mac
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txen => pktrx_rdy);

	miitx_udp_e : entity hdl4fpga.miitx_udp
	generic map (
		MAC_DESTADDR => MAC_DESTADDR,
		payload_size => 2**(PAGE_SIZE+1))
	port map (
		mii_txc      => mii_txc,
		mii_treq     => miitx_req,
		mii_trdy     => miitx_rdy,
		mii_txen     => mii_txen,
		mii_txd      => mii_txd,
		miidma_req   => miidma_req,
		miidma_rxen  => miidma_txen,
		miidma_rxd   => miidma_txd);

	: entity hdl4fpga.dmadevice
		generic map (
			DDR_BANKSIZE  => DDR_BANKSIZE,
			DDR_ADDRSIZE  => DDR_ADDRSIZE,
			DDR_CLNMSIZE  => DDR_CLNMSIZE,
			DDR_LINESIZE  => DDR_LINESIZE,
			PAGE_SIZE     => PAGE_SIZE)
		port map (
			dmabridge_rst => 

			ddr_ref_req   => 
			ddr_cmd_req   => 
			ddr_cmd_rdy   => 

			ddr_act       => 
			ddr_cas       => 
			ddr_rw        => 
			ddr_bnka      => ddrs_ba,
			ddr_rowa      => ddrs_ra,
			ddr_cola      => ddrs_ca,

			ddr_di_req    => ddrs_di_rdy,
			ddr_di_rdy    => ddrs_di_rdy,
			ddr_di        => ddrs_di,
			ddr_do_rdy    => ddrs_do_rdy,
			ddr_do        => ddrs_do,
			
			input_clk     => input_clk,
			input_req     => 
			input_rdy     => 
			input_addr    => 
			input_data    => 

			miitx_clk     => miitx_clk,
			miitx_req     => 
			miitx_rdy     => 
			miitx_ena     => 
			miitx_addr    => 
			miitx_dat     => 
	

	ini          <= ddr_phyini   when FPGA=VIRTEX5 or FPGA=VIRTEX7   else ddr_ini;
	ddr_rlreq    <= ddr_ini;
	ddr_cmd_req  <= ddrs_cmd_req when ddr_phyini='1' else ddr_phycmd_req;
	ddr_rw       <= ddrs_rw      when ddr_phyini='1' else ddr_phyrw;
	process(ddrs_clks(0))
	begin
		if rising_edge(ddrs_clks(0)) then
			ddrs_ini <= ini;
		end if;
	end process;

	ddrs_cmd_rdy <= cmd_rdy;

	ddr_e : entity hdl4fpga.xdr
	generic map (
		FPGA        => FPGA,
		MARK        => DDR_MARK,
		CMMD_GEAR   => DDR_CMMDGEAR,
		SCLK_PHASES => DDR_SCLKPHASES,
		SCLK_EDGES  => DDR_SCLKEDGES,
		DATA_PHASES => DDR_DATAPHASES,
		DATA_EDGES  => DDR_DATAEDGES,
		BANK_SIZE   => DDR_BANKSIZE,
		ADDR_SIZE   => DDR_ADDRSIZE,
		DATA_GEAR   => DDR_DATAGEAR,
		WORD_SIZE   => DDR_WORDSIZE,
		BYTE_SIZE   => DDR_BYTESIZE,
		TCP         => DDR_TCP)
	port map (
		sys_rst     => ddrs_rst,
		sys_rtt     => ddrs_rtt,
		sys_bl      => ddrs_bl,
		sys_cl      => ddrs_cl,
		sys_cwl     => ddrs_cwl,
		sys_wr      => ddrs_wr,
		sys_clks    => ddrs_clks,
		sys_ini     => ddr_ini,

		sys_cmd_req => ddr_cmd_req,
		sys_cmd_rdy => cmd_rdy,
		sys_wlreq   => ddr_wlreq,
		sys_wlrdy   => ddr_wlrdy,
		sys_rlcal   => ddr_rlcal,
		sys_rlseq   => ddr_rlseq,
		sys_b       => ddrs_ba,
		sys_a       => ddrs_a,
		sys_rw      => ddr_rw,
		sys_act     => ddr_act,
		sys_cas     => ddrs_cas,
		sys_di_rdy  => ddrs_di_rdy,
		sys_di_req  => ddrs_di_req,
		sys_di      => ddrs_di,
		sys_do_rdy  => ddrs_do_rdy,
		sys_do      => ddrs_do,

		sys_ref     => ddrs_ref_req,

		xdr_rst     => ddr_rst,
		xdr_cke     => ddr_cke,
		xdr_cs      => ddr_cs,
		xdr_ras     => ddr_ras,
		xdr_cas     => ddr_cas,
		xdr_we      => ddr_we,
		xdr_b       => ddr_b,
		xdr_a       => ddr_a,
		xdr_dmi     => ddr_dmi,
		xdr_dmt     => ddr_dmt,
		xdr_dmo     => ddr_dmo,
		xdr_dqst    => ddr_dqst,
		xdr_dqsi    => ddr_dqsi,
		xdr_dqso    => ddr_dqso,
		xdr_dqt     => ddr_dqt,
		xdr_dqi     => ddr_dqi,
		xdr_dqo     => ddr_dqo,
		xdr_odt     => ddr_odt,

		xdr_sti     => ddr_sti,
		xdr_sto     => ddr_sto);
end;
