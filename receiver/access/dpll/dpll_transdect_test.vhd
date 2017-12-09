--***************************************************************
--* TITLE: DPLL Transition detector TESTBENCH (receiver)	*
--* TYPE: Component						*
--* AUTHOR: Dylan Van Assche 		       			*
--* DATE: 5/12/2017 			       			*
--***************************************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Detect transitions on sdi_spread
--2)Principle:
-- Wait for transition on sdi_spread.
-- Send puls out for 1 CLK period.
-- Moore statemachine (4 states):
--	* WAIT FOR 0: wait until the input returns to 0, go to PULSE 0.
--	* WAIT FOR 1: wait until the input returns to 1, go to PULSE 1.
--	* PULSE 0: send out pulse for 1 CLK period, go to WAIT FOR 1.
--	* PULSE 1: send out pulse for 1 CLK period, go to WAIT FOR 0.
--3)Inputs:
-- sdi_spread, clk, clk_en, rst
--4)Outputs:
-- extb
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY dpll_transdect_test IS
END dpll_transdect_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF dpll_transdect_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '0';
	SIGNAL sdi_spread      : std_logic := '0';
	SIGNAL extb            : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.dpll_transdect(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		sdi_spread	=> sdi_spread,
		extb		=> extb
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
		WAIT FOR PERIOD*2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- Puls for transition 0 -> 1:
	sdi_spread <= '0';
	sdi_spread <= '1';
	WAIT FOR PERIOD*3;
	-- Puls for transition 1 -> 0:
	sdi_spread <= '1';
	sdi_spread <= '0';
	WAIT FOR PERIOD*3;
	-- 2x Puls for transitions  1 -> 0 and 0 -> 1:
	sdi_spread <= '1';
	sdi_spread <= '0';
	sdi_spread <= '1';
	WAIT FOR PERIOD*3;
	-- clk_en off nothing may happen now:
	clk_en <= '0';
	sdi_spread <= '1';
	sdi_spread <= '0';
	WAIT FOR PERIOD*3;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

