library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity vector is
	port (
		vector_clk   : in  std_logic;
		vector_rst   : in  std_logic;
		vector_ena   : in  std_logic := '1';
		vector_addr  : in  std_logic_vector;
		vector_full  : out std_logic;
		vector_di    : in  std_logic_vector;
		vector_do    : out std_logic_vector;
		vector_left  : out std_logic_vector;
		vector_right : out std_logic_vector;
		left_ena     : in  std_logic;
		left_up      : in  std_logic;
		right_ena    : in  std_logic;
		right_up     : in  std_logic);
end;

architecture def of vector is
	signal mem_ptr : unsigned(vector_addr'length-1 downto 0);
	signal left    : unsigned(vector_left'length-1 downto 0);
	signal right   : unsigned(vector_right'length-1 downto 0);
	signal full    : std_logic;
begin

	process(vector_clk)
	begin
		if rising_edge(vector_clk) then
			mem_ptr <= unsigned(vector_addr);
		end if;
	end process;

	left_p : process(vector_clk)
		variable ptr : unsigned(vector_left'range);
	begin
		if rising_edge(vector_clk) then
			if vector_rst='1' then
				ptr := (others => '0');
			elsif vector_ena='1' then
				if left_ena='1' then
					if left_up='1' then
						ptr := ptr + 1;
					else
						ptr := ptr - 1;
					end if;
				elsif full='1' then
					if right_ena='1'  then
						if right_up='1' then
							ptr := ptr + 1;
						else
							ptr := ptr - 1;
						end if;
					end if;
				end if;
			end if;
			left <= ptr;
		end if;
	end process;

	right_p : process(vector_clk)
		variable ptr : unsigned(vector_addr'range);
	begin
		if rising_edge(vector_clk) then
			if vector_rst='1' then
				ptr := (others => '0');
			elsif vector_ena='1' then
				if right_ena='1' then
					if right_up='1' then
						ptr := ptr + 1;
					else
						ptr := ptr - 1;
					end if;
				elsif full='1' then
					if left_ena='1' then
						if left_up='1' then
							ptr := ptr + 1;
						else
							ptr := ptr - 1;
						end if;
					end if;
				end if;
			end if;
			right <= ptr;
		end if;
	end process;

	full <= setif((left(mem_ptr'range)-right(mem_ptr'range)=(vector_addr'range => '1')));

	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => vector_clk,
		wr_ena  => vector_ena,
		wr_addr => vector_addr,
		wr_data => vector_di,
		rd_addr => std_logic_vector(mem_ptr),
		rd_data => vector_do);

	vector_full  <= full;
	vector_left  <= std_logic_vector(left);
	vector_right <= std_logic_vector(right);

end;
