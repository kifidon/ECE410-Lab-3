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
    -- CONSTANT OPCODE_XXXX : STD_LOGIC_VECTOR(3 DOWNTO 0) := "XXXX"; -- left for implementation
    CONSTANT OPCODE_HALT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

    TYPE state_type IS ( STATE_FETCH
                       , STATE_DECODE
                       , STATE_LDI
                       , STATE_STA
                       , STATE_INC
                       , STATE_HALT
                       );

    SIGNAL state : state_type;
    SIGNAL IR    : STD_LOGIC_VECTOR(15 DOWNTO 0); -- instruction register
    SIGNAL PC    : INTEGER RANGE 0 TO 31 := 0;    -- program counter
    SIGNAL SIMD  : STD_LOGIC;
    -- program memory that will store the instructions sequentially from part 1 and part 2 test program
    TYPE PM_BLOCK IS ARRAY(0 TO 33) OF STD_LOGIC_VECTOR(16 DOWNTO 0);

BEGIN

    --opcode is kept up-to-date
    OPCODE_output <= IR(3 DOWNTO 0);
    SIMD <= IR(14);

    PROCESS (reset)
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
            PM(13) := "0000000000100000"; -- LDI xBABA
            PM(14) := "1011101010111010"; -- xBABA
            PM(12) := "0000000001000000"; -- STA r[0]
            PM(17) := "0000000010010000"; -- INC
            PM(23) := "0000000011110000"; -- HALT

        ELSIF RISING_EDGE(clock) THEN
            CASE state IS

                WHEN STATE_FETCH => -- FETCH instruction
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
                        -- PC             <= ???;
                        -- IR             <= ???;
                        output_en      <= '0';
                        state          <= STATE_DECODE;
                    ELSIF  enter = '0' THEN
                        state <= STATE_FETCH;
                    END IF;

                WHEN STATE_DECODE => -- DECODE instruction

                    OPCODE := IR(3 DOWNTO 0);

                    CASE OPCODE IS
                        WHEN OPCODE_LDI => state <= STATE_LDI;
                        WHEN OPCODE_STA => state <= STATE_STA;
                        WHEN OPCODE_INC => state <= STATE_INC;
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
                    rf_mode        <= IR(14); -- SIMD mode
                    -----------------------------
                    -- ALU setup
                    alu_sel        <= "0000";
                    shift_amt      <= IR(3 DOWNTO 0);
                    -----------------------------
                    immediate_data <= PM(PC); -- pre-fetching immediate data
                    output_en      <= '0';
                    done           <= '0';

                WHEN STATE_LDI => -- LDI exceute
                    mux_sel        <= "10";
                    acc_mux_sel    <= '0';
                    alu_mux_sel    <= '0';
                    immediate_data <= PM(PC);
                    acc0_write     <= '1';
                    acc1_write     <= '0';
                    rf_address     <= "000";
                    rf_write       <= '0';
                    alu_sel        <= "0000";
                    output_en      <= '0';
                    done           <= '0';
                    PC             <= PC + 1;
                    state          <= STATE_FETCH;

                WHEN STATE_STA            => -- STA exceute
                    immediate_data <= (OTHERS => '0');
                    acc0_write     <= '0';
                    acc1_write     <= '0';
                    alu_sel        <= "0000";
                    mux_sel        <= "00";
                    rf_write       <= '1';
                    acc_mux_sel    <= '1';
                    alu_mux_sel    <= '0';
                    output_en      <= '0';
                    done           <= '0';
                    state          <= STATE_FETCH;

                WHEN STATE_INC            =>
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