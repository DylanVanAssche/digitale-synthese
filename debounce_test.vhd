--******************************************************************************
--*   TITLE:  Debouncer TESTBENCH (sender)           			       *
--*   TYPE:   Component                                                        *
--*   AUTHOR: Dylan Van Assche                                                 *
--*   DATE:   01/10/2017                                                       *
--******************************************************************************

--********************
--*   DESCRIPTION    *
--********************
--1)Purpose:
--  	TESTBENCH: Debouncing the input buttons.
--2)Principle:
-- 	When detecting 4 clock cycles the same input, data is valid.
--3)Ingangen:
-- 	cha, rst, clk
--4)Uitgangen:
-- 	syncha

--***************************
--*   LIBRARIES & ENTITY    *
--***************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;


ENTITY debouncer_test IS
END debouncer_test;

ARCHITECTURE structural OF debouncer_test IS 

COMPONENT debouncer
PORT (
	cha, clk, clk_en, rst: IN std_logic;
	syncha : OUT std_logic
);
END COMPONENT;

--**************************************************
--*   ARCHITECTURE, SIGNALS, TYPES & COMPONENTS    *
--**************************************************
FOR uut : debouncer USE ENTITY work.debouncer(behavior);

--initialize signals & constants
CONSTANT period : time := 100 ns;
CONSTANT delay  : time :=  10 ns;
SIGNAL end_of_sim : boolean := false;

SIGNAL clk: std_logic := '0';
SIGNAL clk_en: std_logic := '0';
SIGNAL rst: std_logic := '0';
SIGNAL cha: std_logic := '0';
SIGNAL syncha: std_logic := '0';

BEGIN

--****************
--*   MAPPING    *
--****************
uut: debouncer PORT MAP(
	clk => clk,
	clk_en => clk_en,
	rst => rst,
	cha => cha,
	syncha => syncha
);

--*******************
--*   STATEMENTS    *
--*******************
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
BEGIN
	-- 4 CLK cycles '0': expected result '0'
	clk_en <= '1';
	cha <= '0';
	WAIT FOR period*4;

	-- 4 CLK cycles '1': expected result '1'
	clk_en <= '1';
	cha <= '1';
	WAIT FOR period*4;

	-- 1 CLK cycle '0': expected result '0'
	clk_en <= '1';
	cha <= '0';
	WAIT FOR period;

	-- 3 CLK cycles '1': expected result '0'
	clk_en <= '1';
	cha <= '0';
	WAIT FOR period*3;

	-- 10 CLK cycles '0': expected result '0'
	clk_en <= '1';
	cha <= '0';
	WAIT FOR period*10;

	-- 5 CLK cycles '1': expected result '0'
	clk_en <= '0';
	cha <= '1';
	WAIT FOR period*5;

	-- 2 CLK cycles '0': expected result '0'
	cha <= '0';
	WAIT FOR period*2;

	end_of_sim <= true;
	WAIT;
END PROCESS;
END;