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

entity rdyreq is
    generic (
        n : natural);
    port (
        clr  : in std_ulogic := '0';
        clk  : in std_ulogic;
        rst  : in std_ulogic := '0';
        reqs : in std_logic_vector(0 to n-1);
        rdys : buffer std_logic_vector(0 to n-1) := (others => '0');
        gntd : buffer std_logic_vector(0 to n-1);
        req  : buffer std_ulogic := '0';
        rdy  : in std_ulogic);
end;

architecture beh of rdyreq is
begin
    process (clk)
        type states is (s_idle, s_busy);
        variable state : states;
    begin
        if clr='1' then
            rdys  <= reqs;
            gntd  <= (others => '0');
            state := s_idle;
        elsif rising_edge(clk) then
            if rst='1' then
                rdys  <= reqs;
                gntd  <= (others => '0');
                state := s_idle;
            else
                case state is
                when s_idle =>
                    gntd <= (others => '0');
                    for i in 0 to n-1 loop
                        if (rdys(i) xor reqs(i))='1' then
                            gntd(i) <= '1';
                            req <= not rdy;
                            state := s_busy;
                            exit;
                        end if;
                    end loop;
                when s_busy =>
                    if (req xor rdy)='0' then
                        for i in 0 to n-1 loop
                            if gntd(i)='1' then
                                rdys(i) <= reqs(i);
                                exit;
                            end if;
                        end loop;
                        state := s_idle;
                    end if;
                end case;
            end if;
        end if;
    end process;
end;