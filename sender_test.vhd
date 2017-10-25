--***************************************
--* TITLE: Sender TESTBENCH (sender) 	*
--* TYPE: Top File			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 25/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Connect all the layers into 1 VHDL file.
--2)Principle:
-- Connect every layer API.
--3)Inputs:
-- up, down, pn_select, rst, clk, clk_en
--4)Outputs:
-- tx
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY sender_test IS
END sender_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF sender_test IS
	--initialize signals & constants
	CONSTANT period   : TIME := 100 ns;
	CONSTANT delay    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL clk_en     : std_logic := '1';
	SIGNAL rst        : std_logic := '0';
	SIGNAL up         : std_logic := '0';
	SIGNAL down       : std_logic := '0';
	SIGNAL tx	  : std_logic := '0';
	SIGNAL pn_select  : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL display_b  : std_logic_vector(6 DOWNTO 0) := "1111111";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.sender(behavior)
	PORT MAP
	(
		clk       => clk,
		clk_en    => clk_en,
		rst       => rst,
		up        => up,
		down      => down,
		pn_select => pn_select,
		display_b => display_b,
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
		WAIT FOR period * 2;
		rst <= '0';
		WAIT FOR period;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT testdata : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		up   <= testdata(0);
		down <= testdata(1);
		WAIT FOR period * 5;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	FOR mux_state IN 0 TO 3 LOOP
		pn_select <= CONV_STD_LOGIC_VECTOR(mux_state, 2); -- loop through all MUX states
		test("01"); -- up=1, down=0
		test("00"); -- nothing
		test("11"); -- nothing
		test("10"); -- up=0, down=1
		test("00");
	END LOOP;
	clk_en <= '0'; -- disable clock
	test("10");
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;