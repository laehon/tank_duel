library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity tank_duel is
	port(
			CLOCK_50 										: in std_logic;
			RESET_N											: in std_logic;
			
			red_led_out										: out std_logic_vector (6 downto 0);
			blue_led_out									: out std_logic_vector (6 downto 0);
	
			--VGA 
			VGA_RED, VGA_GREEN, VGA_BLUE : out std_logic_vector(7 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK		: out std_logic;
			
			--LCD
			lcd_rs, lcd_e, lcd_on, reset_led, sec_led		: OUT	STD_LOGIC;
			lcd_rw						: BUFFER STD_LOGIC;
			data_bus				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			
			keyboard_clk, keyboard_data : in std_logic
			

		);
end entity tank_duel;

architecture structural of tank_duel is

	component pixelGenerator is
		port(
				clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
				pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
				red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
				blue_tank, red_tank                       : in std_logic_vector(9 downto 0);
				red_bull_act										: in std_logic;
				red_bull_x, red_bull_y							: in std_logic_vector(9 downto 0);
				blue_bull_act										: in std_logic;
				blue_bull_x, blue_bull_y						: in std_logic_vector(9 downto 0);
				blue_win, red_win									: in std_logic
			);
	end component pixelGenerator;

	component VGA_SYNC is
		port(
				clock_50Mhz										: in std_logic;
				horiz_sync_out, vert_sync_out, 
				video_on, pixel_clock, eof						: out std_logic;												
				pixel_row, pixel_column						    : out std_logic_vector(9 downto 0)
			);
	end component VGA_SYNC;
	
	component pulse_generator is
    port (
        clk     : in  std_logic; 
        rst_n   : in  std_logic;
        pulse   : out std_logic
    );
	end component pulse_generator;
	
	component tank is
   port(
        rst_n     : in std_logic; 
        pulse     : in std_logic;
		  speed		: in std_logic_vector(1 downto 0);
        tank_pos  : out std_logic_vector(9 downto 0);
		  clk 		: in std_logic
    );
	end component tank;
	
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
        is_active : out std_logic;
		  hit_detected : in std_logic;
		  clk				: in std_logic
   );
	end component bullet;
	
	component hit_detection is
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
		  clk 			  : in std_logic
   );
	end component hit_detection;
	
	component leddcd is
	port(
		  data_in : in std_logic_vector (3 downto 0);
		  segments_out : out std_logic_vector (6 downto 0)
	);
	end component;
	
	component de2lcd is
	PORT(reset, clk_50Mhz				: IN	STD_LOGIC;
		 LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
		 LCD_RW						: BUFFER STD_LOGIC;
		 DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		 display, write_choice : IN STD_LOGIC);
	end component;
	
	component ps2 is
	port( 	
			keyboard_clk, keyboard_data, clock_50MHz ,
			reset : in std_logic;--, read : in std_logic;
			scan_code : out std_logic_vector( 7 downto 0 );
			scan_readyo : out std_logic
	);
	end component ps2;
	

	--Signals for VGA sync
	signal pixel_row_int 										: std_logic_vector(9 downto 0);
	signal pixel_column_int 									: std_logic_vector(9 downto 0);
	signal video_on_int											: std_logic;
	signal VGA_clk_int											: std_logic;
	signal eof													   : std_logic;
	signal pulse												   : std_logic;
	signal red_tank_pos, blue_tank_pos						: std_logic_vector(9 downto 0);
	signal red_bull_x, red_bull_y								: std_logic_vector(9 downto 0);
	signal blue_bull_x, blue_bull_y								: std_logic_vector(9 downto 0);
	signal red_bull_int, blue_bull_int					   : std_logic;
	signal red_score, blue_score								: std_logic_vector(3 downto 0);
	signal red_hit_detected, blue_hit_detected			: std_logic;
	signal blue_win, red_win, someone_won					: std_logic;
	signal red_bull_act, blue_bull_act						: std_logic;
	signal scan2, scan3											: std_logic;
	signal scan_code2			 									: std_logic_vector( 7 downto 0 );
	signal red_tank_speed, blue_tank_speed					: std_logic_vector(1 downto 0);
	signal red_tank_fire, blue_tank_fire					: std_logic;
	signal scan_count												: unsigned (19 downto 0);
	

begin

