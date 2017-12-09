--***************************************
--* TITLE: Application (receiver)	*
--* TYPE: Topfile			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 14/11/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Application layer API.
--2)Principle:
-- Provide an API as application layer
--3)Inputs:
-- preamble, value, rst, clk, clk_en
--4)Outputs:
-- display_b
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY application_layer IS
	PORT
	(
		clk       : IN std_logic;
		clk_en    : IN std_logic;
		rst       : IN std_logic;
		bitsample : IN std_logic;
		preamble  : IN std_logic_vector(6 DOWNTO 0);
		data_in   : IN std_logic_vector(3 DOWNTO 0);
		display_b : OUT std_logic_vector(6 DOWNTO 0)
	);
END application_layer;
ARCHITECTURE behavior OF application_layer IS
	SIGNAL data_out     : std_logic_vector(3 DOWNTO 0);
BEGIN
datalatch : ENTITY work.datalatch(behavior)
PORT MAP
(
  	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	bitsample  => bitsample,
	data_in    => data_in,
	preamble   => preamble,
	data_out  => data_out
);
decoder : ENTITY work.decoder(behavior)
PORT MAP
(
	bin    => data_out,
	disp_b => display_b
);
END behavior;
