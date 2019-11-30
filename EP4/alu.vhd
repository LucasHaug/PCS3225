library ieee;
use ieee.numeric_bit.all;

-- ALU 1 bit

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
        b when "11"; -- B

    set <= (a_input xor b_input) xor cin;

    cout <= carry_out;

    overflow <= carry_out xor cin;
end architecture alu1bit_arch;

-- Full ALU

entity alu is
    generic(
        size : natural := 64 -- bit size
    );
    port(
        A, B : in  bit_vector(size - 1 downto 0); -- input
        F    : out bit_vector(size - 1 downto 0); -- output
        S    : in  bit_vector(3 downto 0); -- op selction
        Z    : out bit; -- zero flag
        Ov   : out bit; -- overflow
        Co   : out bit -- carry out
    );
end entity alu;

architecture alu_arch of alu is
    component alu1bit is
        port(
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation : in bit_vector(1 downto 0)
        );
    end component alu1bit;

    signal result : bit_vector(size - 1 downto 0) := (others => '0');
    signal cout   : bit_vector(size - 1 downto 0) := (others => '0');
    signal set    : bit_vector(size - 1 downto 0) := (others => '0');

    signal less   : bit := '0';
begin
    alu_gen: for i in (size - 1) downto 0 generate
        msb: if i = (size - 1) generate
            full_alu : alu1bit port map(A(i), B(i), '0', cout(i - 1), result(i), Co, set(i), Ov, S(3), S(2), S(1 downto 0));
        end generate;

        lsb: if i = 0 generate
            full_alu : alu1bit port map(A(i), B(i), less, S(2), result(i), cout(i), set(i), open, S(3), S(2), S(1 downto 0));
        end generate;

        middle_bits: if i > 0 and i < (size - 1) generate
            full_alu : alu1bit port map(A(i), B(i), '0', cout(i - 1), result(i), cout(i), set(i), open, S(3), S(2), S(1 downto 0));
        end generate;
    end generate alu_gen;

    F <= result;

    less <= set(size - 1);

    Z <= '1' when result = (result'range => '0') else '0';
end architecture alu_arch;
