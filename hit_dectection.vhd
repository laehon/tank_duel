library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hit_detection is
    port(
        bullet_x       : in std_logic_vector(9 downto 0);
        bullet_y       : in std_logic_vector(9 downto 0);
        tank_x         : in std_logic_vector(9 downto 0);
        tank_y_lower   : in std_logic_vector(9 downto 0);
        tank_y_upper   : in std_logic_vector(9 downto 0);
        pulse          : in std_logic;
        rst_n          : in std_logic;
		  active_bull	  : in std_logic;
        hit_detected   : out std_logic;
        score          : out std_logic_vector(1 downto 0);
		  win				  : out std_logic;
		  clk				  : in std_logic
    );
end entity hit_detection;

architecture behavioral of hit_detection is
    signal score_reg       : unsigned(1 downto 0);
    signal hit_detected_reg: std_logic;
	 
    signal next_score       : unsigned(1 downto 0);
    signal next_hit_detected: std_logic;
begin
    
    hit_detected <= hit_detected_reg;
    score <= std_logic_vector(score_reg(1 downto 0));
	 
	 win <= '1' when score_reg(1 downto 0) = "11" else '0';
	 
	 process(clk, rst_n)
    begin
        if rst_n = '0' then
            score_reg <= (others => '0');
            hit_detected_reg <= '0';
        elsif rising_edge(clk) then
            score_reg <= next_score;
            hit_detected_reg <= next_hit_detected;
        end if;
    end process;

    process(pulse, bullet_x, bullet_y, tank_x)
        variable bullet_x_plus_2  : unsigned(9 downto 0);
        variable bullet_x_minus_2 : unsigned(9 downto 0);
        variable bullet_y_plus_2  : unsigned(9 downto 0);
        variable bullet_y_minus_2 : unsigned(9 downto 0);
        variable tank_x_minus_28  : unsigned(9 downto 0);
        variable tank_x_plus_28   : unsigned(9 downto 0);
        variable tank_y_lb        : unsigned(9 downto 0);
        variable tank_y_ub        : unsigned(9 downto 0);
    begin
		  next_hit_detected <= hit_detected_reg;
        next_score <= score_reg;
			
        if pulse = '1' then
            bullet_x_plus_2  := unsigned(bullet_x) + 2;
            bullet_x_minus_2 := unsigned(bullet_x) - 2;
            bullet_y_plus_2  := unsigned(bullet_y) + 2;
            bullet_y_minus_2 := unsigned(bullet_y) - 2;
            tank_x_minus_28  := unsigned(tank_x) - 35;
            tank_x_plus_28   := unsigned(tank_x) + 35;
            tank_y_lb        := unsigned(tank_y_lower);
            tank_y_ub        := unsigned(tank_y_upper);

            if (bullet_y_plus_2 >= tank_y_lb and bullet_y_minus_2 <= tank_y_ub and active_bull = '1' and
                bullet_x_plus_2 >= tank_x_minus_28 and bullet_x_minus_2 <= tank_x_plus_28) then
                next_hit_detected <= '1';
                next_score <= score_reg + 1;
            else
                next_hit_detected <= '0';
            end if;
        end if;
    end process;
end architecture behavioral;