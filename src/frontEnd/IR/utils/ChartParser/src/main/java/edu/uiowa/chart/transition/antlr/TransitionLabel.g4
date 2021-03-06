/*
 * This file is part of CoCoSim.
 * Copyright (C) 2017-2018  The University of Iowa
 */
 
 /** 
 * @author Mudathir Mahgoub
 */
 
grammar TransitionLabel;

// parser rules

transitionLabel : eventOrMessage?
                    (LeftSquareBracket condition RightSquareBracket)?
                    (LeftCurlyBracket conditionAction RightCurlyBracket)?
                    (Slash LeftCurlyBracket transitionAction RightCurlyBracket)? ;

eventOrMessage : Identifier;

condition:  (.)*?  ;

conditionAction: (.)*? ;

transitionAction: (.)*? ;

// lexer rules

LeftSquareBracket : '[' ;

RightSquareBracket : ']' ;

LeftCurlyBracket : '{' ;

RightCurlyBracket : '}' ;

Slash : '/' ;

Identifier : IdentifierLetter (IdentifierLetter | Digit)* ;

IdentifierLetter : 'a'..'z'|'A'..'Z'|'_' ;

Digit : '0'..'9' ;

LineComment : '%' .*? '\n' -> skip ;

WhiteSpace : [ \t\r]+ -> skip ;

AnyCharacter : . ;