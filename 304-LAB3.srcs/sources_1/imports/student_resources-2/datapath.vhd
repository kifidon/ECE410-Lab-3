----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Antonio Andara Lara, Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Design Name: DATAPATH FOR THE CPU
-- Module Name: cpu - structural(datapath)
-- Description: CPU_PART 1 OF LAB 3 - ECE 410 (2021)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 5.01 - File Modified by Timmy Ifidon (November 13, 2024)
-- Additional Comments:
--*********************************************************************************
-- datapath top level module that maps all the components used inside of it
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.numeric_std.ALL;

ENTITY datapath IS
PORT (
        reset               : IN STD_LOGIC
    ;   clock               : IN STD_LOGIC
    ;   input_mux_sel       : IN STD_LOGIC_VECTOR(1 DOWNTO 0) 
    ;   usser_input_val     : IN STD_LOGIC_VECTOR(15 DOWNTO 0) 
    ;   immediate_data_val  : IN STD_LOGIC_VECTOR(15 DOWNTO 0) 
    ;   acc_mux_sel         : IN STD_LOGIC
    ;   alu_mux_sel         : IN STD_LOGIC
    ;   alu0_shift          : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    ;   alu0_select         : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    ;   alu1_shift          : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    ;   alu1_select         : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
    ;   acc0_write_en       : IN STD_LOGIC
    ;   acc1_write_en       : IN STD_LOGIC
    ;   rf_write_en         : IN STD_LOGIC
    ;   rf_mode_sel         : IN STD_LOGIC
    ;   rf_address_sel      : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
    ;   output_en           : IN STD_LOGIC
    ;   output_buffer       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    ;   alu0_overflow       : OUT STD_LOGIC
    ;   alu1_overflow       : OUT STD_LOGIC
    ;   sign_out            : OUT STD_LOGIC
    ;   zero_out            : OUT STD_LOGIC
    );
END datapath;

ARCHITECTURE Structural OF datapath IS
    ---------------------------------------------------------------------------
    SIGNAL alu0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc0_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc1_out     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf0_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_in       : STD_LOGIC_VECTOR(15 DOWNTO 0);  
    SIGNAL rf0_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rf1_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mux_out      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL alu_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL acc_mux_out  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL clock_div   : STD_LOGIC;
    ---------------------------------------------------------------------------
BEGIN
    -- Instantiate all components here
    mux4 : ENTITY work.mux4
        PORT MAP(
            in0          => alu0_out,
            in1          => rf0_out,
            in2          => immediate_data_val, --
            in3          => usser_input_val, --
            mux_sel      => input_mux_sel,  
            mux_out      => mux_out
        );
        
    acc_mux : ENTITY work.mux2
        PORT MAP(
            mux_sel      => acc_mux_sel,
            in0          => acc0_out, 
            in1          => acc1_out,
            mux_out      => acc_mux_out
        );
            
        rf1_in <= acc_mux_out;       
    
    alu_mux : ENTITY work.mux2
        PORT MAP(
            mux_sel      => alu_mux_sel,
            in0          => rf1_out    ,
            in1          => acc0_out   ,
            mux_out      => alu_mux_out
        );

    accumulator0 : entity work.accumulator
        PORT MAP(
            clock        => clock            ,
            reset        => reset            ,
            acc_write    => acc0_write_en    ,
            acc_in       => mux_out          ,
            acc_out      => acc0_out
        );  
        
        rf0_in <= acc0_out;

    accumulator1 : entity work.accumulator
        PORT MAP(
            clock        => clock            ,
            reset        => reset            ,
            acc_write    => acc1_write_en    ,
            acc_in       => alu1_out         ,
            acc_out      => acc1_out
        );  

    register_file : entity work.register_file
        PORT MAP(
            clock        => clock           ,
            rf_write     => rf_write_en     ,
            rf_mode      => rf_mode_sel     ,
            rf_address   => rf_address_sel  ,
            rf0_in       => rf0_in          ,
            rf1_in       => rf1_in          ,
            rf0_out      => rf0_out         ,
            rf1_out      => rf1_out
        );

    alu0 : entity work.alu16
        PORT MAP(
            A            => rf0_out          ,
            B            => alu_mux_out      ,
            shift_amt    => alu0_shift       ,
            alu_sel      => alu0_select      ,
            alu_out      => alu0_out         ,
            overflow     => alu0_overflow
        );

    alu1 : entity work.alu16
        PORT MAP(
            A            => rf1_out          ,
            B            => acc0_out         ,
            shift_amt    => alu1_shift       ,
            alu_sel      => alu1_select      ,
            alu_out      => alu1_out         ,
            overflow     => alu1_overflow
        ); 

    tri_state_buffer : entity work.tri_state_buffer
        PORT MAP(
            output_en     => output_en     ,
            buffer_input  => acc0_out      ,
            buffer_output => output_buffer
        );

    -- logic for flags
    
    sign_out <= '0' WHEN reset = '1' ELSE  mux_out(15); -- MSB IS THE SIGN OF THE 4-1 MUX
    
    zero_out <= '0' WHEN reset = '1' ELSE 
           '1' WHEN unsigned(mux_out) = 0 ELSE 
           '0';
END Structural;