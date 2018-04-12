grammar Mat;

@header{
    package project.prototype.parser;
    import project.prototype.*;
    import java.util.*;
}


@members{
    public MatSymbolTable symbolTable = new MatSymbolTable();
    ArrayList<List<Double>> matrixToLoad;//for each matrix declaration, will temporarily collect the information list format, and send it to the symbolTable. gets reset for each new matrix declaration



    //static library class with all math/algorithm based functions
    public MatEvaluator eval;
    public boolean flag = false;// error flag for reference
    public int numOpenBrackets = 0;// the number of open brackets in an equation, incremented when '(' is seen in an expression, decremented when ')' is recognized. if it is not 0 at the end of the expression, throw error


    String operationStack = "";//stores the set of current operations to perform
    /*
        if a new op is recognized, its corresponding char is loaded at the front of the operationStack
        once an op is tasked for completion, it is removed from the stack by using the String.substring method
        Set of Characters Used To Represent Operations:
        +       elemWiseAdd
        -       elemWiseSub
        *       elemWiseMult
        /       elemWiseDiv
        ^       elemWisePow
        M       multiplyMatrices
        C       copy matrix
        A       add matrices
        S       subtract matrices
        T       transpose matrix
        D       determinant
        I       inverse
        P       print matrix(ces)
        X       export matrix(ces)
    */


    //will store the symbol(s) to output for an outputStatement
    List<String> referencesToOutput = new ArrayList<String>();
    public MatFileWriter fileWriter = new MatFileWriter();

    //simple helper func
    public static void printError(String err){
        System.out.println("Error! " + err);
    }
}

program:
    matrixDeclaration*
    operationStatement*
    outputStatement*
    EOF
    {

    }
    ;


