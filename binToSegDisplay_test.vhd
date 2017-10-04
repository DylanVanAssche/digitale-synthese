--******************************************************************************
--*   TITLE:  Binary-To-7-Segment-Display decoder TESTBENCH (sender)           *
--*   TYPE:   Component                                                        *
--*   AUTHOR: Dylan Van Assche                                                 *
--*   DATE:   01/10/2017                                                       *
--******************************************************************************

--********************
--*   DESCRIPTION    *
--********************
--1)Purpose:
--  TESTBENCH: Convert a 4 bit STD_LOGIC_VECTOR to a 7 segment display output (active low)
--2)Principle:
-- 	Switch statement converts the binary data to HEX values which are understand by the 7 segment display
--3)Inputs:
-- 	bin
--4)Outputs:
-- 	disp_b

--***************************
--*   LIBRARIES & ENTITY    *
--***************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;


ENTITY decoder_test IS
END decoder_test;

ARCHITECTURE structural OF decoder_test IS 

COMPONENT decoder
PORT (
	bin: IN std_logic_vector(3 DOWNTO 0);
	disp_b: OUT std_logic_vector(6 DOWNTO 0)
  );
END COMPONENT;

--**************************************************
--*   ARCHITECTURE, SIGNALS, TYPES & COMPONENTS    *
--**************************************************
FOR uut : decoder USE ENTITY work.decoder(behavior);

-- Initialize signals & constants
CONSTANT period : time := 100 ns;
CONSTANT delay  : time :=  10 ns;
SIGNAL end_of_sim : boolean := false;

SIGNAL bin: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
SIGNAL disp_b: std_logic_vector(6 DOWNTO 0) := (OTHERS => '0');

BEGIN

--****************
--*   MAPPING    *
--****************
uut: decoder PORT MAP(
	bin => bin,
	disp_b => disp_b
);

--*******************
--*   STATEMENTS    *
--*******************
-- Only for synchronous components
--clock : PROCESS
--BEGIN 
--		clk <= '0';
--		WAIT FOR period/2;
--	LOOP
--		clk <= '0';
--		WAIT FOR period/2;
--		clk <= '1';
--		WAIT FOR period/2;
--      	EXIT WHEN end_of_sim;
--	END LOOP;
--	WAIT;
--END PROCESS clock;

-- Testbench
tb : PROCESS
BEGIN
	FOR i IN 0 TO 15 LOOP
		bin <= CONV_STD_LOGIC_VECTOR(i,4);
		WAIT FOR period;
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;