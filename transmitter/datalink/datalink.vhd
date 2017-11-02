--***************************************
--* TITLE: Datalink (transmitter)	*
--* TYPE: Component			*
--* AUTHOR: Dylan Van Assche 		*
--* DATE: 25/10/2017 			*
--***************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Datalink layer API.
--2)Principle:
-- Provide an API as datalink layer
--3)Inputs:
-- data, pn_start, rst, clk, clk_en
--4)Outputs:
-- output
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY datalink_layer IS
	PORT
	(
		clk       : IN std_logic;
		clk_en    : IN std_logic;
		rst       : IN std_logic;
		data      : IN std_logic_vector(3 DOWNTO 0);
		pn_start  : IN std_logic;
		output	  : OUT std_logic
	);
END datalink_layer;
ARCHITECTURE behavior OF datalink_layer IS
	SIGNAL sh_output : std_logic;
	SIGNAL ld_output : std_logic;
BEGIN
--components
sequencecontroller : ENTITY work.sequencecontroller(behavior)
PORT MAP
(
	clk      => clk,
	clk_en   => clk_en,
	rst      => rst,
	pn_start => pn_start,
	ld       => ld_output,
	sh       => sh_output
);
datareg : ENTITY work.datareg(behavior)
PORT MAP
(
	clk    => clk,
	clk_en => clk_en,
	rst    => rst,
	sh     => sh_output,
	ld     => ld_output,
	output => output,
	data   => data         
);
END behavior;