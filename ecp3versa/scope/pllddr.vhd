library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library ecp3;
use ecp3.components.ALL;

entity pllddr is
	generic (
		dcm_per : real := 20.0);
	port (
        pllddr_rst  : in  std_logic; 
		pllddr_clki : in  std_logic; 
		pllddr_clk0 : out std_logic; 
		pllddr_clk90 : out std_logic; 
		pllddr_lkd  : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of pllddr is
	signal clkfb : std_logic;
begin

	pll_i : ehxpllf
	generic map (
		feedbk_path  => "CLKOP",
		clkos_trim_delay =>  0,
		clkos_trim_pol => "RISING", 
		clkop_trim_delay =>  0,
		clkop_trim_pol => "RISING", 
		delay_pwd => "DISABLED",
		delay_val => 0, 
		duty => 8,
		phase_delay_cntl => "STATIC",
		phaseadj => "90.0", 
		clkok_div => 2,
		clkop_div => 4,
		clkfb_div => 2,
		clki_div  => 1,
		fin => to_string(1000.0/dcm_per))
	port map (
		clki  => pllddr_clki,
		clkfb => clkfb,
		rst   => '0', 
		rstk  => '0',
		wrdel => '0',
		drpai3 => '0', 
		drpai2 => '0',
		drpai1 => '0',
		drpai0 => '0', 
		dfpai3 => '0',
		dfpai2 => '0',
		dfpai1 => '0', 
		dfpai0 => '0',
		fda3 => '0',
		fda2 => '0', 
		fda1 => '0',
		fda0 => '0',
		clkop => clkfb, 
		clkok => pllddr_clk90,
		clkok2 => open,
		lock => pllddr_lkd, 
		clkintfb => open);

	pllddr_clk0 <= clkfb;

end;
