--***************************************
--* TITLE: Access TESTBENCH (sender) 	*
--* TYPE: Component 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 12/10/2017 			*
--***************************************
--********************
--* DESCRIPTION *
--********************
--1)Purpose:
-- TESTBENCH: Access layer API.
--2)Principle:
-- Provide an API as access layer
--3)Inputs:
-- rst, clk, clk_en
--4)Outputs:
-- output, display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY access_layer_test IS
END access_layer_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF access_layer_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic;
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic;
	SIGNAL data	  : std_logic;
	SIGNAL pn_select  : std_logic_vector(1 DOWNTO 0);
	SIGNAL pn_start   : std_logic;
	SIGNAL tx         : std_logic;
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.access_layer(behavior)
	PORT MAP
	(
		clk       => clk,
		clk_en    => clk_en,
		rst       => rst,
		data	  => data,
		pn_select => pn_select,
		pn_start => pn_start,
		tx => tx
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
	-- Test data
	FOR i IN 0 TO 3 LOOP
		pn_select <= CONV_STD_LOGIC_VECTOR(i, 2);
		data <= '1';
		WAIT FOR period*10;
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
