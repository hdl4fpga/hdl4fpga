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

entity miitxmem is
	generic (
		bram_size : natural := 9;
		data_size : natural := 32);
	port (
		ddrs_clk   : in  std_logic;
		ddrs_gnt   : in  std_logic;
		ddrs_req   : in  std_logic := '1';
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

architecture def of miitxmem is
	constant wr_delay : natural := 2;
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

	signal rd_address : std_logic_vector(0 to bram_size-1);
	signal rd_data : dword;
	signal rad : dword;
	signal bysel : std_logic_vector(1 to unsigned_num_bits(ddrs_di'length/miitx_dat'length-1));

	signal addri_edge : std_logic;
	signal addro_edge : std_logic;
	signal rdy : std_logic;
	signal ena : std_logic;
	signal dirdy : std_logic;
	signal txd : std_logic_vector(miitx_dat'range);

begin

	process (ddrs_clk)
		variable rdy : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			if ddrs_gnt='0' then
				addri <= to_unsigned(2**addri'length-1, addri'length);
				addri_edge <='1';
				dirdy <= '0';
				rdy := '0';
				ddrs_direq <= '0';
			else
				if dirdy='1' then
					if (addri(bram_num-1) xor addri_edge)='1' then
						rdy := '1';
						ddrs_direq <= '0';
					end if;
				elsif ddrs_req='1' then
					ddrs_direq <= '1';
					if rdy='1' then
						ddrs_direq <= '0';
					end if;
				else
					rdy := '0';
					ddrs_direq <= '0';
				end if;

				if ddrs_dirdy='1' then
					addri <= addri - 1;
				end if;

				addri_edge <= addri(bram_num-1);
				dirdy <= ddrs_dirdy;
			end if;
			ddrs_rdy <= rdy;
		end if;
	end process; 

	process (miitx_clk)
		variable bycnt : unsigned(0 to bysel'right);
		variable bydly : std_logic_vector(bysel'range);
	begin
		if rising_edge(miitx_clk) then
			if ddrs_gnt='0' then
				addro <= to_unsigned(2**addro'length-1, addro'length);
				addro_edge <= '1';
				bycnt := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
				bydly := to_unsigned(2**(bycnt'length-1)-3, bydly'length); 
				bysel <= to_unsigned(2**(bycnt'length-1)-2, bysel'length); 
				ena <= '1';
				rdy <= '0';
			elsif miitx_req='0' then
				addro_edge <= addro(bram_num-1);
				bycnt := to_unsigned(2**(bycnt'length-1)-4, bycnt'length); 
				bydly := to_unsigned(2**(bycnt'length-1)-3, bydly'length); 
				bysel <= to_unsigned(2**(bycnt'length-1)-2, bysel'length); 
				ena <= '1';
				rdy <= '0';
			else
				ena <= not rdy;
				if rdy='0' then
					rdy <= addro(bram_num-1) xor addro_edge;
					bysel <= bydly;
					bydly := std_logic_vector(bycnt(bydly'range));
					if bycnt(0)='1' then
						addro_edge <= addro(bram_num-1);
						bycnt := to_unsigned(2**(bycnt'length-1)-2, bycnt'length); 
						if (addro(bram_num-1) xor addro_edge)='0' then
							addro <= addro - 1;
						end if;
					else
						bycnt := bycnt - 1;
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
		clk => ddrs_clk,
		di(0) => dirdy,
		do(0) => wr_ena);

	rd_address_i : entity hdl4fpga.align
	generic map (
		n => rd_address'length,
		d => (rd_address'range => 1))
	port map (
		clk => miitx_clk,
		di  => std_logic_vector(addro),
		do  => rd_address);

	bram_e : entity hdl4fpga.dpram
	port map (
		wr_clk => ddrs_clk,
		wr_addr => wr_address, 
		wr_ena => wr_ena,
		wr_data => wr_data,
		rd_clk => miitx_clk,
		rd_addr => rd_address,
		rd_data => rd_data);

	rad <= std_logic_vector(unsigned(rd_data) ror 15*miitx_dat'length); -- 1,3,7 2*n/2-1 n= number of bytes
	txd <= word2byte (
		word => rad,
		addr => not bysel);
	miitx_dat <= reverse (txd);
end;
