library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tank_tb is
	port(
			tank_pos_tb  : out std_logic_vector(9 downto 0)
	);
end entity tank_tb;

architecture behavior of tank_tb is

	component tank is
		port(
			rst_n     : in std_logic; 
			pulse     : in std_logic;
			speed		: in std_logic_vector(1 downto 0);
			tank_pos  : out std_logic_vector(9 downto 0);
			clk		: in std_logic
		);
	end component tank;
	
	signal clk_tb   : std_logic := '0';
	signal rst_tb : std_logic := '0';
	signal pulse_tb : std_logic := '0';
	signal speed_tb : std_logic_vector(1 downto 0) := "01";

	constant clk_period : time := 1 ns;

begin

	dut: tank
		port map (
			rst_n   => rst_tb,
			pulse => pulse_tb,
			speed => speed_tb,
			tank_pos => tank_pos_tb,
			clk     => clk_tb
		);

	clk_gen: process
	begin
		while true loop
			clk_tb <= '0';
			wait for clk_period / 2;
			clk_tb <= '1';
			wait for clk_period / 2;
		end loop;
	end process clk_gen;
	
	pulse_gen: process
	begin
		while true loop
			pulse_tb <= '0';
			wait for clk_period * 3;
			pulse_tb <= '1';
			wait for clk_period;
		end loop;
	end process pulse_gen;


	stimulus: process
	begin

		rst_tb <= '0';
		wait for 20 ns;
		rst_tb <= '1';
		wait for 15 ns;
		speed_tb <= "01";
		wait for 15 ns;
		speed_tb <= "10";
		wait for 15 ns;
		speed_tb <= "11";
		wait for 15 ns;
		speed_tb <= "01";
		wait for 1 ms;

		wait;
	end process stimulus;

end architecture behavior;