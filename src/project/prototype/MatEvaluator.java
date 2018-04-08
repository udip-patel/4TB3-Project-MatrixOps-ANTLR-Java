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
    public static MatExpressionObject transpose(ArrayList<List<Double>> matObj){
        ArrayList<List<Double>> resultMat = new ArrayList<List<Double>>();

        //for each row in original matrix
        for(int i = 0; i < matObj.get(0).size(); i++){
            List<Double> transposedRow = new ArrayList<Double>();
            //for each column in the original matrix
            for(int j = 0; j < matObj.size(); j++){
                transposedRow.add(matObj.get(j).get(i));
            }
            resultMat.add(transposedRow);
        }
        System.out.println(resultMat);
        return new MatExpressionObject(resultMat);
    }


    //incomplete for now...
    public static MatExpressionObject determinant(ArrayList<List<Double>> matObj){

        return new MatExpressionObject();
    }

    public static MatExpressionObject invertMat(ArrayList<List<Double>> matObj){

        return new MatExpressionObject();
    }


    public static MatExpressionObject dotProduct(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){

        return new MatExpressionObject();
    }

    public static MatExpressionObject crossProduct(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){

        return new MatExpressionObject();
    }



    //complete functions...
    public static MatExpressionObject addMat(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){
        ArrayList<List<Double>> resultMat = new ArrayList<List<Double>>();

        for(int i = 0; i < f1.get(0).size(); i++){
            List<Double> sumOfMatsRow = new ArrayList<Double>();
            for(int j = 0; j < f1.size(); j++){
                sumOfMatsRow.add(f1.get(i).get(j) + f2.get(i).get(j));
            }
            resultMat.add(sumOfMatsRow);
        }
        //System.out.println(resultMat);
        return new MatExpressionObject(resultMat);
    }

    public static MatExpressionObject subtractMat(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){
        ArrayList<List<Double>> resultMat = new ArrayList<List<Double>>();

        for(int i = 0; i < f1.get(0).size(); i++){
            List<Double> differenceOfMatsRow = new ArrayList<Double>();
            for(int j = 0; j < f1.size(); j++){
                differenceOfMatsRow.add(f1.get(i).get(j) - f2.get(i).get(j));
            }
            resultMat.add(differenceOfMatsRow);
        }
        //System.out.println(resultMat);
        return new MatExpressionObject(resultMat);
    }


    /*element-wise add/subtract/mult/divide functions */
    public static MatExpressionObject elemWiseAdd(ArrayList<List<Double>> f1, Double f2){
        return new MatExpressionObject();
    }

    public static MatExpressionObject elemWiseSub(ArrayList<List<Double>> f1, Double f2){
        return new MatExpressionObject();
    }

    public static MatExpressionObject elemWiseMult(ArrayList<List<Double>> f1, Double f2){
        return new MatExpressionObject();
    }

    public static MatExpressionObject elemWiseDivide(ArrayList<List<Double>> f1, Double f2){
        return new MatExpressionObject();
    }



}
