package project.prototype;

import java.util.*;

public class MatExpressionObject {
    //TYPE refers to whether this expr is a matrix (1) or a scalar value (0)
    public boolean isMatrix;
    public Double scalarValue;
    //uninitialized array, best to leave uninit. until calculations are needed
    public ArrayList<List<Double>> matrix;


    //base constructor --> set up an expression of type matrix
    public MatExpressionObject(){
        this.isMatrix = true;
    }
    //constructor used for setting up an expr that returns a scalar value
    public MatExpressionObject(Double scalarValue){
        this.isMatrix = false;
        this.scalarValue = scalarValue;
    }

    //constructor used to load/copy a representation of a matrix
    public MatExpressionObject(ArrayList<List<Double>> matrix){
        this.isMatrix = true;
        this.matrix = new ArrayList<List<Double>>(matrix);
    }

}