--------------------------------------------------------------------------------------------

	lcdGen: de2lcd
		port map(RESET_N, CLOCK_50, lcd_rs, lcd_e, lcd_on, reset_led, sec_led, lcd_rw, data_bus, someone_won, red_win);
		
	keyboard: ps2
		port map(keyboard_clk, keyboard_data, CLOCK_50, RESET_N, scan_code2, scan2);

	videoGen : pixelGenerator
		port map(CLOCK_50, VGA_clk_int, RESET_N, video_on_int, eof, pixel_row_int, pixel_column_int, VGA_RED, VGA_GREEN, VGA_BLUE,
					blue_tank_pos, red_tank_pos, red_bull_act, red_bull_x, red_bull_y, blue_bull_act, blue_bull_x, blue_bull_y, blue_win, red_win);
	
	pulse_gen : pulse_generator
		port map(CLOCK_50, RESET_N, pulse);
		
	red_tank : tank
		port map(RESET_N, pulse, red_tank_speed, red_tank_pos, CLOCK_50);
		
	red_bullet : bullet
		port map(RESET_N, red_tank_fire, pulse, '1', red_tank_pos, "0000101001", red_bull_x, red_bull_y, red_bull_int, red_hit_detected, CLOCK_50);
		
	red_hit_detect : hit_detection
		port map(blue_bull_x, blue_bull_y, red_tank_pos, "0000000101", "0000101000", pulse, RESET_N, blue_bull_act,
					blue_hit_detected, blue_score(1 downto 0), blue_win, CLOCK_50);
		
	red_score(3 downto 2) <= "00";

	red_led : leddcd
		port map(red_score, red_led_out);
		
	blue_tank : tank
		port map(RESET_N, pulse, blue_tank_speed, blue_tank_pos, CLOCK_50);
		
	blue_bullet : bullet
		port map(RESET_N, blue_tank_fire, pulse, '0', blue_tank_pos, "0110110110", blue_bull_x, blue_bull_y, blue_bull_int, blue_hit_detected, CLOCK_50);
		
	blue_hit_detect : hit_detection
		port map(red_bull_x, red_bull_y, blue_tank_pos, "0110111000", "0111011001", pulse, RESET_N, red_bull_act,
					red_hit_detected, red_score(1 downto 0), red_win, CLOCK_50);
					
	blue_score(3 downto 2) <= "00";

	blue_led : leddcd
		port map(blue_score, blue_led_out);
		
	someone_won <= blue_win or red_win;
	
	blue_bull_act <= blue_bull_int and (not someone_won);
	
	red_bull_act <= red_bull_int and (not someone_won);
	
	process(CLOCK_50, RESET_N)
	begin
		if RESET_N = '0' then
			red_tank_speed <= "01";
			blue_tank_speed <= "01";
			red_tank_fire <= '1';
			blue_tank_fire <= '1';
		elsif rising_edge(CLOCK_50) then
			if scan2 = '1' then
				case scan_code2 is
					when "00011100" => 
					   red_tank_speed <= "01";
					when "00011011" => 
					   red_tank_speed <= "10";
					when "00100011" => 
					   red_tank_speed <= "11"; 
					when "01101011" =>  
					   blue_tank_speed <= "01"; 
					when "01110011" =>
					   blue_tank_speed <= "10";
					when "01110100" =>
					   blue_tank_speed <= "11";
					when "00011101" =>
					   red_tank_fire <= '0';
					when "01110101" =>
					   blue_tank_fire <= '0';
					when others => 
						red_tank_speed <= red_tank_speed;
						blue_tank_speed <= blue_tank_speed;
						red_tank_fire <= '1';
						blue_tank_fire <= '1';
				end case;
			else
				red_tank_speed <= red_tank_speed;
				blue_tank_speed <= blue_tank_speed;
				red_tank_fire <= '1';
				blue_tank_fire <= '1';
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------------------
--This section should not be modified in your design.  This section handles the VGA timing signals
--and outputs the current row and column.  You will need to redesign the pixelGenerator to choose
--the color value to output based on the current position.

	videoSync : VGA_SYNC
		port map(CLOCK_50, HORIZ_SYNC, VERT_SYNC, video_on_int, VGA_clk_int, eof, pixel_row_int, pixel_column_int);	

	VGA_BLANK <= video_on_int;

	VGA_CLK <= VGA_clk_int;

--------------------------------------------------------------------------------------------	

end architecture structural;