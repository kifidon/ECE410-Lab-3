----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2024 07:25:34 PM
-- Design Name: 
-- Module Name: datapath_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  

ENTITY tb_datapath IS

END tb_datapath;

ARCHITECTURE behavior OF tb_datapath IS

    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT datapath
    PORT (
        reset               : IN STD_LOGIC;
        clock               : IN STD_LOGIC;
        input_mux_sel       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        usser_input_val     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        immediate_data_val  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        acc_mux_sel         : IN STD_LOGIC;
        alu_mux_sel         : IN STD_LOGIC;
        alu0_shift          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        alu0_select         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        alu1_shift          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        alu1_select         : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        acc0_write_en       : IN STD_LOGIC;
        acc1_write_en       : IN STD_LOGIC;
        rf_write_en         : IN STD_LOGIC;
        rf_mode_sel         : IN STD_LOGIC;
        rf_address_sel      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        output_en           : IN STD_LOGIC;
        output_buffer       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        alu0_overflow       : OUT STD_LOGIC;
        alu1_overflow       : OUT STD_LOGIC;
        sign_out            : OUT STD_LOGIC;
        zero_out            : OUT STD_LOGIC
    );
    END COMPONENT;

    -- Signals to drive the UUT
    SIGNAL reset               : STD_LOGIC := '0';
    SIGNAL clock               : STD_LOGIC := '0';
    SIGNAL input_mux_sel       : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL usser_input_val     : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL immediate_data_val  : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL acc_mux_sel         : STD_LOGIC := '0';
    SIGNAL alu_mux_sel         : STD_LOGIC := '0';
    SIGNAL alu0_shift          : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu0_select         : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu1_shift          : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL alu1_select         : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL acc0_write_en       : STD_LOGIC := '0';
    SIGNAL acc1_write_en       : STD_LOGIC := '0';
    SIGNAL rf_write_en         : STD_LOGIC := '0';
    SIGNAL rf_mode_sel         : STD_LOGIC := '0';
    SIGNAL rf_address_sel      : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL output_en           : STD_LOGIC := '0';
    SIGNAL output_buffer       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu0_overflow       : STD_LOGIC;
    SIGNAL alu1_overflow       : STD_LOGIC;
    SIGNAL sign_out            : STD_LOGIC;
    SIGNAL zero_out            : STD_LOGIC;

    -- Clock period definition
    CONSTANT clk_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: datapath
        PORT MAP (
            reset               => reset,
            clock               => clock,
            input_mux_sel       => input_mux_sel,
            usser_input_val     => usser_input_val,
            immediate_data_val  => immediate_data_val,
            acc_mux_sel         => acc_mux_sel,
            alu_mux_sel         => alu_mux_sel,
            alu0_shift          => alu0_shift,
            alu0_select         => alu0_select,
            alu1_shift          => alu1_shift,
            alu1_select         => alu1_select,
            acc0_write_en       => acc0_write_en,
            acc1_write_en       => acc1_write_en,
            rf_write_en         => rf_write_en,
            rf_mode_sel         => rf_mode_sel,
            rf_address_sel      => rf_address_sel,
            output_en           => output_en,
            output_buffer       => output_buffer,
            alu0_overflow       => alu0_overflow,
            alu1_overflow       => alu1_overflow,
            sign_out            => sign_out,
            zero_out            => zero_out
        );

    -- Clock generation process
    CLOCK_GEN: PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clk_period / 2;
        clock <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    STIMULUS: PROCESS
    BEGIN
        -- Apply reset
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;
        
    -- TEST 1: POPULATE REGISTER FILE 
        --LOAD ACC 0
        immediate_data_val     <= X"1111";
        input_mux_sel          <= "10";
        acc_mux_sel            <= '0';
        acc0_write_en          <= '1';
        acc1_write_en          <= '0';
        rf_write_en            <= '0';
        rf_mode_sel            <= '0';
        rf_address_sel         <= "000";

        WAIT FOR clk_period;

        ASSERT (sign_out = '0' and zero_out = '0' ) 
                REPORT "Mismatch in expected sign/zero value !" 
                SEVERITY ERROR;
        
        -- LOAD NEXT A AND STORE PREVIOUS A IN REG FILE
        immediate_data_val     <= X"4444";
        input_mux_sel          <= "10"; -- IMMED
        acc_mux_sel            <= '0'; -- ACC0
        acc0_write_en          <= '1';
        rf_write_en            <= '1'; 
        rf_mode_sel            <= '1'; -- SIMD
        rf_address_sel         <= "000"; -- 0 AND 4
        output_en              <= '1'; 
        WAIT FOR clk_period;

        -- LOAD NEXT A AND STORE PREVIOUS A IN REG FILE
        immediate_data_val     <= X"8888";
        input_mux_sel          <= "10"; -- IMMED
        acc_mux_sel            <= '0'; -- ACC0
        acc0_write_en          <= '1';
        rf_write_en            <= '1'; 
        rf_mode_sel            <= '1'; -- SIMD
        rf_address_sel         <= "001"; -- 1 AND 5
        WAIT FOR clk_period;

        -- LOAD NEXT A AND STORE PREVIOUS A IN REG FILE
        immediate_data_val     <= X"FFFF";
        input_mux_sel          <= "10"; -- IMMED
        acc_mux_sel            <= '0'; -- ACC0
        acc0_write_en          <= '1';
        rf_write_en            <= '1'; 
        rf_mode_sel            <= '1'; -- SIMD
        rf_address_sel         <= "010"; -- 2 AND 6
        WAIT FOR clk_period;

        -- STORE LAST IMMEDIATE 
        immediate_data_val     <= X"0000"; -- 
        input_mux_sel          <= "00"; 
        acc_mux_sel            <= '0'; -- ACC0
        acc0_write_en          <= '0';
        rf_write_en            <= '1'; 
        rf_mode_sel            <= '1'; -- SIMD
        rf_address_sel         <= "111"; -- 7 AND 3
        WAIT FOR clk_period;
        ASSERT (output_buffer = X'FFFF') 
                REPORT "Mismatch in expected output value !" 
                SEVERITY ERROR;

        --update register outputs for next test 
        input_mux_sel          <= "00"; 
        acc_mux_sel            <= '0'; -- ACC0
        acc0_write_en          <= '0';
        rf_write_en            <= '0'; 
        rf_mode_sel            <= '0';
        rf_address_sel         <= "011"; -- 3
        WAIT FOR clk_period;
        
    -- Test 2: Check for overflow on alu operations    
        alu_mux_sel            <= '1'; --ACC0: X"FFFF"
        alu0_select            <= "0101"; -- ADD
        alu1_select            <= "0101"; -- ADD
        acc0_write_en          <= '0';
        acc1_write_en          <= '0'; -- NO WRITE FOR FORCED OVERFLOW
        rf_mode_sel            <= '1'; --SIMD
        rf_address_sel         <= "011"; -- SHOULD BE FFFF AND CAUSE OVERFLOW
        WAIT FOR clk_period;
        ASSERT (alu1_overflow ='1' AND alu0_overflow = '1') 
                REPORT "Mismatch in expected OVERFLOW value !" 
                SEVERITY ERROR;

    -- TEST 3: STORING ALU OUTPUT 
        -- change rf outputs, load acc0 
        immediate_data_val     <= X"1234";
        alu_mux_sel            <= '1'; --ACC0: X"FFFF"
        alu0_select            <= "0000"; -- ADD
        alu1_select            <= "0000"; -- ADD
        acc0_write_en          <= '1';
        acc1_write_en          <= '0'; 
        rf_mode_sel            <= '0'; 
        rf_address_sel         <= "000"; --R0: SHOULD BE X"1111" 
        WAIT FOR clk_period;
        -- store alu operation 
        input_mux_sel          <= "00"; -- alu0
        immediate_data_val     <= X"1234";
        alu_mux_sel            <= '1'; --ACC0: X"1234"
        alu0_select            <= "1001"; -- AND
        alu1_select            <= "1001"; -- AND
        acc0_write_en          <= '1';
        acc1_write_en          <= '0'; 
        rf_mode_sel            <= '0'; 
        rf_address_sel         <= "000"; --R0: SHOULD BE X"1111"
        WAIT FOR clk_period;
        ASSERT (output_buffer =(X"1234" AND X"1111")) 
                REPORT "Mismatch in expected output value! (test 3)" 
                SEVERITY ERROR;

    -- TEST 4: STORE AND DISPLAY ACC1
        -- COMPUTE NOT ACC0 AND STORE IN ACC1
        input_mux_sel          <= "00"; -- alu0
        alu_mux_sel            <= '1'; --ACC0: X"1111"
        alu0_select            <= "1100"; -- not b
        alu1_select            <= "1100"; -- not b
        acc0_write_en          <= '0';
        acc1_write_en          <= '1';  
        rf_mode_sel            <= '0'; 
        rf_address_sel         <= "010"; --R2: SHOULD BE X"4444"
        -- STORE ACC1 IN REG6
        WAIT FOR clk_period;
        input_mux_sel          <= "01"; -- rf0 - premptive
        alu_mux_sel            <= '1'; --ACC0: X"1111"
        acc_mux_sel            <= '1'; -- ACC1
        alu0_select            <= "0000"; -- not b
        alu1_select            <= "0000"; -- not b
        acc0_write_en          <= '0';
        acc1_write_en          <= '0'; 
        rf_write_en            <= '1';  
        rf_mode_sel            <= '1'; -- SIMD
        rf_address_sel         <= "010"; --R2, R6: SHOULD BE X"4444"
        -- UPDATER REG OUTS
        WAIT FOR clk_period;
        input_mux_sel          <= "01"; -- rf0 - premptive
        alu_mux_sel            <= '1'; --ACC0: X"1111"
        acc_mux_sel            <= '1'; -- ACC1
        alu0_select            <= "0000"; 
        alu1_select            <= "0000"; 
        acc0_write_en          <= '0';
        acc1_write_en          <= '0'; 
        rf_write_en            <= '0';  
        rf_mode_sel            <= '0'; 
        rf_address_sel         <= "110"; --R6
        WAIT FOR clk_period;
        -- STORE UPDATED REG OUTS
        input_mux_sel          <= "01"; -- rf0 - premptive
        alu_mux_sel            <= '1'; --ACC0: X"1111"
        acc_mux_sel            <= '1'; -- ACC1
        alu0_select            <= "0000"; 
        alu1_select            <= "0000"; 
        acc0_write_en          <= '1';
        acc1_write_en          <= '0'; 
        rf_write_en            <= '0';  
        rf_mode_sel            <= '0'; 
        rf_address_sel         <= "110"; --R6:
        WAIT FOR clk_period;
        ASSERT (output_buffer = NOT X"1111")
                REPORT "Mismatch in expected output value! (test 4)" 
                SEVERITY ERROR;
                
        reset <= '1';
        WAIT;

    END PROCESS;

END behavior;
