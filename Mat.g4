grammar Mat;

@header{
    package project.prototype.parser;
    import java.util.*;
}


@members{

}

/* PARSER

    -- definition of language here ...
*/

program:
    (ANYTHING
    {
        System.out.println($ANYTHING.text);
    })+
    EOF;




/* LEXER */
ANYTHING: .;
