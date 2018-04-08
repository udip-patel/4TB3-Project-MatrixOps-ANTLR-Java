grammar Mat;

@header{
    package project.prototype.parser;
    import project.prototype.MatSymbolTable;
    import project.prototype.MatExpressionObject;
    import project.prototype.MatEvaluator;
    import java.util.*;
}


@members{
    public MatSymbolTable symbolTable = new MatSymbolTable();
    //static library class with all math/algorithm based functions
    public MatEvaluator eval;
    public boolean flag = false;// error flag for reference
    public int numOpenBrackets = 0;// the number of open brackets in an equation, incremented when '(' is seen in an expression, decremented when ')' is recognized. if it is not 0 at the end of the expression, throw error

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
        if(numOpenBrackets != 0){
            flag = true;
            printError("Odd Number of Brackets in Expression, Missing ( or )");
        }

        //if no flags, save the value of the expression to IDENTIFIER
        if(!flag){

            //if expression.type is a scalar, will need to add to scalar symbol table, else save the contents of expression.result in the ST with a new key or at a key that already exists

            //make sure IDENTIFIER, if it is in either ST or ScalarST matches the expression type, if not, use the moveKey... functions to re-orient the identifier to the appropriate symbol table
            System.out.println($expression.result.matrix);

        }
        else{
            System.out.println("Due to the error, the statement < " +  $IDENTIFIER.text + " = ... > was not executed");
        }
        flag = false;//reset error flag at the end of the statement
        numOpenBrackets = 0;// reset numOpenBrackets for next expresson
    }
;

/*3 categories of expressions - separated based on types of accepted params
ALL MUST return either a matrix or num*/
expression
returns [MatExpressionObject result]:
        elementWiseOperation    { $result = $elementWiseOperation.result; }
    |   operationOnTwoMats      { $result = $operationOnTwoMats.result; }
    |   operationOnOneMat       { $result = $operationOnOneMat.result; }
;

/* elementWise('add'|'subtract'|'mult'|'divide') '(' factor ',' factor ')'
the first factor must be a matrix and the second factor a scalar number */
elementWiseOperation
returns [MatExpressionObject result]:
    (isA=ELEMADD|isS=ELEMSUB|isM=ELEMMULT|isD=ELEMDIV|isP=ELEMPOW) OPENBRACKET
        f1=factor {
            if(!$factor.result.type){//if 1st factor is a scalar, print error
                flag = true;
                printError("First factor of ElementWiseAdd/Subtract/Mult/Divide must be a matrix, not a scalar");
            }
        } COMMA f2=factor {
            if(!flag){
                if($factor.result.type){//if 2nd factor is a matrix, print error
                    flag = true;
                    printError("Second factor of ElementWiseAdd/Subtract/Mult/Divide must be a scalar, not a matrix");
                }
            }
        }
    CLOSEBRACKET
    {
        if(flag) $result = new MatExpressionObject();//return empty obj
        else{
            ArrayList<List<Double>> F1 = $f1.result.matrix;
            Double F2 = $f2.result.scalarValue;

            if($isA != null) $result = eval.elemWiseOperation(F1, F2, '+');
            if($isS != null) $result = eval.elemWiseOperation(F1, F2, '-');
            if($isM != null) $result = eval.elemWiseOperation(F1, F2, '*');
            if($isP != null) $result = eval.elemWiseOperation(F1, F2, '^');
            if($isD != null){
                //guard against 'divide-by-0' issue
                if(F2 == 0.0){
                    flag = true;
                    printError("Cannot use ElementWiseDivide to divide by 0");
                    $result = new MatExpressionObject();
                }
                else{
                    $result = eval.elemWiseOperation(F1, F2, '/');
                }
            }
        }
    }
    ;

