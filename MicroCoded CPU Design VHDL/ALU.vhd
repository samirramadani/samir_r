library IEEE;
use IEEE.std_logic_1164.all;
library lpm;
use lpm.lpm_components.all;

entity exp7_ALU is
port (a, b: in std_logic_vector(7 downto 0);
op: in std_logic_vector(0 downto 0);   
result: out std_logic_vector(7 downto 0));
end exp7_ALU;

architecture structural of exp7_ALU is
signal add_result, and_result: std_logic_vector(7 downto 0);
signal mux_data: std_logic_2D(1 downto 0, 7 downto 0);
begin
ALU_adder: lpm_add_sub
generic map (lpm_width=>8)
port map (dataa=>a, datab=>b, result=>add_result);
and_result<= a and b;
for_label: for i in 7 downto 0 generate
mux_data(0,i) <= add_result(i);
mux_data(1,i) <= and_result(i);
end generate;
ALU_mux: lpm_mux
generic map (lpm_width=>8, lpm_size=>2, lpm_widths=>1)
port map (data=>mux_data, result=>result, sel=>op);
end structural;
