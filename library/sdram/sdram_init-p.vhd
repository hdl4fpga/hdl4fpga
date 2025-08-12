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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;

package xxx is
	procedure mr (
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in  std_logic_vector;
		constant asr   : in  std_logic_vector;
		constant bl    : in  std_logic_vector;
		constant bt    : in  std_logic;
		constant cl    : in  std_logic_vector;
		constant cwl   : in  std_logic_vector;
		constant drtt  : in  std_logic_vector;
		constant mpr   : in  std_logic_vector;
		constant mprrf : in  std_logic_vector;
		constant ods   : in  std_logic_vector;
		constant pd    : in  std_logic_vector;
		constant rdqs  : in  std_logic_vector;
		constant rtt   : in  std_logic_vector;
		constant tdqs  : in  std_logic_vector;
		constant wr    : in  std_logic_vector;
		constant generation : in  string;
		constant row   : in  string);
end;

package body xxx is

	procedure sdr_mr (
		signal   b  : out std_logic_vector;
		signal   a  : out std_logic_vector;
		constant bl : in std_logic_vector;
		constant bt : in std_logic;
		constant cl : in std_logic_vector;
		constant row : in string) is
		constant mr  : string := "{mr0 :'00'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (b'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="mr0" then 
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8 downto 7) <= "00";
				a(9) <= '0';
			else
				assert false
					report "sdr_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr_mr(
		signal   b  : out std_logic_vector;
		signal   a  : out std_logic_vector;
		constant bl : in std_logic_vector;
		constant bt : in std_logic;
		constant cl : in std_logic_vector;
		constant row : in string) is
		constant mr  : string := "{mr0 :'00', mr1:'01'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="rst_dll" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8) <= '1';
			elsif reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8) <= '0';
			elsif reg="mr1" then
				b <= hdo(mr)**".mr1";
				a <= (a'range =>'0');
			else
				assert false
					report "ddr_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr2_mr(
		signal   b    : out std_logic_vector;
		signal   a    : out std_logic_vector;
		constant al   : in std_logic_vector;
		constant bl   : in std_logic_vector;
		constant bt   : in std_logic;
		constant cl   : in std_logic_vector;
		constant ods  : in std_logic_vector;
		constant pd   : in std_logic_vector;
		constant rdqs : in std_logic_vector;
		constant rtt  : in std_logic_vector;
		constant tdqs : in std_logic_vector;
		constant wr   : in std_logic_vector;
		constant row  : in string) is
		constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			report reg;
			if reg="ena_dll" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
			elsif reg="rst_dll" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(8) <= '1';
			elsif reg="ena_ocd" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(5 downto 3) <= al(3-1 downto 0);
				a(6)  <= rtt(1);
				a(9 downto 7) <= "111";
				a(10) <= tdqs(0);
				a(11) <= rdqs(0);
				a(12) <= '0';
			elsif reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a( 2 downto 0) <= bl(3-1 downto 0);
				a(3)  <= bt;
				a( 6 downto 4) <= cl(3-1 downto 0);
				a(7)  <= '0';
				a(8)  <= '0';
				a(11 downto 9) <= wr;
				a(12) <= pd(0);
			elsif reg="mr1" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(5 downto 3) <= al(3-1 downto 0);
				a(6)  <= rtt(1);
				a(9 downto 7) <= "000";
				a(10) <= tdqs(0);
				a(11) <= rdqs(0);
				a(12) <= '0';
			elsif reg="mr2" then
				b <= hdo(mr)**".mr2";
				a <= (a'range => '0');
				a(7) <= '1';
			elsif reg="mr3" then
				b <= hdo(mr)**".mr3";
				a <= (a'range => '0');
			else
				assert false
					report "ddr2_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr3_mr(
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in std_logic_vector;
		constant asr   : in std_logic_vector;
		constant bl    : in std_logic_vector;
		constant bt    : in std_logic;
		constant cl    : in std_logic_vector;
		constant cwl   : in std_logic_vector;
		constant drtt  : in std_logic_vector;
		constant mprrf : in std_logic_vector;
		constant mpr   : in std_logic_vector;
		constant ods   : in std_logic_vector;
		constant pd    : in std_logic_vector;
		constant rdqs  : in std_logic_vector;
		constant rtt   : in std_logic_vector;
		constant tdqs  : in std_logic_vector;
		constant wr    : in std_logic_vector;
		constant row   : in string) is
		constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif op ="zqc" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(1 downto 0)  <= bl(2-1 downto 0);
				a(2)  <= cl(0);
				a(3)  <= bt;
				a(6 downto 4)  <= cl(4-1 downto 1);
				a(7)  <= '0';
				a(8)  <= '1'; -- DLL reset
				a(11 downto 9) <= wr;
				a(12) <= pd(0);
			elsif reg="dll_dis" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '1';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '0';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="wl_on" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '1';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="wl_off" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '0';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="mr2" then
				b <= hdo(mr)**".mr2";
				a <= (a'range => '0');
				a(2 downto 0) <= "000";
				a(5 downto 3) <= cwl;
				a(6) <= asr(0);
				a(7) <= '0'; -- self refresh temperature
				a(8) <= '0';
				a(10 downto 9) <= drtt;
			elsif reg="mr3" then
				b <= hdo(mr)**".mr3";
				a <= (a'range => '0');
				a(1 downto 0) <= mprrf;
				a(2) <= mpr(0);
			else
				assert false
					report "ddr3_mr () : row => " & '"' & row & '"' & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure mr (
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in  std_logic_vector;
		constant asr   : in  std_logic_vector;
		constant bl    : in  std_logic_vector;
		constant bt    : in  std_logic;
		constant cl    : in  std_logic_vector;
		constant cwl   : in  std_logic_vector;
		constant drtt  : in  std_logic_vector;
		constant mpr   : in  std_logic_vector;
		constant mprrf : in  std_logic_vector;
		constant ods   : in  std_logic_vector;
		constant pd    : in  std_logic_vector;
		constant rdqs  : in  std_logic_vector;
		constant rtt   : in  std_logic_vector;
		constant tdqs  : in  std_logic_vector;
		constant wr    : in  std_logic_vector;
		constant generation       : in  string;
		constant row              : in  string) is
	begin
		   if generation="sdr" then
			sdr_mr(b => b, a => a, bl => bl, bt => bt, cl => cl, row => row);
		   elsif generation="ddr" then
			ddr_mr(b => b, a => a, bl => bl, bt => bt, cl => cl, row => row);
		   elsif generation="ddr2" then
			ddr2_mr(b => b, a => a, al => al, bl => bl, bt => bt, cl => cl, ods => ods, pd => pd, rdqs => rdqs, rtt => rtt, tdqs => tdqs, wr => wr, row => row);
		   elsif generation="ddr3" then
			ddr3_mr(b => b, a => a, al => al, asr => asr, bl => bl, bt => bt, cl => cl, cwl => cwl, drtt => drtt, mpr => mpr, mprrf => mprrf, ods => ods, pd => pd, rdqs => rdqs, rtt => rtt, tdqs => tdqs, wr => wr, row => row);
		   else
		   	assert false
		   		report "sdram_init : generation => " & '"' & generation & '"' & " invalid"
		   		severity failure;
		   end if;
	end;

end;