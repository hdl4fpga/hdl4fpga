
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_axisreading is
	generic (
		grid_unit  : natural);
	port (
		rgtr_clk : in  std_logic;
		txt_req  : in  std_logic;
		txt_rdy  : buffer std_logic;
		offset   : in  std_logic_vector;
		scale    : in  std_logic_vector;
		str_req  : buffer std_logic;
		str_rdy  : in  std_logic;
		btod_req : buffer std_logic;
		btod_rdy : in  std_logic;
		binary   : out std_logic_vector);
end;

architecture def of scopeio_axisreading is
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
				if (txt_rdy xor txt_req)='1' then
					a <= scale;
					if signed(offset) >= 0 then
						b <=  signed(offset);
					else 
						b <= -signed(offset);
					end if;
					mul_req <= not mul_rdy;
					str_req <= not str_rdy;
					state   := s_label;
				end if;
			when s_offset =>
				if (btod_req xor btod_rdy)='0' then
					if (mul_req xor mul_rdy)='0' then
						btod_req <= not btod_rdy;
						state   := s_unit;
					end if;
				end if;
			when s_unit =>
				if (btod_req xor btod_rdy)='0' then
					a <= scale;
					b <= to_signed(grid_unit, b'length);
					mul_req <= not mul_rdy;
					str_req <= not str_rdy;
					btod_req <= not btod_rdy;
					state   := s_scale;
				end if;
			when s_scale =>
				if (btod_req xor btod_rdy)='0' then
					if (mul_req xor mul_rdy)='0' then
						btod_req <= not btod_rdy;
						txt_rdy <= txt_req;
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
		s   => binary);

end;
