library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;


entity regfile is
    generic(
        regn : natural := 32;
        wordSize: natural := 64
    );
    port(
        clock:        in  bit; --! entrada de clock
        reset:        in  bit; --! clear assincrono
        regWrite:     in  bit;
        rr1, rr2, wr: in  bit_vector(natural(ceil(log2(real(regn)))) - 1 downto 0);
        d:            in  bit_vector(wordSize - 1 downto 0); --! entrada
        q1, q2:       out bit_vector(wordSize - 1 downto 0)  --! saida
    );
end regfile;

architecture regfile_arch of regfile is
    type regfile_t is array(0 to regn - 1) of bit_vector(wordSize - 1 downto 0);

    signal regs : regfile_t := (others => (others => '0'));
begin
    regfile_process : process(clock, reset)
    begin
        if (reset = '1') then
            regs <= (others => (others => '0'));
        elsif (rising_edge(clock)) then
            if (regWrite = '1') then
                if (to_integer(unsigned(wr)) /= regn - 1) then
                    regs(to_integer(unsigned(wr))) <= d;
                end if;
            end if;
        end if;
    end process regfile_process;

    q1 <= regs(to_integer(unsigned(rr1)));
    q2 <= regs(to_integer(unsigned(rr2)));

end architecture regfile_arch;
