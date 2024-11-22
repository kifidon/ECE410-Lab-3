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

        -- Test 1: Test input MUX behavior (input_mux_sel) storing in accumulator0
        acc0_write_en <= '1';
        acc1_write_en <= '0';
        usser_input_val <= X"0000"; 
        immediate_data_val <= X"DCBA";
        input_mux_sel <= "11";  
        WAIT FOR clk_period; 
        ASSERT (sign_out = '0' and zero_out = '1' ) 
                REPORT "Mismatch in expected sign/zero value !" 
                SEVERITY ERROR;
        
        -- Test 2: store user in acc0
        usser_input_val <= X"ABCD"; 
        immediate_data_val <= X"DCDA";
        input_mux_sel <= "11"; -- select user in
        alu_mux_sel <= '1'; -- acc0
        acc_mux_sel <= '0'; -- acc0
        rf_mode_sel <= '1'; -- Double access      
        WAIT FOR CLK_PERIOD;
        ASSERT (sign_out /= '0' and zero_out /= '1' ) 
                REPORT "Mismatch in expected overflow value !" 
                SEVERITY ERROR;
        -- Test Storin in Acc 1  
        acc0_write_en <= '0';
        alu1_select <= "0010"; --Pass B: acc0
        acc1_write_en <= '1';

--        alu1_select <= "0100"; -- SHIFT RIGHT: TO STORE IN ACC1 on next clock cycle
        -- can't read+write in 1 cycle
        alu_mux_sel <= '1'; -- to acc0
        rf_write_en <= '1'; -- STORE acc0 in REGISTER FILE 0 and 4
        WAIT FOR CLK_PERIOD;
        acc1_write_en <= '0';
        alu0_select <= "0101"; -- ADD: SHOULD CAUSE OVERFLOW 
        alu1_select <= "0100"; -- shift right
        alu1_shift <= X"4";
        rf_write_en <= '0'; -- Read Mode 
        WAIT FOR CLK_PERIOD;
         ASSERT (alu0_overflow = '1') 
                REPORT "Mismatch in expected overflow value !" 
                SEVERITY ERROR;
--        alu0_select <= "0101"; -- add
--        WAIT FOR clk_period;
        -- store acc1 
        acc1_write_en <= '1'; 
        alu0_select <= "0001";-- Pass A: rf0_out;
        input_mux_sel <= "01"; -- rf0_out;
        usser_input_val <= X"1234"; -- User in can change without affecting acc0 in
        rf_write_en <= '0';
        rf_mode_sel <= '1'; -- Double acces mode
        acc_mux_sel <= '1'; -- acc 1
        WAIT FOR CLK_PERIOD;
        rf_write_en <= '1'; -- stroe acc 1 in register file 4
        acc1_write_en <= '0';
        WAIT FOR CLK_PERIOD;
        rf_mode_sel <= '0';
        rf_address_sel <= "100";
        rf_write_en <= '0'; -- Update outputs;
        WAIT FOR CLK_PERIOD;
        acc0_write_en <= '1';  
        output_en <= '1';
--        WAIT FOR CLK_PERIOD
        WAIT FOR CLK_PERIOD*2;
        
        
        RESET <= '1';
        --OUTPUT SHOULD BE THE RIGHT SHIFTED VALUE OF THE ORIGINAL INPUT X"ABCD". FOR TESTING
        -- I PASSED THE VALUE TO ALU1, SHIFTED IT, STORED ACC1 AND THEN IN THE REGISTER FILE
        -- WHILE ACC0 COMPUTED OTHER TASKS: ADDING THE INPUT VALUE AGAINST ITSELF BY STORING IT IN REGFILE AND THEN 
        -- USEING THE ALU_MUX TO SELECT ACC0 FOR ALLU0. THE PURPOSE OF THIS WAS TO TEST THE OVERFLOW FLAG .
        -- THEN OBTAINED THE RESULT AND OUTPUT TO THE TSB ON THE NEXT RIZING CLOCK EDGE.
        
        WAIT;
    END PROCESS;

END behavior;
