-- Aluno: Lucas Haug
-- Número USP: 10773565
-- Trabalho final da disciplina PCS3225

-------------------------------- Shift Left 2 --------------------------------

library ieee;
use ieee.numeric_bit.all;

entity shift_left_2 is
    generic(word_size : natural := 64);
    port(
        input_to_be_shifted : in  bit_vector(word_size - 1 downto 0);
        shifted_output      : out bit_vector(word_size - 1 downto 0)
    );
end entity shift_left_2;

architecture shift_left_2_arch of shift_left_2 is
begin
    shifted_output <= (input_to_be_shifted(word_size - 3 downto 0) & "00");
end architecture shift_left_2_arch;

-------------------------------- Mux 2 to 1 --------------------------------

library ieee;
use ieee.numeric_bit.all;

entity mux2 is
    generic(word_size : natural := 64);
    port(
        selector   : in  bit;
        input_zero : in  bit_vector(word_size - 1 downto 0);
        input_one  : in  bit_vector(word_size - 1 downto 0);
        choice     : out bit_vector(word_size - 1 downto 0)
    );
end entity mux2;

architecture mux2_arch of mux2 is
begin
    with selector select choice <=
        input_zero when '0',
        input_one  when '1';
end architecture mux2_arch;

-------------------------------- Register File --------------------------------

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

-------------------------------- ALU 1 bit --------------------------------

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
        b when "11"; -- B

    set <= (a_input xor b_input) xor cin;

    cout <= carry_out;

    overflow <= carry_out xor cin;
end architecture alu1bit_arch;

-------------------------------- Full ALU --------------------------------

library ieee;
use ieee.numeric_bit.all;

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

-------------------------------- Sign Extend --------------------------------

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

-------------------------------- ALU Control --------------------------------

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

-------------------------------- Control Unit --------------------------------

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

-------------------------------- PC --------------------------------

library ieee;
use ieee.numeric_bit.all;

entity PC is
    generic(wordSize: natural := 64);
    port(
        clock           : in  bit; --! entrada de clock
        reset           : in  bit; --! clear assincrono
        load            : in  bit; --! write enable (carga paralela)
        new_address     : in  bit_vector(wordSize - 1 downto 0); --! entrada
        current_address : out bit_vector(wordSize - 1 downto 0)  --! saida
    );
end entity PC;

architecture PC_arch of PC is
    signal address : bit_vector(wordSize - 1 downto 0) := (others => '0');
begin
    PC_process : process(clock, reset)
    begin
        if (reset = '1') then
            address <= (others => '0');
        elsif (rising_edge(clock)) then
            if (load = '1') then
                address <= new_address;
            end if;
        end if;
    end process PC_process;

    current_address <= address;
end architecture PC_arch;

-------------------------------- Datapath --------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity datapath is
    port(
        -- Common
        clock : in bit;
        reset : in bit;

        -- From Control Unit
        reg2loc  : in bit;
        pcsrc    : in bit;
        memToReg : in bit;
        aluCtrl  : in bit_vector(3 downto 0);
        aluSrc   : in bit;
        regWrite : in bit;

        -- To Control Unit
        opcode : out bit_vector(10 downto 0);
        zero   : out bit;

        -- IM interface
        imAddr : out bit_vector(63 downto 0);
        imOut  : in  bit_vector(31 downto 0);

        -- DM interface
        dmAddr : out bit_vector(63 downto 0);
        dmIn   : out bit_vector(63 downto 0);
        dmOut  : in  bit_vector(63 downto 0)
    );
end entity datapath ;

