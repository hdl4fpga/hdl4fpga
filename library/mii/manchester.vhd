library ieee;
use ieee.numeric_bit.all;

entity tx_manchester is
	port (
		clk  : in  bit;
		txen : in  bit;
		txd  : in  bit;
		sout : out bit);
end;

architecture def of tx_manchester is
	signal clk_n : bit;
begin
	clk_n <= not clk;
	sout  <= txd xor clk_n when txen='1' else '0';
end;

library ieee;
use ieee.numeric_bit.all;

entity rx_manchester is
	port (
		sin  : in  bit;
		clk  : in  bit;
		rxdv : out bit;
		rxd  : buffer bit);
end;

architecture def of rx_manchester is
	signal xxx : bit;
begin
	process (clk)
		variable cntr : natural range 0 to 15;
	begin
		if rising_edge(clk) then
			if cntr > 0 then
				if cntr=1 then
					rxd <= sin;
				end if;
				cntr := cntr - 1;
				xxx <= '1';
			elsif (sin xor rxd)='1' then
				cntr := (16*3)/4;
				xxx <= '0';
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.numeric_bit.all;

entity tb is
end;

architecture def of tb is
	constant data : bit_vector(0 to 64-1) := x"aaaa_aaab" & x"0000_ffff";
	signal txc  : bit;
	signal txen : bit;
	signal txd : bit;
	signal rxc  : bit;
	signal rxd : bit;
	signal xd  : bit;
begin
	txc <= not txc after 20*15 ns;
	rxc <= not rxc after 20 ns;
	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				txd <= data(cntr);
				txen <= '1';
				cntr := cntr + 1;
			else
				txen <= '0';
			end if;
		end if;
	end process;

	tx_d : entity work.tx_manchester
	port map (
		clk  => txc,
		txen => txen,
		txd  => txd,
		sout => xd);

	rx_d : entity work.rx_manchester
	port map (
		clk => rxc,
		rxd => rxd,
		sin => xd);
end;