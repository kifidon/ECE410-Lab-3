----------------------------------------------------------------------------------
-- Filename : mux2_tb.vhdl
-- Author : Timmy Ifidon
-- Date : 13-November 2024
-- Design Name: mux_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the mux_2 of the simple CPU
-- Revision 0.01 - File Created
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mux2_tb IS
END mux2_tb;

ARCHITECTURE sim OF mux2_tb IS

    -- Signals to connect to UUT
    SIGNAL mux_sel   : STD_LOGIC := '0';
    SIGNAL in0_s     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in1_s     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux_out   : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : ENTITY WORK.mux2(Dataflow)
        PORT MAP ( mux_sel => mux_sel,
                   in0     => in0_s,
                   in1     => in1_s,
                   mux_out => mux_out );

    -- Stimulus process to drive test cases
    stim_proc : PROCESS
    BEGIN
        -- Test Case 1: mux_sel = '0', output should be in0_s
        mux_sel <= '0';
        in0_s <= X"1234";  -- Set in0 to some value (for example, 0x1234)
        in1_s <= X"5678";  -- Set in1 to some value (for example, 0x5678)
        WAIT FOR 20ns;     -- Wait for 20ns to observe the result
        ASSERT (mux_out = in0_s)  -- Verify mux_out equals in0_s when mux_sel is '0'
            REPORT "Mismatch in mux_out for mux_sel = '0'" SEVERITY ERROR;

        -- Test Case 2: mux_sel = '1', output should be in1_s
        mux_sel <= '1';
        WAIT FOR 20ns;     -- Wait for 20ns to observe the result
        ASSERT (mux_out = in1_s)  -- Verify mux_out equals in1_s when mux_sel is '1'
            REPORT "Mismatch in mux_out for mux_sel = '1'" SEVERITY ERROR;

        -- Test Case 3: Test with other value for in0_s and in1_s
        in0_s <= X"AAAA";  -- Change in0 to some value (for example, 0xAAAA)
        in1_s <= X"BBBB";  -- Change in1 to some value (for example, 0xBBBB)
        
        -- Test Case 3.1: mux_sel = '0', output should be in0_s (0xAAAA)
        mux_sel <= '0';
        WAIT FOR 20ns;     -- Wait for 20ns to observe the result
        ASSERT (mux_out = in0_s)
            REPORT "Mismatch in mux_out for mux_sel = '0' with new values" SEVERITY ERROR;

        -- Test Case 3.2: mux_sel = '1', output should be in1_s (0xBBBB)
        mux_sel <= '1';
        WAIT FOR 20ns;     -- Wait for 20ns to observe the result
        ASSERT (mux_out = in1_s)
            REPORT "Mismatch in mux_out for mux_sel = '1' with new values" SEVERITY ERROR;

        -- End of simulation
        WAIT;
    END PROCESS;

END sim;