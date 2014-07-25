library ieee;
use ieee.std_logic_1164.all;

entity iddr is
	generic (
		data_size : natural := 1;
		data_phases : natural := 2);
	port (
		sclk  : in std_logic;
		eclk  : in std_logic;
		eclkdqsr => idqs_eclk,
		ddrclkpol => dqsbuf_ddrclkpol,
		ddrlat => dqsbuf_ddrlat,
		dclks : in std_logic_vector(0 to data_phases-1) := (others => '-');
		d : in  std_logic_vector(data_size-1 downto 0);
		q : out std_logic_vector(data_size*data_phases-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of iddr is
begin
	assert data_phases = 1 or data_phases = 2 or data_phases = 4
	report "DATA_PHASES should be 1, 2, 4"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if data_phases = 1 generate
		begin
			ff_i : entity hdl4fpga.ff
			port map (
				clk => sclk,
				d => q(data_size*0+i),
				q => d(i));
		end generate;

		ddrx1_g : if data_phases = 2 generate
			attribute iddrapps : string;
			attribute iddrapps of iddr_i : label is "DQS_ALIGNED";
		begin
			iddr_i : iddrxd1
			port map (
				sclk => sclk,
				d  => d(i),
				qa => q(data_size*0+i),
				qb => q(data_size*1+i));
		end generate;

		ddrx2_g : if data_phases = 4 generate
			attribute iddrapps : string;
			attribute iddrapps of iddr_i : label is "DQS_ALIGNED";
		begin
			iddr_i : iddrx2d
			port map (
				sclk => sclk,
				eclk => eclk,
				eclkdqsr => idqs_eclk,
				ddrclkpol => dqsbuf_ddrclkpol,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				d   => q(i),
				qa0 => d(data_size*0+i),
				qa1 => d(data_size*2+i),
				qb0 => d(data_size*1+i),
				qb1 => d(data_size*3+i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddr is
	generic (
		data_size : natural := 1;
		data_phases : natural := 2);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to data_phases-1) := (others => '-');
		d : in  std_logic_vector(data_size*data_phases-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddr is
begin
	assert data_phases = 1 or data_phases = 2 or data_phases = 4
	report "DATA_PHASES should be 1, 2, 4"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if data_phases = 1 generate
		begin
			ff_i : entity hdl4fpga.ff
			port map (
				clk => sclk,
				d => d(data_size*0+i),
				q => q(i));
		end generate;

		ddrx1_g : if data_phases = 2 generate
			attribute oddrapps : string;
			attribute oddrapps of oddr_i : label is "DQS_ALIGNED";
		begin
			oddr_i : oddrxd1
			port map (
				sclk => sclk,
				da => d(data_size*0+i),
				db => d(data_size*1+i),
				q  => q(i));
		end generate;

		ddrx2_g : if data_phases = 4 generate
			attribute oddrapps : string;
			attribute oddrapps of oddr_i : label is "DQS_ALIGNED";
		begin
			oddr_i : oddrx2d
			port map (
				sclk => sclk,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				da0 => d(data_size*0+i),
				da1 => d(data_size*2+i),
				db0 => d(data_size*1+i),
				db1 => d(data_size*3+i),
				q   => q(i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrt is
	generic (
		data_size : natural := 1);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to data_phases-1) := (others => '-');
		d : in  std_logic_vector(data_size*data_phases-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrt is
begin
	assert data_phases = 1
	report "DATA_PHASES should be 1"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if data_phases = 2 generate
			oddrtdqa_i : oddrtdqa
			port map (
				sclk => sclk,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				ta => d(data_edges*0+i),
				q  => q(i));
		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrdqs is
	generic (
		data_size : natural := 1;
		data_phases : natural := 2);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to data_phases) := (others => '-');
		t : in  std_logic_vector(data_size-1 downto 0);
		d : in  std_logic_vector(data_size*data_phases-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrdqs is
begin
	assert data_phases = 2
	report "DATA_PHASES should be 2"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrdqs_i : label is "DQS_CENTERED";
	begin
		oddrdqs_i : oddrx2dqsa
		port map (
			sclk => sclk,
			db0 => d(data_size*0+i),
			db1 => d(data_size*1+i),
			dqsw => dclks(data_phases),
			dqclk0 => dclks(0),
			dqclk1 => dclks(1),
			dqstclk => t(i),
			q => q);

		end generate;
	end generate;
end;

library ieee;
use ieee.std_logic_1164.all;

entity oddrdqst is
	generic (
		data_size : natural := 1);
	port (
		sclk  : in std_logic;
		dclks : in std_logic_vector(0 to data_phases-1) := (others => '-');
		d : in  std_logic_vector(data_size*data_phases-1 downto 0);
		q : out std_logic_vector(data_size-1 downto 0));
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of oddrdqst is
begin
	assert data_phases = 1
	report "DATA_PHASES should be 1"
	severity FAILURE;

	g : for i in data_size-1 to 0 generate
		ff_g : if data_phases = 2 generate
			oddrtdqa_i : oddrtdqa
			port map (
				sclk => sclk,
				dqclk0 => dclks(0),
				dqclk1 => dclks(1),
				ta => d(data_edges*0+i),
				q  => q(i));
		end generate;
	end generate;
end;