architecture datapath_arch of datapath is
    --------- Components ---------

    component regfile is
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
    end component regfile;

    component alu is
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
    end component alu;

    component signExtend is
        port (
            i : in  bit_vector(31 downto 0); -- input
            o : out bit_vector(63 downto 0) -- output
        );
    end component signExtend;

    component mux2 is
        generic(word_size : natural := 64);
        port(
            selector   : in  bit;
            input_zero : in  bit_vector(word_size - 1 downto 0);
            input_one  : in  bit_vector(word_size - 1 downto 0);
            choice     : out bit_vector(word_size - 1 downto 0)
        );
    end component mux2;

    component shift_left_2 is
        generic(word_size : natural := 64);
        port(
            input_to_be_shifted : in  bit_vector(word_size - 1 downto 0);
            shifted_output      : out bit_vector(word_size - 1 downto 0)
        );
    end component shift_left_2;

    component PC is
        generic(wordSize: natural := 64);
        port(
            clock           : in  bit; --! entrada de clock
            reset           : in  bit; --! clear assincrono
            load            : in  bit; --! write enable (carga paralela)
            new_address     : in  bit_vector(wordSize - 1 downto 0); --! entrada
            current_address : out bit_vector(wordSize - 1 downto 0)  --! saida
        );
    end component PC;

    --------- Signals ---------

    -- Registers

    signal reg1_addr      : bit_vector(04 downto 0) := (others => '0');
    signal reg2_addr      : bit_vector(04 downto 0) := (others => '0');
    signal reg_to_wr_addr : bit_vector(04 downto 0) := (others => '0');
    signal data_to_write  : bit_vector(63 downto 0) := (others => '0');
    signal reg1_data      : bit_vector(63 downto 0) := (others => '0');
    signal reg2_data      : bit_vector(63 downto 0) := (others => '0');

    -- Instruction

    signal instruction   : bit_vector(31 downto 0) := (others => '0');
    signal extended_addr : bit_vector(63 downto 0) := (others => '0');

    -- Main ALU

    signal main_alu_result  : bit_vector(63 downto 0) := (others => '0');
    signal main_alu_b_input : bit_vector(63 downto 0) := (others => '0');

    -- Branch ALU

    signal branch_alu_result  : bit_vector(63 downto 0) := (others => '0');
    signal branch_alu_b_input : bit_vector(63 downto 0) := (others => '0');

    -- PC

    signal current_pc_value : bit_vector(63 downto 0) := (others => '0');
    signal new_pc_value     : bit_vector(63 downto 0) := (others => '0');
    signal pc_plus_4        : bit_vector(63 downto 0) := (others => '0');
begin
    -- PC

    programm_counter : PC generic map (64) port map (clock, reset, '1', new_pc_value, current_pc_value);

    -- Register file

    registers_file : regfile generic map (32, 64) port map(clock, reset, regWrite, reg1_addr, reg2_addr, reg_to_wr_addr, data_to_write, reg1_data, reg2_data);

    -- Sign Extend

    dp_sign_extend : signExtend port map (instruction, extended_addr);

    -- Shift Left 2

    sl2: shift_left_2 generic map (64) port map (extended_addr, branch_alu_b_input);

    -- ULAs

    pc_adder   : alu generic map (64) port map(current_pc_value, X"0000000000000004", pc_plus_4, "0010", open, open, open);
    branch_alu : alu generic map (64) port map(current_pc_value, branch_alu_b_input, branch_alu_result, "0010", open, open, open);
    main_alu   : alu generic map (64) port map(reg1_data, main_alu_b_input, main_alu_result, aluCtrl, zero, open, open);

    -- Muxes

    pc_mux         : mux2 generic map (64) port map (pcsrc, pc_plus_4, branch_alu_result, new_pc_value);
    instr_mux      : mux2 generic map (5) port map (reg2loc, instruction(20 downto 16), instruction(4 downto 0), reg2_addr);
    mem_to_reg_mux : mux2 generic map (64) port map (memToReg, main_alu_result, dmOut, data_to_write);
    alu_mux        : mux2 generic map (64) port map (aluSrc, reg2_data, extended_addr, main_alu_b_input);

    -- Instruction

    instruction <= imOut;

    reg1_addr      <= instruction(9 downto 5);
    reg_to_wr_addr <= instruction(4 downto 0);

    imAddr <= current_pc_value;

    opcode <= ("10110100" & "000") when instruction(31 downto 24) = "10110100" else
              ("000101" & "00000") when instruction(31 downto 26) = "000101" else
              instruction(31 downto 21);

    -- Data Memory

    dmAddr <= main_alu_result;
    dmIn   <= reg2_data;

