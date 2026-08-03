library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mdio_wr is
	port (
		clk  : in  std_logic;
		req  : in  std_logic;
		rdy  : buffer std_logic := '0';
		addr : in  std_logic_vector( 5-1 downto 0):= b"00001";
		rdi  : in  std_logic_vector(16-1 downto 0);
		data : in  std_logic_vector(16-1 downto 0):
		mdc  : out std_logic   := '0';
		mdio : inout std_logic := 'Z');
end;

architecture mix of mdio is
begin
	process(clk)
		type states is (s_init, s_send);
		variable state : states;
		variable shr   : unsigned(0 to addr'length+rid'length+data'lenght-1);
		variable cntr  : integer range -2**shr'length/2 to 2**shr'length-1;
	begin
		if rising_edge(clk) then
			case state is
			when s_rdy =>
				if (rdy xor req)='1' then
					shr  := x"ffffffff" & b"01" & OP & addr & rdi & "10" & data;
					cntr := shr'length-1;
					state := s_req;
				end if;
			when s_req =>
				if (req xor rdy)='0' then
					state := s_rdy;
				elsif cntr <= 0 then
					rdy   <=req;
					state := s_rdy;
				end if;
				cntr := cntr - 1;
				shr  := shift_left(shr, 1);
			end case;
			mdio <=shr(0);
		end if;
	end process;
	mdc <= clk;
end;
