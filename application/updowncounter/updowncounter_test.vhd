--***************************************
--* TITLE: Counter TESTBENCH (sender) 	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 01/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Counting up/down
--2)Principle:
-- When up or down input is high, count
--3)Ingangen:
-- up, down, rst, clk, clk_en
--4)Uitgangen:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY counter_test IS
END counter_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF counter_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL up         : std_logic := '0';
	SIGNAL down       : std_logic := '0';
	SIGNAL output     : std_logic_vector(3 DOWNTO 0);
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.counter(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		up     => up,
		down   => down,
		output => output
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
	PROCEDURE test (CONSTANT testdata : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		up   <= testdata(0);
		down <= testdata(1);
		WAIT FOR period * 5;
		END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	test("01"); -- up=1, down=0
	test("00"); -- nothing
	test("11"); -- nothing
	test("10"); -- up=0, down=1
	test("00");
	clk_en <= '0'; -- disable clock
	test("10");
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
