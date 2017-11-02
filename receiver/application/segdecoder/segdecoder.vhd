--***************************************************************
--* TITLE: Binary-To-7-Segment-Display decoder (receiver)	*
--* TYPE: Component 						*
--* AUTHOR: Dylan Van Assche 					*
--* DATE: 01/10/2017 						*
--***************************************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Convert a 4 bit STD_LOGIC_VECTOR to a 7 segment display output (active low)
--2)Principle:
-- Switch statement converts the binary data to HEX values which are understand by the 7 segment display
--3)Inputs:
-- bin
--4)Outputs:
-- disp_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY decoder IS
	PORT
	(
		bin    : IN std_logic_vector(3 DOWNTO 0);
		disp_b : OUT std_logic_vector(6 DOWNTO 0)
	);
END decoder;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF decoder IS
BEGIN
decode : PROCESS (bin)
BEGIN
	CASE bin IS
		WHEN "0000" => disp_b  <= "0000001"; -- '0'
		WHEN "0001" => disp_b  <= "1001111"; -- '1'
		WHEN "0010" => disp_b  <= "0010010"; -- '2'
		WHEN "0011" => disp_b  <= "0000110"; -- '3'
		WHEN "0100" => disp_b  <= "1001100"; -- '4'
		WHEN "0101" => disp_b <= "0100100"; -- '5'
		WHEN "0110" => disp_b <= "0100000"; -- '6'
		WHEN "0111" => disp_b <= "0001111"; -- '7'
		WHEN "1000" => disp_b <= "0000000"; -- '8'
		WHEN "1001" => disp_b <= "0000100"; -- '9'
		WHEN "1010" => disp_b <= "0000010"; -- 'A'
		WHEN "1011" => disp_b <= "1100000"; -- 'B'
		WHEN "1100" => disp_b <= "0110001"; -- 'C'
		WHEN "1101" => disp_b <= "1000010"; -- 'D'
		WHEN "1110" => disp_b <= "0010000"; -- 'E'
		WHEN "1111" => disp_b <= "0111000"; -- 'F'
		WHEN OTHERS => disp_b     <= "0000000";
	END CASE;
END PROCESS decode;
END behavior;
