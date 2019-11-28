-------------------------------------------------------
--! @file memorias.vhd
--! @brief TB para memorias em VHDL
--! @author Bruno Albertini (balbertini@usp.br)
--! @date 20190606
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity memorias_tb is
end memorias_tb;

architecture testbench of memorias_tb is
  component ram is
    generic(
      address_size : natural;
      word_size    : natural
    );
    port(
      ck, wr : in  bit;
      addr   : in  bit_vector(address_size-1 downto 0);
      data_i : in  bit_vector(word_size-1 downto 0);
      data_o : out bit_vector(word_size-1 downto 0)
    );
  end component;
  -- sinais de suporte
  signal address: bit_vector(4 downto 0);
  signal data_in, data_out : bit_vector(3 downto 0);
  signal stopc, clk, wrt: bit := '0';
  -- Periodo do clock
  constant periodo : time := 10 ns;
begin
  -- Geração de clock
  clk <= stopc and (not clk) after periodo/2;
  -- Instâncias a serem testada
  dut_ram: ram generic map(5,4) port map(clk, wrt, address, data_in, data_out);
  -- Estímulos
  stim: process
    variable addr_tmp: bit_vector(4 downto 0);
  begin
    stopc <= '1';
    wrt <='0';
    --! Escrevendo um padrão na RAM
    for i in 0 to 31 loop
      addr_tmp := bit_vector(to_unsigned(i,5));
      data_in <= addr_tmp(3 downto 0);
      address <= addr_tmp;
      wrt<='1';
      wait until rising_edge(clk);
      wrt<='0';
    end loop;
    --! Lendo todas as memórias
    for i in 0 to 31 loop
      address <= bit_vector(to_unsigned(i,5));
      wait for 1 ns;

      assert data_out = address(3 downto 0)
        report "Erro";

    end loop;
    stopc <= '0';
    wait;
  end process;
end architecture;