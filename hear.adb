-- Authors: Spencer Hirsch, shirsch2020@my.fit.edu
--          Tyler Gutowski, tgutowski2020@my.fit.edu
-- Course:  CSE 4250, Fall 2022
-- Project: Project 3, Can you HEAR me now?

WITH ADA.TEXT_IO;
WITH ADA.TEXT_IO.UNBOUNDED_IO;
WITH ADA.STRINGS;
WITH ADA.STRINGS.FIXED;
WITH ADA.INTEGER_TEXT_IO;
WITH ADA.CONTAINERS.DOUBLY_LINKED_LISTS;
WITH ADA.STRINGS.UNBOUNDED;
USE ADA.STRINGS.UNBOUNDED;
WITH GRAPH;


-- Main procedure that handles all input and processing.
-- Takes user input, then adds values to the graph package.
PROCEDURE HEAR IS
SUBTYPE POSITION IS INTEGER RANGE 0 .. 150;
IS_VALID_INPUT     : BOOLEAN         := TRUE;
LAST               : NATURAL;
FOREVER            : BOOLEAN         := TRUE;
INPUT              : STRING(1..150);
TOWER_FIRST_START  : POSITION;
TOWER_FIRST_END    : POSITION;
TOWER_SECOND_START : POSITION;
TOWER_SECOND_END   : POSITION;
COMMAND_INDEX      : POSITION;
COMMAND            : CHARACTER;

	-- Procedure used to process the user's input accordintly. The input is
	-- fragmented into multiple strings. This also calls the necessary graph
	-- operations to either prompt output, or to add new links to the graph.
    PROCEDURE PROCESS_STRING(TOWER_FIRST_NAME : STRING; TOWER_SECOND_NAME : STRING; COMMAND : CHARACTER) IS
	LINK_FOUND         : BOOLEAN             := FALSE;
	TOWER_SOURCE       : GRAPH.TOWERS_ACCESS := NEW GRAPH.TOWERS;
	TOWER_CONNECTED    : GRAPH.TOWERS_ACCESS := NEW GRAPH.TOWERS;
	FIRST_TOWER_EXISTS : BOOLEAN;
	BEGIN
		-- If the user inputs '.', they want to add a new link
		-- to the graph.
		IF COMMAND = '.' THEN
			FIRST_TOWER_EXISTS := GRAPH.EXISTS_IN_SOURCE(TOWER_FIRST_NAME);
			-- If the first tower exists, then you take the existing tower and
			-- add a new value to its "links" list.
			IF FIRST_TOWER_EXISTS THEN
				TOWER_CONNECTED.SOURCE := TO_UNBOUNDED_STRING(TOWER_SECOND_NAME);
				TOWER_SOURCE := GRAPH.GET_FROM_SOURCE(TOWER_FIRST_NAME);
				TOWER_SOURCE.LINK.APPEND(TOWER_CONNECTED);
			-- If the first tower doesn't exist, you must instance a new tower,
			-- and add it to the "sources" list.
			ELSE
				TOWER_SOURCE.SOURCE := TO_UNBOUNDED_STRING(TOWER_FIRST_NAME);		
				TOWER_CONNECTED.SOURCE := TO_UNBOUNDED_STRING(TOWER_SECOND_NAME);
				TOWER_SOURCE.LINK.APPEND(TOWER_CONNECTED);
				GRAPH.SOURCES.APPEND(TOWER_SOURCE);
			END IF;

		-- If the user inputs '?', they want to query two
		-- towers, to see if the first tower is connected
		-- to the second tower via the digraph.
		ELSIF COMMAND = '?' THEN
			FIRST_TOWER_EXISTS := GRAPH.EXISTS_IN_SOURCE(TOWER_FIRST_NAME);
			-- If the first tower isn't in the "source" list, then the connection doesnt exist.
			IF NOT FIRST_TOWER_EXISTS THEN
				ADA.TEXT_IO.PUT_LINE("- " & TOWER_FIRST_NAME & " => " & TOWER_SECOND_NAME); 
			-- If the first tower exists, and both towers are the same tower, then the connection
			-- should exist.
			ELSIF FIRST_TOWER_EXISTS AND TOWER_FIRST_NAME = TOWER_SECOND_NAME THEN
				ADA.TEXT_IO.PUT_LINE("+ " & TOWER_FIRST_NAME & " => " & TOWER_SECOND_NAME);
			-- Otherwise, as long as the first tower exists, attempt to
			-- find any matching towers using depth-first-search.
			ELSIF FIRST_TOWER_EXISTS THEN
				GRAPH.DFS(TOWER_FIRST_NAME, TOWER_SECOND_NAME, TOWER_FIRST_NAME);
			END IF;		
		END IF;
    END PROCESS_STRING;

    -- Returns the index of where a tower starts, given a string and a starting index.
	FUNCTION GET_TOWER_START( INPUT : STRING; START_INDEX : POSITION) RETURN INTEGER IS
	BEGIN
		FOR I IN START_INDEX..150 LOOP
			IF INPUT(I) /= ' ' THEN
				RETURN I;
			END IF;
		END LOOP;
	RETURN 0;
	END GET_TOWER_START;
	
	-- Returns the index of where a tower ends, given a string and a starting index.
	FUNCTION GET_TOWER_END( INPUT : STRING; START_INDEX : POSITION) RETURN INTEGER IS
	BEGIN
		FOR I IN START_INDEX..150 LOOP
			IF INPUT(I) = ' ' THEN
				RETURN (I - 1);
			ELSIF INPUT(I) = '.' THEN
				RETURN (I - 1);
			ELSIF INPUT(I) = '?' THEN
				RETURN (I - 1);
			END IF;
		END LOOP;
	RETURN 0;
	END GET_TOWER_END;

    -- Returns the index of a '?' or a '.', as long as it exists. If neither character exist,
	-- return 0
	FUNCTION GET_COMMAND_POSITION( INPUT : STRING; START_INDEX : POSITION; END_INDEX : INTEGER) RETURN INTEGER IS
	BEGIN
		FOR I IN START_INDEX..END_INDEX LOOP
			IF INPUT(I) = '.' THEN
				RETURN (I);
			ELSIF INPUT(I) = '?' THEN
				RETURN (I);
			ELSIF INPUT(I) = '#' THEN
				RETURN 0;
			END IF;
		END LOOP;
	RETURN 0;
	END GET_COMMAND_POSITION;


	-- Returns the character that exists at an index, given a string and an index.
	FUNCTION GET_CHAR_AT_INDEX( INPUT : STRING; INDEX : POSITION) RETURN CHARACTER IS
	BEGIN
		RETURN INPUT(INDEX);
	END GET_CHAR_AT_INDEX;
	
	
	FUNCTION GET_TOWER_NAME( INPUT : STRING; START_INDEX : POSITION; END_INDEX : POSITION ) RETURN STRING IS
	TOWER_NAME : STRING(1..(END_INDEX - START_INDEX + 1));
	BEGIN
		TOWER_NAME := INPUT(START_INDEX..END_INDEX);
		RETURN TOWER_NAME;
	END GET_TOWER_NAME;


