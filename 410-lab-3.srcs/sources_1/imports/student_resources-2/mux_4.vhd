----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: cpu - structural(datapath)
-- Description: CPU LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Shyama Gandhi (Nov 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 5.01 - File Modified by Timmy Ifidon (November 13, 2024)
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)

-- Additional Comments:
--*********************************************************************************
--THIS IS A 4x1 MUX that selects between the four inputs as shown in the lab manual.
-----------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux4 IS
    PORT( in0      : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; in1      : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; in2      : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; in3      : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
        ; mux_sel  : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
        ; mux_out  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END mux4;

ARCHITECTURE Dataflow OF mux4 IS
BEGIN
    WITH mux_sel SELECT
        mux_out <= in0 WHEN "00", -- changed encoding to be more intuitive 
                   in1 WHEN "01",
                   in2 WHEN "10",
                   in3 WHEN "11",
       (OTHERS => '0') WHEN OTHERS;
END Dataflow;
