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

entity serlzr is
	generic (
		fifo_mode : boolean := false;
		lsdfirst  : boolean := true);
	port (
		src_clk   : in  std_logic;
		src_frm   : in  std_logic := '1';
		src_irdy  : in  std_logic := '1';
		src_trdy  : out std_logic := '1';
		src_data  : in  std_logic_vector;
		dst_clk   : in  std_logic := '1';
		dst_frm   : in  std_logic := '1';
		dst_irdy  : buffer std_logic;
		dst_trdy  : in  std_logic := '1';
		dst_data  : buffer std_logic_vector);
end;

architecture def of serlzr  is

	function max_and_mask (
		constant wide_size : natural;
		constant narrow_size : natural)
		return natural_vector is

		constant debug_mask : boolean := false;
		constant debug_shft : boolean := false;
		constant debug_max  : boolean := false;

		function barrel_stage (
			constant mask   : natural;
			constant shft   : natural;
			constant mode   : bit := '0') 
			return natural is
			variable vmask  : natural;
			variable vshft  : natural;
			variable stage  : natural;
			variable retval : natural;
		begin
			vmask  := mask;
			vshft  := shft;
			stage  := 0;
			retval := mask;
			while vshft > 0 or vmask > 0 loop
				if mode='0' then
					if vmask mod 2 = 0 then
						if vshft mod 2 = 1 then
							retval := retval + 2**stage;
						end if;
					end if;
				else
					if vmask mod 2 = 1 then
						if vshft mod 2 = 0 then
							retval := retval - 2**stage;
						end if;
					end if;
				end if;
				vmask := vmask / 2;
				vshft := vshft / 2;
				stage := stage + 1;
			end loop;
			return retval;
		end;

		variable max   : natural;
		variable mask0 : natural;
		variable mask1 : natural;
		variable shft  : natural;

	begin
		max   := 0;
		mask0 := 0;
		mask1 := 2**unsigned_num_bits(wide_size-1)-1;
		shft  := 0;
		for i in 0 to narrow_size-1 loop
			shft := shft + wide_size mod narrow_size + (wide_size/narrow_size-1)*narrow_size;
			if shft > max then
				max := shft;
			end if;

			assert not debug_max
			report CR & "MAX SHIFT   : " & natural'image(max)
			severity note;

			assert not debug_shft
			report CR & "SHIFT VALUE : " & natural'image(shft)
			severity note;

			mask0 := barrel_stage(mask0,shft, '0');
			-- mask1 := barrel_stage(mask1,shft, '1');
			assert not debug_mask
			report CR & "UPDATED MASK0 : " & natural'image(mask0)
			severity note;
			assert not debug_mask
			report CR & "UPDATED MASK1 : " & natural'image(mask1)
			severity note;

			while shft >= narrow_size loop
				shft := shft - narrow_size;
				mask0 := barrel_stage(mask0,shft, '0');
				-- mask1 := barrel_stage(mask1,shft, '1');

				assert not debug_shft
				report CR & "SHIFT ALUE : " & natural'image(shft)
				severity note;

				assert not debug_mask
				report CR & "UPDATED MASK0 : " & natural'image(mask0)
				severity note;
				assert not debug_mask
				report CR & "UPDATED MASK1 : " & natural'image(mask1)
				severity note;

			end loop;
		end loop;
		return (max+narrow_size, mask0, mask1);
	end;

	constant wide_size   : natural := max(src_data'length, dst_data'length);
	constant narrow_size : natural := hdl4fpga.base.min(src_data'length, dst_data'length);

	constant debug_mm : boolean := false;
	constant mm : natural_vector := max_and_mask(wide_size, narrow_size);

	signal shf  : std_logic_vector(unsigned_num_bits(wide_size-1)-1 downto 0);
	signal rgtr : std_logic_vector(mm(0)-1 downto 0);
	signal shfd : std_logic_vector(rgtr'range);

begin 

	assert not debug_mm
	report CR & "(MAX => " & natural'image(mm(0)) & ", MASK0 => " & to_string((to_unsigned(mm(1), shf'length))) & ", MASK1 => " & to_string((to_unsigned(mm(2), shf'length))) & ")"
	severity note;

	srcgtdst_g : if src_data'length > dst_data'length generate
		signal fifo_trdy : std_logic;
		signal fifo_data : std_logic_vector(src_data'range);
	begin
		fifooff_g : if not fifo_mode generate
			fifo_data <= src_data;
		end generate;

		fifoon_g : if fifo_mode generate
		begin
			fifo_e : entity hdl4fpga.phy_iofifo
			port map (
				in_clk   => src_clk,
				in_data  => src_data,
				out_clk  => dst_clk,
				out_trdy => fifo_trdy,
				out_data => fifo_data);
		end generate;

		none0_g : if true or src_data'length mod dst_data'length /= 0 generate 
			src_trdy <= fifo_trdy;
			process (dst_clk)
				variable shr : unsigned(rgtr'range);
				variable acc : unsigned(shf'range) := (others => '0');
			begin 
				if rising_edge(dst_clk) then
					if dst_frm='0' then
						acc := (others => '0');
						dst_irdy  <= '0';
						fifo_trdy <= '0';
					elsif acc >= dst_data'length then 
						if dst_trdy='1' then
							acc := acc - dst_data'length;
						end if;
						fifo_trdy <= '0';
						dst_irdy  <= '1';
	   				elsif dst_trdy='1' then
						if src_irdy='1' then
							shr := shift_left(shr, src_data'length);
							shr(src_data'length-1 downto 0) := unsigned(setif(lsdfirst,reverse(fifo_data), fifo_data));
							acc := acc + (src_data'length - dst_data'length);
							fifo_trdy <= '1';
							dst_irdy  <= '1';
						else
							dst_irdy  <= '0';
						end if;
					end if;
					shf  <= std_logic_vector(acc(shf'range) and to_unsigned(mm(1), shf'length));
					rgtr <= std_logic_vector(shr);
				end if;
			end process;

			shl_i : entity hdl4fpga.barrel
			generic map (
				left => false)
			port map (
				shf => shf,
				di  => rgtr,
				do  => shfd);
		
			dst_data <= setif(lsdfirst,reverse(shfd(dst_data'length-1 downto 0)), shfd(dst_data'length-1 downto 0));
		end generate;

		mod0_g : if false and src_data'length mod dst_data'length = 0 generate 
			process (dst_clk)
				variable shr : unsigned(rgtr'range);
				variable acc : unsigned(shf'range) := (others => '0');
			begin
				if rising_edge(dst_clk) then
					if dst_frm='0' then
						acc := (others => '0');
						dst_irdy  <= '0';
						fifo_trdy <= '0';
					elsif acc >= dst_data'length then 
						if dst_trdy='1' then
							shr := shift_right(shr, dst_data'length);
							acc := acc - dst_data'length;
						end if;
						fifo_trdy <= '0';
						dst_irdy  <= '1';
	   				elsif dst_trdy='1' then
						if src_irdy='1' then
							shr(src_data'length-1 downto 0) := unsigned(setif(not lsdfirst,reverse(fifo_data), fifo_data));
							acc := acc + (src_data'length - dst_data'length);
							fifo_trdy <= '1';
							dst_irdy  <= '1';
						else
							dst_irdy  <= '0';
						end if;
					end if;
					rgtr <= std_logic_vector(shr);
				end if;
			end process;

			dst_data <= setif(not lsdfirst, reverse(rgtr(dst_data'length-1 downto 0)), rgtr(dst_data'length-1 downto 0));

		end generate;
	end generate;

	srcltdst_g : if src_data'length < dst_data'length generate
		fifoon_g : if fifo_mode generate 
			signal fifo_rst  : std_logic;
			signal fifo_irdy : std_logic;
			signal fifo_data : std_logic_vector(dst_data'range);
		begin
			process (src_clk)
				variable shr : unsigned(rgtr'range);
				variable acc : unsigned(shf'range) := (others => '0');
			begin 
				if rising_edge(src_clk) then
					if src_frm='0' then
						acc := (others => '0');
						fifo_irdy <= '0';
					elsif src_irdy='1' then
						if acc >= dst_data'length-src_data'length then 
							acc := acc - (dst_data'length - src_data'length);
							fifo_irdy <= '1';
						else
							acc := acc + src_data'length;
							fifo_irdy <= '0';
						end if;
						shr := shift_left(shr, src_data'length);
						shr(src_data'length-1 downto 0) := unsigned(setif(lsdfirst,reverse(src_data), src_data));
					end if;
					shf  <= std_logic_vector(acc and to_unsigned(mm(1) mod src_data'length, acc'length));
					rgtr <= std_logic_vector(shr);
				end if;
			end process;
	
			shl_i : entity hdl4fpga.barrel
			generic map (
				left => false)
			port map (
				shf => shf,
				di  => rgtr,
				do  => shfd);
	
			dst_data <= setif(lsdfirst,reverse(shfd(dst_data'length-1 downto 0)), shfd(dst_data'length-1 downto 0));

			fifo_rst <= not src_frm;
			fifo_e : entity hdl4fpga.phy_iofifo
			port map (
				in_clk   => src_clk,
				in_rst   => fifo_rst,
				in_data  => dst_data,
				in_irdy  => fifo_irdy,
				out_clk  => dst_clk,
				out_data => fifo_data);
		end generate;

		fifo_off_g : if not fifo_mode generate 
			signal rgtr : std_logic_vector(mcm(src_data'length,dst_data'length)-1 downto 0);
			signal sel  : unsigned(0 to unsigned_num_bits(rgtr'length/dst_data'length-1)-1) := (others => '0');
		begin
			process (src_clk, dst_clk)
				variable shr  : unsigned(rgtr'range);
				variable acc  : unsigned(0 to unsigned_num_bits(shr'length-1)-1);
				variable full : bit;
			begin 
				if rising_edge(src_clk) then
					if to_bit(src_frm)='0' then
						acc  := (others => '0');
						full := '0';
					elsif src_irdy='1' then
						if acc >= shr'length-src_data'length then 
							acc  := (others => '0');
							full := '1';
						else
							acc  := acc + src_data'length;
							full := '0';
						end if;
						shr := shift_left(shr, src_data'length);
						shr(src_data'length-1 downto 0) := unsigned(setif(lsdfirst,reverse(src_data), src_data));
						if full='1' then
							rgtr <= std_logic_vector(shr);
						end if;
					else
						full := '0';
					end if;
				end if;

				if rising_edge(dst_clk) then
					if full='1' then
						sel <= (others => '0');
						dst_irdy <= '1';
					elsif rgtr'length=dst_data'length then
						sel <= (others => '0');
						dst_irdy <= '0';
					elsif sel < unsigned_num_bits(rgtr'length/dst_data'length-1) then
						sel <= sel + 1;
						dst_irdy <= src_frm;
					else
						dst_irdy <= '0';
					end if;
				end if;
			end process;
	
			dst_data <= multiplex(rgtr, std_logic_vector(sel), dst_data'length);
		end generate;

	end generate;

end;