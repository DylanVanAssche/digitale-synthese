--******************************
--* TITLE: Total              	*
--* TYPE: Top File			          *
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 12/12/2017 			       *
--******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Connect both transmitter and receiver with each other for testing purposes.
--2)Principle:
-- Connect the output of the transmitter to the input of the receiver.
--3)Inputs:
-- up, down, pn_select, rst, clk, clk_en
--4)Outputs:
-- tx
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY total IS
	PORT
	(
		clk		: IN std_logic;
		rst		: IN std_logic;
		up		: IN std_logic;
		down		: IN std_logic;
		pn_select	: IN std_logic_vector(1 DOWNTO 0);
		display_b	: OUT std_logic_vector(6 DOWNTO 0)
	);
END total ;
ARCHITECTURE behavior OF total IS
	SIGNAL output_transmitter	: std_logic;
	SIGNAL display_b_rx		: std_logic_vector(6 DOWNTO 0);
BEGIN
--components
transmitter : ENTITY work.transmitter(behavior)
PORT MAP
(
	clk		=> clk,
	rst		=> rst,
	up		=> up,
	down		=> down,
	pn_select	=> pn_select,
	display_b	=> display_b_rx,
	tx		=> output_transmitter
);
receiver : ENTITY work.receiver(behavior)
PORT MAP
(
	clk		=> clk,
	rst		=> rst,
	rx		=> output_transmitter,
	pn_select	=> pn_select,
	display_b	=> display_b      
);
END behavior;
