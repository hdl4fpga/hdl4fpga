library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ddr_timer is
	generic ( 
		c200u : natural := 9;
		c500u : natural := 10;
		cDLL  : natural := 6;
		cREF  : natural := 4);
	port (
		ddr_timer_clk  : in  std_logic;
		ddr_timer_rst  : in  std_logic;
		ddr_timer_sel  : in  std_logic_vector(0 to 1);
		ddr_timer_200u : out std_logic;
		ddr_timer_dll  : out std_logic;
		ddr_timer_ref  : out std_logic);

	constant q200u : natural := unsigned_num_bits(c200u);
	constant qdll  : natural := unsigned_num_bits(cDLL);
	constant qref  : natural := unsigned_num_bits(cREF);
end;

architecture def of ddr_timer is
	constant q_len   : natural_vector(0 to 1) := (max(qdll,qref), q200u-max(qdll,qref));
	constant cnt_len : natural_vector(0 to 1) := (max(qdll,qref), q200u-max(qdll,qref));
	signal q0  : std_logic_vector(0 to 1);

	signal timer_200u : std_logic;
	signal timer_dll  : std_logic;
	signal timer_ref  : std_logic;
begin
--	process
--		variable msg : line;
--	begin
--		write (msg, string'("q200u "));
--		write (msg, q200u);
--		write (msg, string'(" : c200u "));
--		write (msg, c200u);
--		write (msg, string'(" : qREF "));
--		write (msg, qREF);
--		write (msg, string'(" : cDLL "));
--		write (msg, cREF);
--		writeline (output, msg);
--		wait;
--	end process;

	counter_g: for i in 0 to 1 generate
		signal tmr_cntr unsigned(0 to q_length(i));
		signal tmr_data : unsigned(0 to q_length(i));
		signal load : std_logic;
		signal ena  : std_logic;
		signal data : unsigned(d'range);
	begin

		process (ddr_timer_clk)
		begin
			if rising_edge(ddr_timer_clk) then
				tmr_cntr <= dec (
					cntr => tmr_cntr,
					load => q(0),
					data => d);
			end if;
		end process;

		tmr_data <= 
			data when else;
			to_unsigned(2**q_length(i)-2, q'length);

		with select
		data <= 
			to_unsigned(c200u/2**cnt_len(i) mod 2**q_len(i), q_len(i)) when 
			to_unsigned( cDLL/2**cnt_len(i) mod 2**q_len(i), q_len(i)) when
			to_unsigned( cREF/2**cnt_len(i) mod 2**q_len(i), q_len(i)) when others;
				
		low_g: if i=0 generate
			signal sel  : std_logic_vector(0 to 1);
		begin
		end generate;

		high_g: if i=1 generate
			signal sel : std_logic;
		begin
			
			sel <= '0' when ddr_timer_sel='0' else '1';
			data   <= to_unsigned(c200u/2**q_length(0)-1, q'length);
		end generate;

		q0(i) <= q(0);
	end generate;

	process (ddr_timer_clk)
	begin
		if rising_edge(ddr_timer_clk) then
			if ddr_timer_rst='1' then
				timer_dll <= '0';
				timer_ref <= '0';
				timer_200u <= '0';
			else
				if timer_200u='0' then
					timer_200u <= q0(1) and q0(0);
				end if;
				if timer_200u='1' then
					if timer_dll='0' then
						timer_dll <= q0(0);
					end if;
				end if;
				if timer_dll='1' then
					timer_ref <= q0(0);
				end if;
			end if;
			ddr_timer_200u <= timer_200u;
			ddr_timer_dll  <= timer_dll;
			ddr_timer_ref  <= timer_ref;
		end if;
	end process;
end;
