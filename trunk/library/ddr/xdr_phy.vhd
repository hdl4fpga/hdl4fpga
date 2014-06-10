library ieee;
use ieee.std_logic_1164.all;

entity xdr_phy is
	generic (
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 2;
		data_bytes  : natural := 2);
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;
		sys_rw   : in  std_logic;
		sys_do   : out std_logic_vector(data_phases*byte_size-1 downto 0);
		sys_di   : in  std_logic_vector(data_phases*byte_size-1 downto 0);
		sys_dqsi : in  std_logic_vector(data_edges-1 downto 0);
		sys_dqst : in  std_logic_vector(data_edges-1 downto 0);

		xdr_dqi  : in  std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqz  : out std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_bytes*byte_size-1 downto 0);

		xdr_dqsi : in  std_logic;
		xdr_dqsz : out std_logic;
		xdr_dqso : out std_logic);
end;

architecture mix of xdr_phy is
begin
	xdr_io_dq_e : entity hdl4fpga.xdr_io_dq
	generic map (
		data_phases => assign_if(data_phases > 2,unsigned_num_bits(data_phases),0),
		data_edges => data_edges,
		data_bytes => data_bytes,
		byte_bits  => byte_bits)
	port map (
		xdr_io_clk => clk90,
		xdr_io_dq  => xdr_wr_dq,
		xdr_mpu_dqz => xdr_mpu_dqz,
		xdr_io_dqz => xdr_io_dqz,
		xdr_io_dqo => xdr_dqo);
	xdr_dqz <= xdr_io_dqz;

	xdr_io_dqs_e : entity hdl4fpga.xdr_io_dqs
	generic map (
		std => std,
		data_phases => data_phases,
		data_edges  => data_edges,
		data_bytes  => data_bytes)
	port map (
		xdr_io_clk => clk0,
		xdr_io_ena => xdr_mpu_dqs,
		xdr_mpu_dqsz => xdr_mpu_dqsz,
		xdr_io_dqsz => xdr_io_dqsz,
		xdr_io_dqso => xdr_dqso);
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
