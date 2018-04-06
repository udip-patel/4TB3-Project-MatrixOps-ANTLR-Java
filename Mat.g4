grammar Mat;

@header{
    package project.prototype.parser;
    import java.util.*;
}


@members{

}

/* PARSER


    csvLine             :=  number (COMMA number)*
    number              := (MINUS)? (INTEGER | FLOAT)

    operationStatement:
      incomplete for now, but something like IDENTIFER EQUALS functionStatement
      and functionStatement can be one of these:
        {between 2 matrices}
        dot-product
        cross-product
        add
        subtract

        {for a single matrix and a scalar number (positive/negative)}
        scalar multiplication
        elementWise Addition
        elementWise Subtraction

        {for a single matrix}
        isSquare
        transpose
        inverse
        determinant

    outputStatment      := EXPORT IDENTIFIER (COMMA IDENTIFER)*
                            ( SEPARATELY | AS IDENTIFIER )
                           BREAK

    MATRIX              := '$'
    IDENTIFIER          := [A-Za-z_]+
    MINUS               := '-'
    INTEGER             := [0-9]+
    FLOAT               := [0-9]+'.'[0-9]+
    COMMA               := ','
    OPENBRACKET         := '('
    CLOSEBRACKET        := ')'
    OPENBRACE           := '{'
    CLOSEBRACE          := '}'
    BREAK               := ';'
    EXPORT              := 'export'|'EXPORT'
    SEPARATELY          := 'separately'|'SEPARATELY'
    AS                  := '>>>'
*/

program:
    matrixDeclaration* EOF;
    /* incomplete for now...
    operationStatement*
    outputStatement+
    */




ws: NEWLINE* SPACES*;//white space


/*
'matrix' <nameOfMatrix> '(' <number of columns in matrix> ')'
        '{' ('{' csvLine '}')+ '}'';'
*/
matrixDeclaration:
    ws MATRIX ws IDENTIFIER ws OPENBRACKET ws INTEGER ws
        {
            System.out.println("add new symbol " + $IDENTIFIER.text + " to ST, and set the currentMatrix to the same string");
            System.out.println("Create new java 2D array with " + $INTEGER.text + " length. The length of each vector in the matrix is checked after processing a csvLine");
        }
    CLOSEBRACKET
    ws OPENBRACE
        (ws OPENBRACE ws csvLine ws CLOSEBRACE ws)+
    CLOSEBRACE ws BREAK ws;

csvLine:
    number (ws COMMA ws number)*;

number:
    (MINUS)?(INTEGER|FLOAT);


/* LEXER */
SPACES:     [ \t]+;
NEWLINE:    ('\r'? '\n')+;



MATRIX:         'matrix';
/*all keywords go before IDENTIFIER to ensure they cannot be used as such */
IDENTIFIER:     [A-Za-z_]+;
MINUS:          '-';
INTEGER:        [0-9]+;
FLOAT:          [0-9]+'.'[0-9]+;
/*symbols */
OPENBRACKET:    '(';
CLOSEBRACKET:   ')';
OPENBRACE:      '{';
CLOSEBRACE:     '}';
COMMA:          ',';
BREAK:           ';';


ANYTHING: .;
