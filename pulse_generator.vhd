library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_generator is
    port (
        clk     : in  std_logic; 
        rst_n   : in  std_logic;
        pulse   : out std_logic
    );
end entity pulse_generator;

architecture behavioral of pulse_generator is

    signal count : unsigned(19 downto 0);

begin

    process (clk, rst_n)
    begin
        if rst_n = '0' then
            count <= (others => '0'); 
            pulse <= '0'; 
        elsif rising_edge(clk) then
				count <= count + 1;
            if count = 0 then
                pulse <= '1';
            else
                pulse <= '0';
            end if;
        end if;
    end process;

end architecture behavioral;
