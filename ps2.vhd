LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2 is
	port( 	keyboard_clk, keyboard_data, clock_50MHz ,
			reset : in std_logic;--, read : in std_logic;
			scan_code : out std_logic_vector( 7 downto 0 );
			scan_readyo : out std_logic
		);
end entity ps2;


architecture structural of ps2 is

component keyboard IS
	PORT( 	keyboard_clk, keyboard_data, clock_50MHz ,
			reset, read : IN STD_LOGIC;
			scan_code : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			scan_ready : OUT STD_LOGIC);
end component keyboard;

component oneshot is
port(
	pulse_out : out std_logic;
	trigger_in : in std_logic; 
	clk: in std_logic );
end component oneshot;

signal scan2 : std_logic;
signal scan_code2 : std_logic_vector( 7 downto 0 );
signal read : std_logic;

begin

u1: keyboard port map(	
				keyboard_clk => keyboard_clk,
				keyboard_data => keyboard_data,
				clock_50MHz => clock_50MHz,
				reset => reset,
				read => read,
				scan_code => scan_code2,
				scan_ready => scan2
			);

pulser: oneshot port map(
   pulse_out => read,
   trigger_in => scan2,
   clk => clock_50MHz
			);

scan_readyo <= scan2;
scan_code <= scan_code2;

end architecture structural;