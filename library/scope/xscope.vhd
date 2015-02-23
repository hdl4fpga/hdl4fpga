library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity scope is
	generic (
		constant DDR_STROBE   : string := "NONE";
		constant DDR_STD      : natural;
		constant DDR_DATAPHASES : natural :=  1;
		constant DDR_CMNDPHASES : natural :=  2;
		constant DDR_BANKSIZE : natural :=  3;
		constant DDR_ADDRSIZE : natural := 13;
		constant DDR_CLMNSIZE : natural :=  6;
		constant DDR_LINESIZE : natural := 16;
		constant DDR_WORDSIZE : natural := 16;
		constant DDR_BYTESIZE : natural :=  8;
		constant DDR_tCP      : natural;

		constant NIBBLE_SIZE  : natural := 4;
		constant XD_LEN : natural);

	port (
		ddrs_rst : in std_logic;
		sys_ini : out std_logic;

		input_clk : in std_logic;

		ddrs_clks : in std_logic_vector(0 to 1);
		ddrs_ini  : out std_logic;

		ddr_rst : out std_logic;
		ddr_cke : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_a   : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_dmi : in  std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmo : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmt : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqsi : in  std_logic_vector(DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqst : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqso : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqt : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqi : in  std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE-1 downto 0);
		ddr_dqo : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE-1 downto 0);
		ddr_odt : out std_logic;
		ddr_sto : out std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_WORDSIZE-1 downto 0);
		ddr_sti : in  std_logic_vector(DDR_DATAPHASES*DDR_LINESIZE/DDR_WORDSIZE-1 downto 0);

		mii_rxc  : in std_logic;
		mii_rxdv : in std_logic;
		mii_rxd  : in std_logic_vector(0 to xd_len-1);
		mii_txc  : in std_logic;
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector(0 to xd_len-1);

		vga_clk   : in  std_logic;
		vga_hsync : out std_logic;
		vga_vsync : out std_logic;
		vga_blank : out std_logic;
		vga_frm   : out std_logic;
		vga_red   : out std_logic_vector(8-1 downto 0);
		vga_green : out std_logic_vector(8-1 downto 0);
		vga_blue  : out std_logic_vector(8-1 downto 0);

		tpo : out std_logic_vector(0 to 4-1) := (others  => 'Z'));
end;

library hdl4fpga;
use hdl4fpga.std.all;
--use hdl4fpga.cgafont.all;