//both factors in this type of operation must be matrices
operationOnTwoMats
returns [MatExpressionObject result]:
    (isMT=MULTIPLY|isAD=ADD|isST=SUBTRACT) OPENBRACKET
        f1=factor {
            if(!$factor.result.type){
                flag = true;
                printError("Cannot use dotproduct/crossproduct/add/subtract on a scalar number");
            }
        } COMMA f2=factor {
            if(!flag){
                if(!$factor.result.type){
                    flag = true;
                    printError("Cannot use dotproduct/crossproduct/add/subtract on a scalar number");
                }
            }
        }
    CLOSEBRACKET
    {
        if(flag) $result = new MatExpressionObject();//return empty obj
        else{
            ArrayList<List<Double>> F1 = $f1.result.matrix;
            ArrayList<List<Double>> F2 = $f2.result.matrix;

            //perform matrix multiplication
            if($isMT != null){
                //ensure #columns in F1 = #rows in F2. if not, throw error
                if(F1.size() != F2.get(0).size()){
                    flag = true;
                    printError("Cannot multiply matrices where the number of columns in the first matrix is not the same as the number of rows in the second matrix");
                    $result = new MatExpressionObject();//return empty obj
                }
                else $result = eval.multiplyMatrices(F1, F2);
            }
            else{
                //the addition and subtraction functions have a precondition
                //both F1 and F2 must be the same dimensions
                if(F1.size() != F2.size() || F1.get(0).size() != F2.get(0).size()){
                    //print error if preconditions are not met
                    flag = true;
                    printError("Cannot add/subtract matrices that have different dimensions");
                    $result = new MatExpressionObject();//return empty obj
                }
                else{
                    if($isAD != null) $result = eval.addMat(F1, F2);
                    if($isST != null) $result = eval.subtractMat(F1, F2);
                }
            }
        }
    }
;

//only one factor needed to perform operation
operationOnOneMat
returns [MatExpressionObject result]:
    (isCY=COPY|isTP=TRANSPOSE|isDT=DETERMINANT|isIN=INVERSE)
    OPENBRACKET factor CLOSEBRACKET
    {
        if(flag){
            $result = new MatExpressionObject();//return empty obj
        }
        else{
            //copy function works for both scalar and matrices
            if($isCY != null) $result = eval.copyObject($factor.result);
            //every other function needs a matrix, so separated from copy
            else{
                //if factor is not a matrix, throw error stmt
                if(!$factor.result.type){
                    flag = true;
                    printError("Cannot use the transpose/determinant/inverse functions on a Scalar number");
                    $result = new MatExpressionObject();//return empty obj
                }
                else{
                    if($isTP != null) $result = eval.transpose($factor.result.matrix);
                    if($isDT != null) $result= eval.determinant($factor.result.matrix);
                    if($isIN != null) $result = eval.invertMat($factor.result.matrix);
                }
            }
        }
    }
;

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
    |   (OPENBRACKET { numOpenBrackets++; })?
            expression
        (CLOSEBRACKET { numOpenBrackets--; })?
        {
            if(!flag) $result = $expression.result;
            else $result = new MatExpressionObject();//return empty obj
        }
    ;

/* LEXER */
MATRIX:         'matrix';
ELEMADD:        'elemwiseadd'|'elemWiseAdd';
ELEMSUB:        'elemwisesub'|'elemWiseSub';
ELEMMULT:        'elemwisemult'|'elemWiseMult';
ELEMDIV:        'elemwisediv'|'elemWiseDiv';
ELEMPOW:        'elemwisepow'|'elemWisePow';
ADD:            'add'|'Add';
SUBTRACT:       'sub'|'Sub';
MULTIPLY:        'mult'|'Mult';
COPY:           'copy';
TRANSPOSE:      'transpose';
DETERMINANT:    'getdeterminant'|'getDeterminant';
INVERSE:        'inverse';
/*all keywords go before IDENTIFIER to ensure they cannot be used as such */
IDENTIFIER:     [A-Za-z_]+[0-9]*;
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
