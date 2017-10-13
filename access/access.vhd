--*******************************
--* TITLE: Access (sender) 	*
--* TYPE: Component 		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 12/10/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Access layer API.
--2)Principle:
-- Provide an API as access layer
--3)Inputs:
-- data, pn_select, rst, clk, clk_en
--4)Outputs:
-- pn_start, tx
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY access_layer IS
	PORT (
		clk : IN std_logic;
		clk_en : IN std_logic;
		rst : IN std_logic;
		data : IN std_logic;
		pn_select : IN std_logic_vector(1 DOWNTO 0);
		pn_start : OUT std_logic;
		tx : OUT std_logic
	);
END access_layer;
ARCHITECTURE behavior OF access_layer IS
	SIGNAL pn_1_output : std_logic;
	SIGNAL pn_2_output : std_logic;
	SIGNAL pn_3_output : std_logic;
	SIGNAL pn_1_xor : std_logic;
	SIGNAL pn_2_xor : std_logic;
	SIGNAL pn_3_xor : std_logic;
BEGIN
	pn_1_xor <= pn_1_output XOR data;
	pn_2_xor <= pn_2_output XOR data;
	pn_3_xor <= pn_3_output XOR data;

	pngenerator : ENTITY work.pngenerator(behavior)
	PORT MAP
	(
		clk    => clk,
		clk_en => clk_en,
		rst => rst,
		pn_1 => pn_1_output,
		pn_2 => pn_2_output,
		pn_3 => pn_3_output,
		pn_s => pn_start
	);

	mux : ENTITY work.mux(behavior)
	PORT MAP
	(
		in_0 => data,
		in_1 => pn_1_xor,
		in_2 => pn_2_xor,
		in_3 => pn_3_xor,
		in_select => pn_select,              
		output => tx             
	);

END behavior;
