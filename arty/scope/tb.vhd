library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;

architecture beh of arty is
	signal align_rst : std_logic;
	signal mii_treq : std_logic := '0';
	signal mii_trdy : std_logic := '0';
	signal mii_txd  : std_logic_vector(eth_txd'range);
	signal mii_txdv : std_logic;

	signal mem_req  : std_logic;
	signal mem_rdy  : std_logic;
	signal mem_ena  : std_logic;
	signal mem_dat  : std_logic_vector(mii_txd'range);
	signal mem_addr : std_logic_vector(0 to 10-1);
	signal dummy    : std_logic_vector(mem_dat'range);
	signal ena      : std_logic;
	signal q0       : std_logic;

begin
  
	process (gclk100)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(gclk100) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	eth_rstn <= not btn(0);
	dut : entity hdl4fpga.scopeio_miitx
	port map (
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txc  => eth_tx_clk,
		mii_txdv => mii_txdv,
		mii_txd  => mii_txd,

		mem_req  => mem_req,
		mem_rdy  => mem_rdy,
		mem_ena  => mem_ena,
		mem_dat  => mem_dat);

	align_rst <= not mii_treq;
	pp_e : entity hdl4fpga.align
	generic map (
		n => 2,
		d => (0 to 1 => 2),
		i => (0 to 1 => '0'))
	port map (
		clk   => eth_tx_clk,
		rst   => align_rst,
		di(0) => ena,
		di(1) => q0,
		do(0) => mem_ena,
		do(1) => mem_rdy);

	ena <= mem_req and not q0;
	process (eth_tx_clk)
		variable cntr : unsigned(0 to mem_addr'length);
	begin
		if rising_edge(eth_tx_clk) then
			if mem_req='0' then
				cntr := (others => '0');
			elsif cntr(0)='0' then
				cntr := cntr + 1;
			end if;
			q0 <= cntr(0);
			mem_addr <= std_logic_vector(cntr(1 to cntr'right));
		end if;
	end process;

	mem_e : entity hdl4fpga.bram
	generic map (
		data => x"f1")
	port map (
		clka  => eth_tx_clk,
		addra => mem_addr,
		enaa  => '0',
		wea   => '0',
		dia   => (mem_dat'range => '-'),
		doa   => dummy,

		clkb  => eth_tx_clk,
		addrb => mem_addr,
		web   => '0',
		dib   => (mem_dat'range => '-'),
		dob   => mem_dat);

	process (eth_tx_clk)
		variable aux : std_logic;
	begin
		if rising_edge(eth_tx_clk) then
			if mii_trdy='1' then
				mii_treq <= '0';
			elsif mii_treq='0' then
				mii_treq <= '1';
			end if;
			aux := mii_trdy;
		end if;
	end process;

	phy1txen_e : entity hdl4fpga.ff
	port map (
		clk => eth_tx_clk,
		d   => mii_txdv,
		q   => eth_tx_en);

	phy1txd_e : entity hdl4fpga.align
	generic map (
		n => mii_txd'length,
		d => (mii_txd'range => 1),
		i => (mii_txd'range => '-'))
	port map (
		clk => eth_tx_clk,
		di  => mii_txd,
		do  => eth_txd);

end;
