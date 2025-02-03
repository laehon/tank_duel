library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity bram is
    port (
        q       : out std_logic_vector(1 downto 0);
        d       : in std_logic_vector(1 downto 0);
        x_in, y_in : in std_logic_vector(9 downto 0);
        x_out, y_out : in std_logic_vector(9 downto 0);
        we      : in std_logic;
        clk     : in std_logic
    );
end bram;

architecture rtl of bram is
    type mem_type is array (0 to 307199) of std_logic_vector(1 downto 0);
    signal mem : mem_type;
    signal addr_rd, addr_wr : unsigned(19 downto 0);
    signal rd_x, rd_y : std_logic_vector(9 downto 0);

    attribute ram_style : string;
    attribute ram_style of mem : signal is "block";
begin

    addr_rd <= unsigned(rd_y) * 640 + unsigned(rd_x);
    addr_wr <= unsigned(y_in) * 640 + unsigned(x_in);

    process (clk)
    begin
        if rising_edge(clk) then
            rd_x <= x_out;
            rd_y <= y_out;
            
            q <= mem(to_integer(addr_rd));
            
            if (we = '1') then
                mem(to_integer(addr_wr)) <= d;
            end if;
        end if;
    end process;

end rtl;
