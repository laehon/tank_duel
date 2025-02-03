library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hit_detection_tb is
	port(
			hit_detected_tb   : out std_logic;
			score_tb          : out std_logic_vector(1 downto 0);
			win_tb			   : out std_logic
	);
end entity hit_detection_tb;

architecture behavior of hit_detection_tb is
	
	component hit_detection is
		port(
			bullet_x       : in std_logic_vector(9 downto 0);
			bullet_y       : in std_logic_vector(9 downto 0);
			tank_x         : in std_logic_vector(9 downto 0);
			tank_y_lower   : in std_logic_vector(9 downto 0);
			tank_y_upper   : in std_logic_vector(9 downto 0);
			pulse          : in std_logic;
			rst_n          : in std_logic;
			active_bull	   : in std_logic;
			hit_detected   : out std_logic;
			score          : out std_logic_vector(1 downto 0);
			win			   : out std_logic;
			clk				  : in std_logic
		);
	end component hit_detection;
	
	signal bullet_x_tb       : std_logic_vector(9 downto 0) := (others => '0');
	signal bullet_y_tb       : std_logic_vector(9 downto 0) := (others => '0');
	signal tank_x_tb         : std_logic_vector(9 downto 0) := (others => '0');
	signal tank_y_lower_tb   : std_logic_vector(9 downto 0) := (others => '0');
	signal tank_y_upper_tb   : std_logic_vector(9 downto 0) := (others => '0');
	signal clk_tb            : std_logic := '0';
	signal rst_tb            : std_logic := '0';
	signal active_bull_tb	 : std_logic := '0';
	signal pulse_tb          : std_logic := '0';
	
	constant clk_period : time := 1 ns;

begin

	dut: hit_detection
		port map (
			bullet_x       => bullet_x_tb,
			bullet_y       => bullet_y_tb,
			tank_x         => tank_x_tb,
			tank_y_lower   => tank_y_lower_tb,
			tank_y_upper   => tank_y_upper_tb,
			pulse          => pulse_tb,
			rst_n          => rst_tb,
			active_bull	   => active_bull_tb,
			hit_detected   => hit_detected_tb,
			score          => score_tb,
			win			   => win_tb,
			clk            => clk_tb
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
		
		bullet_x_tb <= "0000100000";
		bullet_y_tb <= "0000100000";
		tank_x_tb <= "0001100000";
		tank_y_lower_tb <= "0001010000";
		tank_y_upper_tb <= "0001110000";
		active_bull_tb <= '1';
		wait for 4 ns;
		
		bullet_x_tb <= "0001100010"; 
		bullet_y_tb <= "0001100100";
		wait for 4 ns;
		
		bullet_x_tb <= "0000111101";
		bullet_y_tb <= "0001010000";
		wait for 4 ns;
		
		bullet_x_tb <= "0000000010";
		bullet_y_tb <= "0000000100";
		wait for 4 ns;
		
		bullet_x_tb <= "0010000010";
		bullet_y_tb <= "0001110000";
		wait for 4 ns;
		
		bullet_x_tb <= "0110010010";
		bullet_y_tb <= "0110000100";
		wait for 4 ns;

		wait;
	end process stimulus;

end architecture behavior;