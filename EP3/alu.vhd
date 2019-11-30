library ieee;
use ieee.numeric_bit.all;

entity alu is
    generic(
        size : natural := 10 -- bit size
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
