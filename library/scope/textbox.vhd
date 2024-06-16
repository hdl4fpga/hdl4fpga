
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_textbox is
	generic (
		grid_unit  : natural);
	port (
		rgtr_clk   : in  std_logic;
		txtwdt_req : in  std_logic;
		txtwdt_rdy : buffer std_logic;
		offset     : in  std_logic_vector;
		scale      : in  std_logic_vector;
		str_req    : buffer std_logic;
		str_rdy    : in  std_logic;
		wdt_req    : buffer std_logic;
		wdt_rdy    : in  std_logic;
		value      : out std_logic_vector);
end;

architecture def of scopeio_textbox is
	signal mul_req : std_logic;
	signal mul_rdy : std_logic;
	signal a       : std_logic_vector(0 to offset'length-1);
	signal b       : signed(0 to offset'length-1);
begin

	process (rgtr_clk)
		type states is (s_label, s_offset, s_unit, s_scale);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				if (txtwdt_rdy xor txtwdt_req)='1' then
					wdt_req  <= not wdt_rdy;
					str_req  <= not str_rdy;
					state    := s_label;
				end if;
			when s_offset =>
				if (str_req xor str_rdy)='0' then
					a <= scale;
					if signed(offset) >= 0 then
						b <=  signed(offset);
					else 
						b <= -signed(offset);
					end if;
					mul_req <= not mul_rdy;
					wdt_req <= not wdt_rdy;
					state   := s_unit;
				end if;
			when s_unit =>
				if (wdt_req xor wdt_rdy)='0' then
					if (txtwdt_req xor txtwdt_rdy)='1' then
					end if;
					state   := s_scale;
				end if;
			when s_scale =>
				if (wdt_req xor wdt_rdy)='0' then
					if (txtwdt_req xor txtwdt_rdy)='1' then
						a <= scale;
						b <= to_signed(grid_unit, b'length);
						mul_req <= not to_stdulogic(to_bit(mul_rdy));
						wdt_req <= not wdt_rdy;
						state   := s_unit;
					end if;
				end if;
			end case;
		end if;
	end process;

	mul_ser_e : entity hdl4fpga.mul_ser
	generic map (
		lsb => true)
	port map (
		clk => rgtr_clk,
		req => mul_req,
		rdy => mul_rdy,
		a   => a,
		b   => std_logic_vector(b(1 to b'right)),
		s   => value);

end;
