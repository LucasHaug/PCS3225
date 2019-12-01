library ieee;
use ieee.numeric_bit.all;

entity alucontrol is
    port (
        aluop   : in  bit_vector(1 downto 0);
        opcode  : in  bit_vector(10 downto 0);
        aluCtrl : out bit_vector(3 downto 0)
    );
end entity alucontrol;

architecture alucontrol_arch of alucontrol is
begin
    aluCtrl <=
        "0010" when (aluop = "00") else -- LDUR and STUR
        "0111" when (aluop = "01") else -- CBZ
        "0010" when (aluop = "10") and (opcode = "10001011000") else -- ADD
        "0110" when (aluop = "10") and (opcode = "11001011000") else -- SUB
        "0000" when (aluop = "10") and (opcode = "10001010000") else -- AND
        "0001" when (aluop = "10") and (opcode = "10101010000");-- ORR
end architecture alucontrol_arch;
