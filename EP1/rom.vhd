library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom is
    generic (
        addressSize : natural := 64;
        wordSize : natural := 32;
        mifFileName : string := "rom.dat"
    );
    port (
        addr : in bit_vector(addressSize - 1 downto 0);
        data : out bit_vector(wordSize - 1 downto 0)
    );
end entity rom;

architecture rom_arch of rom is
    constant depth : natural := 2**addressSize;
    type mem_t is array (0 to depth - 1) of bit_vector(wordSize - 1 downto 0);

    impure function init_mem(fileName : in string) return mem_t is
        file mifFile : text open read_mode is fileName;
        variable mifLine : line;
        variable temp_bv : bit_vector(wordSize - 1 downto 0);
        variable temp_mem : mem_t;
        variable it : natural := 0;
    begin
        while not endfile(mifFile) loop
            readline(mifFile, mifLine);
            read(mifLine, temp_bv);
            temp_mem(it) := temp_bv;
            it := it + 1;
        end loop;
        return temp_mem;
    end function init_mem;

    constant memory : mem_t := init_mem(mifFileName);
begin
    data <= memory(to_integer(unsigned(addr)));
end architecture rom_arch;
