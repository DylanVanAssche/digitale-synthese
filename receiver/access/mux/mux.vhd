--*******************************
--* TITLE: MUX (receiver)	*
--* TYPE: Component 		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 12/11/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Selecting the right PN code
--2)Principle:
-- Decode a dipswitch to select the right PN code
--3)Inputs:
-- 
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY mux IS
	PORT
	(
		in_0, in_1, in_2, in_3  : IN std_logic;
		in_select               : IN std_logic_vector(1 DOWNTO 0);
		output                  : OUT std_logic
	);
END mux;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF mux IS
BEGIN
decode : PROCESS (in_0, in_1, in_2, in_3, in_select)
BEGIN
	CASE in_select IS
		WHEN "00" => output  <= in_0; -- 'input in_0'
		WHEN "01" => output  <= in_1; -- 'input in_1'
		WHEN "10" => output  <= in_2; -- 'input in_2'
		WHEN "11" => output  <= in_3; -- 'input in_3'
		WHEN OTHERS => output <= in_0; -- fallback
	END CASE;
END PROCESS decode;
END behavior;
