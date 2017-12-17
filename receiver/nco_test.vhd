--***************************************
--* TITLE: NCO TESTBENCH (receiver)     *
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 13/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: NCO to divide the 100 Mhz clock of the Virtex II Pro.
--2)Principle:
-- When counting down, send a clk_en signal out and restart.
--3)Ingangen:
-- rst, clk
--4)Uitgangen:
-- clk_en
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY nco_test_rx IS
END nco_test_rx;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF nco_test_rx IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAY    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL rst        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.nco_rx(behavior)
	PORT MAP
	(
		clk    => clk,
		rst    => rst,
		clk_en => clk_en
	);
-- Only for synchronous components
clock : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR period/2;
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
		WAIT FOR PERIOD*2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- Free running NCO
	WAIT FOR PERIOD*100;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
