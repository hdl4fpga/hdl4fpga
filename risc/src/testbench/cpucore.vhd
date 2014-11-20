library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end;

architecture behavioral of testbench is
    constant N : natural := 32;

	type codeT is array (natural range <>) of std_ulogic_vector (0 to 15);
	type opcT is (
		alu,   one,  two, three,
		four,  five, six, seven,
		jal,   jral, brt, eleven,
		twelve, thirteen, addi, cmpi);

	type opcT_vector is array (0 to 15) of opcT;

	constant clkC : std_ulogic_vector := "01";
	constant codeC : codeT := (
	component cpucore
 		generic (
 			dwidth : natural := N;
 			cwidth : natural := 16);
 		port (
 			rst   : in  std_ulogic;
 			clk   : in  std_ulogic;
 			caddr : out std_ulogic_vector(dwidth-1 downto 0);
		
 			code  : in  std_ulogic_vector(0 to cwidth-1));
	end component;
			
	signal rstS : std_ulogic;
	signal clkS : std_ulogic;
	signal codeS : std_ulogic_vector(0 to 15);
	signal caddrS : std_ulogic_vector(N-1 downto 0);
	signal clkNumS : natural;
	signal opcS : opcT;

begin
	dut : cpucore
 		port map (
 			rst => rstS,
 			clk => clkS,
 			caddr => caddrS,
 			code  => codeS);

	rstS <= '1', '0' after 25 ns;
	
	process (caddrS)
		variable codeV : std_ulogic_vector(0 to 15);
	begin
		codeV := codeC(to_integer(unsigned(caddrS)) mod codeC'length);
		codeS <= codeV ;--  after 5 ns;
		opcS <= opcC(to_integer(unsigned(codeV(0 to 3)))); --after 5 ns;
	end process;

	process
		variable step : natural := 0;
		variable mullen : natural := 0;

	begin
	    
        mullen := 1;

		clkS <= clkC((step / mullen) mod clkC'length);
		mullen := mullen * clkC'length;
		clkNumS <= step / mullen;
        
		step := step + 1;
		wait for 20 ns;
	end process;
end;
