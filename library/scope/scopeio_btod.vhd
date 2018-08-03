library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_tobcd is
	port (
		bcd_rgt : in std_logic_vector;
		bin_ena   : in  std_logic;
		bin_dv    : out std_logic;
		bin_di    : in  std_logic_vector;
		bcd_ena   : in  std_logic;
		bcd_lst   : out std_logic;
		bcd_do    : out std_logic_vector);
end;

architecture def of scopeio_tobcd is

	signal bcd_di  : std_logic_vector(bcd_do'range);
	signal bcd_ptr : signed;
begin

	process (clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' and bcd_ena='0' then
				bcd_ptr <= not resize(signed(size1), bcd_ptr'length);
			elsif bcd_ptr(0)='1' then
				bcd_ptr <= not resize(signed(size1), bcd_ptr'length);
			else
				bcd_ptr <= bcd_ptr - 1;
			end if;
		end if;
	end process;

	bin_dv <= bcd_ptr(0);
	bcd_dv <= bcd_ena and bcd_ptr(0);

	btod_e : entity hdl4fpga.btod
	generic map (
		registered_output => true)
	port map (
		clk    => clk,
		bin_dv => bcd_ptr(0),
		bin_di => bin_di,

		bcd_dv => '1',
		bcd_di => bcd_di,
		bcd_do => bcd_do);

	rd_addr <=
		std_logic_vector(bcd_ptr(1 to 4) when bin_ena='1' else
		
	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bin_ena,
		wr_addr => std_logic_vector(bcd_ptr(1 to 4)),
		wr_data => bcd_do,
		rd_addr => std_logic_vector(bcd_ptr(1 to 4)),
		rd_data => bcd_di);

end;
