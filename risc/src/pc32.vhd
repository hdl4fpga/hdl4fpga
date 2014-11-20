library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC32 is
	generic (
		N : natural := 16;
		M : natural := 2);
	port (
		rst : in std_ulogic;
		clk : in std_ulogic;
		ena : in std_ulogic;
		enaSel : in std_ulogic;
		selData : in std_ulogic_vector (M-1 downto 0);
		data   : in std_ulogic_vector (2**M*N-1 downto N);
		dataP2 : in std_ulogic_vector (2**M*N-1 downto N);
		q   : out std_ulogic_vector (N-1 downto 0);
		cy  : out std_ulogic);
end;

architecture Mixed of PC32 is
	constant Half : natural := N/2;
	constant WdLw : natural := half;
	constant WdHi : natural := N-half;
	
	component MultiLdCntr
		port (
			rst : in std_ulogic;
			clk : in std_ulogic;
			ena : in std_ulogic;
			enaSel : in std_ulogic;
			sel : in std_ulogic_vector;
			data   : in std_ulogic_vector;
			dataP2 : in std_ulogic_vector;
			q   : out std_ulogic_vector;
			cy  : out std_ulogic);
	end component;

	subtype dataWdLw is std_ulogic_vector(2**M*WdLw-1 downto WdLw);
	subtype dataWdHi is std_ulogic_vector(2**M*WdHi-1 downto WdHi);
	signal dataL : dataWdLw;
	signal dataH : dataWdLw;
	signal dataP2L : dataWdHi;
	signal dataP2H : dataWdHi;
	
	signal cyH : std_ulogic;
	signal ldHigh : std_ulogic;
	signal enaHigh : std_ulogic;
	signal selHigh : std_ulogic_vector(M-1 downto 0);
	signal enaSelHigh : std_ulogic;

	signal qAux : std_ulogic_vector(q'range);

begin

	q <= qAux;

	pcLow : MultiLdCntr
		port map (
			rst => rst,
			clk => clk,
			ena => ena,
			enaSel => ena,
			sel => selData,
			data   => dataL,
			dataP2 => dataP2L,
			q   => qAux(WdLw-1 downto 0),
			cy  => cyH);

	SplitData : for i in 1 to 2**M-1 generate
		dataL(WdLw*(i+1)-1 downto WdLw*i) <= data(N*i+WdLw-1 downto N*i);
		dataH(WdHi*(i+1)-1 downto WdHi*i) <= data(N*i+N-1 downto N*i+WdHi);
		
		dataP2L(WdLw*(i+1)-1 downto WdLw*i) <= dataP2(N*i+WdLw-1 downto N*i);
		dataP2H(WdHi*(i+1)-1 downto WdHi*i) <= dataP2(N*i+N-1 downto N*i+WdHi);
	end generate;
	
	process (rst,clk)
	begin
		if rst='1' then
			ldHigh <= '0';
			enaSelHigh <= '0';
			selHigh <= (selHigh'range => '0');
		elsif rising_edge(clk) then
			if ena='1' then 
				ldHigh <= enaSelHigh;
				selHigh <= selData;

				if selData /= (selData'range => '0') then
					enaSelHigh <= '1';
				else
					enaSelHigh <= '0';
				end if;
			end if;
		end if;
	end process;

	enaHigh <= (cyH and not qAux(q'right)) or ldHigh;

	pcHigh : MultiLdCntr
		port map (
			rst => rst,
			clk => clk,
			ena => enaHigh,
			enaSel => enaSelHigh,
			sel => selHigh,
			data   => dataH,
			dataP2 => dataP2H,
			q   => qAux(N-1 downto N-WdHi),
			cy  => cy);
end;