/*
'matrix' <nameOfMatrix>
        '{' ('{' csvLine '}')+ '}'';'
*/
matrixDeclaration:
    MATRIX IDENTIFIER OPENBRACE
        {
            matrixToLoad = new ArrayList<List<Double>>();//init matrix to load

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
                    //if this is NOT the first row to load AND the size of this row is NOT the same as the size of the first row, print err
                    if(matrixToLoad.size() != 0
                        && $csvLine.rowData.size() != matrixToLoad.get(0).size()){
                            printError("All rows in matrix < " + $IDENTIFIER.text + " > must contain < " + matrixToLoad.get(0).size() + " > elements (found:" + $csvLine.rowData.size() + " elements)");
                            flag = true;
                    }
                    //else add row into the matrixToLoad
                    else{
                        matrixToLoad.add($csvLine.rowData);
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
        else{
            symbolTable.addMatrixToSymbol($IDENTIFIER.text, matrixToLoad);
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
            //RESULT IS A SCALAR
            if(!$expression.result.isMatrix){
                //if reference used to previously store a matrix type
                if(symbolTable.ST.containsKey($IDENTIFIER.text)){
                    //remove the symbol from ST and put a new one in ScalarST
                    symbolTable.moveSTKeyToScalarST($IDENTIFIER.text, $expression.result.scalarValue);
                }
                else{
                    //update or insert the reference in the scalar symbol table
                    symbolTable.ScalarST.put($IDENTIFIER.text, $expression.result.scalarValue);
                }
            }
            //RESULT IS A MATRIX
            else{
                //if reference was used to store a scalar before
                if(symbolTable.ScalarST.containsKey($IDENTIFIER.text)){
                    //move the reference to the matrix symbol table
                    symbolTable.moveScalarSTKeyToST($IDENTIFIER.text, $expression.result.matrix);
                }
                else{
                    //update or insert the reference in the matrix symbol table
                    symbolTable.ST.put($IDENTIFIER.text, $expression.result.matrix);
                }
            }
        }
        else{
            System.out.println("Due to the error, the statement < " +  $IDENTIFIER.text + " = ... > was not executed");
        }
        flag = false;//reset error flag at the end of the statement
        numOpenBrackets = 0;// reset numOpenBrackets for next expresson
    }
;

/*3 categories of expressions - separated based on types of accepted params
ALL MUST return either a matrix or num, stored in custom object*/
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
    //add the appropriate character to the OperationStack
    (   ELEMADD { operationStack = "+" + operationStack; }
    |   ELEMSUB { operationStack = "-" + operationStack; }
    |   ELEMMULT { operationStack = "*" + operationStack;}
    |   ELEMDIV { operationStack = "/" + operationStack; }
    |   ELEMPOW { operationStack = "^" + operationStack;; }
    )
    OPENBRACKET
        f1=factor {
            //SIMIPLE ERROR-CHECKS BEFORE MAIN CHUNK OF CODE
            if(!$factor.result.isMatrix){//if 1st factor is a scalar, print error
                flag = true;
                printError("First factor of ElementWiseAdd/Subtract/Mult/Divide must be a matrix, not a scalar");
            }
        } COMMA f2=factor {
            if(!flag){
                if($factor.result.isMatrix){//if 2nd factor is a matrix, print error
                    flag = true;
                    printError("Second factor of ElementWiseAdd/Subtract/Mult/Divide must be a scalar, not a matrix");
                }
            }
        }
    CLOSEBRACKET
    {
        if(flag) $result = new MatExpressionObject();//return empty obj
        else{
            double[][] F1 = $f1.result.matrix;
            double F2 = $f2.result.scalarValue;

            //get currentSymbol from OperationStack
            char currentOpSymbol = operationStack.charAt(0);
            operationStack = operationStack.substring(1);//remove from stack

            //guard against 'divide-by-0' issue
            if(currentOpSymbol == '/'){
                if(F2 == 0.0){
                    flag = true;
                    printError("Cannot use ElementWiseDivide to divide by 0");
                    $result = new MatExpressionObject();
                }
                else{
                    $result = eval.elemWiseOperation(F1, F2, '/');
                }
            }
            else {
                $result = eval.elemWiseOperation(F1, F2, currentOpSymbol);
            }
        }
    }
    ;

//both factors in this type of operation must be matrices
operationOnTwoMats
returns [MatExpressionObject result]:
    (   MULTIPLY    { operationStack = "M" + operationStack; }
    |   ADD         { operationStack = "A" + operationStack; }
    |   SUBTRACT    { operationStack = "S" + operationStack; }
    ) OPENBRACKET
        f1=factor {
            //again, simple error checks
            if(!$factor.result.isMatrix){
                flag = true;
                printError("Cannot use mult/add/subtract on a scalar number");
            }
        } COMMA f2=factor {
            if(!flag){
                if(!$factor.result.isMatrix){
                    flag = true;
                    printError("Cannot use mult/add/subtract on a scalar number");
                }
            }
        }
    CLOSEBRACKET
    {
        if(flag) $result = new MatExpressionObject();//return empty obj
        else{
            double[][] F1 = $f1.result.matrix;
            double[][] F2 = $f2.result.matrix;

            //schedule the first task on operationStack to be executed
            char currentOp = operationStack.charAt(0);
            operationStack = operationStack.substring(1);//remove op from stack

            if(currentOp == 'M'){
                //multiply matrices F1 and F2, but before that..
                //ensure #columns in F1 = #rows in F2. if not, throw error
                if(F1[0].length != F2.length){
                    flag = true;
                    printError("Cannot multiply matrices where the number of columns in the first matrix is not the same as the number of rows in the second matrix");
                    $result = new MatExpressionObject();//return empty obj
                }
                else $result = eval.multiplyMatrices(F1, F2);
            }
            else{
                //the addition and subtraction functions have a precondition
                //both F1 and F2 must be the same dimensions
                if(F1.length != F2.length || F1[0].length != F2[0].length){
                    //print error if preconditions are not met
                    flag = true;
                    printError("Cannot add/subtract matrices that have different dimensions");
                    $result = new MatExpressionObject();//return empty obj
                }
                else{
                    if(currentOp == 'A') $result = eval.addMat(F1, F2);
                    if(currentOp == 'S') $result = eval.subtractMat(F1, F2);
                }
            }
        }
    }
;

//only one factor needed to perform operation
operationOnOneMat
returns [MatExpressionObject result]:
    (   COPY        { operationStack = "C" + operationStack; }
    |   TRANSPOSE   { operationStack = "T" + operationStack; }
    |   DETERMINANT { operationStack = "D" + operationStack; }
    |   INVERSE     { operationStack = "I" + operationStack; }
    ) OPENBRACKET factor CLOSEBRACKET
    {
        if(flag){
            $result = new MatExpressionObject();//return empty obj
        }
        else{
            char op = operationStack.charAt(0);
            operationStack = operationStack.substring(1);

            //copy function works for both scalar and matrices
            if(op == 'C') $result = eval.copyObject($factor.result);
            //every other function needs a matrix, so separated from copy
            else{
                //if factor is not a matrix, throw error stmt
                if(!$factor.result.isMatrix){
                    flag = true;
                    printError("Cannot use the transpose/determinant/inverse functions on a Scalar number");
                    $result = new MatExpressionObject();//return empty obj
                }
                else{
                    //transpose
                    if(op=='T')$result = eval.transpose($factor.result.matrix);
                    else{
                        //both determinant and inversion have a precondition. The factor must be a SQUARE MATRIX
                        if($factor.result.matrix.length != $factor.result.matrix[0].length){
                            flag = true;
                            printError("Cannot use the transpose/determinant/inverse functions on a matrix that is NOT SQUARE");
                            $result = new MatExpressionObject();
                        }
                        else{
                            if(op=='D')$result= eval.determinant($factor.result.matrix);
                            if(op=='I')$result = eval.invertMat($factor.result.matrix);
                        }
                    }
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
                        (double)symbolTable.ScalarST.get($IDENTIFIER.text)
                    );//cast the Double object to a double primitive when loading into MatExpressionObject
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



outputStatement:
    (PRINT  { operationStack = "P" + operationStack; }
    |EXPORT { operationStack = "X" + operationStack; }
    )
    //store the references to keep track of what to output
    (IDENTIFIER
        {
            if(symbolTable.ST.containsKey($IDENTIFIER.text) || symbolTable.ScalarST.containsKey($IDENTIFIER.text)){
                referencesToOutput.add($IDENTIFIER.text);
            }
            else{
                printError("Cannot Output the variable < " + $IDENTIFIER.text + " > because it does not exist");//no error flags for an outputstmt
            }
        }
        (COMMA IDENTIFIER
            {
                if(symbolTable.ST.containsKey($IDENTIFIER.text) || symbolTable.ScalarST.containsKey($IDENTIFIER.text)){
                    referencesToOutput.add($IDENTIFIER.text);
                }
                else{
                    printError("Cannot Output the variable < " + $IDENTIFIER.text + " > because it does not exist");
                }
            }
        )*
    |(ALL
        {
            //SPECIAL CASE: print or export all variables created
            if(operationStack.charAt(0) == 'P'){
                System.out.println("\n\n*****Showing All Variables*****\n");
                symbolTable.printST(); symbolTable.printScalarST();//prints all
                operationStack = operationStack.substring(1);//remove op
                System.out.println("\n**********************************\n");
            }
            else{
                //operation is EXPORT ALL objects
                referencesToOutput.clear();
                for(String symbol : symbolTable.ST.keySet()){
                    referencesToOutput.add(symbol);
                }
                for(String symbol : symbolTable.ScalarST.keySet()){
                    referencesToOutput.add(symbol);
                }
                //note: in this case, the op is still not over, it is said to be over when the file is exported successfully
            }
        })?
    )

    (TO IDENTIFIER {
        //only works for export, not print. IDENTIFIER specifies a filename to save a CSV file under
        if(operationStack.length() > 0 && operationStack.charAt(0) == 'X'){
            System.out.println("\n\n*****Exported File*****");
            for(String ref: referencesToOutput){
                if(symbolTable.ST.containsKey(ref)){
                    fileWriter.addMatrixToFile(ref, symbolTable.ST.get(ref));
                }
                if(symbolTable.ScalarST.containsKey(ref)){
                    fileWriter.addScalarValueToFile(ref, symbolTable.ScalarST.get(ref));
                }
            }
            //op is done, remove first char from operationStack
            operationStack = operationStack.substring(1);
            //save the buffered content into a file with name $IDENTIFIER
            fileWriter.saveCsvContent($IDENTIFIER.text);
            fileWriter.clearExportData();//clear all data exported for this statement, a fresh buffer is needed for the next output statement (if it exists)
            System.out.println("\n**********************************\n");
        }
    })?
    BREAK
    {
        //this block of code handles a statement like "print a, b, c;"
        //where a, b, c are identifiers that are in the symbol table
        if(operationStack.length() > 0 && operationStack.charAt(0) == 'P'){
            symbolTable.printSymbols(referencesToOutput);
            operationStack = operationStack.substring(1);
        }
        if(fileWriter.csvContent.length() > 0){
            //only way this happens is if op X is chosen, but no CSV file is saved (since fileWriter.csvContent has not been cleared)
            System.out.println("Error. Missing filename in export statement. Could not save the file");
        }

        referencesToOutput.clear();// clear the list of refs for this stmt
    }
;





/* LEXER */
MATRIX:         'matrix';
ELEMADD:        'elemWiseAdd';
ELEMSUB:        'elemWiseSub';
ELEMMULT:       'elemWiseMult';
ELEMDIV:        'elemWiseDiv';
ELEMPOW:        'elemWisePow';
ADD:            'add';
SUBTRACT:       'sub';
MULTIPLY:       'mult';
COPY:           'copy';
TRANSPOSE:      'transpose';
DETERMINANT:    'determinant';
INVERSE:        'inverse';
PRINT:          'print';
EXPORT:         'export';
ALL:            '*';
TO:             '>>';
/*all keywords go before IDENTIFIER to ensure they cannot be used as such */
IDENTIFIER:     [A-Za-z_]+[0-9]*;//numbers allowed in identifier, but 1 char req
MINUS:          '-';
INTEGER:        [0-9]+;
FLOAT:          [0-9]*'.'[0-9]+;

OPENBRACKET:    '(';
CLOSEBRACKET:   ')';
OPENBRACE:      '{';
CLOSEBRACE:     '}';
COMMA:          ',';
EQUALS:         '=';
BREAK:           ';';

WS : [ \t\n\r]+ -> skip;// skip whitespace
ANYTHING: .;
