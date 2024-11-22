----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Updated Date: 01/11/2021
-- Design Name: CONTROLLER FOR THE CPU
-- Module Name: cpu - behavioral(controller)
-- Description: CPU_LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 5.01 - File Modified by Timmy Ifidon (November 21, 2024)
-- Additional Comments:
--*********************************************************************************
-- The controller implements the states for each instructions and asserts appropriate control signals for the datapath during every state.
-- For detailed information on the opcodes and instructions to be executed, refer the lab manual.
-----------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controller IS
    PORT( clock          : IN STD_LOGIC
        ; reset          : IN STD_LOGIC
        ; enter          : IN STD_LOGIC
        ; zero_flag      : IN STD_LOGIC
        ; sign_flag      : IN STD_LOGIC
        ; of_flag        : IN STD_LOGIC
        ; immediate_data : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; mux_sel        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        ; acc_mux_sel    : OUT STD_LOGIC
        ; alu_mux_sel    : OUT STD_LOGIC
        ; acc0_write     : OUT STD_LOGIC
        ; acc1_write     : OUT STD_LOGIC
        ; rf_address     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        ; rf_write       : OUT STD_LOGIC
        ; rf_mode        : OUT STD_LOGIC
        ; alu_sel        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; shift_amt      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; output_en      : OUT STD_LOGIC
        ; PC_out         : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        ; OPCODE_output  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        ; done           : OUT STD_LOGIC
        );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- Instructions and their opcodes (pre-decided)
    CONSTANT OPCODE_LDI  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT OPCODE_STA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT OPCODE_INC  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT OPCODE_NOT  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111"; -- left for implementation
    -- BIT WISE NOT ON ACC0
    CONSTANT OPCODE_XCHG : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100"; -- left for implementation
    -- SWAP REGISTER AND ACC W SIMD EXTENSION
    CONSTANT OPCODE_LDA  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT OPCODE_ADD  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT OPCODE_SUB  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT OPCODE_SHFL : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    CONSTANT OPCODE_DEC  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    CONSTANT OPCODE_AND  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
    CONSTANT OPCODE_JMPZ : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
    CONSTANT OPCODE_OUTA : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    
    CONSTANT OPCODE_HALT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    TYPE state_type IS ( STATE_FETCH
                       , STATE_DECODE
                       , STATE_LDI
                       , STATE_STA
                       , STATE_INC
                       , STATE_HALT
                       , STATE_JMPZ
                       , STATE_DEC
                       , STATE_ADD
                       , STATE_SUB
                       , OPCODE_SHFL
                       , OPCODE_AND
                       , OPCODE_NOT
                       , OPCODE_XCHG
                       );

    SIGNAL state : state_type;
    SIGNAL IR    : STD_LOGIC_VECTOR(15 DOWNTO 0); -- instruction register
    SIGNAL PC    : INTEGER RANGE 0 TO 31 := 0;    -- program counter
    SIGNAL SIMD  : STD_LOGIC;
    -- program memory that will store the instructions sequentially from part 1 and part 2 test program
    -- TYPE PM_BLOCK IS ARRAY(0 TO 33) OF STD_LOGIC_VECTOR(16 DOWNTO 0);
    TYPE PM_BLOCK IS ARRAY(0 TO 31) OF STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    --opcode is kept up-to-date
    -- OPCODE_output <= IR(3 DOWNTO 0);
    -- SIMD <= IR(14);
    OPCODE_output <= IR(7 DOWNTO 4);
    SIMD <= IR(15);

    PROCESS (clock, reset)
    -- PROCESS (reset)
        -- "PM" is the program memory that holds the instructions to be executed by the CPU 
        VARIABLE PM     : PM_BLOCK;

        -- To STATE_DECODE the 4 MSBs from the PC content
        VARIABLE OPCODE : STD_LOGIC_VECTOR(3 DOWNTO 0);

    BEGIN
        IF (reset = '1') THEN -- RESET initializes all the control signals to 0.
            PC             <= 0;
            IR             <= (OTHERS => '0');
            PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
            mux_sel        <= "00";
            alu_mux_sel    <= '0';
            acc_mux_sel    <= '0';
            immediate_data <= (OTHERS => '0');
            acc0_write     <= '0';
            acc1_write     <= '0';
            rf_address     <= "000";
            rf_write       <= '0';
            rf_mode        <= '0';
            alu_sel        <= "0000";
            output_en      <= '0';
            done           <= '0';
            shift_amt      <= "0000";
            state          <= STATE_DECODE;

            -- Test program for STA, LDI and INC
            PM(0)  := "0000110011010000"; -- JMPZ X"0C"
            PM(12) := "0000000001000000"; -- STA r[0]
            PM(13) := "0000000000100000"; -- LDI xBABA
            PM(14) := "1011101010111010"; -- xBABA
            PM(15) := "0001000111010000"; -- JMPZ X"11"
            PM(17) := "0000000010010000"; -- INC

            PM(23) := "0000000011110000"; -- HALT
            --
            
        ELSIF RISING_EDGE(clock) THEN
            CASE state IS

                WHEN STATE_FETCH     => -- FETCH instruction
                    IF enter = '1' THEN
                        PC_out         <= STD_LOGIC_VECTOR(to_unsigned(PC, PC_out'length));
                        mux_sel        <= "00";
                        alu_mux_sel    <= '0';
                        acc_mux_sel    <= '0';
                        immediate_data <= (OTHERS => '0');
                        acc0_write     <= '0';
                        acc1_write     <= '0';
                        rf_address     <= "000";
                        rf_write       <= '0';
                        rf_mode        <= '0';
                        alu_sel        <= "0000";
                        shift_amt      <= "0000";
                        done           <= '0';
                        IR             <= PM(PC); 
                        PC             <= PC+1; 
                        output_en      <= '0';
                        state          <= STATE_DECODE;
                        ELSIF  enter = '0' THEN
                        state <= STATE_FETCH;
                    END IF;

                WHEN STATE_DECODE    => -- DECODE instruction

                    -- OPCODE := IR(3 DOWNTO 0);
                    OPCODE := IR(7 DOWNTO 4);

                    CASE OPCODE IS
                        WHEN OPCODE_LDI => state <= STATE_LDI;
                        WHEN OPCODE_STA => state <= STATE_STA;
                        WHEN OPCODE_INC => state <= STATE_INC;
                        WHEN OPCODE_JMPZ=> state <= STATE_JMPZ;
                        WHEN OPCODE_DEC => state <= STATE_DEC;
                        WHEN OPCODE_ADD => state <= STATE_ADD;
                        WHEN OPCODE_SUB => state <= STATE_SUB;
                        WHEN OPCODE_SHFL=> state <= STATE_SHFL;
                        WHEN OPCODE_AND => state <= STATE_AND;
                        WHEN OPCODE_OUTA=> state <= STATE_OUTA;
                        WHEN OPCODE_NOT => state <= STATE_NOT;
                        WHEN OPCODE_XCHG=> state <= STATE_XCHG;
                        WHEN OTHERS     => state <= STATE_HALT;
                    END CASE;

                    -----------------------------
                    -- multiplexer set up
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    -----------------------------
                    -- accumulator setup
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    -----------------------------
                    -- register file setup
                    rf_address     <= IR(2 DOWNTO 0); -- decode pre-emptively sets up the register file
                    rf_write       <= '0';
                    -- rf_mode        <= IR(14); -- SIMD mode
                    rf_mode        <= IR(15); -- SIMD mode
                    -----------------------------
                    -- ALU setup
                    alu_sel        <= "0000";
                    shift_amt      <= IR(3 DOWNTO 0);
                    -----------------------------
                    immediate_data <= PM(PC); -- pre-fetching immediate data
                    output_en      <= '0';
                    done           <= '0';

                WHEN STATE_LDI       => -- LDI exceute
                    mux_sel        <= "10";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= PM(PC);
                    acc0_write     <= '1';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    shift_amt      <= "0000";
                    output_en      <= '0';
                    done           <= '0';
                    PC             <= PC + 1;
                    state          <= STATE_FETCH;
                WHEN STATE_LDA       => -- LDA execute
                    mux_sel        <= "01"; -- RF0 out
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= (OTHERS => '0'); -- NOT USED
                    acc0_write     <= '1';
                    acc1_write     <= SIMD; 
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0001"; -- PASS A
                    shift_amt      <= "0000";
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_STA       => -- STA exceute
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    alu_sel        <= "0000";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    rf_write       <= '1';
                    rf_mode        <= SIMD;
                    acc_mux_sel    <= '0'; -- ACC 0
                    alu_mux_sel    <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_ADD       => -- ADD execute
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '1'; -- store alu0 in acc0
                    acc1_write     <= SIMD; -- store alu1 in acc1
                    alu_sel        <= "0101"; -- ADD
                    shift_amt      <= "0000";
                    mux_sel        <= "00"; -- ALU0
                    rf_write       <= '0';
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1'; -- ACC0
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_SHFL      =>
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '1';  -- store alu0 in acc0
                    acc1_write     <= 0; 
                    alu_sel        <= "1000"; -- SHIFT LEFT 
                    shift_amt      <= IR(3 DOWNTO 0);
                    mux_sel        <= "00"; -- ALU0
                    rf_write       <= '0'; 
                    acc_mux_sel    <= '0'; 
                    alu_mux_sel    <= '1'; -- ACC0
                    output_en      <= '0'; 
                    done           <= '0'; 
                    state          <= STATE_FETCH;
                WHEN STATE_SUB       =>
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '1';  -- store alu0 in acc0
                    acc1_write     <= SIMD; -- store alu1 in acc1
                    alu_sel        <= "0110"; -- SUB
                    mux_sel        <= "00"; -- ALU0
                    rf_write       <= '0'; 
                    acc_mux_sel    <= '0'; 
                    alu_mux_sel    <= '1'; -- ACC0
                    output_en      <= '0'; 
                    done           <= '0'; 
                    state          <= STATE_FETCH;
                WHEN STATE_INC       => -- INC execute
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0111";
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_DEC       => -- DEC execute
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "1000"; -- DEC
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1';
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    rf_address     <= "000";
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_AND       =>
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "1001"; -- DEC
                    shift_amt      <= "0000";
                    mux_sel        <= "00"; -- alu0
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1'; --ACC0
                    acc0_write     <= '1'; 
                    acc1_write     <= SIMD;
                    rf_address     <= "000"; 
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_OUTA       =>
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "0000"; -- NOT USED
                    shift_amt      <= "0000";
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0'; 
                    acc0_write     <= '0'; 
                    acc1_write     <= '0';
                    rf_address     <= "000"; 
                    rf_write       <= '0';
                    output_en      <= '1';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_JMPZ      => -- JPMZ execite
                    IF zero_flag = '1' THEN
                        PC             <= TO_INTEGER(UNSIGNED(IR(12 DOWNTO 8))); -- JUMP TO INSTRUCTION
                        -- IR             <= PM(PC); 
                    ELSE 
                        PC             <= PC + 1;
                    END IF;
                        mux_sel        <= "00";
                        alu_mux_sel    <= '0';
                        acc_mux_sel    <= '0';
                        immediate_data <= (OTHERS => '0');
                        acc0_write     <= '0';
                        acc1_write     <= '0';
                        rf_address     <= "000";
                        rf_write       <= '0';
                        rf_mode        <= '0';
                        alu_sel        <= "0000";
                        shift_amt      <= "0000";
                        done           <= '0'; 
                        output_en      <= '0';
                        state          <= STATE_FETCH;
                WHEN STATE_XCHG     =>
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '1';
                    acc1_write     <= SIMD;
                    alu_sel        <= "0001"; -- PASS A
                    shift_amt      <= "0000";
                    mux_sel        <= "01";
                    rf_write       <= '1';
                    rf_mode        <= SIMD;
                    acc_mux_sel    <= '1'; -- ACC 1
                    alu_mux_sel    <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN STATE_NOT      =>
                    immediate_data <= (OTHERS => '0');
                    alu_sel        <= "1100"; -- NOT B
                    shift_amt      <= "0000";
                    mux_sel        <= "00"; -- alu0
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '1'; --ACC0
                    acc0_write     <= '1'; 
                    acc1_write     <= '0';
                    rf_address     <= "000"; 
                    rf_write       <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;
                WHEN OTHERS =>
                    mux_sel        <= "00";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    output_en      <= '1';
                    done           <= '1';
                    state          <= STATE_HALT;

            END CASE;
        END IF;
    END PROCESS;

END Behavioral;