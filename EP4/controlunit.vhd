library ieee;
use ieee.numeric_bit.all;

entity controlunit is
    port (
        -- To Datapath
        reg2loc      : out bit;
        uncondBranch : out bit;
        branch       : out bit;
        memRead      : out bit;
        memToReg     : out bit;
        aluOp        : out bit_vector(1 downto 0);
        memWrite     : out bit;
        aluSrc       : out bit;
        regWrite     : out bit;

        -- From Datapath
        opcode : in bit_vector(10 downto 0)
    );
end entity controlunit;

architecture controlunit_arch of controlunit is
    constant LDUR_OP : bit_vector(10 downto 0) := "11111000010";
    constant STUR_OP : bit_vector(10 downto 0) := "11111000000";
    constant CBZ_OP  : bit_vector(07 downto 0) := "10110100";
    constant B_OP    : bit_vector(05 downto 0) := "000101";
    constant ADD_OP  : bit_vector(10 downto 0) := "10001011000";
    constant SUB_OP  : bit_vector(10 downto 0) := "11001011000";
    constant AND_OP  : bit_vector(10 downto 0) := "10001010000";
    constant ORR_OP  : bit_vector(10 downto 0) := "10101010000";
begin
    reg2loc      <= '0' when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP else
                    '1' when opcode = STUR_OP or opcode(10 downto 3) = CBZ_OP;
    uncondBranch <= '1' when opcode(10 downto 5) = B_OP else
                    '0';
    branch       <= '0' when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP or opcode = STUR_OP or opcode = LDUR_OP else
                    '1' when opcode(10 downto 3) = CBZ_OP;
    memRead      <= '1' when opcode = LDUR_OP else
                    '0';
    memToReg     <= '0' when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP else
                    '1' when opcode = LDUR_OP;
    aluOp        <= "00" when opcode = STUR_OP or opcode = LDUR_OP else
                    "01" when opcode(10 downto 5) = B_OP or opcode(10 downto 3) = CBZ_OP else
                    "10" when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP;
    memWrite     <= '1' when opcode = STUR_OP else
                    '0';
    aluSrc       <= '0' when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP or opcode(10 downto 3) = CBZ_OP else
                    '1' when opcode = STUR_OP or opcode = LDUR_OP;
    regWrite     <= '0' when opcode(10 downto 5) = B_OP or opcode(10 downto 3) = CBZ_OP OR opcode = STUR_OP else
                    '1' when opcode = ADD_OP or opcode = SUB_OP or opcode = ORR_OP or opcode = AND_OP or opcode = LDUR_OP;
end architecture controlunit_arch;
