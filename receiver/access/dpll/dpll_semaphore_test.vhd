--***********************************************
--* TITLE: DPLL Semaphore TESTBENCH (receiver)	*
--* TYPE: Component	 			*
--* AUTHOR: Dylan Van Assche	 		*
--* DATE: 9/12/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: DPLL semaphore regulates the segment signals depending on extb and chipsample_1 signals (synchronisation).
--2)Principle:
-- Mealy statemachine (2 states):
-- 	* WAIT FOR EXTB: waiting for synchronisation pulse, send SEG_C out. On EXTB signal, go to WAIT FOR CS.
--	* WAIT FOR CS: waiting for chipsample pulse, send input segment (from periodcounter) out. On chipsample_1 signal, go to WAIT FOR EXTB.
--3)Inputs:
-- segments_in, extb, chipsample_1
--4)Outputs:
-- segments_out
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY dpll_semaphore_test IS
END dpll_semaphore_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF dpll_semaphore_test IS
	-- Segment codes for segments_in/out
	CONSTANT SEG_A      : std_logic_vector(4 DOWNTO 0) := "10000";
	CONSTANT SEG_B      : std_logic_vector(4 DOWNTO 0) := "01000";
	CONSTANT SEG_C      : std_logic_vector(4 DOWNTO 0) := "00100";
	CONSTANT SEG_D      : std_logic_vector(4 DOWNTO 0) := "00010";
	CONSTANT SEG_E      : std_logic_vector(4 DOWNTO 0) := "00001";
	--initialize signals & constants
	CONSTANT PERIOD		: TIME := 100 ns;
	CONSTANT DELAY		: TIME := 10 ns;
	SIGNAL end_of_sim	: BOOLEAN := false;
	SIGNAL clk		: std_logic := '0';
	SIGNAL clk_en		: std_logic := '1';
	SIGNAL rst		: std_logic := '0';
	SIGNAL extb		: std_logic := '0';
	SIGNAL chipsample_1	: std_logic := '0';
	SIGNAL segments_in	: std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
	SIGNAL segments_out	: std_logic_vector(4 DOWNTO 0) := (OTHERS => '0');
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.dpll_semaphore(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		extb		=> extb,
		chipsample_1	=> chipsample_1,
		segments_in	=> segments_in,
		segments_out	=> segments_out
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
	PROCEDURE test(TESTSEGMENT: std_logic_vector(4 DOWNTO 0); TESTEXTB: std_logic; TESTCS: std_logic) IS
	BEGIN
		segments_in <= TESTSEGMENT;
		extb <= TESTEXTB;
		chipsample_1 <= TESTCS;
		WAIT FOR PERIOD; -- make sure we are completely done
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- synchronise signal EXTB received, output = input
	test(SEG_A, '1', '0');
	test(SEG_B, '0', '0');
	test(SEG_C, '0', '0');
	test(SEG_D, '0', '0');
	test(SEG_E, '0', '0');
	test(SEG_A, '0', '0');
	-- out of sync since signal chipsample_1 received, output = SEG_C
	test(SEG_A, '0', '1');
	test(SEG_B, '0', '0');
	test(SEG_C, '0', '0');
	test(SEG_D, '0', '0');
	test(SEG_E, '0', '0');
	test(SEG_A, '0', '0');
	-- clk_en off, nothing may happen now:
	clk_en <= '0';
	test(SEG_B, '1', '0');
	test(SEG_D, '0', '0');
	test(SEG_E, '0', '1');
	test(SEG_A, '0', '0');
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;


