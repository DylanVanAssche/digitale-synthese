--***********************************************
--* TITLE: Access TESTBENCH (transmitter)	*
--* TYPE: Top File 				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 12/10/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
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
ENTITY access_layer_test_tx IS
END access_layer_test_tx;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF access_layer_test_tx IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL data	  : std_logic := '0';
	SIGNAL pn_start   : std_logic := '0';
	SIGNAL tx         : std_logic := '0';
	SIGNAL pn_select  : std_logic_vector(1 DOWNTO 0) := (OTHERS => '0');
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.access_layer_tx(behavior)
	PORT MAP
	(
		clk       => clk,
		clk_en    => clk_en,
		rst       => rst,
		data	  => data,
		pn_select => pn_select,
		pn_start  => pn_start,
		tx        => tx
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
		WAIT FOR period * 4;
		rst <= '0';
		WAIT FOR period;
	END reset;
BEGIN
	-- Reset at startup
	reset;
	-- Test data with all MUX
	-- data '1'
	FOR i IN 0 TO 3 LOOP
		pn_select <= CONV_STD_LOGIC_VECTOR(i, 2);
		data <= '1';
		WAIT FOR period*10;
	END LOOP;
	-- data '0'
	FOR i IN 0 TO 3 LOOP
		pn_select <= CONV_STD_LOGIC_VECTOR(i, 2);
		data <= '0';
		WAIT FOR period*10;
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;