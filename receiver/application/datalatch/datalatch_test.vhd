--***********************************************
--* TITLE: Dataregister TESTBENCH (receiver)	*
--* TYPE: Component 				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 26/10/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Read the serial data stream from the access layer and keep it for a limited time in a register.
-- Application layer will 'ask' if the preamble is in the register before it reads from it
--2)Principle:
-- When the shift signal is received, data is shifted out (1 place).
--3)Inputs:
-- sh, serialdata, clk, clk_en, rst
--4)Outputs:
-- preamble, value
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY datalatch_test IS
END datalatch_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF datalatch_test IS
	--initialize signals & constants
	CONSTANT PERIOD		: TIME := 100 ns;
	CONSTANT DELAY		: TIME := 10 ns;
	SIGNAL end_of_sim	: BOOLEAN := false;
	SIGNAL clk		: std_logic := '0';
	SIGNAL clk_en		: std_logic := '1';
	SIGNAL rst		: std_logic := '0';
	SIGNAL bitsample	: std_logic := '1';
	SIGNAL preamble		: std_logic_vector(6 DOWNTO 0) := (OTHERS => '0'); -- preamble input from datashiftreg datalink layer
	SIGNAL data_in		: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); -- data input from datashiftreg datalink layer
	SIGNAL data_out		: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); -- valid data
	-- preamble valid code:
	CONSTANT PREAMBLE_VALUE	: std_logic_vector(6 DOWNTO 0) := "0111110";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.datalatch(behavior)
	PORT MAP
	(
		clk        => clk,
		clk_en     => clk_en,
		rst        => rst,
		bitsample  => bitsample,
		preamble   => preamble,
		data_in    => data_in,
		data_out   => data_out 
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
	PROCEDURE test (CONSTANT TESTPREAMBLE: IN std_logic_vector(6 DOWNTO 0); CONSTANT TESTDATA: IN std_logic_vector(3 DOWNTO 0)) IS
	BEGIN
		preamble <= TESTPREAMBLE;
		data_in <= TESTDATA;
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- output = input
	test(PREAMBLE_VALUE, "0001");
	test(PREAMBLE_VALUE, "0010");
	-- remember old output
	test("0011111", "0100");
	test("0110110", "1000");
	-- nothing may happen now:
	clk_en <= '0';
	test(PREAMBLE_VALUE, "1010");
	WAIT FOR PERIOD*3;
	clk_en <= '1';
	bitsample <= '0';
	test(PREAMBLE_VALUE, "1111");
	WAIT FOR PERIOD*3;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;

