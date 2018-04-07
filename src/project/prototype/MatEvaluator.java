package project.prototype;

import java.util.*;

public class MatEvaluator{
    public MatEvaluator(){
        //empty constructor.. this class should be a static library but Java only allows nested static classes
    }

    //simiple copy method, uses constructors to return a new MatExpressionObject
    public static MatExpressionObject copyMat(MatExpressionObject exprObj){
        //if the object is a scalar value
        if(!exprObj.type){
            return new MatExpressionObject(exprObj.scalarValue);
        }
        else{
            return new MatExpressionObject(exprObj.matrix);
        }
    }


    //transpose function, returns new MatExpressionObject with appropriate vals
    //each cell c(i, j) in the matrix now becomes c(j, i)
    public static MatExpressionObject transpose(MatExpressionObject obj){
        ArrayList<List<Double>> resultMat = new ArrayList<List<Double>>();

        //for each row in original matrix
        for(int i = 0; i < obj.matrix.get(0).size(); i++){
            List<Double> transposedRow = new ArrayList<Double>();
            //for each column in the original matrix
            for(int j = 0; j < obj.matrix.size(); j++){
                transposedRow.add(obj.matrix.get(j).get(i));
            }
            resultMat.add(transposedRow);
        }
        System.out.println(resultMat);
        return new MatExpressionObject(resultMat);
    }




    //incomplete for now...
    public static MatExpressionObject determinant(MatExpressionObject obj){

        return new MatExpressionObject();
    }

    public static MatExpressionObject invertMat(MatExpressionObject obj){

        return new MatExpressionObject();
    }



}
