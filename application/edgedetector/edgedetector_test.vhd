--***********************************************
--* TITLE: Edgedetector FSM TESTBENCH (sender) 	*
--* TYPE: Component 				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 05/10/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Check if a signal goes from LOW to HIGH
--2)Principle:
-- Moore FSM
--3)Inputs:
-- data, clk, clk_en, rst
--4)Outputs:
-- puls
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY edgedetector_test IS
END edgedetector_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF edgedetector_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL data       : std_logic;
	SIGNAL clk        : std_logic;
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic;
	SIGNAL puls       : std_logic;
BEGIN
--***********
--* MAPPING *
--***********
-- Connect ports to signals (PORT => SIGNAL)
uut : ENTITY work.edgedetector(behavior)
	PORT MAP
	(
		data   => data,
		puls   => puls,
		clk    => clk,
		clk_en => clk_en,
		rst    => rst
	);

-- Only for synchronous components
clock : PROCESS
	BEGIN
	clk <= '0';
	WAIT FOR period/2;
	LOOP
		clk <= '0';
		WAIT FOR period/2;
		clk <= '1';
		WAIT FOR period/2;
	EXIT WHEN end_of_sim;
	END LOOP;
	WAIT;
END PROCESS clock;
-- Testbench
PROCESS
	-- Reset procedure to initialize the component
	PROCEDURE reset IS
	BEGIN
		rst <= '1';
		WAIT FOR period * 2;
		rst <= '0';
		WAIT FOR period;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT testdata : IN std_logic) IS
	BEGIN
		data <= testdata;
		WAIT FOR period * 4;
		END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	test('0');
	test('1');
	test('0');
	test('1');
	end_of_sim <= true;
	WAIT;
END PROCESS;
END structural;