architecture def of scope is
	signal video_don : std_logic;
	signal video_frm : std_logic;
	signal video_ena : std_logic;
	signal video_hsync : std_logic;
	signal video_vsync : std_logic;
	signal video_blank : std_logic;

	signal cga_clk : std_logic;
	signal vga_row : std_logic_vector(9-1 downto 0);
	signal cga_row : std_logic_vector(9-1 downto 4);
	signal cga_col : std_logic_vector(4-1 downto 0);
	signal cga_ptr : std_logic_vector(9-1 downto 0);
	signal cga_we  : std_logic;
	signal cga_dot : std_logic;
	signal cga_don : std_logic;
	signal cga_code : byte;

	signal ddrs_clk180 : std_logic;

	signal ddr_lp_clk : std_logic;

	signal ddr_ini : std_logic;
	signal ddrs_ref_req : std_logic;
	signal ddrs_cmd_req : std_logic;
	signal ddrs_cmd_rdy : std_logic;
	signal ddrs_ba : std_logic_vector(0 to DDR_BANKSIZE-1);
	signal ddrs_a  : std_logic_vector(0 to 13-1);
	signal ddrs_rowa  : std_logic_vector(0 to 13-1);
	signal ddrs_cola  : std_logic_vector(0 to 13-1);
	signal ddrs_act : std_logic;
	signal ddrs_cas : std_logic;
	signal ddrs_pre : std_logic;
	signal ddrs_rw  : std_logic;

	signal ddrs_di_rdy : std_logic;
	signal ddrs_di : std_logic_vector(DDR_LINESIZE-1 downto 0);
	signal ddrs_do_rdy : std_logic_vector(DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
	signal ddrs_do : std_logic_vector(DDR_LINESIZE-1 downto 0);

	signal dataio_rst : std_logic;
	signal input_rdy : std_logic := '0';
	signal input_req : std_logic := '0';
	signal input_dat : std_logic_vector(0 to 15);
	
	signal win_rowid  : std_logic_vector(2-1 downto 0);
	signal win_rowpag : std_logic_vector(5-1 downto 0);
    signal win_rowoff : std_logic_vector(7-1 downto 0);
    signal win_colid  : std_logic_vector(2-1 downto 0);
    signal win_colpag : std_logic_vector(2-1 downto 0);
    signal win_coloff : std_logic_vector(13-1 downto 0);

    signal chann_dat : std_logic_vector(32-1 downto 0);

	signal grid_dot : std_logic;
	signal plot_dot : std_logic_vector(0 to 2-1);

	signal miitx_req  : std_logic;
	signal miitx_rdy  : std_logic;
	signal miitx_addr : std_logic_vector(7-1 downto 0);
	signal miitx_data : std_logic_vector(DDR_LINESIZE-1 downto 0);
	signal miitx_ena  : std_logic;

	signal trdy : std_logic := '0';
	signal treq : std_logic := '0';
	signal rxdv : std_logic;
	signal rxd  : nibble;
	signal rpkt : std_logic;
	signal pkt_cntr : std_logic_vector(15 downto 0) := x"0000";
	signal tpkt_cntr : byte := x"00";
	signal a0 : std_logic;
	signal tp : nibble_vector(7 downto 0) := (others => "0000");

begin

	ddrs_ini <= ddr_ini;

--	process (input_clk)
--		variable sample : unsigned(0 to 15) := (others => '0');
--	begin
--		if falling_edge(input_clk) then
--			input_dat <= std_logic_vector(resize(sample, input_dat'length));
--			if ddrs_ini='0' then
--				input_req <= '0';
--			elsif input_rdy='0' then
--				input_req <= '1';
--			end if;
--			sample := sample + 1;
--		end if;
--	end process;

	input_req <= ddr_ini and not input_rdy;
	process (input_clk)
		constant n : natural := 15;
		variable r : unsigned(0 to n);
	begin
		if rising_edge(input_clk) then
			input_dat <= std_logic_vector(resize(signed(r(0 to n)), input_dat'length));
--			input_dat <= (others => r(n-2));
			r := r + 1;
			if ddr_ini='0' then
				r := to_unsigned(61, r'length);
			end if;
		end if;
	end process;

--	video_vga_e : entity hdl4fpga.video_vga
--	generic map (
--		n => 12)
--	port map (
--		clk   => vga_clk,
--		hsync => video_hsync,
--		vsync => video_vsync,
--		frm   => video_frm,
--		don   => video_don);
--	vga_frm <= video_frm;
--	video_blank <= video_don and video_frm;
--		
--	win_stym_e : entity hdl4fpga.win_sytm
--	port map (
--		win_clk => vga_clk,
--		win_frm => video_frm,
--		win_don => video_don,
--		win_rowid  => win_rowid ,
--		win_rowpag => win_rowpag,
--		win_rowoff => win_rowoff,
--		win_colid  => win_colid,
--		win_colpag => win_colpag,
--		win_coloff => win_coloff);
--
--	win_ena_b : block
--		signal scope_win : std_logic;
--		signal cga_win : std_logic;
--		signal grid_don : std_logic;
--		signal plot_dot1 : std_logic_vector(plot_dot'range);
--		signal grid_dot1 : std_logic;
--		signal plot_start  : std_logic;
--		signal plot_end  : std_logic;
--	begin
--		scope_win <= setif(win_rowid&win_colid = "1111");
--		cga_win   <= cga_dot and setif(win_rowid&win_colid="1101");
--
--		align_e : entity hdl4fpga.align
--		generic map (
--			n => 10,
--			d => (
--				0 to 2 => 4+10,		-- hsync, vsync, blank
--				3 to 3 => 2+10,		-- scope_win -> plot_end
--				4 to 5 => 1,		-- plot
--				6 to 6 => 1+10,		-- grid
--			    7 to 7 => 1,		-- plot_end -> grid_don
--			    8 to 8 => 3,		-- grid_don -> plot_start
--			    9 to 9 => 3))		-- cga_dot -> cga_dot
--		port map (
--			clk   => vga_clk,
--
--			di(0) => video_hsync,
--			di(1) => video_vsync,
--			di(2) => video_blank,
--
--			di(3) => scope_win,
--
--			di(4) => plot_dot(0),
--			di(5) => plot_dot(1),
--			di(6) => grid_dot,
--			di(7) => plot_end,
--			di(8) => grid_don,
--			di(9) => cga_win,
--
--			do(0) => vga_hsync,
--			do(1) => vga_vsync,
--			do(2) => vga_blank,
--
--			do(3) => plot_end,
--
--			do(4) => plot_dot1(0),
--			do(5) => plot_dot1(1),
--			do(6) => grid_dot1,
--			do(7) => grid_don,
--			do(8) => plot_start,
--			do(9) => cga_don);
--
--		vga_red   <= (others => (plot_start and plot_end and plot_dot1(1)) or cga_don);
--		vga_green <= (others => (plot_start and plot_end and plot_dot1(0)) or cga_don);
--		vga_blue  <= (others => (grid_don and grid_dot1) or cga_don);
--		
--	end block;
--
--	video_ena <= setif(win_rowid="11");

	ddrs_a <= ddrs_rowa when ddrs_act='1' else ddrs_cola;

	dataio_rst <= not ddr_ini;
	dataio_e : entity hdl4fpga.dataio 
	generic map (
		PAGE_SIZE => 9,
		DDR_BANKSIZE => DDR_BANKSIZE,
		DDR_ADDRSIZE => DDR_ADDRSIZE,
		DDR_CLNMSIZE => DDR_CLMNSIZE,
		DDR_LINESIZE => DDR_LINESIZE)
	port map (
		sys_rst   => dataio_rst,

		input_req => input_req,
		input_rdy => input_rdy,
		input_clk => input_clk,
		input_dat => input_dat,

		video_clk => vga_clk,
		video_ena => video_ena,
		video_row => win_rowpag(3 downto 0),
		video_col => win_coloff,
		video_do  => chann_dat,

		ddrs_clk => ddrs_clks(0),
		ddrs_rreq => ddrs_ref_req,
		ddrs_creq => ddrs_cmd_req,
		ddrs_crdy => ddrs_cmd_rdy,
		ddrs_bnka => ddrs_ba,
		ddrs_rowa => ddrs_rowa,
		ddrs_cola => ddrs_cola,
		ddrs_rw  => ddrs_rw,
		ddrs_act => ddrs_act,
		ddrs_cas => ddrs_cas,
		ddrs_pre => ddrs_pre,

		ddrs_di_rdy => ddrs_di_rdy,
		ddrs_di => ddrs_di,
		ddrs_do_rdy => ddrs_do_rdy(0),
		ddrs_do => ddrs_do,

		mii_txc => mii_txc,
		mii_a0 => a0,
		miitx_req => miitx_req,
		miitx_rdy => miitx_rdy,
		miitx_addr => miitx_addr,
		miitx_data => miitx_data);

	process (ddrs_clks(0))
		variable trdy_edge : std_logic_vector(0 to 1);
	begin
		if rising_edge(ddrs_clks(0)) then
			if miitx_rdy/='0' then
				miitx_rdy <= not miitx_req;
			elsif trdy='1' then
				if trdy_edge(0)='0' then
					miitx_rdy <= miitx_req;
				end if;
			end if;
			trdy_edge := not trdy_edge(0) & not trdy;
		end if;
	end process;

	process (mii_txc)
		variable rpkt_edge : std_logic_vector(0 to 1);
	begin
		if rising_edge(mii_txc) then
			if treq='0' then
				if rpkt='1' then
					if rpkt_edge(0)='0' then
						treq <= '1';
					end if;
				end if;
			elsif trdy='1' then
				treq <= '0';
			end if;
			rpkt_edge := not rpkt_edge(1) & not rpkt;
		end if;
	end process;
	tpo (0) <= rpkt;

	mii_txen <= miitx_ena;
	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		sys_addr => miitx_addr,
		sys_data => miitx_data,
		mii_txc  => mii_txc,
		mii_treq => treq,
		mii_trdy => trdy,
		mii_txen => miitx_ena,
		mii_txd  => mii_txd);

	process (mii_txc)
		variable edge : std_logic;
	begin
		if rising_edge(mii_txc) then
			if miitx_ena='1' then
				if edge='0' then
					tpkt_cntr <= byte(unsigned(tpkt_cntr) + 1);
				end if;
			end if;
			edge := miitx_ena;
		end if;
	end process;

	process (mii_rxc)
		variable edge : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if rpkt='1' then
				if edge='0' then
					pkt_cntr <= std_logic_vector(unsigned(pkt_cntr) + 1);
				end if;
			end if;
			edge := rpkt;
		end if;
	end process;

--	process (cga_clk)
--		variable nibble_ptr : unsigned(3-1 downto 0);
--	begin
--		if rising_edge(cga_clk) then
--			nibble_ptr := nibble_ptr + 1;
--			cga_code <= to_ascii(tp(to_integer(nibble_ptr)));
--			cga_ptr <= (3 to 5 => '0',others => '1');
--			cga_ptr(2 downto 0) <= std_logic_vector(nibble_ptr);
--		end if;
--	end process;

--	cga_clk <= mii_rxc;
--	vga_row <= win_rowpag(4-1 downto 0) & win_rowoff(6-1 downto 1);
--	cga_e : entity hdl4fpga.cga
--	generic map (
--		bitrom => psf1cp850x8x16,
--		height => 16,
--		width  => 8,
--		row_reverse => true,
--		col_reverse => true)
--	port map (
--		sys_clk => cga_clk,
--		sys_row => cga_ptr(cga_row'range),
--		sys_col => cga_ptr(cga_col'range),
--		sys_we  => '1',
--		sys_code => cga_code,
--		vga_clk => vga_clk,
--		vga_row => vga_row,
--		vga_col => win_coloff(8-1 downto 1),
--		vga_dot => cga_dot);

	miirx_udp_e : entity hdl4fpga.miirx_mac
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => open,
		mii_txen => rpkt,
		mii_txd  => open);

	win_scope_e : entity hdl4fpga.win_scope
	generic map (
		num_chann => 2)
	port map (
		video_clk => vga_clk,

		chann_row => win_rowoff,
		chann_col => win_coloff,
		chann_seg => win_rowpag(3 downto 0),
		chann_dat => chann_dat,
		grid_dot  => grid_dot,
		plot_dot  => plot_dot);

	ddr_e : entity hdl4fpga.xdr
	generic map (
		strobe    => DDR_STROBE,
		data_phases => DDR_DATAPHASES,
		bank_size => DDR_BANKSIZE,
		addr_size => DDR_ADDRSIZE,
		line_size => DDR_LINESIZE,
		word_size => DDR_WORDSIZE,
		byte_size => DDR_BYTESIZE,
		tCP  => DDR_tCP,
		tDDR => DDR_tCP/2)
	port map (
		sys_rst => ddrs_rst,
		sys_bl  => "000",
		sys_cl  => "010",
		sys_cwl => "000",
		sys_wr  => "101",
		sys_pl  => "---",
		sys_dqsn => '-',
		sys_clks => ddrs_clks,
		sys_ini  =>  ddr_ini,
		xdr_wclks(0) => ddrs_clks(0),

		sys_cmd_req => ddrs_cmd_req,
		sys_cmd_rdy => ddrs_cmd_rdy,
		sys_b   => ddrs_ba,
		sys_a   => ddrs_a,
		sys_rw  => ddrs_rw,
		sys_act => ddrs_act,
		sys_cas => ddrs_cas,
		sys_pre => ddrs_pre,
		sys_di_rdy => ddrs_di_rdy,
		sys_di  => ddrs_di,
		sys_do_rdy => ddrs_do_rdy,
		sys_do  => ddrs_do,
		sys_ref => ddrs_ref_req,

		xdr_rst => ddr_rst,
		xdr_cke => ddr_cke,
		xdr_cs  => ddr_cs,
		xdr_ras => ddr_ras,
		xdr_cas => ddr_cas,
		xdr_we  => ddr_we,
		xdr_b   => ddr_b,
		xdr_a   => ddr_a,
		xdr_dmi  => ddr_dmi,
		xdr_dmt  => ddr_dmt,
		xdr_dmo  => ddr_dmo,
		xdr_dqst => ddr_dqst,
		xdr_dqsi => ddr_dqsi,
		xdr_dqso => ddr_dqso,
		xdr_dqt => ddr_dqt,
		xdr_dqi => ddr_dqi,
		xdr_dqo => ddr_dqo,
		xdr_odt => ddr_odt,

		xdr_sti => ddr_sti,
		xdr_sto => ddr_sto);
end;
