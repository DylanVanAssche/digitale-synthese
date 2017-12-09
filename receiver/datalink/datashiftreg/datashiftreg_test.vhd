--***********************************************
--* TITLE: Datashiftreg TESTBENCH (receiver)	*
--* TYPE: Component 		          	*
--* AUTHOR: Dylan Van Assche 	  		*
--* DATE: 29/11/2017 		         	*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Generating a PN code
--2)Principle:
-- Lineair feedback register to generate a PN code (31 bits)
--3)Inputs:
-- rst, clk, clk_en
--4)Outputs:
-- pn_start, pn_1, pn_2, pn_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY datashiftreg_test IS
END datashiftreg_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF datashiftreg_test IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAY    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL bitsample  : std_logic := '1';
	SIGNAL databit    : std_logic := '0';
	SIGNAL preamble   : std_logic_vector(6 DOWNTO 0);
	SIGNAL data       : std_logic_vector(3 DOWNTO 0);
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.datashiftreg(behavior)
PORT MAP
(
	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	bitsample  => bitsample,
	databit    => databit,
	preamble   => preamble,
	data       => data
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
BEGIN
	-- Reset at startup
	reset;

	-- Test data
	FOR i IN 0 TO 15 LOOP
		databit <= CONV_STD_LOGIC_VECTOR(i, 4)(1); -- pick bit 1 as data
		WAIT FOR PERIOD;		
	END LOOP;

	-- nothing should happen now:
	bitsample <= '0';
	WAIT FOR PERIOD*5;
	-- back to normal:
	bitsample <= '1';
	WAIT FOR PERIOD*5;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;