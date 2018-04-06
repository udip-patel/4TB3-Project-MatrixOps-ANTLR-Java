Author: Udip Patel
Final Project - Context-Free Language System for Matrix Operations
For Class: CS4TB3 (Taught By Prof. Eden Burton)


Functionality:
Given an input text file which contains matrix definitions and operations that can be interpreted as sentences of the context-free language, the system will execute the instructions given on the specific matrices and store the results in one or more output files (again, based on the instructions given).

Formal Definition of Context-free Language:
//will be called MAT (matrix-arithmetic-terminology) for this project

    program             :=  programBlock* EOF
    programBlock        :=  matrixDeclaration | operationStatement | outputStatement

    matrixDeclaration   :=  MATRIX IDENTIFIER OPENBRACE
                                (OPENBRACE csvLine CLOSEBRACE)+
                            CLOSEBRACE BREAK
    csvLine             :=  number (COMMA number)*
    number              := (MINUS)? (INTEGER | FLOAT)

    operationStatement:
    //incomplete for now, but something like IDENTIFER EQUALS functionStatement
    //and functionStatement can be one of these:
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
