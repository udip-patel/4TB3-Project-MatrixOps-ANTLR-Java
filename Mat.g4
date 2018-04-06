grammar Mat;

@header{
    package project.prototype.parser;
    import java.util.*;
}


@members{

}

/* PARSER

    program             :=  programBlock* EOF
    programBlock        :=  matrixDeclaration | operationStatement | outputStatement

    matrixDeclaration   :=  MATRIX IDENTIFIER OPENBRACKET INTEGER CLOSEBRACKET
                            OPENBRACE
                                (OPENBRACE csvLine CLOSEBRACE)+
                            CLOSEBRACE BREAK
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
    OPENBRACE           := '{'
    CLOSEBRACE          := '}'
    BREAK               := ';'
    EXPORT              := 'export'|'EXPORT'
    SEPARATELY          := 'separately'|'SEPARATELY'
    AS                  := '>>>'
*/

program:
    programBlock*
    EOF;

whiteSpace: SPACES* NEWLINE*;

programBlock:
    (whiteSpace ANYTHING
    {
        System.out.println($ANYTHING.text);
    } whiteSpace)+;



/* LEXER */

NEWLINE:    ('\r'? '\n')+;
SPACES:     [ \t]+;
ANYTHING: .;
