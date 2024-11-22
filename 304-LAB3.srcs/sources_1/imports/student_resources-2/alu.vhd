----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
-- Create Date: 10/29/2020 07:18:24 PM
-- Module Name: cpu - structural(datapath)
-- Description: CPU LAB 3 - ECE 410 (2023)
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Revision 3.01 - File Modified by Antonio Andara (October 31, 2023)
-- Revision 4.01 - File Modified by Antonio Andara (October 28, 2024)
-- Revision 5.01 - File Modified by Timmy Ifidon (November 13, 2024)
-- Revision 6.01 - File Modified by Timmy Ifidon (November 20, 2024)
-- Additional Comments:
--*********************************************************************************
-- A total of fifteen operations can be performed using 4 select lines of this ALU.
-- The select line codes have been given to you in the lab manual.
-----------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY alu16 IS
    PORT ( A         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; B         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
         ; shift_amt : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_sel   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)
         ; alu_out   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		 ; overflow  : OUT STD_LOGIC
         );
END alu16;

ARCHITECTURE Dataflow OF alu16 IS
	
	

BEGIN
	PROCESS (A, B, shift_amt, alu_sel)
	VARIABLE arith_result : SIGNED(15 DOWNTO 0);  
	BEGIN
--	    variable arith_result : INTEGER;
        overflow <= '0';
		CASE alu_sel IS
			WHEN "0001" =>
				alu_out <= A; -- Pass A
			WHEN "0010" =>
				alu_out <= B; -- Pass B
			WHEN "0011" =>
				alu_out <= STD_LOGIC_VECTOR(shift_left(unsigned(B), to_integer(unsigned(shift_amt)))); -- Shift left
			WHEN "0100" =>
				alu_out <= STD_LOGIC_VECTOR(shift_right(unsigned(B), to_integer(unsigned(shift_amt)))); -- Shift right
			WHEN "0101" =>
				arith_result := (signed(A) + signed(B)); -- ADD
				IF (A(15) = '0' AND B(15) = '0' AND arith_result(15) = '1') OR  -- Positive overflow
                (A(15) = '1' AND B(15) = '1' AND arith_result(15) = '0') THEN -- Negative overflow  THEN 
					overflow <= '1';
				else 
					overflow <= '0';
				END if;
				alu_out <= STD_LOGIC_VECTOR(arith_result); 
			WHEN "0110" => -- SUB
				arith_result := signed(A) - signed(B);
				IF (A(15) = '0' AND B(15) = '1' AND arith_result(15) = '1') OR  -- Positive overflow
                (A(15) = '1' AND B(15) = '0' AND arith_result(15) = '0') THEN 
					overflow <= '1';  -- Set overflow flag (indicating underflow in unsigned context)
				ELSE
					overflow <= '0';
				END IF;
				alu_out <= STD_LOGIC_VECTOR(arith_result); 
			WHEN "0111" =>
				arith_result := (signed(B) + 1); -- INC
				IF (A(15) = '0' AND arith_result(15) = '1') THEN -- Negative overflow  THEN 
					overflow <= '1';
				else 
					overflow <= '0';
				END if;
				alu_out <= STD_LOGIC_VECTOR(arith_result); 
			WHEN "1000" => -- DEC
				arith_result := signed(B) - 1;
				IF (A(15) = '1'  AND arith_result(15) = '0') THEN
					overflow <= '1';  -- Set overflow flag (indicating underflow in unsigned context)
				ELSE
					overflow <= '0';
				END IF;
				alu_out <= STD_LOGIC_VECTOR(arith_result); 
			
			WHEN "1001" =>
				alu_out <= STD_LOGIC_VECTOR(unsigned(A) AND unsigned(B)); -- A AND B
			WHEN "1010" =>
				alu_out <= STD_LOGIC_VECTOR(unsigned(A) OR unsigned(B)); -- A OR B
			WHEN "1011" =>
				alu_out <= NOT A; -- Not A
			WHEN "1100" =>
				alu_out <= NOT B; -- NOT B
			WHEN "1101" =>
				alu_out <= X"0001"; -- 1
			WHEN "1110" =>
				alu_out <= (OTHERS => '0'); -- 0
			WHEN "1111" =>
				alu_out <= (OTHERS => '1'); -- -1 (all ones)
			WHEN OTHERS =>
				alu_out <= (OTHERS => '1'); -- Default case, set to all ones
		END CASE;
	END PROCESS;
END Dataflow;