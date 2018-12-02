library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_ftod is
	port (
		clk     : in  std_logic;
		bin_pnt : in  std_logic_vector := std_logic_vector'(0 to 0 => '0');
		bin_ena : in  std_logic;
		bin_di  : in  std_logic_vector;
		bin_fix : in  std_logic := '0';

		bcd_rdy : out std_logic;
		bcd_lft : out std_logic_vector(4-1 downto 0);
		bcd_rgt : out std_logic_vector(4-1 downto 0);

		bcd_do  : out std_logic_vector);
end;

architecture def of scopeio_ftod is

    signal bcd_lst : std_logic;

begin

	process (clk)
		variable cntr : unsigned(0 to bin_pnt'length);
	begin
		if rising_edge(clk) then
			if bin_ena='1' then
				cntr := resize(unsigned(bin_pnt), cntr'length);
			elsif bcd_lst='1' then
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
		end if;
	end process;

	du: entity hdl4fpga.ftod
	generic map (
		size       => 4)
	port map (
		clk     => clk,
		bin_frm => bin_ena,
		bin_di  => bin_di,
		bin_flt => bin_fix,

		bcd_left => bcd_lft,
		bcd_right => bcd_rgt,
		bcd_do  => bcd_do);

	bcd_rdy <= bcd_lst;
end;
