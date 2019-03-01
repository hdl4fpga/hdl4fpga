library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity btod is
	port (
		clk           : in  std_logic;

		bin_frm       : in  std_logic;
		bin_irdy      : in  std_logic := '1';
		bin_trdy      : buffer std_logic;
		bin_di        : in  std_logic_vector;

		mem_ena       : buffer std_logic;
		mem_full      : in  std_logic;

		mem_left      : in  std_logic_vector;
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in  std_logic_vector;
		mem_right_up  : out std_logic := '-';
		mem_right_ena : out std_logic := '0';

		mem_addr      : buffer std_logic_vector;
		mem_di        : out std_logic_vector;
		mem_do        : in  std_logic_vector);
end;

architecture def of btod is

	signal btod_ena : std_logic;
	signal bcd_ini  : std_logic;
	signal bcd_zero : std_logic := '1';
	signal bcd_trdy : std_logic;
	signal bcd_cy   : std_logic;
	signal bcd_di   : std_logic_vector(mem_do'range);
	signal bcd_do   : std_logic_vector(mem_di'range);

	signal cy : std_logic;
	signal up : std_logic;

	signal frm      : std_logic;
	signal addr     : unsigned(mem_addr'range);
	signal bcd_irdy : std_logic;
	signal mem_trdy : std_logic;
	signal mem_irdy : std_logic;
	signal addr_eq  : std_logic;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			frm <= bin_frm;
		end if;
	end process;

	process(bin_frm, clk)
		type states is (s1, s2, s3);
		variable state : states;
	begin
		if bin_frm='0' then
			btod_ena <= '0';
			bcd_irdy <= '1';
			bcd_trdy <= '0';
			bin_trdy <= '0';
			bcd_ini  <= '1';
			state    := s1;
		elsif rising_edge(clk) then
			case state is
			when s1 =>
				if bcd_irdy='1' then
					btod_ena <= '1';
					bcd_trdy <= '0';
				else
					btod_ena <= '0';
					bcd_trdy <= '0';
				end if;
			when s2 =>
				btod_ena <= '0';
				bcd_trdy <= '1';
				bcd_ini  <= '0';
				if addr_eq='1' then
					if cy='0' then
						bin_trdy <= '1';
					else
						bin_trdy <= '0';
					end if;
				else
					bin_trdy <= '0';
				end if;
			when s3 =>
				btod_ena <= '0';
				bcd_trdy <= '0';
			end case;	

			case state is
			when s1 =>
				if bcd_irdy='1' then
					state := s2;
				end if;
			when s2 =>
				state := s3;
			when s3 =>
				state := s1;
			end case;	
		end if;
	end process;

	dbdbbl_e : entity hdl4fpga.dbdbbl
	port map (
		clk     => clk,
		ena     => btod_ena,
		bin_di  => bin_di,

		bcd_ini => bcd_ini,
		bcd_di  => bcd_di,
		bcd_do  => bcd_do,
		bcd_cy  => bcd_cy);

	process (clk)
	begin
		if rising_edge(clk) then
			if bcd_zero='1' then
				bcd_di <= (bcd_di'range => '0');
			else
				bcd_di <= mem_do;
			end if;
			addr_eq <= setif(mem_addr=mem_left);
			mem_di  <= bcd_do;
			cy      <= bcd_cy;
		end if;
	end process;


	mem_ena  <= bcd_trdy;
	mem_p : process(clk)
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				mem_addr     <= mem_right(mem_addr'range);
				mem_left_up  <= '-';
				mem_left_ena <= '0';
			elsif bcd_trdy='1' then
				if addr_eq='1' then
					if cy='1' then
						mem_addr     <= std_logic_vector(unsigned(mem_addr) + 1);
						mem_left_up  <= '1';
						mem_left_ena <= '1';
					else
						mem_addr     <= mem_right(mem_addr'range);
						mem_left_up  <= '-';
						mem_left_ena <= '0';
					end if;
				else
					mem_addr     <= std_logic_vector(unsigned(mem_addr) + 1);
					mem_left_up  <= '-';
					mem_left_ena <= '0';
				end if;
			else
				mem_left_up  <= '-';
				mem_left_ena <= '0';
			end if;
		end if;
	end process;

end;
