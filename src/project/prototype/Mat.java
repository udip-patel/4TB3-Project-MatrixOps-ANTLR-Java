package project.prototype;

import project.prototype.parser.MatLexer;
import project.prototype.parser.MatParser;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.io.IOException;

public class Mat{

    public static void main(String[] args) throws IOException{
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        MatLexer lexer = new MatLexer(input);

        CommonTokenStream tokens = new CommonTokenStream(lexer);
        MatParser parser = new MatParser(tokens);

        try{
            parser.program();
        } catch(Exception e){
            System.out.println("Error: " + e.getMessage());
        }
    }

}
