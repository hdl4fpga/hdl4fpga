library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity is
	port (
		clkin1_in     : in  std_logic; 
		rst_in        : in  std_logic; 
		clk0_out      : out std_logic; 
		locked_out    : out std_logic; 
		u1_clk90_out  : out std_logic; 
		u1_clk180_out : out std_logic);
end;

architecture behavioral of pll is
   signal clkfbdcm_clkfbin   : std_logic;
   signal clkfb_in           : std_logic;
   signal clkin1_ibufg       : std_logic;
   signal clkoutdcm0_clkin   : std_logic;
   signal clk0_buf           : std_logic;
   signal gnd_bit            : std_logic;
   signal gnd_bus_5          : std_logic_vector (4 downto 0);
   signal gnd_bus_7          : std_logic_vector (6 downto 0);
   signal gnd_bus_16         : std_logic_vector (15 downto 0);
   signal or2_out            : std_logic;
   signal pll_adv_locked_inv : std_logic;
   signal pll_adv_locked_out : std_logic;
   signal srl16_q_out        : std_logic;
   signal u1_clk90_buf       : std_logic;
   signal u1_clk180_buf      : std_logic;
   signal vcc_bit            : std_logic;
begin
   gnd_bit <= '0';
   gnd_bus_5(4 downto 0) <= "00000";
   gnd_bus_7(6 downto 0) <= "0000000";
   gnd_bus_16(15 downto 0) <= "0000000000000000";
   vcc_bit <= '1';
   clk0_out <= clkfb_in;
   clkin1_ibufg_inst : ibufg
      port map (i=>clkin1_in,
                o=>clkin1_ibufg);
   
   clk0_bufg_inst : bufg
      port map (i=>clk0_buf,
                o=>clkfb_in);
   
   dcm_adv_inst : dcm_adv
   generic map( clk_feedback => "1x",
            clkdv_divide => 2.0,
            clkfx_divide => 1,
            clkfx_multiply => 4,
            clkin_divide_by_2 => false,
            clkin_period => 2.222,
            clkout_phase_shift => "none",
            dcm_autocalibration => true,
            dcm_performance_mode => "max_speed",
            deskew_adjust => "system_synchronous",
            dfs_frequency_mode => "low",
            dll_frequency_mode => "high",
            duty_cycle_correction => true,
            factory_jf => x"f0f0",
            phase_shift => 0,
            startup_wait => false,
            sim_device => "virtex5")
	port map (
		clkfb =>clkfb_in,
		clkin =>clkoutdcm0_clkin,
		daddr => (others => '0'),
		dclk => '0',
		den  => '0',
		di    => (others => '0'),
		dwe   => '0',
		psclk => '0',
		psen  => '0',
		psincdec => '0',
		rst    => or2_out,
		clk0   => clk0_buf,
		clk90  => u1_clk90_buf,
		clk180 => u1_clk180_buf,
		locked => locked_out);
   
	inv_inst : inv
	port map (
		i => pll_adv_locked_out
		o => pll_adv_locked_inv);
   
	or2_inst : or2
	port map (
		i1 => rst_in,
		i0 => srl16_q_out,
		o  => or2_out);
   
   pll_adv_inst : pll_adv
   generic map( bandwidth => "optimized",
            clkin1_period => 10.000,
            clkin2_period => 10.000,
            clkout0_divide => 1,
            clkout0_phase => 0.000,
            clkout0_duty_cycle => 0.500,
            compensation => "pll2dcm",
            divclk_divide => 2,
            clkfbout_mult => 11,
            clkfbout_phase => 0.0,
            ref_jitter => 0.005000)
      port map (clkfbin=>clkfbdcm_clkfbin,
                clkinsel=>vcc_bit,
                clkin1=>clkin1_ibufg,
                clkin2=>gnd_bit,
                daddr(4 downto 0)=>gnd_bus_5(4 downto 0),
                dclk=>gnd_bit,
                den=>gnd_bit,
                di(15 downto 0)=>gnd_bus_16(15 downto 0),
                dwe=>gnd_bit,
                rel=>gnd_bit,
                rst=>rst_in,
                clkfbdcm=>clkfbdcm_clkfbin,
                clkfbout=>open,
                clkoutdcm0=>clkoutdcm0_clkin,
                clkoutdcm1=>open,
                clkoutdcm2=>open,
                clkoutdcm3=>open,
                clkoutdcm4=>open,
                clkoutdcm5=>open,
                clkout0=>open,
                clkout1=>open,
                clkout2=>open,
                clkout3=>open,
                clkout4=>open,
                clkout5=>open,
                do=>open,
                drdy=>open,
                locked=>pll_adv_locked_out);
   
   srl16_inst : srl16
      port map (a0=>gnd_bit,
                a1=>gnd_bit,
                a2=>gnd_bit,
                a3=>gnd_bit,
                clk=>clkin1_ibufg,
                d=>pll_adv_locked_inv,
                q=>srl16_q_out);
   
   u1_clk90_bufg_inst : bufg
      port map (i=>u1_clk90_buf,
                o=>u1_clk90_out);
   
   u1_clk180_bufg_inst : bufg
      port map (i=>u1_clk180_buf,
                o=>u1_clk180_out);
   
end behavioral;


