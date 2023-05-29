library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

architecture def of testbench is
    constant oversampling : natural := 16;

	constant data : std_logic_vector(0 to 64-1) := x"aaaa_aaab" & x"0000_ffff";

	signal txc  : std_logic;
	signal txen : std_logic;
	signal txd  : std_logic;
	signal rxc  : std_logic;
	signal rxdv : std_logic;
	signal rxd  : std_logic;
	signal txr  : std_logic;

begin

	txc <= not txc after 20*15 ns;
	rxc <= not rxc after 20 ns;
	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				txd  <= data(cntr);
				txen <= '1';
				cntr := cntr + 1;
			else
				txen <= '0';
			end if;
		end if;
	end process;

	tx_d : entity hdl4fpga.tx_manchester
	port map (
		clk  => txc,
		txen => txen,
		txd  => txd,
		tx   => txr);

	rx_d : entity hdl4fpga.rx_manchester
    generic map (
        oversampling => oversampling)
	port map (
		clk  => rxc,
		rxdv => rxdv,
		rxd  => rxd,
		rx   => txr);
end;