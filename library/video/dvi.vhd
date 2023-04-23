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

entity dvi_subpxl is
    port (
        clk   : in  std_logic;
        hsync : in  std_logic;
        vsync : in  std_logic;
        blank : in  std_logic;
        red   : in  std_logic_vector( 8-1 downto 0);
        grn   : in  std_logic_vector( 8-1 downto 0);
        blu   : in  std_logic_vector( 8-1 downto 0);
        chn0  : out std_logic_vector(10-1 downto 0);
        chn1  : out std_logic_vector(10-1 downto 0);
        chn2  : out std_logic_vector(10-1 downto 0));
end;

architecture def of dvi_subpxl is
    constant c00  : std_logic_vector := "1101010100";
    constant c01  : std_logic_vector := "0010101011";
    constant c10  : std_logic_vector := "0101010100";
    constant c11  : std_logic_vector := "1010101011";

    signal allchn : std_logic_vector(3*chn0'length-1 downto 0);
    signal chn0_c : std_logic_vector(chn0'range);
    signal c      : std_logic_vector(3*chn0'length-1 downto 0);
    signal pixel  : std_logic_vector(3*blu'length-1 downto 0);
begin
    pixel <= red & grn & blu;
    with std_logic_vector'(vsync, hsync) select
    chn0_c <= 
        c00 when "00",
        c01 when "01",
        c10 when "10",
        c11 when others;
    c <= c00 & c00 & chn0_c;
    chn0to2_g : for i in 0 to 3-1 generate
        tmds_encoder_e : entity hdl4fpga.tmds_encoder1
        port map (
            clk     => clk,
            c       => c(c00'length*(i+1)-1 downto c00'length*i),
            de      => blank,
            data    => pixel(  blu'length*(i+1)-1 downto  blu'length*i),
            encoded => allchn(chn0'length*(i+1)-1 downto chn0'length*i));
    end generate;
    chn0 <= allchn(chn0'length*1-1 downto chn0'length*0);
    chn1 <= allchn(chn0'length*2-1 downto chn0'length*1);
    chn2 <= allchn(chn0'length*3-1 downto chn0'length*2);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity dvi is
    port (
        clk   : in  std_logic;
        hsync : in  std_logic;
        vsync : in  std_logic;
        blank : in  std_logic;
        red   : in  std_logic_vector( 8-1 downto 0);
        grn   : in  std_logic_vector( 8-1 downto 0);
        blu   : in  std_logic_vector( 8-1 downto 0);
        chn0  : out std_logic_vector(10-1 downto 0);
        chn1  : out std_logic_vector(10-1 downto 0);
        chn2  : out std_logic_vector(10-1 downto 0));
end;

architecture def of dvi is
begin

    dvisubpxl_e : entity hdl4fpga.dvi_subpxl
    port map (
        clk   => clk,
        hsync => hsync,
        vsync => vsync,
        blank => blank,
        red   => red,
        grn   => grn,
        blu   => blu,
        chn0  => chn0,
        chn1  => chn1,
        chn2  => chn2);
end;