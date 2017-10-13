--***********************************************
--* TITLE: PNGenerator TESTBENCH (sender)	*
--* TYPE: Component 		          	*
--* AUTHOR: Dylan Van Assche 	  		*
--* DATE: 12/10/2017 		         	*
--***********************************************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Generating a PN code
--2)Principle:
-- Lineair feedback register to generate a PN code (31 bits)
--3)Inputs:
-- rst, clk, clk_en
--4)Outputs:
-- pn_s, pn_1, pn_2, pn_3
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
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic;
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic;
	SIGNAL pn_1       : std_logic;
	SIGNAL pn_2       : std_logic;
	SIGNAL pn_3       : std_logic;
	SIGNAL pn_s	  : std_logic;
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.pngenerator(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst    => rst,
		pn_1   => pn_1,
		pn_2   => pn_2,
		pn_3   => pn_3,
		pn_s   => pn_s
	);
-- Only for synchronous components
clock : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR period/2;
	LOOP
		clk <= '0';
		WAIT FOR period/2;
		clk <= '1';
		WAIT FOR period/2;
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
		WAIT FOR period * 2;
		rst <= '0';
		WAIT FOR period;
	END reset;
BEGIN
	-- Reset at startup
	reset;
	-- Test runs automatically only a wait statement is required
	WAIT FOR period*33;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
