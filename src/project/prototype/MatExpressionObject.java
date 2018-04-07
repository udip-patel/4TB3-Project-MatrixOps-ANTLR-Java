package project.prototype;

import java.util.*;

public class MatExpressionObject {
    public boolean type;//TYPE refers to whether this object contains a matrix (1) or a scalar value (0)
    public int scalarValue;
    public List<List<Double>> matrix;//an uninitialiazed reference with a type that is compatible with how the system represents a matrix


    //base constructor --> set up an expression that returns a matrix
    public MatExpressionObject(){
        this.type = true;
    }
    //constructor used for setting up an expr that returns a scalar value
    public MatExpressionObject(boolean type){
        this.type = type;
    }

    //WILL NEED a load function to load a given ArrayList into 'matrix'
    // -> for when a symbol table entry needs to be loaded into an expression

}
