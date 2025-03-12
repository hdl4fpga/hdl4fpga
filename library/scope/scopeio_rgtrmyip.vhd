library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrmyip is
	generic (
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		ip4_ena  : out std_logic;
		ip4_dv   : out std_logic;
		ip4_num1 : out std_logic_vector(8-1 downto 0);
		ip4_num2 : out std_logic_vector(8-1 downto 0);
		ip4_num3 : out std_logic_vector(8-1 downto 0);
		ip4_num4 : out std_logic_vector(8-1 downto 0));

end;

architecture def of scopeio_rgtrmyip is

	signal dv : std_logic;

begin
	dv <= setif(rgtr_id=rid_ipaddr, rgtr_dv);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			ip4_dv <= dv;
		end if;
	end process;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if dv='1' then
					ip4_num1 <= bitfield(rgtr_data, ip4num1_id, ip4addr_bf);
					ip4_num2 <= bitfield(rgtr_data, ip4num2_id, ip4addr_bf);
					ip4_num3 <= bitfield(rgtr_data, ip4num3_id, ip4addr_bf);
					ip4_num4 <= bitfield(rgtr_data, ip4num4_id, ip4addr_bf);
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		ip4_num1 <= bitfield(rgtr_data, ip4num1_id, ip4addr_bf);
		ip4_num2 <= bitfield(rgtr_data, ip4num2_id, ip4addr_bf);
		ip4_num3 <= bitfield(rgtr_data, ip4num3_id, ip4addr_bf);
		ip4_num4 <= bitfield(rgtr_data, ip4num4_id, ip4addr_bf);
	end generate;

	ip4_ena <= dv;
end;
