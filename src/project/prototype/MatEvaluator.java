package project.prototype;

import java.util.*;
import java.lang.Math.*;

public class MatEvaluator{
    public MatEvaluator(){
        //empty constructor.. this class should be a static library but Java only allows nested static classes
    }

    //simiple copy method, uses constructors to return a new MatExpressionObject
    public static MatExpressionObject copyObject(MatExpressionObject exprObj){
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
        return new MatExpressionObject(resultMat);
    }


    //incomplete for now...
    public static MatExpressionObject determinant(ArrayList<List<Double>> matObj){

        return new MatExpressionObject();
    }

    public static MatExpressionObject invertMat(ArrayList<List<Double>> matObj){

        return new MatExpressionObject();
    }



    //functions for two matrices...
    //patern used for functions:
    /*  given f1, f2
        f0 := f1 OPERATION f2;
        return f0

        cannot use f1 to store intermediary results in this case
    */


    //MATRIX MULTIPLICATION function
    public static MatExpressionObject multiplyMatrices(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){

        Double tmp = 0.0;//used to store intermediate results
        ArrayList<List<Double>> f0 = new ArrayList<List<Double>>();
        for(int i=0; i < f1.size(); i++){
            List<Double> resultRow = new ArrayList<Double>();
            for(int j = 0; j < f2.get(0).size(); j++){
                //each cell in the resulting Matrix = dot product of a single row from F1 and a single column from F2
                tmp = 0.0;
                for(int k = 0; k < f1.get(0).size(); k++){
                    tmp += f1.get(i).get(k) * f2.get(k).get(j);
                }
                resultRow.add(tmp);
            }
            f0.add(resultRow);
        }
        return new MatExpressionObject(f0);
    }



    public static MatExpressionObject addMat(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){
        ArrayList<List<Double>> f0 = new ArrayList<List<Double>>();
        for(int i = 0; i < f1.size(); i++){

            List<Double> rowOfSummedResults = new ArrayList<Double>();
            for(int j = 0; j < f1.get(0).size(); j++){
                rowOfSummedResults.add(f1.get(i).get(j) + f2.get(i).get(j));
            }
            f0.add(rowOfSummedResults);
        }
        return new MatExpressionObject(f0);
    }

    public static MatExpressionObject subtractMat(ArrayList<List<Double>> f1, ArrayList<List<Double>> f2){
        ArrayList<List<Double>> f0 = new ArrayList<List<Double>>();
        for(int i = 0; i < f1.size(); i++){
            List<Double> rowOfDifferences = new ArrayList<Double>();
            for(int j = 0; j < f1.get(0).size(); j++){
                rowOfDifferences.add(f1.get(i).get(j) - f2.get(i).get(j));
            }
            f0.add(rowOfDifferences);
        }
        return new MatExpressionObject(f0);
    }


    /*element-wise add/subtract/mult/divide functions */
    public static MatExpressionObject elemWiseOperation(ArrayList<List<Double>> f1, Double f2, char op){
        ArrayList<List<Double>> f0 = new ArrayList<List<Double>>();
        for(int i = 0; i < f1.size(); i++){
            List<Double> newRow = new ArrayList<Double>();
            for(int j = 0; j < f1.get(0).size(); j++){
                //this switch statement may add to the performance cost, but adding 4 separate functions with almost the same code seemed like too much code repetition
                switch(op){
                    case '+':newRow.add(f1.get(i).get(j)+f2); break;
                    case '-':newRow.add(f1.get(i).get(j)-f2); break;
                    case '*':newRow.add(f1.get(i).get(j)*f2); break;
                    case '/':newRow.add(f1.get(i).get(j)/f2); break;
                    case '^':newRow.add(Math.pow(f1.get(i).get(j), f2)); break;
                    default: break;
                }
            }
            f0.add(newRow);
        }
        return new MatExpressionObject(f0);
    }



}
