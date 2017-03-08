use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;

entity tb is
end;

architecture beh of tb is
	signal mii_treq : std_logic := '0';
	signal mii_txc  : std_logic := '0';
	signal mii_txdv : std_logic;
	signal mii_txd  : std_logic_vector(0 to 4-1);

	signal mem_req  : std_logic;
	signal mem_rdy  : std_logic;
	signal mem_ena  : std_logic;
	signal mem_dat  : std_logic_vector(0 to 4-1);
	signal mem_addr : std_logic_vector(0 to 0);
	signal dummy    : std_logic_vector(mem_dat'range);
	signal ena      : std_logic;
	signal q0 : std_logic;
begin

	mii_txc <= not mii_txc after 5 ns;
	dut : entity hdl4fpga.scopeio_miitx
	port map (
		mii_treq => mii_treq,
		mii_txc  => mii_txc,
		mii_txdv => mii_txdv,
		mii_txd  => mii_txd,

		mem_req  => mem_req,
		mem_rdy  => mem_rdy,
		mem_ena  => mem_ena,
		mem_dat  => mem_dat);

	pp_e : entity hdl4fpga.align
	generic map (
		n => 2,
		d => (0 to 1 => 2))
	port map (
		clk   => mii_txc,
		di(0) => ena,
		di(1) => q0,
		do(0) => mem_ena,
		do(1) => mem_rdy);

	ena <= mem_req and not q0;
	process (mii_txc)
		variable cntr : unsigned(0 to mem_addr'length);
	begin
		if rising_edge(mii_txc) then
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
		data => x"80")
	port map (
		clka  => '0',
		addra => (0 to 0 => '0'),
		enaa  => '0',
		wea   => '0',
		dia   => (0 to 3 => '-'),
		doa   => dummy,

		clkb  => mii_txc,
		addrb => mem_addr,
		web   => '0',
		dib   => (0 to 3 => '-'),
		dob   => mem_dat);


	process (mii_txc)
		variable msg : line;
	begin
		if rising_edge(mii_txc) then
			mii_treq <= '1';
			write (msg, string'("mii_txd : "));
			hwrite(msg, mii_txd);
			write (msg, string'(" : mii_txdv : "));
			write (msg, mii_txdv);
			writeline(output, msg);
		end if;
	end process;

end;
