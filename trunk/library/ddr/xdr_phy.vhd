library ieee;
use ieee.std_logic_1164.all;

entity xdr_phy is
	generic (
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_rst : in  std_logic;
		sys_clk : in  std_logic_vector;
		sys_rw  : in  std_logic;
		sys_dqi : in  std_logic_vector(data_phases*byte_size-1 downto 0);
		sys_dqz : in  std_logic;
		sys_dqo : out std_logic_vector(data_phases*byte_size-1 downto 0);

		sys_dqsi : in  std_logic_vector(data_edges-1 downto 0);
		sys_dqsz : in  std_logic_vector(data_edges-1 downto 0);

		xdr_dqi  : in  std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqz  : out std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_bytes*byte_size-1 downto 0);

		xdr_dqsi : in  std_logic;
		xdr_dqsz : out std_logic;
		xdr_dqso : out std_logic);
end;

architecture mix of xdr_phy is
begin
	xdr_dqi_e : entity hdl4fpga.xdr_dqi
	generic map (
		byte_size   => byte_size,
		data_phases => data_phases,
		data_edges  => data_edges)
	port map (
		sys_clk => ,
		sys_dqi => sys_di,
		xdr_dqi => xdr_dqi);

	xdr_dqo_e : entity hdl4fpga.xdr_dqo
	generic map (
		byte_size   => byte_size,
		data_edges  => data_edges,
		data_phases => data_phases)
	port map (
		sys_clk => ,
		sys_dqo => sys_dqo,
		sys_dqz => sys_dqz,
		xdr_dqz => xdr_dqz,
		xdr_dqo => xdr_dqo);

	xdr_dqs_e : entity hdl4fpga.xdr_dqs
	generic map (
		byte_size   => byte_size,
		data_edges  => data_edges,
		data_phases => data_phases)
	port map (
		sys_clk => clk0,
		sys_ena => xdr_mpu_dqs,
		sys_dqsz => xdr_mpu_dqsz,
		xdr_dqsz => xdr_io_dqsz,
		xdr_dqso => xdr_dqso);
	xdr_dqsz <= xdr_io_dqsz;
	
	xdr_mpu_dmx <= xdr_wr_fifo_ena;
	xdr_io_dm_e : entity hdl4fpga.xdr_io_dm
	generic map (
		strobe => strobe,
		xdr_phases => assign_if(data_phases > 2,unsigned_num_bits(data_phases),0),
		data_edges => data_edges,
		data_bytes => data_bytes)
	port map (
		sys_dmi
		sys_dmo
		xdr_io_clk => xdr_clk,
		xdr_mpu_st => xdr_mpu_dr,
		xdr_mpu_dm => xdr_wr_dm,
		xdr_mpu_dmx => xdr_mpu_dmx,
		xdr_io_dmo => xdr_dm);

	xdr_st_g : if strobe="EXTERNAL" generate
		signal st_dqs : std_logic;
	begin
		xdr_st_hlf <= setif(std=1 and cas(0)='1');
		xdr_st_e : entity hdl4fpga.xdr_stw
		port map (
			xdr_st_hlf => xdr_st_hlf,
			xdr_st_clk => sys_clk0,
			xdr_st_drr => xdr_mpu_dr(r),
			xdr_st_drf => xdr_mpu_dr(f),
			xdr_st_dqs => st_dqs);
		xdr_st_dqs <= (others => st_dqs);
	end generate;
end;
