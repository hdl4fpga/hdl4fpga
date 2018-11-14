library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity vector is
	port (
		vector_clk  : in  std_logic;
		vector_rst  : in  std_logic;
		vector_ena  : in  std_logic := '1';
		vector_addr : in  std_logic_vector;
		vector_full : out std_logic;
		vector_di   : in  std_logic_vector;
		vector_do   : out std_logic_vector;
		vector_head : out std_logic_vector;
		vector_tail : out std_logic_vector;
		head_ena   : in  std_logic;
		head_updn  : in  std_logic;
		tail_ena   : in  std_logic;
		tail_updn  : in  std_logic);
end;

architecture def of vector is
	signal mem_ptr : unsigned(vector_addr'length-1 downto 0);
	signal head    : unsigned(vector_head'length-1 downto 0);
	signal tail    : unsigned(vector_tail'length-1 downto 0);
	signal full    : std_logic;
begin

	mem_ptr <= unsigned(vector_addr);
	head_p : process(vector_clk)
		variable ptr : unsigned(vector_head'range);
	begin
		if rising_edge(vector_clk) then
			if vector_rst='1' then
				ptr := (others => '0');
			elsif vector_ena='1' then
				if head_ena='1' then
					if head_updn='0' then
						ptr := ptr + 1;
					else
						ptr := ptr - 1;
					end if;
				elsif full='1' then
					if tail_ena='1'  then
						if tail_updn='0' then
							ptr := ptr + 1;
						else
							ptr := ptr - 1;
						end if;
					end if;
				end if;
			end if;
			head <= ptr;
		end if;
	end process;

	tail_p : process(vector_clk)
		variable ptr : unsigned(vector_addr'range);
	begin
		if rising_edge(vector_clk) then
			if vector_rst='1' then
				ptr := (others => '0');
			elsif vector_ena='1' then
				if tail_ena='1' then
					if tail_updn='0' then
						ptr := ptr + 1;
					else
						ptr := ptr - 1;
					end if;
				elsif full='1' then
					if head_ena='1' then
						if head_updn='0' then
							ptr := ptr + 1;
						else
							ptr := ptr - 1;
						end if;
					end if;
				end if;
			end if;
			tail <= ptr;
		end if;
	end process;

	full <= setif((head(mem_ptr'range)+tail(mem_ptr'range)=(vector_addr'range => '1')));

	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => vector_clk,
		wr_ena  => vector_ena,
		wr_addr => std_logic_vector(mem_ptr),
		wr_data => vector_di,
		rd_addr => std_logic_vector(mem_ptr),
		rd_data => vector_do);

	vector_full <= full;
	vector_head <= std_logic_vector(head);
	vector_tail <= std_logic_vector(tail);

end;
