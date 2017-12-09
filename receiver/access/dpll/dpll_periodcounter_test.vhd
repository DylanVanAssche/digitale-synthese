--*******************************************************
--* TITLE: DPLL Periodcounter TESTBENCH (receiver)	*
--* TYPE: Component	 				*
--* AUTHOR: Dylan Van Assche	 			*
--* DATE: 5/12/2017 					*
--*******************************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: DPLL period counter counts the periods of the transition detector pulses.
--2)Principle:
-- Deadendupcounter (4 bits) which decodes the segments of the period as output.
-- Segments are exclusive active! Each period is divided in 16 pieces and we want to sample in segment C (middle of a period)
-- Synchronisation is needed to do this!
--3)Inputs:
-- extb
--4)Outputs:
-- segments
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY dpll_periodcounter_test IS
END dpll_periodcounter_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF dpll_periodcounter_test IS
	--initialize signals & constants
	CONSTANT PERIOD		: TIME := 100 ns;
	CONSTANT DELAY		: TIME := 10 ns;
	SIGNAL end_of_sim	: BOOLEAN := false;
	SIGNAL clk		: std_logic := '0';
	SIGNAL clk_en		: std_logic := '1';
	SIGNAL rst		: std_logic := '0';
	SIGNAL extb		: std_logic := '0';
	SIGNAL segments		: std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.dpll_periodcounter(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		extb		=> extb,
		segments	=> segments
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
	-- Test data procedure
	PROCEDURE test IS
	BEGIN
		extb <= '1';
		WAIT FOR PERIOD;
		extb <= '0';
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data, first pass will be too short to reach deadend
  	FOR i IN 0 TO 2 LOOP
	    test;
	WAIT FOR PERIOD * (10 + i*15);
	END LOOP;
	-- clk_en off nothing may happen now:
	clk_en <= '0';
	test;
	
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;



