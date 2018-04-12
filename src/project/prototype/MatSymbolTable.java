package project.prototype;

import java.util.*;
import java.lang.Math.*;

public class MatSymbolTable {
    /*
    Custom SYMBOL TABLE used to store matrices and scalar numbers (as doubles)

    decided to use 2 separate hashmaps (one for matrices and one for scalars) instead of having a type attribute to avoid performance loss
        -> since creating and storing a custom object that contains sub-objects (the matrix representation as a 2d double array) and a type attribute, Instead type-checking and error handling is done by the parser

        - does not need scope functions, all matrices are in a global scope
        - does not need a find function, since hashMap provides an optimized get function based on the string key (which will hold the symbol the user wanted to assign to the matrix)
    */
    public HashMap<String, double[][]> ST;
    public HashMap<String, Double> ScalarST;

    //constructor - init the ST
    public MatSymbolTable(){
        ST = new HashMap<String, double[][]>();
        ScalarST = new HashMap<String, Double>();//cannot store a primitive in a a hashmap, so must be the Double object
    }



    //initializes an empty matrix with the key symbol
    public boolean addMatrixItem(String symbol){
        if(!ST.containsKey(symbol)){
            ST.put(symbol, new double[0][0]);
            return true;
        }
        else return false;
    }


    //takes in an arrayList of Lists and saves to ST as a 2d-array of doubles
    public void addMatrixToSymbol(String symbol, ArrayList<List<Double>> mat){
        //run a for loop, put vals in a double add it to the newly improved ST
        if(ST.containsKey(symbol)){
            double[][] STentry = new double[mat.size()][mat.get(0).size()];

            for(int i = 0; i < mat.size(); i++){
                for(int j = 0; j < mat.get(0).size(); j++){
                    STentry[i][j] = (double)mat.get(i).get(j);
                }
            }
            ST.put(symbol, STentry);

        }
    }


    public boolean addScalarItem(String symbol, double scalarValue){
        if(!ScalarST.containsKey(symbol)){
            ScalarST.put(symbol, (Double)scalarValue);//cast to Double object
            return true;
        }
        else return false;
    }


    //functions used when variable types are overwritten by calculations
    // This ensures that a symbol table transition from Scalar to matrix and vice-versa
    public void moveSTKeyToScalarST(String symbol, double newVal){
        ST.remove(symbol);
        ScalarST.put(symbol, (Double)newVal);
    }

    public void moveScalarSTKeyToST(String symbol, double[][] newVal){
        ScalarST.remove(symbol);
        ST.put(symbol, newVal);
    }



    //print a given set of elements from both symbol tables
    public void printSymbols(List<String> symbols){
        System.out.println("\n*****Showing Specific Variables*****\n");
        double[][] matToPrint;
        for(String symbol: symbols){
            if(ScalarST.containsKey(symbol)){
                System.out.println("\nVariable Name: " + symbol + " = " + Math.round(ScalarST.get(symbol)*100.0)/100.0 );
            }
            if(ST.containsKey(symbol)){
                System.out.println("\nMatrix Name: " + symbol);
                matToPrint = ST.get(symbol);
                for(int i = 0; i < matToPrint.length; i++){
                    System.out.print("\t\t[ ");//tab for each row
                    for(int j = 0; j < matToPrint[0].length - 1; j++){
                        System.out.print(Math.round(matToPrint[i][j]*100.0)/100.0 + ", ");
                    }
                    System.out.print(Math.round(matToPrint[i][matToPrint[0].length-1]*100.0)/100.0
                     + " ]\n");
                }
                System.out.print("\n");
            }
        }
        System.out.println("\n**********************************\n");
    }




    //print all elements in symbol table
    public void printST(){
        double[][] matToPrint;
        System.out.println("\nMatrices:");
        System.out.println("---------------------------");
        for(Map.Entry<String, double[][]> symbol: ST.entrySet()){
            System.out.println("\nMatrix Name: " + symbol.getKey());
            matToPrint = symbol.getValue();
            for(int i = 0; i < matToPrint.length; i++){
                System.out.print("\t\t[ ");//tab for each row
                for(int j = 0; j < matToPrint[0].length - 1; j++){
                    System.out.print(Math.round(matToPrint[i][j]*100.0)/100.0 + ", ");
                }
                System.out.print(Math.round(matToPrint[i][matToPrint[0].length-1]*100.0)/100.0
                 + " ]\n");
            }
            System.out.print("\n");
        }
    }

    public void printScalarST(){
        System.out.println("\nScalar Values:");
        System.out.println("---------------------------");
        for(Map.Entry<String, Double> symbol:ScalarST.entrySet()){
            System.out.println("\nVariable Name: " + symbol.getKey() + " = " + Math.round(symbol.getValue()*100.0)/100.0);
        }
    }

}
