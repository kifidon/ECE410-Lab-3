----------------------------------------------------------------------------------
-- Filename : alu.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: alu_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the ALU of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 2.01 - File Modified by Timmy Ifidon (November 13, 2024)
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE sim OF alu_tb IS
    SIGNAL alu_sel   : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL input_a   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL input_b   : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL shift_amt : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
    SIGNAL alu_out   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL overflow  : STD_LOGIC := '0';
BEGIN

    uut : ENTITY WORK.alu16(Dataflow)
        PORT MAP( alu_sel     => alu_sel
                , A     => input_a
                , B     => input_b
                , shift_amt   => shift_amt
                , alu_out     => alu_out
                , overflow  => OVERFLOW
                );

        stim_proc : PROCESS
        BEGIN
        
        --------------TEST OVERFLOW ON SUB, INC AND DEC
            -- Test ALU operations:

            -- Direct output of input_a
            alu_sel <= "0001";          -- Select Pass A operation (4-bit selector)
            input_a <= "00000000" & "01100100";     -- Set input_a to some value
            input_b <= "00000000" & "00110011";     -- Set input_b to another value (doesn't matter for this operation)
            WAIT FOR 20 ns;            -- Wait for 20 ns to allow the operation to complete

            -- Check if the output matches input_a (since this is a Pass A operation)
            ASSERT (alu_out = input_a) 
                REPORT "Mismatch in alu_out value when Pass A is selected!" 
                SEVERITY ERROR;

            -- NAND operation (A AND B, then NOT the result)
            alu_sel <= "1001";  -- Use the AND operation, will test the not operator seperatly 
            input_a <= "00000000" & "01100100";  -- Input A
            input_b <= "00000000" & "00110011";  -- Input B
            WAIT FOR 20 ns;

            -- Assert the NAND result: A NAND B = NOT (A AND B)
            ASSERT (NOT alu_out = NOT (input_a AND input_b))
            REPORT "Mismatch in ALU output for NAND operation!"
            SEVERITY ERROR;

            -- Add cases for each ALU operation...
        --Pass B
            alu_sel <= "0010"; 
            input_a <= "00000000" & "01100100";  -- Input A
            input_b <= "00000000" & "00110011";  -- Input B
            WAIT FOR 20 ns;

            -- Check if the output matches input_b 
            ASSERT (alu_out = input_b) 
                REPORT "Mismatch in alu_out value when Pass B is selected!" 
                SEVERITY ERROR;

        -- Shift Left 
            alu_sel <= "0011";
            input_a <= X"0087";
            input_b <= X"0105";
            shift_amt <= X"4";
            WAIT FOR 20ns;

            -- check output matches shift a;
            ASSERT (alu_out = STD_LOGIC_VECTOR(shift_left(unsigned(input_a), to_integer(unsigned(shift_amt)))))
                REPORT "Mismatch in alu_out value on shift left of input_a"
                SEVERITY ERROR;
        -- Shift Right 
            alu_sel <= "0100";
            input_a <= X"0087";
            input_b <= X"0105";
            shift_amt <= X"4";
            WAIT FOR 20ns;

            -- check output matches shift right a;
            ASSERT (alu_out = STD_LOGIC_VECTOR(shift_right(unsigned(input_a), to_integer(unsigned(shift_amt)))))
                REPORT "Mismatch in alu_out value on shift right"
                SEVERITY ERROR;
            
        -- ADD
            input_a <= X"0055";
            input_b <= X"0133";
            alu_sel <= "0101";
            WAIT FOR 20ns;

            -- check output matches a + b;
            ASSERT (alu_out = STD_LOGIC_VECTOR(unsigned(input_a) + unsigned(input_b)))
                REPORT "Mismatch in alu_out value on ADD"
                SEVERITY ERROR;
         -- TESTING OVERFLOW
            input_a <= X"7FFF";
            input_b <= X"7ffF";
            alu_sel <= "0101";
            WAIT FOR 20ns;

            -- check output matches a + b;
            ASSERT (overflow = '1')
                REPORT "Mismatch in overflow value on ADD"
                SEVERITY ERROR;
                
        -- SUB
            input_a <= X"1087";
            input_b <= X"0032";
            alu_sel <= "0110";
            shift_amt <= X"0"; -- set to zero for the rest of the tests
            WAIT FOR 20ns;

            -- check output matches a - b;
            ASSERT (alu_out = STD_LOGIC_VECTOR(unsigned(input_a) - unsigned(input_b)))
                REPORT "Mismatch in alu_out value on SUB"
                SEVERITY ERROR;         
        -- TESTING NEGATIVE
            input_a <= X"000F";
            input_b <= X"00F0";
            alu_sel <= "0110";
            WAIT FOR 20ns;

            -- check output matches a + b;
            ASSERT (alu_out(15) = '1')
                REPORT "Mismatch in alu_out value on ADD"
                SEVERITY ERROR;
                
        -- INC
            input_a <= X"1087";
            input_b <= X"0105";
            alu_sel <= "0111";
            WAIT FOR 20ns;

            -- check output matches a + 1;
            ASSERT (alu_out =  STD_LOGIC_VECTOR(unsigned(input_a) + 1))
                REPORT "Mismatch in alu_out value on INC"
                SEVERITY ERROR;         
        -- DEC
            input_a <= X"1087";
            input_b <= X"0105";
            alu_sel <= "1000";
            WAIT FOR 20ns;

            -- check output matches a - 1;
            ASSERT (alu_out = STD_LOGIC_VECTOR(unsigned(input_a) - 1))
                REPORT "Mismatch in alu_out value on DEC"
                SEVERITY ERROR;         
                
        -- AND
            input_a <= X"0F0F";
            input_b <= X"0707";
            alu_sel <= "1001";

            WAIT FOR 20ns;

            -- check output matches a And b;
            ASSERT (alu_out = STD_LOGIC_VECTOR(unsigned(input_a) AND unsigned(input_b)))
                REPORT "Mismatch in alu_out value on AND"
                SEVERITY ERROR;   
                
        -- OR
            input_a <= X"0F0F";
            input_b <= X"F0F0";
            alu_sel <= "1010";
            WAIT FOR 20ns;

            -- check output matches a or b;
            ASSERT (alu_out = STD_LOGIC_VECTOR(unsigned(input_a) OR unsigned(input_b)))
                REPORT "Mismatch in alu_out value on OR"
                SEVERITY ERROR;  

        -- NOT A
            input_a <= X"0F0F";
            input_b <= X"F0F0";
            alu_sel <= "1011";
            WAIT FOR 20ns;

            -- check output matches not a;
            ASSERT (alu_out = NOT input_a)
                REPORT "Mismatch in alu_out value on NOT A"
                SEVERITY ERROR;  

        -- NOT B
            alu_sel <= "1100";
            input_a <= X"0F0F";
            input_b <= X"F0F0";
            WAIT FOR 20ns;

            -- check output matches not b;
            ASSERT (alu_out = NOT input_b)
                REPORT "Mismatch in alu_out value on NOT B"
                SEVERITY ERROR;  
                
        -- 1
            alu_sel <= "1101";
            input_a <= X"0F0F"; -- dont matter 
            input_b <= X"F0F0"; -- dont matter 
            WAIT FOR 20ns;

            -- check output matches 1;
            ASSERT (alu_out = X"0001")
                REPORT "Mismatch in alu_out value on 1"
                SEVERITY ERROR;  

        -- 0
            alu_sel <= "1110";
            input_a <= X"0F0F"; -- dont matter 
            input_b <= X"F0F0"; -- dont matter 
            WAIT FOR 20ns;

            -- check output matches 0;
            ASSERT (alu_out = X"0000")
                REPORT "Mismatch in alu_out value on 0"
                SEVERITY ERROR;  
            
        -- -1
            alu_sel <= "1111";
            input_a <= X"0F0F"; -- dont matter 
            input_b <= X"F0F0"; -- dont matter 
            WAIT FOR 20ns;

            -- check output matches 0;
            ASSERT (alu_out = X"FFFF")
                REPORT "Mismatch in alu_out value on -1"
                SEVERITY ERROR;  
                
            WAIT;
    END PROCESS stim_proc;

END sim;
