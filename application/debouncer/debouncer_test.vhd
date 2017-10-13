--***************************************
--* TITLE: Debouncer TESTBENCH (sender) *
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 01/10/2017 			*
--***************************************
--********************
--* DESCRIPTION *
--********************
--1)Purpose:
-- TESTBENCH: Debouncing the input buttons.
--2)Principle:
-- When detecting 4 clock cycles the same input, data is valid.
--3)Inputs:
-- cha, rst, clk
--4)Outputs:
-- syncha
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY debouncer_test IS
END debouncer_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF debouncer_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic;
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic;
	SIGNAL cha        : std_logic;
	SIGNAL syncha     : std_logic;
BEGIN
--***********
--* MAPPING *
--***********
-- Connect ports to signals (PORT => SIGNAL)
uut : ENTITY work.debouncer(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		cha    => cha,
		syncha => syncha
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
tb : PROCESS
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
		cha <= testdata;
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
END;
