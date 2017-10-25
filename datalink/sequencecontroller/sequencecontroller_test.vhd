--*******************************************************
--* TITLE: Sequencecontroller TESTBENCH (sender)	*
--* TYPE: Component 					*
--* AUTHOR: Dylan Van Assche 				*
--* DATE: 19/10/2017 					*
--*******************************************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Controlling the behavior of the dataregister
--2)Principle:
-- When 0, emit load signal. Data is loaded into the register. From 1 to 10 data is shifted by emitting the shift signal.
-- On 10, the counter rests itself and the sequence starts again.
--3)Inputs:
-- clk, clk_en, rst, pn_start
--4)Outputs:
-- ld, sh
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY sequencecontroller_test IS
END sequencecontroller_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF sequencecontroller_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL pn_start   : std_logic := '0';
	SIGNAL ld         : std_logic :='0';
	SIGNAL sh         : std_logic :='0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.sequencecontroller(behavior)
	PORT MAP
	(
		clk      => clk,
		clk_en   => clk_en,
		rst      => rst,
		pn_start => pn_start,
		ld       => ld,
		sh       => sh
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
	PROCEDURE test IS
	BEGIN
		pn_start <= '1';
		WAIT FOR period * 1;
		pn_start <= '0';
		END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	FOR i IN 0 TO 11 LOOP -- 12 loops: 1 full cycle + start of the next one
		test;
		WAIT FOR period*30; -- 1 period from pn_start + 30 = 31 periods
	END LOOP;
	clk_en <= '0'; -- disable clock
	test;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

