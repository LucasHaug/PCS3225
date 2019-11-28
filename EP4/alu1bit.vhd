library ieee;
use ieee.numeric_bit.all;

entity alu1bit is
    port(
        a, b, less, cin: in bit;
        result, cout, set, overflow: out bit;
        ainvert, binvert: in bit;
        operation : in bit_vector(1 downto 0)
    );
end entity alu1bit;

architecture alu1bit_arch of alu1bit is
    signal a_input : bit := '0';
    signal b_input : bit := '0';

    signal carry_out : bit := '0';
begin
    a_input <= a xor ainvert;
    b_input <= b xor binvert;

    carry_out <= (a_input and b_input) or (a_input and cin) or (b_input and cin);

    with operation select result <=
        a_input and b_input when "00", -- AND
        a_input or b_input when "01", -- OR
        (a_input xor b_input) xor cin when "10", -- ADD
        less when "11"; -- SLT

    set <= (a_input xor b_input) xor cin;

    cout <= carry_out;

    overflow <= carry_out xor cin;
end architecture alu1bit_arch;
