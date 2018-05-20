grammar StateLabel;

// parser rules

stateLabel : Identifier '\r'? '\n'* actions?;

actions : (action)+ ;

action : actionType (',' actionType)*  ':'  actionBody;

actionType: Entry
            | During
            | Exit
            | Bind
            | On Identifier
            | On After '(' Number ',' Identifier ')'
            | On Before '(' Number ',' Identifier ')'
            | On At '(' Number ',' Identifier ')'
            | On Every '(' Number ',' Identifier ')'
            ;

actionBody: (.| '\r'? '\n')*? ;

// lexer rules

Entry : 'entry' | 'en' ;

During : 'during' | 'du' ;

Exit : 'exit' | 'ex' ;

Bind : 'bind' ;

On : 'on' ;

After : 'after' ;

Before : 'before' ;

At : 'at' ;

Every : 'every' ;

Identifier : IdentifierLetter (IdentifierLetter | Digit)* ;

IdentifierLetter : 'a'..'z'|'A'..'Z'|'_' ;

Number : Integer | Float ;

Integer : Digit+ ;

Float   : Digit+ '.' Digit*
          | '.' Digit+ ;

Digit : '0'..'9' ;

LineComment : '%' .*? '\n' -> skip ;

WhiteSpace : [ \t\r]+ -> skip ;

AnyCharacter : . ;