grammar Mat;

@header{
    package project.prototype.parser;
    import project.prototype.MatSymbolTable;
    import project.prototype.MatExpressionObject;
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
    matrixDeclaration+
    operationStatement+
    EOF
    {
        symbolTable.printST();
    }
    ;
    /* incomplete for now...
    outputStatement+
    */


/*
'matrix' <nameOfMatrix> '(' <number of rows in matrix> ')'
        '{' ('{' csvLine '}')+ '}'';'
*/
matrixDeclaration:
    MATRIX IDENTIFIER OPENBRACKET INTEGER CLOSEBRACKET OPENBRACE
        {
            //add matrix to symbol table as an empty matrix
            if(!symbolTable.addItem($IDENTIFIER.text)){
                System.out.println("Error! Cannot re-use the same names for multiple matrices (error with name: " + $IDENTIFIER.text + ")");
                flag = true;//set error flag if cannot be added
            }

        }
        //for each csvLine, make sure # of rows is consistent and save the data
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

/*one csvLine contains all of the information for one row in a matrix */
csvLine
returns [List<Double> rowData]:
    number
        {
            $rowData = new ArrayList<Double>();//init new list
            $rowData.add($number.value);//add first element
        }
    (COMMA number
        {
            $rowData.add($number.value);//add as many elements that follow
        }
    )*;

//all numbers treated as double-type to avoid confusion while doing calculations
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


/*almost like an assignment statement in programming languages */
operationStatement:
    IDENTIFIER EQUALS expression BREAK;

//expressions are divided into 3 categories. MUST return either a matrix or num
expression
/*[returns MatExpressionObject result] */:
        elementWiseOperation
    |   operationOnTwoMats
    |   operationOnOneMat;

/* elementWise('add'|'subtract'|'mult'|'divide') '(' factor ',' factor ')'
the first factor must be a matrix and the second factor a scalar number */
elementWiseOperation
/*[returns MatExpressionObject result] */:
    ELEMENTWISE(ADD|SUBTRACT|MULT|DIVIDE) OPENBRACKET
        factor COMMA factor
    CLOSEBRACKET;

//both factors in this type of operation must be matrices
operationOnTwoMats
/*[returns MatExpressionObject result] */:
    (DOTPRODUCT|CROSSPRODUCT|ADD|SUBTRACT) OPENBRACKET
        factor COMMA factor
    CLOSEBRACKET;

//only one factor needed to perform operation
operationOnOneMat
/*[returns MatExpressionObject result] */:
    (COPY|TRANSPOSE|DETERMINANT|INVERSE) OPENBRACKET factor CLOSEBRACKET;

factor
/*[returns MatExpressionObject result] */:
        number
    |   IDENTIFIER
    |   (OPENBRACKET)? expression (CLOSEBRACKET)?
        {
            //FIRST thing to add: check if (OP && CLOSE) are the same value, if not error ( extra openbracket or missing closbracket )
        }
    ;

/* LEXER */
MATRIX:         'matrix';
ELEMENTWISE:    'elementWise';
ADD:            'add'|'Add';
SUBTRACT:       'subtract'|'Subtract';
MULT:           'mult'|'Mult';
DIVIDE:         'divide'|'Divide';
DOTPRODUCT:     'dotproduct|dotProduct';
CROSSPRODUCT:   'crossproduct|crossProduct';
COPY:           'copymat|copyMat';
TRANSPOSE:      'transpose';
DETERMINANT:    'getdeterminant|getDeterminant';
INVERSE:        'inverse';
/*all keywords go before IDENTIFIER to ensure they cannot be used as such */
IDENTIFIER:     [A-Za-z_]+;
MINUS:          '-';
INTEGER:        [0-9]+;
FLOAT:          [0-9]+'.'[0-9]+;

OPENBRACKET:    '(';
CLOSEBRACKET:   ')';
OPENBRACE:      '{';
CLOSEBRACE:     '}';
COMMA:          ',';
EQUALS:         '=';
BREAK:           ';';

WS : [ \t\n\r]+ -> skip;// skip whitespace
ANYTHING: .;
