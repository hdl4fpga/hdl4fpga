--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture usbphy of testbench is
	constant usb_freq : real := 12.0e6;
    constant oversampling : natural := 4;

	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50df2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a527b2",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a50302",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"a5badf",8);
	-- constant data : std_logic_vector(0 to 24-1) := reverse(x"2d0010",8);
	constant data : std_logic_vector := reverse(x"c300052f_0000000000_ed6b",8);
	-- constant data : std_logic_vector := reverse(x"c300_0517_000000_0000_e9d3",8);

	signal txc  : std_logic := '0';
	signal txen : std_logic := '0';
	signal txd  : std_logic := '0';
	signal dp   : std_logic;
	signal dn   : std_logic;
	signal rxc  : std_logic := '0';
	signal frm  : std_logic := '0';
	signal rxdv : std_logic := '0';
	signal busy : std_logic;

	signal rxd : std_logic_vector(0 to 0);
begin

	txc <= not txc after 1 sec/(2.0*usb_freq)*(50.0e6/12.0e6); --*0.975;
	rxc <= not rxc after 1 sec/(2.0*usb_freq);

	process (txc)
		variable cntr : natural := 0;
	begin
		if rising_edge(txc) then
			if cntr < data'length then
				if busy='0' then
					txd  <= data(cntr);
					txen <= '1';
					cntr := cntr + 1;
				end if;
			elsif busy='0' then
				if cntr > data'length+7 then
					txen <= '0';
				else
					cntr := cntr + 1;
				end if;
			end if;
		end if;
	end process;

	tx_d : entity hdl4fpga.usbphy_tx
	port map (
		clk  => txc,
		txen => txen,
		txbs => busy,
		txd  => txd,
		txdp => dp,
		txdn => dn);

	usbphy_e : entity hdl4fpga.usbphy
	generic map (
		oversampling => oversampling)
	port map (
		dp   => dp,
		dn   => dn,
		clk  => rxc,
		cken => rxdv,
		rxdv => frm,
		rxd  => rxd(0));

	process (rxc)
		variable rx_data : unsigned(data'range);
	begin
		if rising_edge(rxc) then
			if (frm and rxdv)='1' then
				rx_data(0) := rxd(0);
				rx_data := rx_data rol 1;
			end if;
		end if;
	end process;

	rx_b : block
	begin

		usbcrc_b : block
			constant g5    : std_logic_vector := b"0_0101"; -- & b"111_1111_1111";
			constant g16   : std_logic_vector := b"1000_0000_0000_0101";
			constant rem5  : std_logic_vector := b"01100";
			constant rem16 : std_logic_vector := b"1000_0000_0000_1101";
			constant g     : std_logic_vector := g5 & g16;
			constant slce  : natural_vector := (0, g5'length, g5'length+g16'length);
			signal crc     : std_logic_vector(g'range);

			alias crc5    : std_logic_vector(0 to g5'length-1)  is crc(slce(0) to slce(1)-1);
			alias crc16   : std_logic_vector(0 to g16'length-1) is crc(slce(1) to slce(2)-1);

			signal crc_frm : std_logic;
		begin

    		process (rxdv, rxc)
				type states is (s_pid, s_data);
				variable state : states;
    			variable cntr  : natural range 0 to 7;
				variable pid   : unsigned(8-1 downto 0);
    		begin
    			if rising_edge(rxc) then
					case state is
					when s_pid =>
						if frm='0' then
							cntr := 0;
						elsif rxdv='1' then
							if cntr < 7 then
								cntr := cntr + 1;
							else 
								state := s_data;
							end if;
							pid(0) := rxd(0);
							pid := pid ror 1;
						end if;
						crc_frm <= '0';
					when s_data =>
						if frm='0' then
							crc_frm <= '0';
							state := s_pid;
						else
							crc_frm <= '1';
						end if;
					end case;
    			end if;
    		end process;

    		usbcrc_g : for i in 0 to 1 generate
    			crc_b : block
    				port (
    					clk  : in  std_logic;
    					g    : in  std_logic_vector;
						frm  : in  std_logic;
    					ena  : in  std_logic;
    					data : in  std_logic_vector;
    					crc  : buffer std_logic_vector);
    				port map (
    					clk  => rxc,
    					g    => g(slce(i) to slce(i+1)-1),
						frm  => crc_frm,
    					ena  => rxdv,
    					data => rxd,
    					crc  => crc(slce(i) to slce(i+1)-1));
    			begin
    				crc_p : process (clk)
						type states is (s_idle, s_run);
						variable state : states;
    				begin
    					if rising_edge(clk) then
							case state is
							when s_idle =>
								if frm='1' then
									if ena='1' then
										crc   <= not galois_crc(data, (crc'range => '1'), g);
										state := s_run;
									end if;
								end if;
							when s_run =>
								if frm='0' then
									state := s_idle;
									crc   <= not crc;
								elsif ena='1' then
									crc   <= not galois_crc(data, not crc, g);
								end if;
							end case;
    					end if;
    				end process;
    			end block;

    		end generate;
		end block;

	end block;

end;