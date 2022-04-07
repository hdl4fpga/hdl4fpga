library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjsto is
	generic (
		GEAR     : natural);
	port (
		ddr_clk  : in std_logic;
		sys_req  : in std_logic;
		sys_rdy  : buffer std_logic;
		ddr_smp  : in std_logic_vector(0 to GEAR-1);
		ddr_sti  : in std_logic;
		ddr_sto  : buffer std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of adjsto is

	constant bl     : natural := 8/2;
	signal cy       : std_logic;
	signal sel      : std_logic_vector(0 to unsigned_num_bits(bl-1)-1);

	signal step_req : std_logic;
	signal step_rdy : std_logic;

begin

	process (ddr_sti, sel, ddr_clk)
		variable delay : unsigned(1 to bl-1);
	begin
		if rising_edge(ddr_clk) then
			delay(1) := ddr_sti;
			delay    := rotate_left(delay,1);
		end if;
		ddr_sto <= word2byte(reverse(std_logic_vector(delay) & ddr_sti), sel);
	end process;

	process (ddr_clk)
		variable start : std_logic;
		variable acc   : unsigned(0 to (unsigned_num_bits(GEAR-1)-1)+3-1);
		variable cntr  : unsigned(0 to 4-1);
		variable sto   : std_logic;
	begin
		if rising_edge(ddr_clk) then
			if to_bit(step_req xor step_rdy)='1' then
				if start='0' then
					cy    <= '0';
					acc   := to_unsigned((GEAR/2)-1, acc'length);
					cntr  := (others => '0');
					start := '1';
				else
					if ddr_sto='1' then
					case ddr_smp(0 to 3) is
					when "0010"|"1001"|"0100" =>
						acc := acc + 1;
					when "1010"|"0101" =>
						acc := acc + 2;
					when "010X" =>
						acc := acc + 1;
					when others =>
					end case;
				elsif acc(0)='1' then
				to_unsigned((GEAR/2)-1, acc'length) then
					cy       <= acc(0);
					acc      := to_unsigned((GEAR/2)-1, acc'length);
					start    := '0';
					step_rdy <= step_req;
				end if;
				end if;
			else
				start    := '0';
				step_rdy <= to_stdulogic(to_bit(step_req));
			end if;
			sto := ddr_sto;
		end if;
	end process;

	process (ddr_clk)
		variable start : std_logic;
	begin
		if to_bit(sys_req xor sys_rdy)='1' then
			if rising_edge(ddr_clk) then
				if start='0' then
					sel      <= (others => '0');
					start    := '1';
					step_req <= not to_stdulogic(to_bit(step_rdy));
				elsif start='1' then
					if to_bit(step_req xor step_rdy)='0' then
						if cy ='0' then
							sel <= std_logic_vector(unsigned(sel)+1);
							step_req <= not step_rdy;
						else
							sys_rdy <= sys_req;
						end if;
					end if;
				end if;
			end if;
		else
			start   := '0';
			sys_rdy  <= to_stdulogic(to_bit(sys_req));
		end if;
	end process;
end;
