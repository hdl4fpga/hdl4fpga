--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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
use ieee.std_logic_arith.all;
    
entity testbench is
end;

architecture mix of testbench is
    constant addressWidth : natural := 32;
    constant codeWidth : natural := 16;
    constant dataWidth : natural := 32;
    
	signal reset   : std_ulogic := '1';
	signal clock   : std_ulogic := '0';
	signal codAddr : std_ulogic_vector (addressWidth-1 downto 0);
	signal datAddr : std_ulogic_vector (addressWidth-1 downto 0);
	signal rdWr    : std_ulogic;
	signal code    : std_ulogic_vector (0 to codeWidth-1);
	signal dataIn  : std_ulogic_vector (dataWidth-1 downto 0);
	signal dataOut : std_ulogic_vector (dataWidth-1 downto 0);
	
	component cpuCore
		port (
			reset   : in  std_ulogic;
			clock   : in  std_ulogic;
			rdWr    : in  std_ulogic;
			codAddr : out std_ulogic_vector;
			datAddr : out std_ulogic_vector;
			code    : in  std_ulogic_vector;
			dataIn  : in  std_ulogic_vector;
			dataOut : out std_ulogic_vector;
			rs1Id   : out std_ulogic_vector;
			rs2Id   : out std_ulogic_vector;
			rdId    : out std_ulogic_vector;
			rs1Val  : in  std_ulogic_vector;
			rs2Val  : in  std_ulogic_vector;
			rdVal   : out std_ulogic_vector;
			disWb   : out std_ulogic);
    end component;
			
	component syncRAM
		port (
			reset  : in  std_ulogic;
			clock  : in  std_ulogic;
			rdAddr : in  std_ulogic_vector;
			wrAddr : in  std_ulogic_vector;
			rdData : out std_ulogic_vector;
			wrData : in  std_ulogic_vector;
			wrEna  : in  std_ulogic;
			rdEna  : in  std_ulogic := '1');
	end component;

	signal rs1Id   : std_ulogic_vector(3 downto 0);
	signal rs2Id   : std_ulogic_vector(3 downto 0);
	signal rdId    : std_ulogic_vector(3 downto 0);
	signal rs1Val  : std_ulogic_vector(dataWidth-1 downto 0);
	signal rs2Val  : std_ulogic_vector(dataWidth-1 downto 0);
	signal rdVal   : std_ulogic_vector(dataWidth-1 downto 0);
	signal disWb   : std_ulogic;
begin
	reset <= '1', '0' after 70 ns;
	clock <= not clock after 25 ns;
	cpu : cpuCore
		port map (
			reset   => reset,
			clock   => clock,
			rdWr    => rdWr,
			codAddr => codAddr,
			datAddr => datAddr,
			code    => code,
			dataIn  => dataIn,
			dataOut => dataOut,
			rs1Id   => rs1Id,
			rs2Id   => rs2Id,
			rdId    => rdId,
			rs1Val  => rs1Val,
			rs2Val  => rs2Val,
			rdVal   => rdVal,
			disWb   => disWb);
			
	rs1: syncRAM port map (reset, clock, rs1Id, rdId, rs1Val, rdVal, disWb);
	rs2: syncRAM port map (reset, clock, rs2Id, rdId, rs2Val, rdVal, disWb);

	dataIn <= "11111111111111111111111111111100";
	process (clock, reset)
		subtype codeWord is std_ulogic_vector (0 to codeWidth-1);
		type codeMem is array (natural range <>) of codeWord;
		constant instWord : codeMem (0 to 6) := (
		    "0000000000000000",     -- nop
			"1110111111111111",		-- addi $r15,-1
			"1000111111111110",     -- jal -2
			"0000000000000000",
			"1001111000000000",     -- jalr $r14
			"0000000000000000",
			"1010111100000001");    -- brt $r15,1
                                    			
	begin
		if reset='1' then
			code <= (code'range => '0');
        elsif clock='1' and clock'event then
            code <= instWord(conv_integer (unsigned(codAddr))/2);
        end if;        
    end process;
end;
