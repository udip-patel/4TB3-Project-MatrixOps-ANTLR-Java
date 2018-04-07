package project.prototype;

import java.util.*;

public class MatExpressionObject {
    //TYPE refers to whether this expr is a matrix (1) or a scalar value (0)
    public boolean type;
    public Double scalarValue;
    //uninitialized array, best to leave uninit. until calculations are needed
    public ArrayList<List<Double>> matrix;


    //base constructor --> set up an expression that returns a matrix
    public MatExpressionObject(){
        this.type = true;
    }
    //constructor used for setting up an expr that returns a scalar value
    public MatExpressionObject(Double scalarValue){
        this.type = false;
        this.scalarValue = scalarValue;
    }

    //constructor used to load/copy a representation of a matrix
    public MatExpressionObject(ArrayList<List<Double>> matrix){
        this.type = true;
        this.matrix = new ArrayList<List<Double>>(matrix);
    }

    //WILL NEED a load function to load a given ArrayList into 'matrix'
    // -> for when a symbol table entry needs to be loaded into an expression

}
