package project.prototype;

import java.util.*;

public class MatExpressionObject {
    //type, refers to whether this expr is a matrix (1) or a scalar value (0)
    public boolean isMatrix;
    public double scalarValue;
    //uninitialized array, best to leave uninit. until calculations are needed
    public double[][] matrix;


    //base constructor --> set up an expression of type matrix
    public MatExpressionObject(){
        this.isMatrix = true;
    }
    //constructor used for setting up an expr that returns a scalar value
    public MatExpressionObject(double scalarValue){
        this.isMatrix = false;
        this.scalarValue = scalarValue;
    }

    //constructor used to load/copy a representation of a matrix
    public MatExpressionObject(double[][] matrix){
        this.isMatrix = true;
        this.matrix = new double[matrix.length][matrix[0].length];
        for(int i = 0; i < matrix.length; i++){
            this.matrix[i] = matrix[i].clone();
        }
    }

}
