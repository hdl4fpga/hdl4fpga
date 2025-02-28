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

architecture usbfrwk of testbench is
	constant usb_freq     : real := 12.0e6;

	signal usb_clk : std_logic := '0';
	signal dp      : std_logic;
	signal dn      : std_logic;

begin

	usb_clk <= not usb_clk after 1 sec/(2.0*usb_freq);
	dp <= 'H';
	dn <= 'L';

	host_b : block
		signal tp   : std_logic_vector(1 to 32);
		signal rst  : std_logic;
		alias  clk  is usb_clk;
		signal cken : std_logic;
		signal txen : std_logic := '0';
		signal txbs : std_logic;
		signal txd  : std_logic := '0';
		signal rxdv : std_logic := '0';
		signal rxbs : std_logic;
		signal rxd  : std_logic;
		signal idle : std_logic;
	begin

		rst <= '1', '0' after 0.500 us;
		process 
			type time_vector is array (natural range <>) of time;
			constant msg : std_logic_vector :=  
				x"b0" & to_ascii("000000000000000000000000000000f") &
				        to_ascii("0000000000000000000000000000000") & x"01";
			constant msgx : std_logic_vector :=  
				to_ascii("1200000000000000000000000000000f") &
				to_ascii("00000000000000000000000000000000");
			constant msg0 : std_logic_vector := x"4b" & msg;
			constant msg1 : std_logic_vector := x"c3" & msg;
			constant msg2 : std_logic_vector := x"4b" & msgx;
			constant data : std_logic_vector := 
				reverse(x"2d0010",8)(0 to 19-1) &
				reverse(x"c3_0005_1500_0000_0000_e831",8)(0 to 72-1) &
				reverse(x"690010",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"2d1530",8)(0 to 19-1) &

				reverse(x"C3_8006_0001_0000_0800_eb94",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"2d1530",8)(0 to 19-1) &

				reverse(x"C3_8006_0001_0000_1200_ae04",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &

				reverse(x"2d1530",8)(0 to 19-1) &
				reverse(x"C3_0009_0100_0000_0000_2725",8)(0 to 72-1) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &

				reverse(x"d2",8) &
				reverse(x"e19500",8)(0 to 19-1) &
				reverse(msg0, 8) &
				reverse(x"e19500",8)(0 to 19-1) &
				reverse(msg1, 8) &

				reverse(x"e19500",8)(0 to 19-1) &
				reverse(msg2, 8) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &

				reverse(x"d2",8) &
				reverse(x"691530",8)(0 to 19-1) &
				reverse(x"d2",8);
			constant length : natural_vector := (
				19,          72,          19,    8,    19,
				72,          19,          19,    8,    19,
				72,          19,           8,   19,     8,
				19,          72,          19,    8,    19,
				 8,          19, msg0'length,   19, msg1'length,
				19, msg0'length,          19,   8,     19,
				8,           19,           8);

			constant delays : time_vector := (
				 0 us,     0 us,        3 us,  3.5 us,  0 us,
				 0 us,     2 us,        9 us,  9 us,    0 us,
				 0 us,     2 us,       15 us,  0 us,    3.5 us,
				 0 us,     0 us,        2 us,  3.5 us,  0 us, 
				 3.5 us,   0 us,        0 us,  2 us,    0 us,
				 2 us,     0 us,        2 us, 46 us,    0 us,
				46.0 us,   0 us,      46 us);

			variable i     : natural;
			variable j     : natural;
			variable right : natural;
		begin
			if rising_edge(clk) then
				if rst='1' then
					txen  <= '0';
					i     := 0;
					j     := 0;
					right := 0;
				elsif j < right then
						if txbs='0' then
							txd  <= data(j);
							txen <= '1';
							j := j + 1;
						end if;
				elsif txbs='0' then
					txen <= '0';
					if idle='1' then
						if i < delays'length then
							wait for delays(i);
							right := right + length(i);
							i     := i + 1;
						else
							wait;
						end if;
					end if;
				end if;
			end if;
			wait on clk;
		end process;

	  	host_e : entity hdl4fpga.usbphycrc
		port map (
			tp   => tp,
			dp   => dp,
			dn   => dn,
			idle => idle,
			clk  => clk,
			cken => cken,

			txen => txen,
			txbs => txbs,
			txd  => txd,

			rxdv => rxdv,
			rxbs => rxbs,
			rxd  => rxd);

		rx_p : process (clk)
			variable cntr : natural := 0;
			variable shr  : std_logic_vector(0 to 128-1);
			variable msb  : std_logic_vector(shr'range);
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (rxdv and not rxbs)='1' then
						if cntr < shr'length then
							shr(cntr) := rxd;
							cntr := cntr + 1;
						end if;
					end if;
				end if;
				msb := reverse(shr,8);
			end if;
		end process;

	end block;

	dev_b : block
		constant oversampling : natural := 3;
		signal tp   : std_logic_vector(1 to 32);
		signal rst  : std_logic;
		signal clk  : std_logic := '0';
		signal cken : std_logic;
		signal txen : std_logic := '0';
		signal txbs : std_logic;
		signal txd  : std_logic;
		signal rxdv : std_logic;
		signal rxbs : std_logic;
		signal rxd  : std_logic;
	begin
		rst <= '0' after 0.500 us;

		with oversampling select
		clk <= 
			not clk after 1 sec/((2.0*usb_freq)*(50.00e6/usb_freq)) when 4,
			not clk after 1 sec/((2.0*usb_freq)*(36.36e6/usb_freq)) when 3,
			not clk after 1 sec/((2.0*usb_freq)*(12.00e6/usb_freq)) when others; --*0.975;

	 	tx_p : process (clk)
			-- constant data : std_logic_vector := reverse(x"01234567",8);
			constant data : std_logic_vector := reverse(x"7f_fe_ff_ff_ff",8); -- stress data
			constant msb  : std_logic_vector(data'range) := reverse(data, 8);
			variable cntr : natural := 0;
		begin
			if rising_edge(clk) then
				if rst='1' then
					cntr := 0;
					txen <= '0';
				elsif cken='1' then
					if cntr < data'length then
						if txbs='0' then
							txd  <= data(cntr);
							txen <= '1';
							cntr := cntr + 1;
						end if;
					elsif txbs='0' then
						if cntr >= data'length then
							txen <= '0';
						else
							cntr := cntr + 1;
						end if;
					end if;
				end if;
			end if;
		end process;

		tp_p : process (rxdv, clk)
			variable cntr : natural := 0;
			variable shr  : std_logic_vector(0 to 256*32-1);
			variable msb  : std_logic_vector(shr'range);
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (tp(1) and not tp(2))='1' then
						if cntr < shr'length then
							shr(cntr) := tp(3);
							cntr := cntr + 1;
						end if;
					end if;
				end if;
				msb := reverse(shr,8);
			end if;
		end process;

	   	dev_e : entity hdl4fpga.usbdev
	   	generic map (
	   		oversampling => oversampling)
		port map (
			tp   => tp,
			dp   => dp,
			dn   => dn,
			clk  => clk,
			cken => cken,

			-- txen => txen,
			-- txbs => txbs,
			-- txd  => txd,

			txen => rxdv,
			txbs => rxbs,
			txd  => rxd,

			rxdv => rxdv,
			rxbs => rxbs,
			rxd  => rxd);

		rx_p : process (rxbs, clk)
			variable cntr : natural := 0;
			variable shr : std_logic_vector(0 to 128-1);
			variable msb : std_logic_vector(0 to 128-1);
		begin
			if rising_edge(clk) then
				if cken='1' then
					if (rxdv and not rxbs)='1' then
						if cntr < shr'length then
							shr(cntr) := rxd;
							cntr := cntr + 1;
						end if;
					end if;
				end if;
				msb := reverse(shr,8);
			end if;
		end process;

	end block;

end;




