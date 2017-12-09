--***********************************************
--* TITLE: Application TESTBENCH (receiver)	*
--* TYPE: Top File 				*
--* AUTHOR: Dylan Van Assche			*
--* DATE: 14/11/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Application layer API.
--2)Principle:
-- Provide an API as application layer
--3)Inputs:
-- cha, rst, clk, clk_en
--4)Outputs:
-- output, display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY application_layer_test IS
END application_layer_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF application_layer_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '1';
	SIGNAL bitsample       : std_logic := '1';
	SIGNAL preamble        : std_logic_vector(6 DOWNTO 0) := "0000000";
	SIGNAL data_in         : std_logic_vector(3 DOWNTO 0) := "0000";
	SIGNAL display_b       : std_logic_vector(6 DOWNTO 0) := "0000000";
	CONSTANT PREAMBLE_CODE : std_logic_vector(6 DOWNTO 0) := "0111110";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.application_layer(behavior)
	PORT MAP
	(
		clk       => clk,
		clk_en    => clk_en,
		rst       => rst,
		bitsample => bitsample,
		preamble  => preamble,
		data_in   => data_in,
		display_b => display_b
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
	PROCEDURE test (CONSTANT TESTDATA : IN std_logic_vector(10 DOWNTO 0)) IS
	BEGIN
		preamble <= TESTDATA(10 DOWNTO 4);
		data_in <= TESTDATA(3 DOWNTO 0);
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	test(PREAMBLE_CODE & "0101");
	test(PREAMBLE_CODE & "1111");
	WAIT FOR PERIOD;
	
	test("0000000" & "0100");
	test(PREAMBLE_CODE & "0001");
	WAIT FOR PERIOD;
	
	bitsample <= '0'; -- disable bitsample 'clock'
	test("0000000" & "0110");
	test(PREAMBLE_CODE & "1001");
	WAIT FOR PERIOD;
	
	clk_en <= '0'; -- disable clock
	test(PREAMBLE_CODE & "0101");
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
