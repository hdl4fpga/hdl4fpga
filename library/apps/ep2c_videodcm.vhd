-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

entity ep2c_videodcm is
	generic (
		dcm : string);
	port (
		rst         : in std_logic := '0';
		clk         : in std_logic;
		video_clk   : out std_logic;
		video_shift_clk : out std_logic;
		videoio_clk : out std_logic;
		locked      : buffer std_logic);
end;

architecture def of ep2c_videodcm is
	constant video_ratio : natural := 10/2; -- 10 bits / 2 DDR video ratio

	component altpll
    	generic (
    		compensate_clock : string;
    		gate_lock_signal : string;
    		inclk0_input_frequency : natural;
    		intended_device_family : string;
    		invalid_lock_multiplier : natural;
    		lpm_hint : string;
    		lpm_type : string;
    		m : natural;
    		m_initial : natural;
    		m_ph : natural;
    		n : natural;
    		operation_mode : string;
    		port_activeclock : string;
    		port_areset : string;
    		port_clkbad0 : string;
    		port_clkbad1 : string;
    		port_clkloss : string;
    		port_clkswitch : string;
    		port_configupdate : string;
    		port_fbin : string;
    		port_inclk0 : string;
    		port_inclk1 : string;
    		port_locked : string;
    		port_pfdena : string;
    		port_phasecounterselect : string;
    		port_phasedone : string;
    		port_phasestep : string;
    		port_phaseupdown : string;
    		port_pllena : string;
    		port_scanaclr : string;
    		port_scanclk : string;
    		port_scanclkena : string;
    		port_scandata : string;
    		port_scandataout : string;
    		port_scandone : string;
    		port_scanread : string;
    		port_scanwrite : string;
    		port_clk0 : string;
    		port_clk1 : string;
    		port_clk2 : string;
    		port_clk3 : string;
    		port_clk4 : string;
    		port_clk5 : string;
    		port_clkena0 : string;
    		port_clkena1 : string;
    		port_clkena2 : string;
    		port_clkena3 : string;
    		port_clkena4 : string;
    		port_clkena5 : string;
    		port_extclk0 : string;
    		port_extclk1 : string;
    		port_extclk2 : string;
    		port_extclk3 : string;
    		valid_lock_multiplier : natural;
    		vco_post_scale : natural;
    		c0_high	 : natural;
    		c0_initial : natural;
    		c0_low : natural;
    		c0_mode : string;
    		c0_ph : natural;
    		c1_high : natural;
    		c1_initial : natural;
    		c1_low : natural;
    		c1_mode : string;
    		c1_ph : natural;
    		c2_high : natural;
    		c2_initial : natural;
    		c2_low : natural;
    		c2_mode : string;
    		c2_ph : natural;
    		clk0_counter : string;
    		clk1_counter : string;
    		clk2_counter : string);
    	port (
    		areset	: in std_logic ;
    		clk	: out std_logic_vector (5 downto 0);
    		inclk	: in std_logic_vector (1 downto 0);
    		locked	: out std_logic);
	end component;

	signal dummy_inclk1 : std_logic;
	signal dummy_clks   : std_logic_vector(3-1 downto 0);

	constant m  : natural := hdo(dcm)**".m"; --16;
	constant n  : natural := hdo(dcm)**".n"; --1;
	constant c1 : natural := hdo(dcm)**".c1"; --2;
	constant c0 : natural := hdo(dcm)**".c0"; --video_ratio*2;
	constant c2 : natural := hdo(dcm)**".c2"; --natural(clkref_freq*real(m)/(2.0*real(n)*clkio_freq));

begin

	pll_i : altpll
	generic map (
		m       => m,
		n       => n,
		c0_high => c0,
		c0_low  => c0,
		c1_high => c1,
		c1_low  => c1,
		c2_high => c2,
		c2_low  => c2,

		compensate_clock => "CLK0",
		gate_lock_signal => "NO",
		inclk0_input_frequency => 20000,
		intended_device_family => "Cyclone II",
		invalid_lock_multiplier => 5,
		lpm_hint => "CBX_MODULE_PREFIX=alt_videopll",
		lpm_type => "altpll",
		m_initial => 1,
		m_ph => 0,
		operation_mode => "NORMAL",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_USED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_UNUSED",
		port_fbin => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_USED",
		port_pfdena => "PORT_UNUSED",
		port_phasecounterselect => "PORT_UNUSED",
		port_phasedone => "PORT_UNUSED",
		port_phasestep => "PORT_UNUSED",
		port_phaseupdown => "PORT_UNUSED",
		port_pllena => "PORT_UNUSED",
		port_scanaclr => "PORT_UNUSED",
		port_scanclk => "PORT_UNUSED",
		port_scanclkena => "PORT_UNUSED",
		port_scandata => "PORT_UNUSED",
		port_scandataout => "PORT_UNUSED",
		port_scandone => "PORT_UNUSED",
		port_scanread => "PORT_UNUSED",
		port_scanwrite => "PORT_UNUSED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_USED",
		port_clk2 => "PORT_USED",
		port_clk3 => "PORT_UNUSED",
		port_clk4 => "PORT_UNUSED",
		port_clk5 => "PORT_UNUSED",
		port_clkena0 => "PORT_UNUSED",
		port_clkena1 => "PORT_UNUSED",
		port_clkena2 => "PORT_UNUSED",
		port_clkena3 => "PORT_UNUSED",
		port_clkena4 => "PORT_UNUSED",
		port_clkena5 => "PORT_UNUSED",
		port_extclk0 => "PORT_UNUSED",
		port_extclk1 => "PORT_UNUSED",
		port_extclk2 => "PORT_UNUSED",
		port_extclk3 => "PORT_UNUSED",
		valid_lock_multiplier => 1,
		vco_post_scale => 1,
		c0_initial => 1,
		c0_mode => "even",
		c0_ph => 0,
		c1_initial => 1,
		c1_mode => "even",
		c1_ph => 0,
		c2_initial => 1,
		c2_mode => "even",
		c2_ph => 0,
		clk0_counter => "c0",
		clk1_counter => "c1",
		clk2_counter => "c2")
	port map (
		areset   => rst,
		inclk(0) => clk,
		inclk(1) => dummy_inclk1,
		locked   => locked,
		clk(0)   => video_clk,
		clk(1)   => video_shift_clk,
		clk(2)   => videoio_clk,
		clk(5 downto 3) => dummy_clks);

end;
