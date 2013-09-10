library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture sa_test of nuhs3dsp is
	function to_ascii (
		constant arg : character)
		return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(character'pos(arg),8)) ;
	end;
	
	signal sys_clk : std_logic;
	signal sys_req : std_logic := '1';
	signal sys_rst : std_logic := '1';
	signal sys_rdy : std_logic;
	signal sys_di  : std_logic_vector(8-1 downto 0);

	constant msg : string := "hola gor";
	                        --0123456789012345
	                          
	signal i : positive range 1 to 128 := 1;
begin
	sys_rst <= not sw1;

	process (xtal)
		variable div : unsigned(0 to 16) := (others => '0');
	begin 
		if rising_edge(xtal) then
			div := div + 1;
			sys_clk <= div(0);
		end if;
	end process;
	
	sa_ctrl_e : entity hdl4fpga.sa_ctlr
	port map (
		sys_clk => sys_clk,
		sys_rst => sys_rst,
		sys_req => sys_req,
		sys_rdy => sys_rdy,
		sys_rs  => '1',
		sys_rw  => '0',
		sys_di  => sys_di,

		sa_e  => lcd_e,
		sa_rs => lcd_rs,
		sa_rw => lcd_rw,
		sa_db => lcd_data);

	sys_di <= to_ascii(msg(i));
	process (xtal)
	begin
		if rising_edge(xtal) then
			if i <= msg'length then
				if sys_rdy='0' then
					sys_req <= '1';
				elsif sys_req='1' then 
					if sys_req='1' then
						i <= i + 1;
					end if;
					sys_req <= '0';
				end if;
			else
				sys_req <= '0';
			end if;
		end if;
	end process;

	hd_t_data <= 'Z';

	--------------
	-- LEDs DAC --
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= '0';

	---------------
	-- Video DAC --
		
	hsync <= '1';
	vsync <= '0';
	clk_videodac <= '0';
	blank <= '0';
	sync  <= '0';
	psave <= '0';
	red   <= (others => '0');
	green <= (others => '0');
	blue  <= (others => '0');

	---------
	-- ADC --

	adc_clkab <= '0';

	-----------------------
	-- RS232 Transceiver --

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	mii_txen <= 'Z';
	mii_txd  <= (others => 'Z');

	-------------
	-- DDR RAM --

	ddr_ckp <= 'Z';
	ddr_ckn <= 'Z';
	ddr_lp_dqs <= 'Z';
	ddr_cke <= 'Z';
	ddr_cs  <= '1';
	ddr_ras <= 'Z';
	ddr_cas <= 'Z';
	ddr_we  <= 'Z';
	ddr_ba  <= (others => 'Z');
	ddr_a   <= (others => 'Z');
	ddr_dm  <= (others => 'Z');
	ddr_dqs <= (others => 'Z');
	ddr_dq  <= (others => 'Z');

	--------------------------
	-- Ethernet Transceiver --

	mii_mdc  <= 'Z';
	mii_mdio <= 'Z';

	mii_rst   <= 'Z'; 
	mii_refclk<= 'Z';

	---------
	-- LCD --

	lcd_backlight <= '1';
end;
