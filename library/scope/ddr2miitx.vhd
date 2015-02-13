library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr2miitx is
	port (
		ddrios_clk : in std_logic;
		ddrios_gnt : in std_logic;
		ddrios_a0  : in std_logic;
		ddrios_brst_req : out std_logic;
		miitx_rdy  : in std_logic;
		miitx_req  : out std_logic);
end;

architecture def of ddr2miitx is

	signal sync_rdy_edge : std_logic;
	signal sync_rdy_pdge : std_logic;
	signal sync_rdy_val  : std_logic_vector(0 to 1);

	signal a0_edge : std_logic;
	signal a0_dly  : std_logic;
	signal req     : std_logic;

begin

	miitx_req <= req;
			a0_edge <= not a0_dly xor ddrios_a0;
	process (ddrios_clk)
	begin
		if rising_edge(ddrios_clk) then

			if ddrios_gnt='1' then
				if req='0' then
					ddrios_brst_req <= '1';
					req <= '0';
					if a0_edge='1' then
						req <= '1';
						ddrios_brst_req <= '0';
					end if;
				elsif miitx_rdy='0' then
					req <= '1';
					ddrios_brst_req <= '0';
				else
					req <= '0';
					ddrios_brst_req <= '0';
				end if;
			else
				req <= '0';
				ddrios_brst_req <= '0';
			end if;

			sync_rdy_val  <= not sync_rdy_val(1) & not miitx_rdy;
			sync_rdy_edge <= sync_rdy_val(0);
			sync_rdy_pdge <= sync_rdy_val(0) xor sync_rdy_edge;

			a0_dly  <= not ddrios_a0;

		end if;
	end process;

end;
