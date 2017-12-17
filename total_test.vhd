--*******************************
--* TITLE: Total TESTBENCH    	*
--* TYPE: Top File		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 12/12/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Connect both transmitter and receiver with each other for testing purposes.
--2)Principle:
-- Connect the output of the transmitter to the input of the receiver.
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
ENTITY total_test IS
END total_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF total_test IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAY    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL rst        : std_logic := '0';
	SIGNAL up         : std_logic := '0';
	SIGNAL down       : std_logic := '0';
	SIGNAL pn_select  : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL display_b  : std_logic_vector(6 DOWNTO 0) := "1111111";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.total(behavior)
	PORT MAP
	(
		clk       => clk,
		rst       => rst,
		up        => up,
		down      => down,
		pn_select => pn_select,
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
		WAIT FOR PERIOD*2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT testdata : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		-- simulate user pushes buttons
		--up   <= testdata(0);
		--down <= testdata(1);
		up <= '1';
		down <= '0';
		WAIT FOR PERIOD*1000;
		up <= '0';
		down <= '0';
		WAIT FOR PERIOD;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	--FOR mux_state IN 0 TO 3 LOOP
--		FOR i IN 0 TO 35 LOOP
--			pn_select <= CONV_STD_LOGIC_VECTOR(mux_state, 2); -- loop through all MUX states
--			test("01"); -- up=1, down=0
--			test("00"); -- nothing
--		END LOOP;
--	END LOOP;
	pn_select <= "00";
	test("01"); -- up=1, down=0
	WAIT FOR PERIOD*100000; -- a lot of clock cycles are needed
	test("01"); -- nothing
	WAIT FOR PERIOD*100000;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
