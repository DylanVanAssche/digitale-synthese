--***********************************************
--* TITLE: PNGenerator TESTBENCH (receiver)	*
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
ENTITY pngenerator_test IS
END pngenerator_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF pngenerator_test IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAY    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL pn_1       : std_logic;
	SIGNAL pn_2       : std_logic;
	SIGNAL pn_3       : std_logic;
	SIGNAL bitsample  : std_logic;
	SIGNAL chipsample : std_logic := '1';
	SIGNAL seq_det	  : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.pngenerator(behavior)
PORT MAP
(
	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	seq_det    => seq_det,
	bitsample  => bitsample,
	chipsample => chipsample,
	pn_1       => pn_1,
	pn_2       => pn_2,
	pn_3       => pn_3
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
	-- PN generator should generate PN code and bitsample should be triggered on full sequence
	WAIT FOR PERIOD*33;

	-- PN generator should reset on seq_det
	seq_det <= '1';
	WAIT FOR PERIOD;
	seq_det <= '0';
	WAIT FOR PERIOD*33;

	-- nothing should happen now:
	chipsample <= '0';
	WAIT FOR PERIOD*5;
	-- back to normal:
	chipsample <= '1';
	WAIT FOR PERIOD*5;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;