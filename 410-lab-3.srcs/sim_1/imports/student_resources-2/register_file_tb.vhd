----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/28/2024 01:01:24 PM
-- Module Name: register_file_tb
-- Description: CPU LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-----------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END register_file_tb;

ARCHITECTURE behavior OF register_file_tb IS

    -- Signals for the UUT
    SIGNAL clock        : STD_LOGIC := '0';
    SIGNAL rf_write     : STD_LOGIC;
    SIGNAL mode         : STD_LOGIC;
    SIGNAL rf_address   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL rf0_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);

    CONSTANT clk_period : TIME := 8 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: ENTITY WORK.register_file
        PORT MAP(
           clock      => CLOCK
        ,  rf_write   => rf_write
        ,  rf_mode    => mode
        ,  rf_address => rf_address
        ,  rf0_in     => rf0_in  
        ,  rf1_in     => rf1_in  
        ,  rf0_out    => rf0_out 
        ,  rf1_out    => rf1_out 
        );            
    -- Clock process
    clk_process : PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clk_period / 2;
        clock <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    stim_process : PROCESS
    BEGIN
        -- Initialize inputs
        rf_write   <= '0';
        mode       <= '0';                -- Single access mode
        rf_address <= "000";              -- Address 0
        rf0_in     <= "0000000000000001"; -- Input value for rf0
        rf1_in     <= "0000000000000010"; -- Input value for rf1

        WAIT FOR clk_period;              -- Wait for one clock cycle

        -- Test single access mode
        rf_write <= '1';
        WAIT FOR clk_period; -- Write rf0_in to registers[0]

        rf_write <= '0';     -- Disable write
        WAIT FOR clk_period; -- Wait for output update

        -- Check outputs
        ASSERT (rf0_out = "0000000000000001") REPORT "Error: rf0_out should be 0000000000000001" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000000") REPORT "Error: rf1_out should be 0000000000000000 in single access mode" SEVERITY ERROR;

        -- Test double access mode
        mode       <= '1';                -- Switch to double access mode
        rf_address <= "001";              -- Address 1
        rf0_in     <= "0000000000000011"; -- Input value for rf0
        rf1_in     <= "0000000000000100"; -- Input value for rf1

        rf_write   <= '1';
        WAIT FOR clk_period; -- Write to registers[1] and registers[5]

        rf_write <= '0';     -- Disable write
        WAIT FOR clk_period; -- Wait for output update

        -- Check outputs after writing
        ASSERT (rf0_out = "0000000000000011") REPORT "Error: rf0_out should be 0000000000000011" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000100") REPORT "Error: rf1_out should be 0000000000000100" SEVERITY ERROR;

        mode       <= '1';                -- Switch to double access mode
        rf_address <= "110";              -- Address 6
        rf0_in     <= "1010101010101010"; -- Input value for rf0
        rf1_in     <= "1111111100000000"; -- Input value for rf1

        rf_write   <= '1';                -- Enable write
        WAIT FOR clk_period;              -- Write to registers[2] and registers[6]

        rf_write <= '0';                  -- Disable write
        WAIT FOR clk_period;              -- Wait for output update

        -- Check outputs after writing
        ASSERT (rf0_out = "1010101010101010") REPORT "Error: rf0_out should be 1010101010101010" SEVERITY ERROR;
        ASSERT (rf1_out = "1111111100000000") REPORT "Error: rf1_out should be 1111111100000000" SEVERITY ERROR;

        -- Add more test cases as needed...

    -- Test read/write only happens once per clock cycle 
        mode       <= '0';                -- Switch to single access mode
        rf_address <= "110";              -- Address 6
        rf0_in     <= X"1234"; -- Input value for rf0
        rf1_in     <= "1111111100000000"; -- Input value for rf1

        rf_write   <= '1';                -- Enable write
        WAIT FOR clk_period;              -- registers[6]

        -- Check: rf0_out should be the same value as previous clock cycle
        ASSERT (rf0_out = "1010101010101010") REPORT "Error: rf0_out should be 1010101010101010" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000000") REPORT "Error: rf1_out should be 0000000000000000 in single access mode" SEVERITY ERROR;
        
        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period;              -- Wait for output update

        -- Check: outputs should reflect most recent write
        ASSERT (rf0_out = X"1234") REPORT "Error: rf0_out should be 0000000000000001" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000000") REPORT "Error: rf1_out should be 0000000000000000 in single access mode" SEVERITY ERROR;
        
    -- Test Read/Write is done properly between dual and single access modes 
        mode       <= '0';                -- Switch to single access mode
        rf_address <= "110";              -- Address 6
        rf0_in     <= X"4321"; -- Input value for rf0
        rf1_in     <= X"1234"; -- Input value for rf1 

        rf_write   <= '1';                -- Enable write
        WAIT FOR clk_period;              -- Write to registers[2] and registers[6]

        rf_write <= '0';                  -- Disable write
        WAIT FOR clk_period;              -- Wait for output update
        -- Check outputs
        ASSERT (rf0_out = X"4321") REPORT "Error: rf0_out should be x4321" SEVERITY ERROR;
        ASSERT (rf1_out = "0000000000000000") REPORT "Error: rf1_out should be 0000000000000000 in single access mode" SEVERITY ERROR;
        
        mode       <= '0';                -- Switch to double access mode

        rf_write   <= '0';                -- Disable write
        WAIT FOR clk_period;              -- Wait for output update

        -- Check: rf1_in was not written to reg 2, it should be the value prior 
        ASSERT (rf0_out = X"1234") REPORT "Error: rf0_out should be 0000000000000001" SEVERITY ERROR;
        ASSERT (rf1_out = "1111111100000000") REPORT "Error: rf1_out should be 1111111100000000" SEVERITY ERROR;
        

        WAIT; -- End simulation
    END PROCESS;

END behavior;
