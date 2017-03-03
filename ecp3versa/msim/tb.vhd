use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;

entity tb is
end;

architecture beh of tb is
	signal mii_treq :  std_logic := '0';
	signal mii_txc  :  std_logic := '0';
	signal mii_txdv :  std_logic;
	signal mii_txd  :  std_logic_vector(0 to 4-1);

	signal mem_req  :  std_logic;
	signal mem_rdy  :  std_logic;
	signal mem_ena  :  std_logic;
	signal mem_dat  :  std_logic_vector(0 to 4-1);
begin

	mii_txc <= not mii_txc after 5 ns;
	dut : entity hdl4fpga.scopeio_miitx
	port map (
		mii_treq => mii_treq,
		mii_txc  => mii_txc,
		mii_txdv => mii_txdv,
		mii_txd  => mii_txd,

		mem_req  => open,
		mem_rdy  => '1',
		mem_ena  => '0',
		mem_dat  => (0 to 4-1 => '0'));

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
