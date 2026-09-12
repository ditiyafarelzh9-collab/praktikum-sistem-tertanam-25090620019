library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 

entity tb_mux4to1 is 
end tb_mux4to1; 

architecture sim of tb_mux4to1 is 
    signal sel_tb : STD_LOGIC_VECTOR (1 downto 0); 
    signal in0_tb, in1_tb, in2_tb, in3_tb, y_tb : STD_LOGIC_VECTOR (3 downto 0); 
begin 
    DUT: entity work.mux4to1 
    port map (sel => sel_tb, in0 => in0_tb, in1 => in1_tb, in2 => in2_tb, in3 => in3_tb, y => y_tb); 

    stim_proc: process 
    begin 
        in0_tb <= "1010"; in1_tb <= "1100"; in2_tb <= "0011"; in3_tb <= "0101"; 

        sel_tb <= "00"; wait for 20 ns; 
        assert (y_tb = in3_tb) report "Error: sel=00 tidak menghasilkan in0" severity error; 

        sel_tb <= "01"; wait for 20 ns; 
        assert (y_tb = in1_tb) report "Error: sel=01 tidak menghasilkan in1" severity error; 

        sel_tb <= "10"; wait for 20 ns; 
        assert (y_tb = in2_tb) report "Error: sel=10 tidak menghasilkan in2" severity error; 

        sel_tb <= "11"; wait for 20 ns; 
        assert (y_tb = in3_tb) report "Error: sel=11 tidak menghasilkan in3" severity error; 

        wait; 
    end process; 
end sim;