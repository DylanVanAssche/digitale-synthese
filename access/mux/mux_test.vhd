--***************************************
--* TITLE: MUX TESTBENCH (sender) 	*
--* TYPE: Component 		 	*
--* AUTHOR: Dylan Van Assche 	  	*
--* DATE: 12/01/2017			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Selecting the right PN code
--2)Principle:
-- Decode a dipswitch to select the right PN code
--3)Inputs:
-- in_0, in_1, in_2, in_3, in_select
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY mux_test IS
END mux_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF mux_test IS
	-- Initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL in_0       : std_logic;
	SIGNAL in_1       : std_logic;
	SIGNAL in_2       : std_logic;
	SIGNAL in_3       : std_logic;
	SIGNAL output     : std_logic; 
	SIGNAL in_select  : std_logic_vector(1 DOWNTO 0) := (OTHERS => '0'); -- Input 0 is preselected
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.mux(behavior)
	PORT MAP
	(
		in_0    => in_0,
		in_1    => in_1,
		in_2    => in_2,
		in_3    => in_3,
		in_select => in_select,
		output => output
	);
			
-- Testbench
tb : PROCESS
BEGIN
	-- random data at the inputs
	in_0 <= '1';
	in_1 <= '0';
	in_2 <= '1';
	in_3 <= '0';
	-- select each input for 1 CLK cycle
	FOR i IN 0 TO 3 LOOP
		in_select <= CONV_STD_LOGIC_VECTOR(i, 2);
		WAIT FOR period;
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
