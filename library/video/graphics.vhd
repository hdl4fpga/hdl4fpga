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

	signal video_word : std_logic_vector(0 to setif(video_pixel'length < ctlr_di'length, ctlr_di'length, video_pixel'length)-1);
	signal vram_irdy  : std_logic;
	signal vram_data  : std_logic_vector(video_word'range);

begin

	assert ctlr_di'length mod video_pixel'length=0 or video_pixel'length mod ctlr_di'length=0
	report
		"video_pixel " & natural'image(video_pixel'length) & 
		" is not multiple of " & "ctlr_di " & natural'image(ctlr_di'length) &
		" or viceversa"
	severity FAILURE;

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
			constant dataperpixel : natural := video_pixel'length/ctlr_di'length;
			constant pixelperdata : natural := setif(ctlr_di'length<video_pixel'length, 1, ctlr_di'length/video_pixel'length);
			constant dpage_size   : natural := setif(dataperpixel/=0, ppage_size*dataperpixel,  ppage_size/pixelperdata);
			constant dslice_size  : natural := setif(dataperpixel/=0, pslice_size*dataperpixel, pslice_size/pixelperdata);
	
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

	serdes_g : if ctlr_di'length < video_pixel'length generate
		signal ser_frm : std_logic;
		signal des_irdy : std_logic;
		signal des_data : std_logic_vector(0 to video_pixel'length-1);
	begin
		ser_frm <= (dma_req xor dma_rdy);

		serdes_e : entity hdl4fpga.serdes
		port map (
			serdes_clk => ctlr_clk,
			serdes_frm => ser_frm,
			ser_irdy   => ctlr_di_dv,
			ser_data   => ctlr_di,

			des_irdy   => des_irdy,
			des_data   => des_data);

			vram_irdy <= des_irdy;
			vram_data <= reverse(reverse(des_data), ctlr_di'length);
	end generate;

	bypass_input_g : if ctlr_di'length >= video_pixel'length generate
		vram_irdy <= ctlr_di_dv;
		vram_data <= ctlr_di;
	end generate;

	video_on <= video_hzon and video_vton;
	vram_e : entity hdl4fpga.fifo
	generic map (
		max_depth  => ppage_size,
		async_mode => true,
		latency    => 1,
		check_sov  => false,
		check_dov  => false,
		gray_code  => false)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => vram_irdy,
		src_data => vram_data,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_trdy,
		dst_data => video_word);

	bypass_output_g : if ctlr_di'length <= video_pixel'length generate
		video_trdy  <= video_on;
		video_pixel <= video_word;
	end generate;

	desser_g : if ctlr_di'length > video_pixel'length generate
        serlzr_e : entity hdl4fpga.serlzr
       	generic map (
       		fifo_mode => false,
       		lsdfirst  => false)
       	port map (
       		src_clk   => video_clk,
			src_frm   => video_on,
       		src_trdy  => video_trdy,
       		src_data  => video_word,
       		dst_clk   => video_clk,
       		dst_data  => video_pixel);

	end generate;

end;
