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
use hdl4fpga.ipoepkg.all;

entity mii_ipoe is
	generic (
		macda : std_logic_vector := x"00_40_00_01_02_03");
	port (
		mii_clk       : in  std_logic;

		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic := '0';
		miirx_trdy    : out std_logic := '1';
		miirx_data    : in  std_logic_vector;
		fcs_sb        : out std_logic;
		fcs_vld       : out std_logic;

		tp            : buffer std_logic_vector(1 to 32) := (others => '0'));

end;

architecture def of mii_ipoe is

	signal dll_frm     : std_logic;
	signal dll_irdy    : std_logic;
	signal dll_trdy    : std_logic;
	signal dll_data    : std_logic_vector(miirx_data'range);

	signal ethda_frm   : std_logic;
	signal ethda_irdy  : std_logic;
	signal ethsa_frm   : std_logic;
	signal ethsa_irdy  : std_logic;
	signal ethtyp_frm  : std_logic;
	signal ethtyp_irdy : std_logic;
	signal ethpyl_frm  : std_logic;
	signal ethpyl_irdy : std_logic;

	signal ipv4da_frm  : std_logic;
begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk  => mii_clk,
		mii_frm  => miirx_frm,
		mii_irdy => miirx_irdy,
		mii_data => miirx_data,

		dll_frm  => dll_frm,
		dll_irdy => dll_irdy,
		dll_trdy => dll_trdy,
		dll_data => dll_data,

		da_frm   => ethda_frm,
		da_irdy  => ethda_irdy,
		sa_frm   => ethsa_frm,
		sa_irdy  => ethsa_irdy,
		typ_frm  => ethtyp_frm,
		typ_irdy => ethtyp_irdy,
		pyl_frm  => ethpyl_frm,
		pyl_irdy => ethpyl_irdy,
		fcs_sb   => fcs_sb,
		fcs_vld  => fcs_vld);

	xxx_b : block
		signal rd_addr : std_logic_vector(1 to unsigned_num_bits(macda'length/miirx_data'length-1));
		signal rd_data : std_logic_vector(miirx_data'range);
		signal wr_addr : std_logic_vector(rd_addr'range);
		signal wr_data : std_logic_vector(miirx_data'range);
		signal ethda_trdy : std_logic;
		signal equ : std_logic;
		signal q : std_logic;

		alias clk  is mii_clk;
		alias frm  is ethda_frm;
		alias irdy is ethda_irdy;
		alias trdy is ethda_trdy;

	begin

		process (frm, clk)
			variable rd_cntr : unsigned(0 to rd_addr'length);
			variable last : std_logic;
		begin
			if rising_edge(clk) then
				if ((last or frm) and irdy and trdy)='1' then
					rd_cntr := rd_cntr + 1;
				end if;
				if (frm or irdy)='0' then
					rd_cntr := (others => '0');
					rd_cntr := rd_cntr-macda'length/miirx_data'length;
				end if;
				if frm='0' then
					if irdy='0' then
						last := '0';
					elsif trdy='1' then
						last := '0';
					end if;
				else
					last := '1';
				end if;
				rd_addr <= std_logic_vector(rd_cntr(rd_addr'range));
			end if;
			trdy <= frm or last;
		end process;

		mem_i : entity hdl4fpga.dpram
		generic map (
			bitrom  => std_logic_vector(resize(unsigned(reverse(macda,8)), miirx_data'length*2**rd_addr'length)))
		port map (
			rd_addr => rd_addr,
			rd_data => rd_data,
	
			wr_clk  => clk,
			wr_ena  => '0',
			wr_addr => wr_addr,
			wr_data => wr_data);

    	cmp_i : entity hdl4fpga.sio_cmp
    	port map (
    		clk     => clk,
    		mr_frm  => frm,
    		mr_irdy => irdy,
    		mr_data => miirx_data,
    		sl_data => rd_data,
    		equ     => equ);

   		process (clk)
   		begin
   			if rising_edge(clk) then
				if (miirx_frm or miirx_irdy)='0' then
					q <= '0';
				elsif equ='1' then
					q <= '1';
				end if;
   			end if;
   		end process;
		-- tp(1) <= (equ or q) and miirx_frm;
		tp(2 to 2+miirx_data'length-1) <= miirx_data;
	end block;

	ipv4rx_i : entity hdl4fpga.ipv4_rx
	port map (
		mii_clk   => mii_clk,
		ipv4_frm  => ethpyl_frm,
		ipv4_irdy => ethpyl_irdy,
		ipv4_data => miirx_data,
		da_frm    => ipv4da_frm);
	tp(1) <= ipv4da_frm;
end;
