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

architecture usbhostfrwk of testbench is
	constant usb_freq : real      := 12.0e6;
	signal   usb_clk  : std_logic := '0';
	signal   dp       : std_logic;
	signal   dn       : std_logic;

	signal msb : std_logic_vector(0 to (64+3)*8-1);
	signal phy_dv    : std_logic;
	signal phy_bs    : std_logic;
	signal phy_d     : std_logic;
	signal clk       : std_logic := '0';
	signal cken      : std_logic;
begin

	usb_clk <= not usb_clk after 1 sec/(2.0*usb_freq);
	dp <= 'H';
	dn <= 'L';

	rx_p : process (phy_bs, clk)
		variable shr : unsigned(msb'range);
		variable dv1 : std_logic;
		variable cntr : natural;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (phy_dv and not phy_bs)='1' then
					if dv1='0' then
						cntr := 0;
						shr := (others => '-');
					end if;
					shr(0) := phy_d;
					shr := shr rol 1;
					cntr := cntr + 1;
				end if;
				dv1 := phy_dv;
			end if;
			if cntr /= 0 then
				msb <= std_logic_vector(reverse(shr ror cntr,8));
			end if;
		end if;
	end process;

	host_b : block
		constant oversampling : natural := 3;
		signal rst       : std_logic;
		signal setup_rdy : std_logic;
		signal setup_req : std_logic;

	begin
		rst <= '0' after 0.500 us;

		with oversampling select
		clk <= 
			not clk after 1 sec/((2.0*usb_freq)*(50.00e6/usb_freq)) when 4,
			not clk after 1 sec/((2.0*usb_freq)*(36.36e6/usb_freq)) when 3,
			not clk after 1 sec/((2.0*usb_freq)*(12.00e6/usb_freq)) when others; --*0.975;

		setup_req <= '0', '1' after 1 us;
		setup_rdy <= '0';
	   	usbhost_e : entity hdl4fpga.usbhostdvr
	   	generic map (
	   		oversampling => oversampling)
		port map (
			dp        => dp,
			dn        => dn,
			clk       => clk,
			cken      => cken,
			phy_dv    => phy_dv,
			phy_bs    => phy_bs,
			phy_d     => phy_d,
			setup_req => setup_req,
			setup_rdy => setup_rdy);

	end block;

	dev_b : block
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
		constant testdata : string := 
			"[" &
				"[0xd2]," &
				"[0x4b12011001000000403412cdab000101000001]," &
				"[0xd2]," &
				"[0xd2]," &
				"[0x4b]," &
				"[0xd2]," &
				"[0x4b09028000000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]," &
				"[0x4b09021001000000403412cdab00010100000101]" &
			"]";

		procedure get_packet (
			signal   packet : inout std_logic_vector;
			variable length : inout natural;
			constant data   : in    string;
			constant index  : in    natural) is
			constant e      : string := hdo(data)**("[" & natural'image(index) & "]=[0]");
			constant bin    : std_logic_vector := reverse(hdo(e)**"[0]",8);
		begin
			if e="[0]" then 
				length := 0;
			else
				length := bin'length;
				packet <= bin & (bin'length to packet'length-1 => '-');
			end if;
		end;

		signal packet : std_logic_vector(0 to (64+3)*8-1);
		signal i      : natural;
		signal j      : natural;
	begin

		rst <= '1', '0' after 0.5 us;
		process 
			variable length : natural;
		begin
			if rising_edge(clk) then
				if rst='1' then
					txen   <= '0';
					i      <= 0;
					j      <= 0;
					length := 0;
				elsif j < length then
					if txbs='0' then
						txd  <= packet(j);
						txen <= '1';
						j <= j + 1;
					end if;
				elsif txbs='0' then
					txen <= '0';
					get_packet(packet, length, testdata, i);
					if length/=0 then
						loop 
							wait on idle until idle='1';
							if   msb(0 to 16-1)=x"80c3" then
								exit;
							elsif msb(0 to 16-1)=x"804b" then
								exit;
							elsif msb(0 to 16-1)=x"8069" then
								exit;
							end if;
						end loop;
						j <= 0;
						i <= i + 1;
					else
						wait;
					end if;
				end if;
			end if;
			wait on clk;
		end process;

	  	dev_e : entity hdl4fpga.usbphycrc
		port map (
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

	end block;

end;
