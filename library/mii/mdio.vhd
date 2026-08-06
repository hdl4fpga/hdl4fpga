library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mdio is
	port (
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic := '0';
		dev  : in  std_logic_vector(0 to  5-1):= b"00001";
		rid  : in  std_logic_vector(0 to 16-1);
		din  : in  std_logic_vector(0 to 16-1);
		dout : out std_logic_vector(0 to 16-1);
		mdc  : out std_logic   := '0';
		mdio : inout std_logic := 'Z');
end;

architecture mix of mdio is
	constant start_bits : std_logic_vector := "01";
	constant trna_bits  : std_logic_vector := "10";
begin
	process(clk)
		type states is (s_prem, s_start, s_op, s_dev, s_rid, s_trna, s_data);
		variable state : states;
		variable cntr  : integer range -1 to 31;
		variable shr   : unsigned(0 to din'length-1);
	begin
		if rising_edge(clk) then
			if (rdy xor req)='1' then
				cntr := cntr - 1;
				case state is
				when s_prem =>
					if cntr < 0 then
						cntr  := start_bits'length;
						shr(0 to 2-1) := start_bits;
						state := s_start;
					else
						shr(0) := '1';
					end if;
				when s_start =>
					if cntr < 0 then
						cntr  := op'length-1;
						shr(op'range) := op;
						state := s_dev;
					end if;
				when s_op =>
					if cntr < 0 then
						cntr  := dev'length-1;
						shr(dev'range) := dev;
						state := s_dev;
					end if;
				when s_dev =>
					if cntr < 0 then
						cntr  := rid'length-1;
						shr(rid'range) := rid;
						state := s_rid;
					end if;
				when s_rid =>
					if cntr < 0 then
						cntr := trna_bits'length-1;
						if op=rd then
							shr(tran_bits'range) := (others => 'Z');
						else
							shr(tran_bits'range) := trna_bits;
						end if;
						state := s_trna;
					end if;
				when s_trna =>
					if cntr < 0 then
						cntr  := din'length-1;
						if op=rd then
							shr(din'range) := (others => 'Z');
						else
							shr(din'range) := din;
						end if;
						state := s_data;
					end if;
				when s_data =>
					if cntr < 0 then
						rdy   <= req;
						cntr  := 32-1;
						dout  <= std_logic_vector(dout'range));
						state := s_prem;
					end if;
				end case;
			else
				cntr   := 32-1;
				shr(0) := '0';
			end if;
			mdio   <= shr(0);
			shr(0) := mdio;
			shr := rotate_left(shr, 1);
		end if;
	end process;
	mdc <= clk;
end;
