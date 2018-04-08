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

    //expects(num of rows, num of cols), returns an empty matrix with those dims
    public static ArrayList<List<Double>> generateMatrix(int rows, int cols){
        ArrayList<List<Double>> mat = new ArrayList<List<Double>>();
        for(int i = 0; i < rows; i++){
            List<Double> row = new ArrayList<Double>();
            for(int j = 0; j < cols; j++){
                row.add(0.0);
            }
            mat.add(row);
        }
        return mat;
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


    //recursive determinant function
    public static MatExpressionObject determinant(ArrayList<List<Double>> matObj){
        ArrayList<List<Double>> tmp;
        Double result = 0.0;

        if(matObj.size() == 1){
            result = matObj.get(0).get(0);
            return new MatExpressionObject(result);
        }
        if(matObj.size() == 2){
            result = (matObj.get(0).get(0)*matObj.get(1).get(1)) - (matObj.get(0).get(1)*matObj.get(1).get(0));
            return new MatExpressionObject(result);
        }

        //do the recursive calculation for determinant
        for(int i = 0; i < matObj.get(0).size(); i++){
            //initialize tmp to be a matrix with dimensions [matObj-1][matObj-1]
            //values are all 0 initially --> might be major cause of performance issues for a deeply nested operation
            tmp = generateMatrix(matObj.size()-1, matObj.size()-1);

            for(int j = 1; j < matObj.size(); j++){
                for(int k = 0; k < matObj.get(0).size(); k++){
                    //set new values for tmp
                    if(k < i){
                        tmp.get(j-1).set(k, matObj.get(j).get(k));
                    }
                    else if(k > i){
                        tmp.get(j-1).set(k-1, matObj.get(j).get(k));
                    }
                }
            }
            result += matObj.get(0).get(i)* Math.pow(-1, (double)i) * determinant(tmp).scalarValue;
        }
        return new MatExpressionObject(result);
    }



    /* INVERSION is said to be about O(n^3), so I relied on research for the optimal algorithm
     - drawing from https://www.sanfoundry.com/java-program-find-inverse-matrix/
     there were several more links implementing this same algorithm
    */

    //helper function for INVERSION
    public static void transformToUpperTriangle(ArrayList<List<Double>> matObj, int[] index){
        int n = index.length;
        double[] c = new double[n];

        //initialize index
        for(int i = 0; i < n; i++) index[i] = i;

        //rescaling factors, one from each row gets loaded into c
        for(int i= 0; i < n; i++){
            double c1 = 0;
            for(int j = 0; j < n; j++){
                double c0 = Math.abs(matObj.get(i).get(j));
                if(c0 > c1) c1 = c0;
            }
            c[i] = c1;
        }

        //seach the pivoting element from each column
        int k = 0;
        for(int j = 0; j < n-1; j++){
            double p1 = 0;
            for(int i = j; i < n; i++){
                double p0 = Math.abs(matObj.get(index[i]).get(j));
                p0 = p0/c[index[i]];
                if(p0 > p1){
                    p1 = p0;
                    k = i;
                }
            }
            //switch the rows according to pivot order
            int tmp = index[j];
            index[j] = index[k];
            index[k] = tmp;
            for(int i = j+1; i < n; i++){
                Double pj = matObj.get(index[i]).get(j)/ matObj.get(index[j]).get(j);

                //record pivoting ratio below the diagonal
                matObj.get(index[i]).set(j, pj);

                //modify other elements accordingly
                for(int l = j+1; l < n; l++){
                    Double cellValue = matObj.get(index[i]).get(l);
                    matObj.get(index[i]).set(l, (cellValue - (pj*matObj.get(index[j]).get(l))));
                }

            }
        }

    }



    public static MatExpressionObject invertMat(ArrayList<List<Double>> matObj){
        int n = matObj.size();
        ArrayList<List<Double>> auxMat = generateMatrix(n, n);
        ArrayList<List<Double>> invMat = generateMatrix(n, n);
        int [] index = new int[n];
        Double cellValue;//tmp variable

        //set auxillary mat to be an Identity matrix
        for(int i = 0; i < n; i++){
            auxMat.get(i).set(i, 1.0);
        }

        transformToUpperTriangle(matObj, index);

        for(int i = 0; i < n-1; i++){
            for(int j = i+1; j < n; j++){
                for(int k = 0; k < n; k++){
                    cellValue = auxMat.get(index[j]).get(k);
                    auxMat.get(index[j]).set(k, cellValue - (matObj.get(index[j]).get(i)*auxMat.get(index[i]).get(k)));

                }
            }
        }

        for(int i = 0; i < n; i++){
            invMat.get(n-1).set(i, auxMat.get(index[n-1]).get(i) / matObj.get(index[n-1]).get(n-1));

            for(int j = n-2; j>= 0; j--){
                invMat.get(j).set(i, auxMat.get(index[j]).get(i));
                for(int k = j+1; k < n; k++){
                    cellValue = invMat.get(j).get(i);
                    invMat.get(j).set(i, cellValue -  matObj.get(index[j]).get(k)*invMat.get(k).get(i));
                }

                cellValue = invMat.get(j).get(i);
                invMat.get(j).set(i, cellValue / matObj.get(index[j]).get(j));
            }
        }
        //return the inverted matrix
        return new MatExpressionObject(invMat);
    }



    //functions for two matrices...
    //patern used for functions:
    /*  given f1, f2
        f0 := f1 OPERATION f2;
        return f0

        cannot use f1 to store intermediary results in this case due to recursive nature of program
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
