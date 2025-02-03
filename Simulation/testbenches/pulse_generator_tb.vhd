library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_generator_tb is
	port(
			pulse_tb : out std_logic
	);
end entity pulse_generator_tb;

architecture behavior of pulse_generator_tb is
	
	component pulse_generator is
		port (
			clk     : in  std_logic; 
			rst_n   : in  std_logic;
			pulse   : out std_logic
		);
	end component pulse_generator;
	
	signal clk_tb   : std_logic := '0';
	signal rst_tb : std_logic := '0';
	
	constant clk_period : time := 1 ns;

begin

	dut: pulse_generator
		port map (
			clk   => clk_tb,
			rst_n => rst_tb,
			pulse => pulse_tb
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

	stimulus: process
	begin

		rst_tb <= '0';
		wait for 20 ns;
		rst_tb <= '1';
		wait for 1 ms;

		wait;
	end process stimulus;

end architecture behavior;