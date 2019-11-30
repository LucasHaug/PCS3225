library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i : in  bit_vector(31 downto 0); -- input
        o : out bit_vector(63 downto 0) -- output
    );
end entity signExtend;

architecture signExtend_arch of signExtend is
begin
    with i(31 downto 30) select o <=
        bit_vector(resize(signed(i(25 downto  0)), o'length)) when "00", -- CBZ
        bit_vector(resize(signed(i(23 downto  5)), o'length)) when "10", -- B
        bit_vector(resize(signed(i(20 downto 12)), o'length)) when "11", -- LDUR and STUR
        (others => '0') when others;
end architecture signExtend_arch;
