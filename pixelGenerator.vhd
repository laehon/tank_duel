library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 		   : in std_logic;
			pixel_row, pixel_column						   : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
			blue_tank, red_tank                       : in std_logic_vector(9 downto 0);
			red_bull_act										: in std_logic;
			red_bull_x, red_bull_y							: in std_logic_vector(9 downto 0);
			blue_bull_act										: in std_logic;
			blue_bull_x, blue_bull_y						: in std_logic_vector(9 downto 0);
			blue_win, red_win									: in std_logic
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

	constant color_red 	 	 : std_logic_vector(1 downto 0) := "01";
	constant color_blue 	 : std_logic_vector(1 downto 0) := "10";
	constant color_black 	 : std_logic_vector(1 downto 0) := "00";
	constant color_white	 : std_logic_vector(1 downto 0) := "11";
		
	component bram is
		port (
			q : out std_logic_vector(1 downto 0);
			d : in std_logic_vector(1 downto 0);
			x_in, y_in : in std_logic_vector(9 downto 0);
			x_out, y_out : in std_logic_vector(9 downto 0);
			we : in std_logic;
			clk : in std_logic
		);
	end component bram;

	signal color, input_color : std_logic_vector (1 downto 0);
	signal bram_we : std_logic;
	signal xin, yin : unsigned (9 downto 0);

begin
	
	
	bram_inst : bram
   port map (
		q => color,
		d => input_color,
		x_in => std_logic_vector(xin),
		y_in => std_logic_vector(yin),
		x_out => pixel_column(9 downto 0),     
		y_out => pixel_row(9 downto 0), 
		we => '1',
		clk => clk
   );
--------------------------------------------------------------------------------------------
	
	pixelDraw : process(clk) is
	begin
		if (rising_edge(clk)) then
		
			red_out <= "00000000";
			green_out <= "00000000";
			blue_out <= "00000000";
			
			if (color = color_red) then
				red_out <= "11111111";
			elsif (color = color_blue) then
				blue_out <= "11111111";
			elsif (color = color_white) then
				red_out <= "11111111";
				blue_out <= "11111111";
				green_out <= "11111111";
			end if;
		end if;
	end process pixelDraw;	
	
	bramDraw_clock : process(clk) is
	begin
		if rising_edge(clk) then
			xin <= xin + 1;
			if (xin > 639) then
				xin <= (others => '0');
				yin <= yin + 1;
			end if;
			if (yin > 479) then
				yin <= (others => '0');
			end if;
		end if;
	end process bramDraw_clock;
	
	bramDraw_comb : process(xin, yin) is
	begin

		if (yin < 40) and (yin > 5) and (xin > (unsigned(red_tank) - 35)) and (xin < (unsigned(red_tank) + 35) and blue_win = '0') then
			input_color <= color_red;
		elsif
			(yin > 440) and (yin < 473) and (xin > (unsigned(blue_tank) - 35)) and (xin < (unsigned(blue_tank) + 35) and red_win = '0') then
			input_color <= color_blue;
		elsif (red_bull_act = '1') and (xin > (unsigned(red_bull_x) - 3)) and (xin < (unsigned(red_bull_x) + 3)) and
				(yin > (unsigned(red_bull_y) - 3)) and (yin < (unsigned(red_bull_y) + 3)) then
			input_color <= color_white;
		elsif (blue_bull_act = '1') and (xin > (unsigned(blue_bull_x) - 3)) and (xin < (unsigned(blue_bull_x) + 3)) and
				(yin > (unsigned(blue_bull_y) - 3)) and (yin < (unsigned(blue_bull_y) + 3)) then
			input_color <= color_white;
		else
			input_color <= color_black;
		end if;
	end process bramDraw_comb;


--------------------------------------------------------------------------------------------
	
end architecture behavioral;		