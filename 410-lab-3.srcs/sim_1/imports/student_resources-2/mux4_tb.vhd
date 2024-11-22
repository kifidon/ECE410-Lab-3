----------------------------------------------------------------------------------
-- Filename : mux_tb.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: mux_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the multiplexer of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux4_tb IS
END mux4_tb;

ARCHITECTURE sim OF mux4_tb IS

    SIGNAL in_0    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_1    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_2    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL in_3    : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mux_sel : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00"; 
    SIGNAL mux_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : ENTITY WORK.mux4(Dataflow)
        PORT MAP ( mux_sel => mux_sel,  
                   in0     => in_0,
                   in1     => in_1,
                   in2     => in_2,
                   in3     => in_3,
                   mux_out => mux_out );

    stimulus : PROCESS
    BEGIN
        -- Setup test data
        in_0     <= X"1111";
        in_1     <= X"2222";
        in_2     <= X"3333";
        in_3     <= X"4444";

        -- Test case 1: Select in_0 (mux_sel = "00")
        mux_sel <= "00";
        WAIT FOR 20 ns;
        ASSERT (mux_out = in_0) REPORT "Mismatch for mux_sel = 00!" SEVERITY ERROR;

        -- Test case 2: Select in_1 (mux_sel = "01")
        mux_sel <= "01";
        WAIT FOR 20 ns;
        ASSERT (mux_out = in_1) REPORT "Mismatch for mux_sel = 01!" SEVERITY ERROR;

        -- Test case 3: Select in_2 (mux_sel = "10")
        mux_sel <= "10";
        WAIT FOR 20 ns;
        ASSERT (mux_out = in_2) REPORT "Mismatch for mux_sel = 10!" SEVERITY ERROR;

        -- Test case 4: Select in_3 (mux_sel = "11")
        mux_sel <= "11";
        WAIT FOR 20 ns;
        ASSERT (mux_out = in_3) REPORT "Mismatch for mux_sel = 11!" SEVERITY ERROR;

        -- End the test
        WAIT;
    END PROCESS stimulus;

END sim;