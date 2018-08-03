library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_btod is
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_dv  : out std_logic;
		bin_di  : in  std_logic_vector;

		bcd_sz1 : in  std_logic_vector;
		bcd_ena : in  std_logic;
		bcd_lst : out std_logic;
		bcd_do  : out std_logic_vector);
end;

architecture def of scopeio_btod is

	signal bin_dv1 : std_logic;
	signal bcd_dv  : std_logic;
	signal bcd_di  : std_logic_vector(bcd_do'range);
	signal bcd_do1 : std_logic_vector(bcd_do'range);
	signal bcd_ptr : signed(0 to 4);
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' and bcd_ena='0' then
				bcd_ptr <= not resize(-signed(bcd_sz1), bcd_ptr'length);
				bcd_dv  <= '1';
			elsif bcd_ptr(0)='1' then
				bcd_ptr <= not resize(-signed(bcd_sz1), bcd_ptr'length);
				bcd_dv  <= '0';
			else
				bcd_ptr <= bcd_ptr - 1;
			end if;
		end if;
	end process;

	bin_dv  <= bin_dv1;
	bin_dv1 <= bcd_ptr(0) or bin_ena;
	bcd_lst <= bcd_ena and bcd_ptr(0);

	btod_e : entity hdl4fpga.btod
	generic map (
		registered_output => true)
	port map (
		clk    => clk,
		bin_dv => bin_dv1,
		bin_di => bin_di,

		bcd_dv => bcd_dv,
		bcd_di => bcd_di,
		bcd_do => bcd_do);

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bin_ena,
		wr_addr => std_logic_vector(bcd_ptr(1 to 4)),
		wr_data => bcd_do1,
		rd_addr => std_logic_vector(bcd_ptr(1 to 4)),
		rd_data => bcd_di);
	bcd_do <= bcd_do1;

end;