end architecture datapath_arch;

-------------------------------- PoliLEG --------------------------------

library ieee;
use ieee.numeric_bit.all;

entity polilegsc is
    port(
        clock, reset : in bit;

        -- Data Memory
        dmem_addr : out bit_vector(63 downto 0);
        dmem_dati : out bit_vector(63 downto 0);
        dmem_dato : in  bit_vector(63 downto 0);
        dmem_we   : out bit;

        -- Instruction Memory
        imem_addr : out bit_vector(63 downto 0);
        imem_data : in  bit_vector(31 downto 0)
    );
end entity polilegsc;

architecture polilegsc_arch of polilegsc is
    component datapath is
        port(
            -- Common
            clock : in bit;
            reset : in bit;

            -- From Control Unit
            reg2loc  : in bit;
            pcsrc    : in bit;
            memToReg : in bit;
            aluCtrl  : in bit_vector(3 downto 0);
            aluSrc   : in bit;
            regWrite : in bit;

            -- To Control Unit
            opcode : out bit_vector(10 downto 0);
            zero   : out bit;

            -- IM interface
            imAddr : out bit_vector(63 downto 0);
            imOut  : in bit_vector(31 downto 0);

            -- DM interface
            dmAddr : out bit_vector(63 downto 0);
            dmIn   : out bit_vector(63 downto 0);
            dmOut  : in bit_vector(63 downto 0)
        );
    end component datapath;

    component alucontrol is
        port (
            aluop   : in  bit_vector(1 downto 0);
            opcode  : in  bit_vector(10 downto 0);
            aluCtrl : out bit_vector(3 downto 0)
        );
    end component alucontrol;

    component controlunit is
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
    end component controlunit;

    -- Opcode

    signal opcode_pl       : bit_vector(10 downto 0) := (others => '0');

    -- ALU

    signal aluCtrl_pl      : bit_vector(3 downto 0) := (others => '0');
    signal aluOp_pl        : bit_vector(1 downto 0) := (others => '0');
    signal aluSrc_pl       : bit := '0';

    -- Registers

    signal reg2loc_pl      : bit := '0';
    signal regWrite_pl     : bit := '0';

    -- Memory

    signal memToReg_pl     : bit := '0';
    signal memRead_pl      : bit := '0';
    signal memWrite_pl     : bit := '0';

    -- Branch

    signal zero_pl         : bit := '0';
    signal branch_pl       : bit := '0';
    signal uncondBranch_pl : bit := '0';

    signal should_branch_because_zero : bit := '0';
    signal should_branch : bit := '0';

    -- PC

    signal pcsrc_pl        : bit := '0';

begin
    -- Datapath

    polileg_dp: datapath port map(clock, reset, reg2loc_pl, pcsrc_pl, memToReg_pl, aluCtrl_pl, aluSrc_pl, regWrite_pl, opcode_pl, zero_pl, imem_addr, imem_data, dmem_addr, dmem_dati, dmem_dato);

    -- Control Unit

    polileg_uc: controlunit port map(reg2loc_pl, uncondBranch_pl, branch_pl, memRead_pl, memToReg_pl, aluOp_pl, memWrite_pl, aluSrc_pl, regWrite_pl, opcode_pl);

    -- ALU Control

    polileg_alucontrol: alucontrol port map(aluOp_pl, opcode_pl, aluCtrl_pl);

    -- Data Memory Write Enable

    dmem_we <= '0' when memRead_pl = '1' else
               '1' when memWrite_pl = '1';

    -- Branch

    should_branch_because_zero <= branch_pl and zero_pl;
    should_branch <= uncondBranch_pl or should_branch_because_zero;
    pcSrc_pl <= should_branch;

end architecture polilegsc_arch;
