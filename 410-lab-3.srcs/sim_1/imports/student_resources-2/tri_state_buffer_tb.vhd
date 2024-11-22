----------------------------------------------------------------------------------
-- Filename : tristatebuffer.vhdl
-- Author : Antonio Alejandro Andara Lara
-- Date : 31-Oct-2023
-- Design Name: tri_state_buffer_tb
-- Project Name: ECE 410 lab 3 2023
-- Description : testbench for the tri-state buffer file of the simple CPU design
-- Revision 1.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-- Copyright : University of Alberta, 2023
-- License : CC0 1.0 Universal
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tri_state_buffer_tb IS
END tri_state_buffer_tb;

ARCHITECTURE sim OF tri_state_buffer_tb IS
    SIGNAL output_enable : STD_LOGIC                     := '0';
    SIGNAL buffer_input  : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL buffer_output : STD_LOGIC_VECTOR (15 DOWNTO 0);

BEGIN

    uut : ENTITY WORK.tri_state_buffer(Behavioral)
        PORT MAP( output_en => output_enable
                , buffer_input  => buffer_input 
                , buffer_output => buffer_output
                );

    stimulus : PROCESS
    BEGIN
        -- Test with output_enable low (should produce high impedance 'Z' output)
        output_enable <= '0';
        buffer_input  <= "1111000010101010";
        WAIT FOR 200 ns;

        -- Assertion to check if output is high impedance state
        ASSERT (buffer_output = "ZZZZZZZZZZZZZZZZ")
        REPORT "Mismatch in buffer_output value with output_enable low!"
        SEVERITY ERROR;

        -- Test with output_enable high (should produce same as input)
        output_enable <= '1';
        WAIT FOR 200 ns;

        -- Assertion to check if output matches input
        ASSERT (buffer_output = buffer_input)
        REPORT "Mismatch in buffer_output value with output_enable high!"
        SEVERITY ERROR;
        
        WAIT FOR 200 ns;
        buffer_input  <= "1111000011111010";
        ASSERT (buffer_output = buffer_input)
        REPORT "Mismatch in buffer_output value with output_enable high!"
        SEVERITY ERROR;
        
        
        WAIT;
    END PROCESS stimulus;

END sim;
