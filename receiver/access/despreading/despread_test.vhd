--***********************************************
--* TITLE: Despreader TESTBENCH (receiver)	*
--* TYPE: Component 				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 14/11/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: EXOR'ing with noise reduction
--2)Principle:
-- Timed EXOR'ing which is synced to the DPLL to reduce the noise on sdi_spread.
--3)Inputs:
-- sdi_spread, pn_code, clk, clk_en, rst
--4)Outputs:
-- sdi_despread
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY despreader_test IS
END despreader_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF despreader_test IS
	--initialize signals & constants
	CONSTANT PERIOD        : TIME := 100 ns;
	CONSTANT DELAY         : TIME := 10 ns;
	SIGNAL end_of_sim      : BOOLEAN := false;
	SIGNAL clk             : std_logic := '0';
	SIGNAL clk_en          : std_logic := '1';
	SIGNAL rst             : std_logic := '0';
	SIGNAL chip_sample     : std_logic := '1';
	SIGNAL sdi_spread      : std_logic := '0';
	SIGNAL pn_code         : std_logic := '0';
	SIGNAL sdi_despread    : std_logic := '0';
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.despreader(behavior)
	PORT MAP
	(
		clk          => clk,
		clk_en       => clk_en,
		rst          => rst,
		sdi_spread   => sdi_spread,
		pn_code      => pn_code,
		chip_sample  => chip_sample,
		sdi_despread => sdi_despread
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
	PROCEDURE test (CONSTANT TESTDATA : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		sdi_spread <= TESTDATA(0);
		pn_code <= TESTDATA(1);
		WAIT FOR PERIOD*3;
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	FOR i IN 0 TO 3 LOOP
		test(CONV_STD_LOGIC_VECTOR(i, 2));
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;
