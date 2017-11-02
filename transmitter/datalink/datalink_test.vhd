--***********************************************
--* TITLE: Datalink TESTBENCH (transmitter)	*
--* TYPE: Top File				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 25/10/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Datalink layer API.
--2)Principle:
-- Provide an API as datalink layer
--3)Inputs:
-- data, pn_start, rst, clk, clk_en
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY datalink_layer_test IS
END datalink_layer_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF datalink_layer_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL data	  : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL pn_start   : std_logic := '0';
	SIGNAL output	  : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.datalink_layer(behavior)
	PORT MAP
	(
		clk       => clk,
		clk_en    => clk_en,
		rst       => rst,
		data	  => data,
		pn_start  => pn_start,
		output    => output
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
	FOR i IN 0 TO 15 LOOP -- all possible counter values
		data <= CONV_STD_LOGIC_VECTOR(i, 4); -- counter
		pn_start <= '1'; -- trigger every 31 periods a PN_START reduced to 5 periods
		WAIT FOR period*1;
		pn_start <= '0';
		WAIT FOR period*5;
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;