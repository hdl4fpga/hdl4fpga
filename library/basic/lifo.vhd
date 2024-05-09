
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity lifo is
	generic (
		size : natural := 16);
	port (
		clk       : in  std_logic;
		ov        : out std_logic;
		push_ena  : in  std_logic;
		push_data : in  std_logic_vector;
		pop_ena   : in  std_logic;
		pop_data  : out std_logic_vector);

	constant addr_size : natural := unsigned_num_bits(size-1);

end;

architecture def of lifo is

	signal   wr_addr   : std_logic_vector(0 to addr_size-1);
	signal   rd_addr   : std_logic_vector(0 to addr_size-1);
	signal   sk_ptr    : unsigned(0 to addr_size-1) := (others => '1');

begin

	wr_addr <= std_logic_vector(sk_ptr + 1);
	rd_addr <= std_logic_vector(sk_ptr);
   	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => x"aaaa_aaaa_aaaa_aaaa")
   	port map (
   		wr_clk  => clk,
   		wr_addr => wr_addr,
   		wr_ena  => push_ena ,
   		wr_data => push_data,
   		rd_addr => rd_addr,
   		rd_data => pop_data);

	process (clk)
		variable length : unsigned(0 to addr_size) := (others => '1');
		type states is (s_pushing, s_popping);
		variable state : states;
	begin
		if rising_edge(clk) then
			if (push_ena xor pop_ena)='1' then
				if push_ena ='1' then
					if state=s_popping then
						length := (others => '1');
					else
						length := length + 1;
					end if;
					sk_ptr <= unsigned(wr_addr);
				elsif pop_ena='1' then
					if state=s_pushing then
					end if;
					if length(0)='0' then
						length := length - 1;
					end if;
					sk_ptr <= sk_ptr - 1;
				end if;
			end if;
		end if;
		ov <= length(0);
	end process;

end;