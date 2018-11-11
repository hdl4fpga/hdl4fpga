library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ftod is
	generic (
		n       : natural := 4);
	port (
		clk     : in  std_logic;
		bin_ena : in  std_logic;
		bin_dv  : out std_logic;
		bin_di  : in  std_logic_vector;
		bin_fix : in  std_logic := '0';

		bcd_lst : out std_logic;
		bcd_lft : out std_logic_vector(n-1 downto 0);
		bcd_rgt : out std_logic_vector(n-1 downto 0);
		bcd_do  : out std_logic_vector);
end;

architecture def of ftod is

	signal queue_left     : unsigned(1 to cntr'right);

	signal mem_ptr  : unsigned(1 to cntr'right);
begin

	btod_bdv  <= bin_ena;

	btod_ddi <= queue_do when else (btod_ddi'range => '0');
	btod_e : entity hdl4fpga.btod
	port map (
		clk     => clk,
		bin_ena => btod_bena,
		bin_dv  => btod_bdv,
		bin_di  => btod_bdi,

		bcd_di  => btod_ddi,
		bcd_do  => btod_ddo,
		bcd_cy  => btod_dcy);
   		
	queue_addr_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_ena='0' then
				queue_addr <= (others => '0');
			else
				queue_addr <= queue_addr + 1;
			end if;
		end if;
	end process;

	process
	begin
		if queue_addr=queue_head then
			head_updn <= '-';
			head_ena  <= '0';
			if btod_dcy='1' then
				head_updn <= up;
				head_ena  <= '1';
			end if;
		end if;
	end process;

	queue_di <= btod_do when fix='0' else dtof_do;
	queue_e : entity hdl4fpga.queue
	port map (
		queue_clk  => queue_clk,
		queue_rst  => queue_rst,
		queue_ena  => queue_ena,
		queue_addr => queue_addr,
		queue_full => queue_full,
		queue_di   => queue_di,
		queue_do   => queue_do,
		head_ena   => left_ena,
		head_updn  => left_updn,
		queue_head => queue_left,
		tail_ena   => tail_ena,
		tail_updn  => tail_updn,
		queue_tail => queue_tail);

	bcd_do <= queue_di;
end;
