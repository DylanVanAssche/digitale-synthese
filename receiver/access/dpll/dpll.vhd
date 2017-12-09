--***************************************
--* TITLE: DPLL (receiver)		*
--* TYPE: Top File 			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 9/12/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Synchronise the receiver with the sender on chipslevel, 
-- the other components of the access layer know then when they have to sample the signal.
--2)Principle:
--	* Transitiondetector to detect transition on the sdi_spread signal.
--	* Periodcounter (deadendupcounter) to measure the time between 2 transitions.
-- 	* Semaphore to react on the period of the signal and synchronisation signals (extb and chipsample_1).
--	* Samplecounter (downcounter) which sends the chipsample signals out when it reaches 0. 
--	  A small register delays the different kind of chipsample signals to synchronise every block from the access layer.
--3)Inputs:
-- sdi_spread, clk, clk_en, rst
--4)Outputs:
-- chipsample_1, chipsample_2, chipsample_3
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY dpll IS
	PORT (
		clk		: IN  std_logic;
		clk_en		: IN  std_logic;
		rst		: IN  std_logic;
		sdi_spread	: IN  std_logic;
		chipsample_1	: OUT std_logic;
		chipsample_2	: OUT std_logic;
		chipsample_3	: OUT std_logic;
		extb_out	: OUT std_logic
  	 );
END dpll;

--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE behavior OF dpll IS
	SIGNAL extb			: std_logic;
	SIGNAL chipsample_semaphore	: std_logic;
	SIGNAL segments_periodcounter	: std_logic_vector(4 DOWNTO 0);
	SIGNAL segments_semaphore	: std_logic_vector(4 DOWNTO 0);
BEGIN
-- Map signals to outputs
chipsample_1 <= chipsample_semaphore;
extb_out <= extb;
-- DPLL parts
transdect : ENTITY work.dpll_transdect(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		sdi_spread	=> sdi_spread,
		extb		=> extb
	);
periodcounter : ENTITY work.dpll_periodcounter(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		extb		=> extb,
		segments	=> segments_periodcounter
	);
semaphore : ENTITY work.dpll_semaphore(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		extb		=> extb,
		chipsample_1	=> chipsample_semaphore,
		segments_in	=> segments_periodcounter,
		segments_out	=> segments_semaphore
	);
samplecounter : ENTITY work.dpll_samplecounter(behavior)
	PORT MAP
	(
		clk		=> clk,
		clk_en		=> clk_en,
		rst		=> rst,
		chipsample_1	=> chipsample_semaphore,
		chipsample_2	=> chipsample_2,
		chipsample_3	=> chipsample_3,
		segments	=> segments_semaphore
	);
END behavior;


