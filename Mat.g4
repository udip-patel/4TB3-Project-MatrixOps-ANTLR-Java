grammar Mat;

@header{
    package project.prototype.parser;
    import project.prototype.MatSymbolTable;
    import project.prototype.MatExpressionObject;
    import java.util.*;
}


@members{
    public MatSymbolTable symbolTable = new MatSymbolTable();
    public boolean flag = false;// error flag for reference


    public static void printError(String err){
        System.out.println("Error! " + err);
    }
}

/* PARSER TODOSTILL


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
    matrixDeclaration*
    operationStatement*
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
            if(!symbolTable.addMatrixItem($IDENTIFIER.text)){
                //set error flag if cannot be added, then print error
                flag = true;
                printError("Cannot re-use the same names for multiple matrices (error with name: < " + $IDENTIFIER.text + " >)");
            }
        }
        //for each csvLine, make sure # of rows is consistent and save the data
        (OPENBRACE
            csvLine
            {
                //only continue saving if no errors have been seen
                if(!flag){
                    if($csvLine.rowData.size() == Integer.parseInt($INTEGER.text)){
                        symbolTable.addRowToMatrix($IDENTIFIER.text, $csvLine.rowData);
                    }
                    else{
                        printError("All rows in matrix " + $IDENTIFIER.text + " must contain < " + $INTEGER.text + " > elements (found:" + $csvLine.rowData.size() + " elements)");
                        flag = true;
                    }
                }
            }
        CLOSEBRACE )+
    CLOSEBRACE
    BREAK {
        if(flag){
            System.out.println("Due to the error, The matrix < " + $IDENTIFIER.text + " > was not created successfully");
            symbolTable.ST.remove($IDENTIFIER.text);// remove bad obj from ST
        }
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

//all numbers treated as Double-type to avoid confusion while doing calculations
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


/*like an assignment statement in most programming languages */
operationStatement:
    IDENTIFIER EQUALS expression BREAK
    {
        if(!flag){
        //if expression.type is a scalar, will need to add to scalar symbol table, else save the contents of expression.result in the ST with a new key or at a key that already exists



        }
        else{
            System.out.println("Due to the error, the statement < " +  $IDENTIFIER.text + " = ... > was not executed");
        }
        flag = false;//reset error flag at the end of the statement
    }
;

/*3 categories of expressions - separated for code readability.
ALL MUST return either a matrix or num*/
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
returns [MatExpressionObject result]:
        number
        {
            $result = new MatExpressionObject($number.value);
        }
    |   IDENTIFIER
        {
            if(flag) $result = new MatExpressionObject();//return empty obj

            //proceed if no errors exist in current statement so far
            else{
                //load a matrix from symbol table into result
                if(symbolTable.ST.containsKey($IDENTIFIER.text)){
                    $result = new MatExpressionObject(
                        symbolTable.ST.get($IDENTIFIER.text)
                    );
                }
                //if the identifier is a scalar that was defined by a previous operationStatement, load from the separate scalarST hashmap
                else if(symbolTable.ScalarST.containsKey($IDENTIFIER.text)){
                    $result = new MatExpressionObject(
                        symbolTable.ScalarST.get($IDENTIFIER.text)
                    );
                }
                //identifier not found
                else{
                    flag = true;
                    printError("Identifier < "+ $IDENTIFIER.text + " > does not exist");
                    $result = new MatExpressionObject();//return empty obj
                }
            }
        }
    |   (isOpenBracket=OPENBRACKET)? expression (isCloseBracket=CLOSEBRACKET)?
        {
            if(!flag){
                //check if brackets are valid, print error if so
                if($isOpenBracket != null){
                    if($isCloseBracket == null){
                        flag = true;
                    }
                }
                if($isCloseBracket != null){
                    if($isOpenBracket == null){
                        flag = true;
                    }
                }
                if(flag){
                    printError("Odd number of Brackets in expression. Missing a ( or ) character");
                    $result = new MatExpressionObject();//return empty obj
                }
                //if no flags, evaluate the nested expression
                else{
                    // set the value of expression to be the result of this factor
                    System.out.println("valid recursion");
                    $result = new MatExpressionObject();
                }
            }
            else $result = new MatExpressionObject();//return empty obj
        }
    ;

/* LEXER */
MATRIX:         'matrix';
ELEMENTWISE:    'elementwise'|'elementWise';
ADD:            'add'|'Add';
SUBTRACT:       'subtract'|'Subtract';
MULT:           'mult'|'Mult';
DIVIDE:         'divide'|'Divide';
DOTPRODUCT:     'dotproduct'|'dotProduct';
CROSSPRODUCT:   'crossproduct'|'crossProduct';
COPY:           'copymat'|'copyMat';
TRANSPOSE:      'transpose';
DETERMINANT:    'getdeterminant'|'getDeterminant';
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
