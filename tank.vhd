library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tank is
    port(
        rst_n     : in std_logic; 
        pulse     : in std_logic;
		  speed		: in std_logic_vector(1 downto 0);
        tank_pos  : out std_logic_vector(9 downto 0);
		  clk			: in std_logic
    );
end entity tank;

architecture behavioral of tank is
	signal pos_val : unsigned(9 downto 0);
	
	    -- State machine signals
    signal next_pos_val : unsigned(9 downto 0);
	 type state_type is (moving_left, moving_right, check_left, check_right);
    signal current_state, next_state : state_type;

begin

	 tank_pos <= std_logic_vector(pos_val);
	
	    -- Process 1: Synchronous state update
    process(rst_n, clk)
    begin
        if rst_n = '0' then
            pos_val <= "0000100000"; -- Initialize position to 128
				current_state <= check_right;
        elsif rising_edge(clk) then
            pos_val <= next_pos_val;
            current_state <= next_state;
        end if;
    end process;

	process(current_state, pulse, speed)
	begin
		next_pos_val <= pos_val;
		next_state <= current_state;
		
		case current_state is
			when moving_right =>
				if pulse = '1' then
					next_pos_val <= pos_val + unsigned(speed);
               next_state <= check_right;
            end if;
			when moving_left =>
				if pulse = '1' then
					next_pos_val <= pos_val - unsigned(speed);
               next_state <= check_left;
            end if;
			when check_right =>
				if pos_val > 600 then
					next_state <= moving_left;
			   else
				   next_state <= moving_right;
			   end if;
			when check_left =>
				if pos_val < 40 then
					next_state <= moving_right;
			   else
				   next_state <= moving_left;
			   end if;
		end case;
	end process;
	
end architecture behavioral;
