grammar Mat;

@header{
    package project.prototype.parser;
    import project.prototype.MatSymbolTable;
    import java.util.*;
}


@members{
    public MatSymbolTable symbolTable = new MatSymbolTable();
    public boolean flag = false;// flag an error if one exists so it can be seen by the whole parser
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
    matrixDeclaration* EOF
    {
        symbolTable.printST();
    }
    ;
    /* incomplete for now...
    operationStatement*
    outputStatement+
    */


/*
'matrix' <nameOfMatrix> '(' <number of rows in matrix> ')'
        '{' ('{' csvLine '}')+ '}'';'
*/
matrixDeclaration:
    MATRIX IDENTIFIER OPENBRACKET INTEGER
        {
            //add matrix to symbol table as an empty matrix
            if(!symbolTable.addItem($IDENTIFIER.text)){
                System.out.println("Error! Cannot re-use the same names for multiple matrices (error with name: " + $IDENTIFIER.text + ")");
                flag = true;//set error flag if cannot be added
            }

        }
    CLOSEBRACKET
    OPENBRACE
        (OPENBRACE
            csvLine
            {
                if(!flag){
                    if($csvLine.rowData.size() == Integer.parseInt($INTEGER.text)){
                        symbolTable.addRowToMatrix($IDENTIFIER.text, $csvLine.rowData);
                    }
                    else{
                        System.out.println("Error! All rows in matrix " + $IDENTIFIER.text + " must contain " + $INTEGER.text + " elements (found:" + $csvLine.rowData.size() + " )");
                        flag = true;
                    }
                }
            }
        CLOSEBRACE )+
    CLOSEBRACE
    BREAK {
        flag = false;//reset error flag after statement is fully read
    };

csvLine
returns [List<Double> rowData]:
    number
        {
            $rowData = new ArrayList<Double>();
            $rowData.add($number.value);
        }
    (COMMA number
        {
            $rowData.add($number.value);
        }
    )*;

number
returns [Double value]:
    (isMinus=MINUS)?
    (INTEGER
    {
      $value = ($isMinus != null ? -1 : 1) * Double.parseDouble($INTEGER.text);
    }
    |FLOAT
    {
      $value = ($isMinus != null ? -1 : 1) * Double.parseDouble($FLOAT.text);
    }
    );


/* LEXER */



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

WS : [ \t\n\r]+ -> skip;
ANYTHING: .;
