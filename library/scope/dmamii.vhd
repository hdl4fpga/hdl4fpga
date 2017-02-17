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

entity dmamii is
	generic (
		BRAM_SIZE  : natural := 9;
		DATA_SIZE  : natural := 32);
	port (
		dmamii_clk    : in  std_logic;
		dmamii_dmareq : in  std_logic;
		dmamii_rdy    : out std_logic;
		dmamii_req    : out std_logic;
		dmamii_di_req : in  std_logic;
		dmamii_di     : out std_logic;

		miitx_clk     => miitx_clk,
		miitx_rdy     => miitx_rdy,
		miitx_req     => miitx_req,
		miitx_ena     => miitx_ena,
		miitx_dat     => miitx_dat);
	port (
		ddrs_clk   : in  std_logic;
		ddr_ini   : in  std_logic;
		dmamii_req   : in  std_logic := '1';
		ddrs_rdy   : out std_logic;
		ddrs_direq : out std_logic;
		ddrs_dirdy : in  std_logic;
		ddrs_di    : in  std_logic_vector(data_size-1 downto 0);

		miitx_clk : in  std_logic;
		miitx_req : in  std_logic := '1';
		miitx_ena : out std_logic;
		miitx_rdy : out std_logic;
		miitx_dat : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of dmaii is
	constant bram_num : natural := (unsigned_num_bits(ddrs_di'length-1)+bram_size)-(unsigned_num_bits(1024/2**0*8-1));

	subtype aword is std_logic_vector(bram_size-1 downto 0);
	type aword_vector is array(natural range <>) of aword;

	subtype dword is std_logic_vector(data_size-1 downto 0);
	type dword_vector is array(natural range <>) of dword;

	signal addri : unsigned(0 to bram_size-1);
	signal addro : unsigned(0 to bram_size-1);

	signal wr_address : std_logic_vector(0 to bram_size-1);
	signal wr_ena  : std_logic;
	signal wr_data : dword;
	signal dummy   : dword;

	signal rd_address : std_logic_vector(0 to bram_size-1);
	signal rd_data    : dword;
	signal tx_data    : dword;
	signal bysel : unsigned(1 to unsigned_num_bits(ddrs_di'length/miitx_dat'length-1));

	signal addri_edge : std_logic;
	signal addro_edge : std_logic;
	signal ena : std_logic;
	signal txd : std_logic_vector(miitx_dat'range);

begin

	process (ddrs_clk)
		variable addr : unsigned(addri'range);
		variable msb  : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			if dmamii_req='0' then
				addr := to_unsigned(2**addri'length-1, addri'length);
				msb  := addr(0);
			elsif dmamii_di_rdy='1' then
				if (addr(bram_num-1) xor msb)='1' then
					dmamii_req <= '0';
				end if;
				msb  := addr(bram_num-1);
				addr := addr - 1;
			else
			end if;
		end if;
	end process; 

	process (miitx_clk)
		variable addr  : unsigned(addri'range);
		variable msb   : std_logic;
	begin
		if rising_edge(miitx_clk) then
			if dmamii_req='0' then
				addr     := to_unsigned(2**addro'length-1, addro'length);
				msb      := addr(0);
				byte_sel := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
			elsif miitx_req='0' then
				msb      := addr(bram_num-1);
				byte_sel <= to_unsigned(2**(bycnt'length-1)-2, bysel'length); 
			else
				rdy <= addr(bram_num-1) xor msb;
				byte_sel := std_logic_vector(bycnt(bydly'range));
					if bycnt(0)='1' then
						addro_edge <= addro(bram_num-1);
						bycnt := to_unsigned(2**(bycnt'length-1)-2, bycnt'length); 
						if (addro(bram_num-1) xor addro_edge)='0' then
							addro <= addro - 1;
						end if;
					else
						byte_sel := byte_sel - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	miitx_rdy <= not ena;
	miitx_ena <= miitx_req and ena;

	wr_address_i : entity hdl4fpga.align
	generic map (
		n => wr_address'length,
		d => (wr_address'range => wr_delay))
	port map (
		clk => ddrs_clk,
		di  => std_logic_vector(addri(wr_address'range)),
		do  => wr_address);

	wr_data_i : entity hdl4fpga.align
	generic map (
		n => ddrs_di'length,
		d => (ddrs_di'range => wr_delay))
	port map (
		clk => ddrs_clk,
		di  => ddrs_di,
		do  => wr_data);

	wr_ena_i : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (1 to 1 => wr_delay-1))
	port map (
		clk   => ddrs_clk,
		di(0) => di_rdy,
		do(0) => wr_ena);

	bram_e : entity hdl4fpga.bram
	port map (
		clka  => ddrs_clk,
		wea   => wr_ena,
		addra => wr_address, 
		dia   => wr_data,
		doa   => dummy,

		clkb  => miitx_clk,
		web   => '0',
		addrb => std_logic_vector(addro), 
		dib   => wr_data, 
		dob   => tx_data);

	txd <= word2byte (
		word => reverse(std_logic_vector(unsigned(tx_data) rol (miitx_dat'length))),
		addr => bysel);
	miitx_dat <= txd;
end;
