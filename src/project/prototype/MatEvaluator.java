package project.prototype;

import java.util.*;
import java.lang.Math.*;

public class MatEvaluator{
    public static long startTimeOfInstance;//used to measure performance of functions, one by one as they are executed
    public static long totalElapsedTime = 0;//stores the sum of the runtimes of each instance that is run

    public MatEvaluator(){
        //empty constructor
    }

    public static void startTimer(){
        startTimeOfInstance = System.nanoTime();
    }

    //add the time pased from when the timer was started to totalElapsedTime
    public static void stopTimer(){
        totalElapsedTime +=  System.nanoTime() - startTimeOfInstance;
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
    public static MatExpressionObject transpose(double[][] matObj){

        double[][] resultMat = new double[matObj[0].length][matObj.length];

        for(int i = 0; i < resultMat.length; i++){
            for(int j = 0; j < resultMat[0].length; j++){
                resultMat[i][j] = matObj[j][i];
            }
        }
        return new MatExpressionObject(resultMat);
    }


    //recursive determinant function
    public static MatExpressionObject determinant(double[][] matObj){
        double[][] tmp;
        double result = 0.0;

        if(matObj.length == 1){
            result = matObj[0][0];
            return new MatExpressionObject(result);
        }
        if(matObj.length == 2){
            result = (matObj[0][0]*matObj[1][1])-(matObj[0][1]*matObj[1][0]);
            return new MatExpressionObject(result);
        }

        //do the recursive calculation for determinant
        for(int i = 0; i < matObj[0].length; i++){
            //initialize tmp to be a matrix with dimensions [matObj-1][matObj-1]
            //values are all 0 initially
            tmp = new double[matObj.length-1][matObj.length-1];

            for(int j = 1; j < matObj.length; j++){
                for(int k = 0; k < matObj[0].length; k++){
                    //set new values for tmp
                    if(k < i){
                        tmp[j-1][k] = matObj[j][k];
                    }
                    else if(k > i){
                        tmp[j-1][k-1] = matObj[j][k];
                    }
                    //if k == i, do nothing
                }
            }
            result += matObj[0][i] * Math.pow(-1, (double)i) * determinant(tmp).scalarValue;
        }
        return new MatExpressionObject(result);
    }



    /* INVERSION is said to be about O(n^3), so I relied on research for the optimal algorithm
     - drawing from https://www.sanfoundry.com/java-program-find-inverse-matrix/
     there were several more links implementing this same algorithm
    */

    //helper function for INVERSION
    public static void transformToUpperTriangle(double[][] matObj, int[] index){
        int n = index.length;
        double[] c = new double[n];

        //initialize index
        for(int i = 0; i < n; i++) index[i] = i;

        //rescaling factors, one from each row gets loaded into c
        for(int i= 0; i < n; i++){
            double c1 = 0;
            for(int j = 0; j < n; j++){
                double c0 = Math.abs(matObj[i][j]);
                if(c0 > c1) c1 = c0;
            }
            c[i] = c1;
        }

        //seach the pivoting element from each column
        int k = 0;
        for(int j = 0; j < n-1; j++){
            double p1 = 0;
            for(int i = j; i < n; i++){
                double p0 = Math.abs(matObj[index[i]][j]);
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
                double pj = matObj[index[i]][j] / matObj[index[j]][j];

                //record pivoting ratio below the diagonal
                matObj[index[i]][j] = pj;

                //modify other elements accordingly
                for(int l = j+1; l < n; l++){
                    Double cellValue = matObj[index[i]][l];
                    matObj[index[i]][l] = cellValue - pj*matObj[index[j]][l];
                }
            }
        }
    }



    public static MatExpressionObject invertMat(double[][] matObj){
        int n = matObj.length;
        double[][] auxMat = new double[n][n];
        double[][] invMat = new double[n][n];
        int [] index = new int[n];
        double cellValue;//tmp variable

        //set auxillary mat to be an Identity matrix
        for(int i = 0; i < n; i++){
            auxMat[i][i] = 1.0;
        }

        transformToUpperTriangle(matObj, index);

        for(int i = 0; i < n-1; i++){
            for(int j = i+1; j < n; j++){
                for(int k = 0; k < n; k++){
                    cellValue = auxMat[index[j]][k];
                    auxMat[index[j]][k] = cellValue - (matObj[index[j]][i] * auxMat[index[i]][k]);
                }
            }
        }

        for(int i = 0; i < n; i++){
            invMat[n-1][i] = auxMat[index[n-1]][i] / matObj[index[n-1]][n-1];

            for(int j = n-2; j>= 0; j--){
                invMat[j][i] = auxMat[index[j]][i];
                for(int k = j+1; k < n; k++){
                    cellValue = invMat[j][i];
                    invMat[j][i] = cellValue - matObj[index[j]][k]*invMat[k][i];
                }
                cellValue = invMat[j][i];
                invMat[j][i] = cellValue / matObj[index[j]][j];
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
    public static MatExpressionObject multiplyMatrices(double[][] f1, double[][] f2){

        double tmp = 0.0;//used to store intermediate results
        double[][] f0 = new double[f1.length][f2[0].length];
        for(int i=0; i < f1.length ; i++){
            for(int j = 0; j < f2[0].length; j++){
                //each cell in the resulting Matrix = dot product of a single row from F1 and a single column from F2
                for(int k = 0; k < f1[0].length; k++){
                    f0[i][j] += f1[i][k] * f2[k][j];
                }
            }
        }
        return new MatExpressionObject(f0);
    }



    public static MatExpressionObject addMat(double[][] f1, double[][] f2){
        double[][] f0 = new double[f1.length][f1[0].length];
        for(int i = 0; i < f1.length; i++){
            for(int j = 0; j < f1[0].length; j++){
                f0[i][j] = f1[i][j] + f2[i][j];
            }
        }
        return new MatExpressionObject(f0);
    }

    public static MatExpressionObject subtractMat(double[][] f1, double[][] f2){
        double[][] f0 = new double[f1.length][f1[0].length];
        for(int i = 0; i < f1.length; i++){
            for(int j = 0; j < f1[0].length; j++){
                f0[i][j] = f1[i][j] - f2[i][j];
            }
        }
        return new MatExpressionObject(f0);
    }


    /*element-wise add/subtract/mult/divide functions */
    public static MatExpressionObject elemWiseOperation(double[][] f1, double f2, char op){
        double[][] f0 = new double[f1.length][f1[0].length];
        for(int i = 0; i < f1.length; i++){
            for(int j = 0; j < f1[0].length; j++){
                //this switch statement may add to the performance cost, but adding 4 separate functions with almost the same code seemed like too much code repetition
                switch(op){
                    case '+':f0[i][j] = f1[i][j] + f2; break;
                    case '-':f0[i][j] = f1[i][j] - f2; break;
                    case '*':f0[i][j] = f1[i][j] * f2; break;
                    case '/':f0[i][j] = f1[i][j] / f2; break;
                    case '^':f0[i][j] = Math.pow(f1[i][j], f2); break;
                    default: break;
                }
            }
        }
        return new MatExpressionObject(f0);
    }



}
