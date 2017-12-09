--*******************************************************
--* TITLE: DPLL Samplecounter TESTBENCH (receiver)	*
--* TYPE: Component	 				*
--* AUTHOR: Dylan Van Assche	 			*
--* DATE: 6/12/2017 					*
--*******************************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: DPLL sample counter counts down from a fixed value given by the periodcounter to synchronise with the transmitter data
--2)Principle:
-- Downcounter with a configurable reset value (Numerical Controlled Oscillator NCO) which resets on the value determined by the decoder.
-- The decoder gets the right segment signal from the semaphore. When the downcounter reaches 0 a pulse is generated (chipsample).
-- In order to synchronise every block in the receiver 3 chipsample signals are generated with a delay of 1 clock cycle between 
-- [chipsample_1, chipsample_2] and [chipsample_2, chipsample_3].
--3)Inputs:
-- segments
--4)Outputs:
-- chipsample_1, chipsample_2, chipsample_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY dpll_samplecounter_test IS
END dpll_samplecounter_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF dpll_samplecounter_test IS
	-- Segment codes for decoder
	CONSTANT SEG_A      : std_logic_vector(4 DOWNTO 0) := "10000";
	CONSTANT SEG_B      : std_logic_vector(4 DOWNTO 0) := "01000";
	CONSTANT SEG_C      : std_logic_vector(4 DOWNTO 0) := "00100";
	CONSTANT SEG_D      : std_logic_vector(4 DOWNTO 0) := "00010";
	CONSTANT SEG_E      : std_logic_vector(4 DOWNTO 0) := "00001";
	--initialize signals & constants test
	CONSTANT PERIOD		: TIME := 100 ns;
	CONSTANT DELAY		: TIME := 10 ns;
	SIGNAL end_of_sim	: BOOLEAN := false;
	SIGNAL clk		: std_logic := '0';
	SIGNAL clk_en		: std_logic := '1';
	SIGNAL rst		: std_logic := '0';
	SIGNAL chipsample_1	: std_logic := '0';
	SIGNAL chipsample_2	: std_logic := '0';
	SIGNAL chipsample_3	: std_logic := '0';
	SIGNAL segments		: std_logic_vector(4 DOWNTO 0) := SEG_C;
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.dpll_samplecounter(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		chipsample_1	=> chipsample_1,
		chipsample_2	=> chipsample_2,
		chipsample_3	=> chipsample_3,
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
	PROCEDURE test(TESTSEGMENT: std_logic_vector(4 DOWNTO 0)) IS
	BEGIN
		segments <= TESTSEGMENT;
		WAIT FOR PERIOD*20; -- make sure we are completely done
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data, test all segments
  	test(SEG_A);
	test(SEG_B);
	test(SEG_C);
	test(SEG_D);
	test(SEG_E);
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
