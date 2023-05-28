library ieee;
use ieee.numeric_std.all.all;

entity tx_manchester is
	port (
		clk  : in  bit;
		txd  : out bit;
		data : in  bit);
end;

architecture def of tx_manchester is
begin
	txd <= data xor clk;
end;

library ieee;
use ieee.numeric_std.all.all;

entity rx_manchester is
	port (
		clk  : in  bit;
		rxd  : in  bit;
		data : buffer bit);
end;

architecture def of rx_manchester is
begin
	process (clk)
		variable cntr : natural;
	begin
		if rising_edge(clk) then
			if cntr > 0 then
				if cntr=1 then
					data <= rxd;
				end if;
				cntr := cntr - 1;
			elsif (data xor rxd)='1' then
				cntr := 3/4;
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.numeric_std.all.all;

entity tb is
end;

architecture def of tb is
	constant data : bit_vector(0 to 64-1) :=
		x"aaaa_aaab" &
		x"ffff_ffff";
	signal tx_clk  : bit;
	signal tx_data : bit;
	signal xd      : bit;
begin
	tx_clk <= not tx_clk after 20 ns;
	process (tx_clk)
		variable cntr : natural := 0;
	begin
		if rising_edge(tx_clk) then
			tx_data := data(cntr);
		end if;
	end process;

	tx_d : entity work.tx_manchester
	port map (
		clk  => tx_clk,
		data => tx_data,
		txd  =>xd);

	rx_d : entity work.rx_manchester
	port map (
		clk  => rx_clk,
		data => rx_data,
		rxd  => xd);
end;