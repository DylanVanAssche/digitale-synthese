--***************************************
--* TITLE: DPLL TESTBENCH(receiver)	*
--* TYPE: Top File 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 9/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Synchronise the receiver with the sender on chipslevel, 
-- the other components of the access layer know then when they have to sample the signal.
--2)Principle:
--	* Transitiondetector to detect transition on the sdi_spread signal.
--	* Periodcounter (deadendupcounter) to measure the time between 2 transitions.
-- 	* Semaphore to react on the period of the signal and synchronisation signals (extb and chipsample_1).
--	* Samplecounter (downcounter) which sends the chipsample signals out when it reaches 0. 
--	  A small register delays the different kind of chipsample signals to synchronise every block from the access layer.
--3)Inputs:
-- sdi_spread, clk, clk_en, rst
--4)Outputs:
-- chipsample_1, chipsample_2, chipsample_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY dpll_test IS
END dpll_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF dpll_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '0';
	SIGNAL sdi_spread      : std_logic := '0';
	SIGNAL chipsample_1    : std_logic := '0';
	SIGNAL chipsample_2    : std_logic := '0';
	SIGNAL chipsample_3    : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.dpll(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		sdi_spread	=> sdi_spread,
		chipsample_1	=> chipsample_1,
		chipsample_2	=> chipsample_2,
		chipsample_3	=> chipsample_3
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
	-- Same testbench as transdetector but with longer WAIT FOR PERIODS to see the output from the counters.
	-- Puls for transition 0 -> 1:
	sdi_spread <= '0';
	sdi_spread <= '1';
	WAIT FOR PERIOD*16;
	-- Puls for transition 1 -> 0:
	sdi_spread <= '1';
	sdi_spread <= '0';
	WAIT FOR PERIOD*16;
	-- 2x Puls for transitions  1 -> 0 and 0 -> 1:
	sdi_spread <= '1';
	sdi_spread <= '0';
	sdi_spread <= '1';
	WAIT FOR PERIOD*16;
	-- clk_en off nothing may happen now:
	clk_en <= '0';
	sdi_spread <= '1';
	sdi_spread <= '0';
	WAIT FOR PERIOD*3;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;



