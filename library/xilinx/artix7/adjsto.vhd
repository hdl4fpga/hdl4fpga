library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjsto is
	generic (
		GEAR     : natural);
	port (
		iod_clk  : in  std_logic;
		sys_req  : in  std_logic;
		sys_rdy  : out std_logic;
		ddr_clk  : in  std_logic;
		ddr_smp  : in  std_logic_vector(0 to GEAR-1);
		ddr_sti  : in  std_logic;
		ddr_sto  : buffer std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjsto is

	constant bl     : natural := 8/2;
	signal inc      : std_logic;
	signal sel      : std_logic_vector(0 to unsigned_num_bits(bl-1)-1);
	signal start    : std_logic;
	signal finish   : std_logic;

	signal step_req : std_logic;
	signal step_rdy : std_logic;

begin

	process (ddr_sti, sel, ddr_clk)
		variable delay  : unsigned(1 to bl-1);
	begin
		if rising_edge(ddr_clk) then
			delay(1) := ddr_sti;
			delay    := rotate_left(dly,1);
		end if;
		ddr_sto <= word2byte(reverse(std_logic_vector(dly) & ddr_sti), sel);
	end process;

	process (ddr_sti, sel, ddr_clk)
		variable start : std_logic;
		variable acc   : unsigned(0 to (unsigned_num_bits(GEAR-1)-1)+3-1);
	begin
		if rising_edge(ddr_clk) then
			if to_bit(step_req xor step_rdy)='1'
				if start='0' then
					inc <= '0';
					acc := to_unsigned((GEAR/2)-1, acc'length);
				elsif ddr_sto='1' then
					case ddr_smp(0 to 3) is
					when "0010"|"1001"|"0100" =>
						acc := acc + 1;
					when "1010"|"0101" =>
						acc := acc + 2;
					when "010X" =>
						acc := acc + 1;
					when others =>
					end case;
				else
					inc      <= not acc(0);
					acc      := to_unsigned((GEAR/2)-1, acc'length);
					start    := '0';
					step_rdy <= step_req;
				end if;
			else
				inc      <= '0';
				acc      := to_unsigned((GEAR/2)-1, acc'length);
				start    := '0';
				step_rdy <= step_req;
			end if;
		end if;
	end process;

	process (sys_req, ddr_clk)
	begin
		if sys_req='0' then
			start <= '0';
		elsif rising_edge(ddr_clk) then
			if ddr_sti='0' then
				start <= '1';
			end if;
		end if;
	end process;

	process (iod_clk)
		variable start : std_logic;
		variable tmr   : unsigned(0 to 4-1);
	begin
		if to_bit(sys_req xor sys_rdy)='1' then
			if rising_edge(iod_clk) then
				if start='0' then
					tmr   := (others => '0');
					sel   <= (others => '0');
					start := '1';
				elsif start='1' then
					if tmr(0)='1' then
						if inc='1' then
							tmr := (others => '0');
							sel <= std_logic_vector(unsigned(sel)+1);
						else
							sys_rdy <= sys_req;
						end if;
					else
						tmr := tmr + 1;
					end if;
				end if;
			end if;
		else
			start   := '0';
			sys_rdy <= sys_req;
		end if;
	end process;
	sys_rdy <= finish;
end;
