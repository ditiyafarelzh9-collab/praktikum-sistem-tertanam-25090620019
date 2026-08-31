library IEEE;
use IEEE.std_logic_1164.ALL;

entity led_switch_top is
    port ( sw : in std_logic_vector (15 downto 0);
        led : out std_logic_vector (15 downto 0));
end led_switch_top ;

architecture Behavioral of led_switch_top is
begin 
    led <= sw;
end Behavioral;