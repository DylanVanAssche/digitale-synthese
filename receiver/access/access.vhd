--*******************************
--* TITLE: Access (receiver)	*
--* TYPE: Topfile		*
--* AUTHOR: Dylan Van Assche 	*
--* DATE: 9/12/2017 		*
--*******************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- Access layer API.
--2)Principle:
-- Provide an API as access layer
--3)Inputs:
-- sdi_spread, pn_select, rst, clk, clk_en
--4)Outputs:
-- bitsample_out, databit
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY access_layer IS
	PORT
	(
		clk		: IN std_logic;
		clk_en		: IN std_logic;
		rst		: IN std_logic;
		sdi_spread	: IN std_logic;
		pn_select	: IN std_logic_vector(1 DOWNTO 0); -- select PN code
		bitsample_out	: OUT std_logic;
		databit		: OUT std_logic
	);
END access_layer;
ARCHITECTURE behavior OF access_layer IS
	SIGNAL chipsample_1	: std_logic := '1';
	SIGNAL chipsample_2	: std_logic := '1';
	SIGNAL chipsample_3	: std_logic := '1';
	SIGNAL bitsample	: std_logic := '0';
	SIGNAL bitsample_edged	: std_logic := '0';
	SIGNAL matchfilter_out	: std_logic := '0';
	SIGNAL despreader_out	: std_logic := '0';
	SIGNAL seq_det		: std_logic := '0';
	SIGNAL pn_1		: std_logic := '0';
	SIGNAL pn_2		: std_logic := '0';
	SIGNAL pn_3		: std_logic := '0';
	SIGNAL pn_seq		: std_logic := '0';
	SIGNAL sdi_despread	: std_logic := '0';
	SIGNAL extb		: std_logic := '0';
BEGIN
-- Connect signals to outputs
bitsample_out <= bitsample_edged;
-- Access layer parts
dpll : ENTITY work.dpll(behavior)
PORT MAP
(
	clk		=> clk,
	clk_en		=> clk_en,
	rst		=> rst,
	sdi_spread	=> sdi_spread,
	chipsample_1	=> chipsample_1,
	chipsample_2	=> chipsample_2,
	chipsample_3	=> chipsample_3,
	extb_out	=> extb
);
matchfilter : ENTITY work.matchfilter(behavior)
PORT MAP
(
	clk          => clk,
	clk_en       => clk_en,
	rst          => rst,
	sdi_spread   => sdi_spread,
	chipsample   => chipsample_1,
	seq_det      => matchfilter_out,
	pn_select    => pn_select
);
mux_match_pn : ENTITY work.mux(behavior)
PORT MAP
(
	in_0      => extb, -- No PN code
	in_1      => matchfilter_out,
	in_2      => matchfilter_out,
	in_3      => matchfilter_out,
	in_select => pn_select,
	output    => seq_det
);
pngenerator : ENTITY work.pngenerator(behavior)
PORT MAP
(
	clk        => clk,
	clk_en     => clk_en,
	rst        => rst,
	seq_det    => seq_det,
	bitsample  => bitsample,
	chipsample => chipsample_2,
	pn_1       => pn_1,
	pn_2       => pn_2,
	pn_3       => pn_3
);
-- PNgenerator depends on chipsample which causes the bitsample to be too long for the datalink's shiftregister.
-- The bitsample signal is reduced to the length of the clk_en period to avoid issues using an edgedetector.
edgedetector_bitsample : ENTITY work.edgedetector(behavior) 
PORT MAP
(
	data   => bitsample,
	puls   => bitsample_edged,
	clk    => clk,
	clk_en => clk_en,
	rst    => rst
);
mux_pn_despread : ENTITY work.mux(behavior)
PORT MAP
(
	in_0      => '0', -- not connected
	in_1      => pn_1,
	in_2      => pn_2,
	in_3      => pn_3,
	in_select => pn_select,
	output    => pn_seq
);
despread : ENTITY work.despreader(behavior)
PORT MAP
(
	clk          => clk,
	clk_en       => clk_en,
	rst          => rst,
	sdi_spread   => sdi_spread,
	pn_code      => pn_seq,
	chipsample   => chipsample_3,
	sdi_despread => despreader_out
);
mux_despread_correlator : ENTITY work.mux(behavior)
PORT MAP
(
	in_0      => sdi_spread,
	in_1      => despreader_out,
	in_2      => despreader_out,
	in_3      => despreader_out,
	in_select => pn_select,
	output    => sdi_despread
);
correlator : ENTITY work.correlator(behavior)
PORT MAP
(
	clk          => clk,
	clk_en       => clk_en,
	rst          => rst,
	chipsample   => chipsample_3,
	bitsample    => bitsample_edged,
	sdi_despread => sdi_despread,
	databit      => databit
);
END behavior;