library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddrwl is
	port (
		clk : in  std_logic;
		req : in  std_logic;
		adjreq : out std_logic;
		rdy : out std_logic;
		nxt : out std_logic;
		dg  : out std_logic_vector);
end;

library hdl4fpga;

architecture beh of ddrwl is
	signal aph_dg  : unsigned(0 to dg'length);
	signal aph_nxt : std_logic;
	signal aph_req : std_logic;
begin

	process (clk)
		variable cntr : unsigned(0 to 5);
	begin
		if rising_edge(clk) then
			if req='0' then
				cntr := to_unsigned(25-2, cntr'length);
			elsif cntr(0)='0' then
				cntr := cntr - 1;
			end if;
			aph_req <= cntr(0);
		end if;
	end process;
	adjreq <= aph_req;

	process (clk)
		variable slr : std_logic_vector(0 to 5-1);
	begin
		if rising_edge(clk) then
			aph_nxt <= slr(slr'right) and not aph_dg(aph_dg'right);
			if aph_req='0' then
				slr    := (0 => '1', others => '0');
				aph_dg <= (0 => '1', others => '0');
				aph_nxt <= '0';
			else
				if aph_nxt='1' then
					aph_dg <= aph_dg srl 1;
				end if;
				slr := slr(slr'right) & slr(0 to slr'right-1);
			end if;
		end if;
	end process;

	nxt <= aph_nxt;
	dg  <= std_logic_vector(aph_dg(0 to dg'length-1));
	rdy <= aph_dg(aph_dg'right);

end;
