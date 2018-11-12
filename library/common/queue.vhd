library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity queue is
	port (
		queue_clk  : in  std_logic;
		queue_rst  : in  std_logic;
		queue_ena  : in  std_logic := '1';
		queue_addr : in  std_logic_vector;
		queue_full : out std_logic;
		queue_di   : in  std_logic_vector;
		queue_do   : out std_logic_vector;
		queue_head : out std_logic_vector;
		queue_tail : out std_logic_vector;
		head_ena   : in  std_logic;
		head_updn  : in  std_logic;
		tail_ena   : in  std_logic;
		tail_updn  : in  std_logic);
end;

architecture def of queue is
	signal mem_ptr : unsigned(queue_addr'length-1 downto 0);
	signal head    : unsigned(queue_head'length-1 downto 0);
	signal tail    : unsigned(queue_tail'length-1 downto 0);
	signal full    : std_logic;
begin

	head_p : process(queue_clk)
		variable ptr : unsigned(queue_head'range);
	begin
		if rising_edge(queue_clk) then
			if queue_rst='0' then
				ptr := (others => '0');
			elsif queue_ena='1' then
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

	tail_p : process(queue_clk)
		variable ptr : unsigned(queue_addr'range);
	begin
		if rising_edge(queue_clk) then
			if queue_rst='0' then
				ptr := (others => '0');
			elsif queue_ena='1' then
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

	full <= setif((head(mem_ptr'range)+tail(mem_ptr'range)=(queue_addr'range => '1')));

	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => queue_clk,
		wr_ena  => queue_ena,
		wr_addr => std_logic_vector(mem_ptr),
		wr_data => queue_di,
		rd_addr => std_logic_vector(mem_ptr),
		rd_data => queue_do);

	queue_full <= full;
	queue_head <= std_logic_vector(head);
	queue_tail <= std_logic_vector(tail);

end;