BEGIN
	-- Iterate forever, in order to allow inputs indefinitely.
    WHILE FOREVER LOOP
		-- Reset the checked values each iteration.
		GRAPH.RESET_CHECKED_SOURCES;
		
		-- Reset the print variable each iteration.
		GRAPH.ALREADY_PRINTED_DFS := FALSE;
		-- Reset the valid input variable each iteration
		IS_VALID_INPUT := TRUE;
		
		
		-- Get input each line
        ADA.TEXT_IO.GET_LINE(ITEM => INPUT, LAST => LAST);
		
		-- Get the tower starts and ends
		TOWER_FIRST_START := GET_TOWER_START(INPUT, 1);
		TOWER_FIRST_END := GET_TOWER_END(INPUT, TOWER_FIRST_START);
		TOWER_SECOND_START := GET_TOWER_START(INPUT, TOWER_FIRST_END + 1);
		TOWER_SECOND_END := GET_TOWER_END(INPUT, TOWER_SECOND_START);
		
		-- Get the index of the command, '?' or '.'.
		COMMAND_INDEX := GET_COMMAND_POSITION(INPUT, TOWER_SECOND_END + 1, 150);
		
		-- As long as there is a command, then which command it is.
		IF COMMAND_INDEX /= 0 THEN
			COMMAND := GET_CHAR_AT_INDEX(INPUT, COMMAND_INDEX);
		-- Otherwise, if there is no command, the input is invalid.
		ELSE
			IS_VALID_INPUT := FALSE;
		END IF;
		
		-- As long as the input is valid, process the string.
		IF IS_VALID_INPUT THEN
			PROCESS_STRING(GET_TOWER_NAME(INPUT,TOWER_FIRST_START,TOWER_FIRST_END),
						   GET_TOWER_NAME(INPUT,TOWER_SECOND_START,TOWER_SECOND_END),
						   COMMAND);
		END IF;
    END LOOP;
END HEAR;