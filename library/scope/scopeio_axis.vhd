library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	generic (
		latency     : natural);
	port (
		clk         : in  std_logic;

		frm         : in  std_logic;
		unit        : in  std_logic_vector;

		wu_frm      : in  std_logic;
		wu_trdy     : in  std_logic;
		wu_value    : in std_logic_vector;
		wu_format   : in std_logic_vector;

		hz_offset   : in  std_logic_vector;
		vt_offset   : in  std_logic_vector;

		video_clk   : in  std_logic;
		video_hcntr : in  std_logic_vector;
		video_vcntr : in  std_logic_vector;

		video_hzon  : in  std_logic;
		video_vton  : in  std_logic;

		video_vtdot : out std_logic;
		video_hzdot : out std_logic);

end;

architecture def of scopeio_axis is

	signal vt_ena      : std_logic;
	signal vt_addr     : std_logic_vector(13-1 downto 6);
	signal vt_vaddr    : std_logic_vector(13-1 downto 6);
	signal vt_tick     : std_logic_vector(wu_format'range);

	signal hz_ena      : std_logic;
	signal hz_addr     : std_logic_vector(13-1 downto 6);
	signal hz_vaddr    : std_logic_vector(13-1 downto 0);
	signal hz_taddr    : std_logic_vector(13-1 downto 6);
	signal hz_tick     : std_logic_vector(wu_format'range);

begin

	ticks_b : block
	begin

		process (clk)
			variable cntr : unsigned(max(hz_addr'length, vt_addr'length)-1 downto 0);
		begin
			if rising_edge(clk) then
				if frm='0' then
					cntr := (others => '0');
				else wu_trdy='1' then
					cntr := cntr + 1;
				end if;
				hz_addr <= cntr(hz_addr'range);
				vt_addr <= cntr(vt_addr'range);
			end if;
		end process:

		ticks_e : entity hdl4fpga.scopeio_ticks
		port map (
			clk      => clk,
			frm      => frm,
			irdy     => irdy,
			trdy     => trdy,
			base     => x"000e",
			step     => x"0010",
			wu_frm   => wu_frm,
			wu_irdy  => wu_irdy,
			wu_trdy  => wu_trdy,
			wu_value => wu_value);

	end block;

	hz_mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => (0 to 2**7*wu_format'length-1 => '1'))
	port map (
		wr_clk  => clk,
		wr_ena  => hz_ena,
		wr_addr => hz_addr,
		wr_data => wu_format,

		rd_addr => hz_taddr,
		rd_data => hz_tick);

	vt_mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => (0 to 2**4*wu_format'length-1 => '1'))
	port map (
		wr_clk  => clk,
		wr_ena  => vt_ena,
		wr_addr => vt_addr,
		wr_data => wu_format,

		rd_addr => vt_vaddr,
		rd_data => vt_tick);

	video_b : block
		signal code     : std_logic_vector(4-1 downto 0);

		signal hz_bcd   : std_logic_vector(code'range);
		signal vt_bcd   : std_logic_vector(code'range);
		signal hz_don   : std_logic;
		signal vt_don   : std_logic;
		signal char_dot : std_logic;
		signal x        : std_logic_vector(hz_vaddr'left downto 0);
		signal y        : std_logic_vector(vt_vaddr'left downto 0);

		signal hs_on    : std_logic;
		signal vs_on    : std_logic;
	begin

		x_p : process (video_clk)
			variable x : signed(hz_vaddr'left downto 0);
		begin
			if rising_edge(video_clk) then
				x := resize(signed(video_hcntr), x'length);
				x := x + signed(hz_offset);
				hz_vaddr <= std_logic_vector(x);
				if video_hzon='1' then
					x := resize(signed(video_hcntr), x'length) + signed(hz_offset);
				end if;
				hs_on <= video_hzon;
			end if;
		end process;
		hz_bcd <= word2byte(hz_tick, hz_vaddr(6-1 downto 3), code'length);

		y_p : process (video_clk)
		begin
			if rising_edge(video_clk) then
				y <= std_logic_vector(resize(signed(video_vcntr), y'length));
				if video_vton='1' then
					y <= std_logic_vector(resize(signed(video_vcntr), y'length) + signed(vt_offset));
				end if;
				vs_on <= video_vton;
			end if;
		end process;

		vt_vaddr <= y(vt_vaddr'range);
		vt_bcd  <= word2byte(std_logic_vector(unsigned(vt_tick) rol 2*code'length), x(6-1 downto 3), code'length);
		code    <= word2byte(hz_bcd & vt_bcd, vs_on);

		rom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => psf1digit8x8,
			font_height => 2**3,
			font_width  => 2**3)
		port map (
			clk         => video_clk,
			char_col    => x(3-1 downto 0),
			char_row    => y(3-1 downto 0),
			char_code   => code,
			char_dot    => char_dot);

		romlat_b : block
			signal ons : std_logic_vector(0 to 2-1);
		begin

			ons(0) <= hs_on;
			ons(1) <= vs_on and y(4) and y(3);
			lat_e : entity hdl4fpga.align
			generic map (
				n => ons'length,
				d => (ons'range => 2))
			port map (
				clk   => video_clk,
				di    => ons,
				do(0) => hz_don,
				do(1) => vt_don);
		end block;

		lat_b : block
			signal dots : std_logic_vector(0 to 2-1);
		begin
			dots(0) <= char_dot and hz_don;
			dots(1) <= char_dot and vt_don;

			lat_e : entity hdl4fpga.align
			generic map (
				n => dots'length,
				d => (dots'range => latency-3))
			port map (
				clk   => video_clk,
				di    => dots,
				do(0) => video_hzdot,
				do(1) => video_vtdot);
		end block;
	end block;

end;
