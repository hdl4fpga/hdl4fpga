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
use hdl4fpga.videopkg.all;

entity graphics is
	generic (
		video_width : natural);
	port (
		ctlr_inirdy : in  std_logic;
		ctlr_clk    : in  std_logic;
		ctlr_di_dv  : in  std_logic;
		ctlr_di     : in  std_logic_vector;
		base_addr   : in  std_logic_vector;
		dmacfg_clk  : in  std_logic;
		dmacfg_req  : buffer std_logic;
		dmacfg_rdy  : in  std_logic;
		dma_req     : buffer std_logic;
		dma_rdy     : in  std_logic;
		dma_len     : out std_logic_vector;
		dma_addr    : buffer std_logic_vector;
		video_clk   : in  std_logic;
		video_hzon  : in  std_logic;
		video_vton  : in  std_logic;
		video_pixel : out std_logic_vector);
end;

architecture def of graphics is

	constant pslice_size : natural := 2**(unsigned_num_bits(video_width-1));
	constant ppage_size  : natural := 2*pslice_size;
	constant pwater_mark : natural := ppage_size-pslice_size;

	signal video_frm     : std_logic;
	signal video_trdy    : std_logic;
	signal video_on      : std_logic;
	signal video_rdy     : std_logic;
	signal video_req     : std_logic;

	signal src_irdy      : std_logic;
	signal src_data      : std_logic_vector(ctlr_di'range);

	signal dma_step      : unsigned(dma_addr'range);

	signal video_word : std_logic_vector(ctlr_di'range);

begin

	dma_b : block
		signal trdy : std_logic;
		signal treq : std_logic;
		signal vrdy : std_logic;
		signal vreq : std_logic;
	begin
		dmacfg_p : process(dmacfg_clk)
			type states is (s_idle, s_cfg, s_trans);
			variable state : states;
	
		begin
			if rising_edge(dmacfg_clk) then
				if ctlr_inirdy='0' then
					vrdy <= to_stdulogic(to_bit(vreq));
					state := s_idle;
				else
					case state is
					when s_idle =>
						if (to_bit(vrdy) xor to_bit(vreq))='1' then
							dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
							state := s_cfg;
						end if;
					when s_cfg =>
						if (to_bit(dmacfg_req) xor to_bit(dmacfg_rdy))='0' then
							treq <= not to_stdulogic(to_bit(trdy));
							state := s_trans;
						end if;
					when s_trans =>
						if (to_bit(treq) xor to_bit(trdy))='0' then
							vrdy <= to_stdulogic(to_bit(vreq));
							state := s_idle;
						end if;
					end case;
				end if;
				vreq <= video_req;
				trdy <= dma_rdy;
			end if;
		end process;

		process (video_clk)
		begin
			if rising_edge(video_clk) then
				video_rdy <= vrdy;
			end if;
		end process;

		process (ctlr_clk)
		begin
			if rising_edge(ctlr_clk) then
				dma_req <= treq;
			end if;
		end process;

	end block;
	
	video_b : block
		signal level  : unsigned(0 to unsigned_num_bits(ppage_size-1));
	begin
		process (video_clk)
			constant dpage_size   : natural := ( ppage_size*video_pixel'length+ctlr_di'length-1)/ctlr_di'length;
			constant dslice_size  : natural := (pslice_size*video_pixel'length+ctlr_di'length-1)/ctlr_di'length;
	
			type states is (s_frm, s_vtpoll, s_hzpoll, s_line);
			variable state : states;

			variable new_level : unsigned(level'range);
		begin
			if rising_edge(video_clk) then
				case state is
				when s_frm =>
					dma_addr <= to_stdlogicvector(to_bitvector(base_addr));
					dma_len  <= std_logic_vector(to_unsigned(dpage_size-1, dma_len'length));
					dma_step <= to_unsigned(dpage_size, dma_step'length);
					if (to_bit(video_rdy) xor to_bit(video_req))='0' then
						if video_frm='1' then
							video_frm <= '0';
						else
							video_req <= not to_stdulogic(to_bit(video_rdy));
							video_frm <= '1';
							state     := s_vtpoll;
						end if;
					end if;
				when s_vtpoll =>
					if (to_bit(video_rdy) xor to_bit(video_req))='0' then
						if video_vton='1' then
							state := s_hzpoll;
						end if;
					end if;
				when s_hzpoll  =>
					if video_vton='1' then
						if video_hzon='1' then
							if new_level <= to_unsigned(pwater_mark, level'length) then
								level     <= new_level + to_unsigned(pslice_size, level'length);
								new_level := new_level + to_unsigned(pslice_size, level'length);
								state := s_line;
							else
								level <= new_level;
							end if;
						else
							new_level := level - to_unsigned(video_width, level'length);
						end if;
					else
						level     <= to_unsigned(ppage_size, level'length);
						new_level := to_unsigned(ppage_size, level'length);
						state     := s_frm;
					end if;
					dma_len  <= std_logic_vector(to_unsigned(dslice_size-1, dma_len'length));
				when s_line =>
					if (to_bit(video_rdy) xor to_bit(video_req))='0' then
						dma_addr  <= std_logic_vector(unsigned(dma_addr) + dma_step);
						dma_step  <= to_unsigned(dslice_size, dma_step'length);
						video_req <= not to_stdulogic(to_bit(video_rdy));
						state     := s_hzpoll;
					end if;
				end case;
			end if;
		end process;
	end block;

	video_on <= video_hzon and video_vton;
	srcltdst_g : if ctlr_di'length < video_pixel'length generate
		signal vram_trdy : std_logic;
		signal vram_word : std_logic_vector(video_pixel'range);
		signal slzr_frm : std_logic;
	begin
		process (video_clk, ctlr_clk)
			variable slzr_rdy  : bit;
			variable slzr_req  : bit;
			variable video_req : bit;
			variable video_rdy : bit;
		begin
			if rising_edge(ctlr_clk) then
				if video_frm='1' then
					if (slzr_rdy xor slzr_req)='1' then
						slzr_rdy := slzr_req;
					end if;
				end if;
				slzr_req := video_req;
			end if;
			if rising_edge(video_clk) then
				if video_frm='0' then
					if (video_rdy xor video_req)='0' then
						video_req := not video_rdy;
					end if;
				end if;
				video_rdy := slzr_rdy;
			end if;
			slzr_frm <= not to_stdulogic(slzr_rdy xor slzr_req);
		end process;

    	deslzr_e : entity hdl4fpga.serlzr
    	generic map (
    		fifo_mode => false,
    		lsdfirst  => false)
    	port map (
    		src_clk   => ctlr_clk,
    		src_frm   => slzr_frm,
			src_irdy  => ctlr_di_dv,
    		src_data  => ctlr_di,
    		dst_clk   => ctlr_clk,
    		dst_irdy  => vram_trdy,
    		dst_data  => vram_word);

    	vram_e : entity hdl4fpga.fifo
    	generic map (
    		max_depth  => ppage_size,
    		async_mode => false,
    		latency    => 1,
    		check_sov  => false,
    		check_dov  => true,
    		gray_code  => false)
    	port map (
    		src_clk  => ctlr_clk,
    		src_frm  => slzr_frm,
    		src_irdy => vram_trdy,
    		src_data => vram_word,

    		dst_clk  => video_clk,
    		dst_trdy => video_on,
    		dst_data => video_pixel);
	end generate;

	srcgtdst_g : if ctlr_di'length > video_pixel'length generate
		signal vram_irdy : std_logic;
		signal vram_trdy : std_logic;
		signal vram_word : std_logic_vector(ctlr_di'range);
	begin
    	vram_e : entity hdl4fpga.fifo
    	generic map (
    		max_depth  => ppage_size,
    		async_mode => true,
    		latency    => 1,
    		check_sov  => false,
    		check_dov  => true,
    		gray_code  => false)
    	port map (
    		src_clk  => ctlr_clk,
    		src_data => ctlr_di,
			src_irdy => ctlr_di_dv,

    		dst_clk  => video_clk,
    		dst_frm  => video_frm,
    		dst_irdy => vram_irdy,
    		dst_trdy => vram_trdy,
    		dst_data => vram_word);

    	deslzr_e : entity hdl4fpga.serlzr
    	generic map (
    		fifo_mode => false,
    		lsdfirst  => false)
    	port map (
    		src_clk   => video_clk,
			src_irdy  => vram_irdy,
			src_trdy  => vram_trdy,
    		src_data  => vram_word,
    		dst_frm   => video_frm,
    		dst_clk   => video_clk,
			dst_trdy  => video_on,
    		dst_data  => video_pixel);

	end generate;

end;
