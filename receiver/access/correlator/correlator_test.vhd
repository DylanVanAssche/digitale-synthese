--***********************************************
--* TITLE: Correlator TESTBENCH (receiver)	*
--* TYPE: Component 				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 21/11/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Removing noise from the despreader signal
--2)Principle:
-- Up/Down counter to detect if the bit (holded in the chips) is '1' or '0'. 
-- A '1' increments the counter, a 0 decrements the counter.
-- On the bitsample signal we check the counter value when > 32 which is a bit = '1' otherwise the bit is '0'.
--3)Inputs:
-- sdi_despread, bitsample, chipsample, clk, clk_en, rst
--4)Outputs:
-- databit
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY correlator_test IS
END correlator_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF correlator_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '0';
	SIGNAL chip_sample     : std_logic := '0';
	SIGNAL bit_sample      : std_logic := '0';
	SIGNAL sdi_despread    : std_logic := '0';
	SIGNAL databit         : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.correlator(behavior)
	PORT MAP
	(
		clk          => clk,
		clk_en       => clk_en,
		rst          => rst,
		chip_sample  => chip_sample,
		bit_sample   => bit_sample,
		sdi_despread => sdi_despread,
		databit      => databit
	);
-- Only for synchronous components
clock : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR PERIOD/2;
	LOOP
		clk <= '0';
		WAIT FOR PERIOD/2;
		clk <= '1';
		WAIT FOR PERIOD/2;
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
		WAIT FOR PERIOD * 2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT TESTBIT : IN std_logic; CONSTANT TESTCHIP: IN std_logic; CONSTANT TESTDATA: IN std_logic) IS
	BEGIN
		bit_sample <= TESTBIT;
		chip_sample <= TESTCHIP;
		sdi_despread <= TESTDATA;
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	FOR i IN 0 TO 30 LOOP
		test('0', '1', '1');
	END LOOP;
	test('1', '0', '0'); -- show databit
	
	FOR i IN 0 TO 60 LOOP
		test('0', '1', '0');
	END LOOP;
	test('1', '0', '0'); -- show databit
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

