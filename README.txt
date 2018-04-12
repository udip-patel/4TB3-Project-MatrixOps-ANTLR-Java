Author: Udip Patel
Final Project - Context-Free Language System for Matrix Operations
For Class: CS4TB3 (Taught By Prof. Eden Burton)

***LIST-BASED IMPLEMENTATION - old, slow version***

System Requirements:
    Operating System: Unix/Linux distribution that can run a .sh script file
    Java: version 1.7, OpenJDK version 1.7

System Description:
    This is a recognizer program for a custom-made language called MAT, which allows the user to define matrices and associate them with identifiers, perform basic matrix operations by referencing the identifiers defined, and output the results to the command line interface (CLI) or export them to a csv file with a name of their choosing. A formal definition of MAT is included in this document.

To Build the System from the base folder:
    execute the script "build.sh" from the command line
        -> set permission to execute the file via chmod...
        -> use "./build.sh" to execute the script

    This will add a file called "Mat.jar" to the base folder. Building process is then complete.

To use the System after it is built:
    The parser expects an input text file which contains all the instructions to execute.
    Instructions for the accepted language (MAT) are broken down into three major categories, matrix declarations, operation statements, and output statements. A file called "sampleInput.txt" is included in the base folder, and contains a template of what a valid input file looks like. A full formal definition of the language is also included below.

    To run the program, simply put the desired input file in the base project folder
    and then run the command:
        java -jar Mat.jar < yourInputFile.txt

    where yourInputFile is the name of the desired input file.

Formal Language Definition:
    Let MAT = (T, N, P, S)

    where T is the Set of Terminals:
        [ ’matrix’, ’elemWiseAdd’, ’elemWiseSub’, ’elemWiseMult’, ’elemWiseDiv’, ’elemWisePow’,
        ’add’, ’sub’, ’mult’, ’copy’, ’transpose’, ’determinant’, ’inverse’, ’print’, ’export’,
        ’>>’, ’-’, ’(’, ’)’, ’{’, ’}’, ’=’, ’;’, ALL, IDENTIFIER, COMMA, INTEGER, FLOAT, EOF
        ]
        where
        COMMA := ’,’ ALL=’*’ and EOF represents the end of the file
        the others are defined by regular expressions,
        IDENTIFIER := [A-Za-z ]+[0-9]*
        INTEGER := [0-9]+
        FLOAT := [0-9]*’.’[0-9]+

    where N is the set of Non-Terminals:
        [ program, matrixDeclaration, operationStatement, outputStatement, csvLine, number,
        operationStatement, expression, elementWiseOperation, operationOnOneMat,
        operationOnTwoMats, factor ]

    where P is the set of possible productions:
        [ program := matrixDeclaration* operationStatement* outputStatement* EOF
        , matrixDeclaration := ’matrix’ IDENTIFIER ’{’ ( ’{’ csvLine ’}’ )+’}”;’
        , csvLine := number (COMMA number)*
        , number := (MINUS)?( INTEGER | FLOAT )
        , operationStatement := IDENTIFIER ’=’ expression ’;’
        , expression := elementWiseOperation | operationOnOneMat
                       |operationOnTwoMats
        , operationOnTwoMats := (’mult’|’add’|’sub’) ’(’ factor ’,’ factor ’)’
        , elementWiseOperation :=
            (’elemAdd’|’elemSub’|’elemMult’|’elemDiv’|’elemPow’) ’(’ factor ’,’ factor ’)’
        , operationOnOneMat :=
            (’copy’|’transpose’|’determinant’|’inverse’) ’(’ factor ’)’
        , factor := number | IDENTIFIER | (’(’)? expression (’)’)?
        , outputStatement :=
            (’print’ | ’export’) (IDENTIFIER (COMMA IDENTIFIER)* | ’*’)
            (’>>’ IDENTIFIER)? ’;’
        ]

    and where S is the start state, this shall be the first character of any given input file, the parser will then execute the instructions by reading characters from the text continously until the EOF.
