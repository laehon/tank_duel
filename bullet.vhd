library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bullet is
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
		  clk				: in std_logic
    );
end entity bullet;

architecture behavioral of bullet is
    signal x_val : unsigned(9 downto 0);
    signal y_val : unsigned(9 downto 0);
    signal active_reg : std_logic;
	 
	 -- State machine signals
    signal next_x_val      : unsigned(9 downto 0);
    signal next_y_val      : unsigned(9 downto 0);
    signal next_active_reg : std_logic;
	 
	 type state_type is (nonactive, loop_down, loop_up, loop_up_cond, loop_down_cond);
    signal current_state, next_state : state_type;

begin
	 
    bullet_x <= std_logic_vector(x_val);
    bullet_y <= std_logic_vector(y_val);
    is_active <= active_reg;
	 
	 -- Process 1: Synchronous state update
    process(rst_n, clk)
    begin
        if rst_n = '0' then
				current_state <= nonactive;
            x_val <= (others => '0');
            y_val <= (others => '0');
            active_reg <= '0';
        elsif rising_edge(clk) then
				current_state <= next_state;
            x_val <= next_x_val;
            y_val <= next_y_val;
            active_reg <= next_active_reg;
        end if;
    end process;

    process(current_state, pulse, trigger, hit_detected, y_val, x_val, active_reg)
    begin
		next_x_val <= x_val;
		next_y_val <= y_val;
		next_active_reg <= active_reg;
		next_state <= current_state;
		  
		case current_state is
			when nonactive =>
				next_x_val <= unsigned(start_x);
				next_y_val <= unsigned(start_y);
				next_active_reg <= '0';
				if trigger = '0' and dir = '1' then
					next_state <= loop_down;
				elsif trigger = '0' and dir = '0' then
					next_state <= loop_up;
				end if;
			when loop_down =>
				next_active_reg <= '1';
				if pulse = '1' then
					next_y_val <= y_val + 4;
					next_state <= loop_down_cond;
				end if;
			when loop_up =>
				next_active_reg <= '1';
				if pulse = '1' then
					next_y_val <= y_val - 4;
					next_state <= loop_up_cond;
				end if;
			when loop_down_cond =>
				if hit_detected = '1' or y_val >= 470 then
					next_state <= nonactive;
				else
					next_state <= loop_down;
				end if;
			when loop_up_cond =>
				if hit_detected = '1' or y_val <= 10 then
					next_state <= nonactive;
				else
					next_state <= loop_up;
				end if;
			end case;
    end process;

end architecture behavioral;