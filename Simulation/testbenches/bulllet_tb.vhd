library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bullet_tb is
	port(
			bullet_x_tb  : out std_logic_vector (9 downto 0); 
			bullet_y_tb  : out std_logic_vector (9 downto 0); 
			is_active_tb    : out std_logic
	);
end entity bullet_tb;

architecture behavior of bullet_tb is
	
	component bullet is
		port(
			rst_n     : in std_logic;
			trigger   : in std_logic;
			pulse     : in std_logic;
			dir       : in std_logic;
			start_x   : in std_logic_vector (9 downto 0);
			start_y   : in std_logic_vector (9 downto 0);
			bullet_x  : out std_logic_vector (9 downto 0); 
			bullet_y  : out std_logic_vector (9 downto 0); 
			is_active    : out std_logic;  
			hit_detected : in std_logic;
			clk       : in std_logic
		);
	end component bullet;
	
	signal clk_tb   : std_logic := '0';
	signal rst_tb : std_logic := '0';
	signal trigger_tb : std_logic := '1';
	signal dir_tb : std_logic := '0';
	signal start_x_tb : std_logic_vector (9 downto 0) := (others => '0');
	signal start_y_tb : std_logic_vector (9 downto 0) := (others => '0');
	signal hit_detected_tb : std_logic := '0';
	signal pulse_tb : std_logic := '0';
	
	constant clk_period : time := 1 ns;

begin

	dut: bullet
		port map (
			rst_n     => rst_tb,
			trigger   => trigger_tb,
			pulse     => pulse_tb,
			dir       => dir_tb,
			start_x   => start_x_tb,
			start_y   => start_y_tb,
			bullet_x  => bullet_x_tb,
			bullet_y  => bullet_y_tb,
			is_active => is_active_tb,
			hit_detected => hit_detected_tb,
			clk       => clk_tb
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
		wait for 5 ns;
		rst_tb <= '1';
		wait for 5 ns;
		
		start_x_tb <= "0001000000"; 
		start_y_tb <= "0000100000"; 
		dir_tb <= '1'; 
		wait for 1 ns;
		trigger_tb <= '0';
		wait for 1 ns;
		trigger_tb <= '1';
		wait for 25 ns;
		trigger_tb <= '0';
		wait for 1 ns;
		trigger_tb <= '1';
		wait for 800 ns;
		

		dir_tb <= '0';  
		start_x_tb <= "0001100000";
		start_y_tb <= "0000110000";
		wait for 1 ns;
		trigger_tb <= '0';
		wait for 1 ns;
		trigger_tb <= '1';
		wait for 24 ns;
		
		hit_detected_tb <= '1';
		wait for 1 ns;
		hit_detected_tb <= '0';
		wait for 1 ns;

		wait;
	end process stimulus;

end architecture behavior;