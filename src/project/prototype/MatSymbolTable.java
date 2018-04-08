package project.prototype;

import java.util.*;

public class MatSymbolTable {
    /*
    Custom SYMBOL TABLE used to store matrices and scalar numbers (as doubles)

    decided to use 2 separate hashmaps (one for matrices and one for scalars) instead of having a type attribute to avoid performance loss
        -> since creating and storing a custom object that contains sub-objects (the matrix representation as a list of lists) and a type attribute, along with functions of its own would take up more space than just storing a list of lists. This would definitely affect the size and performance of the symbol table. Instead type-checking is done by the parser and helper functions from external classes that actually perform the matrix operations

        - does not need scope functions, all matrices are in a global scope
        - does not need a find function, since hashMap provides an optimized get function based on the string key (which will hold the symbol the user wanted to assign to the matrix)
    */
    public HashMap<String, ArrayList<List<Double>>> ST;
    public HashMap<String, Double> ScalarST;

    //constructor - init the ST
    public MatSymbolTable(){
        ST = new HashMap<String, ArrayList<List<Double>>>();
        ScalarST = new HashMap<String, Double>();
    }



    //initializes an empty matrix with the key symbol
    public boolean addMatrixItem(String symbol){
        if(!ST.containsKey(symbol)){
            ST.put(symbol, new ArrayList<List<Double>>());
            return true;
        }
        else return false;
    }

    //add a symbol along with its matrix
    public boolean addMatrixItem(String symbol, ArrayList<List<Double>> matrix){
        //..todoLater..
        return false;
    }

    //add rowData to the tail of the 'matrix' corresponding to the symbol, used for loading matrices from an input file
    public void addRowToMatrix(String symbol, List<Double> rowData){
        if(ST.containsKey(symbol)){
            ST.get(symbol).add(new ArrayList<Double>(rowData));
        }
    }

    public boolean addScalarItem(String symbol, Double scalarValue){
        if(!ScalarST.containsKey(symbol)){
            ScalarST.put(symbol, scalarValue);
            return true;
        }
        else return false;
    }


    //functions used when variable types are overwritten by calculations
    // This ensures that a symbol table transition from Scalar to matrix and vice-versa
    public void moveSTKeyToScalarST(String symbol, Double newVal){
        ST.remove(symbol);
        ScalarST.put(symbol, newVal);
    }

    public void moveScalarSTKeyToST(String symbol, ArrayList<List<Double>> newVal){
        ScalarST.remove(symbol);
        ST.put(symbol, newVal);
    }



    //print a given set of elements from both symbol tables
    public void printSymbols(List<String> symbols){
        for(String symbol: symbols){
            if(ScalarST.containsKey(symbol)){
                System.out.println("\nVariable Name: " + symbol + " = " + ScalarST.get(symbol));
            }
            if(ST.containsKey(symbol)){
                System.out.println("\nMatrix Name: " + symbol);
                for(List<Double>row:ST.get(symbol)){
                    System.out.println("\t\t" + row);
                }
            }
        }
    }




    //print all elements in symbol table
    public void printST(){
        System.out.println("\nMatrices:");
        System.out.println("---------------------------");
        for(Map.Entry<String, ArrayList<List<Double>>> symbol: ST.entrySet()){
            System.out.println("\nMatrix Name: " + symbol.getKey());
            for(List<Double> row: symbol.getValue()){
                System.out.println("\t\t" + row);
            }
        }
    }

    public void printScalarST(){
        System.out.println("\nScalar Values:");
        System.out.println("---------------------------");
        for(Map.Entry<String, Double> symbol:ScalarST.entrySet()){
            System.out.println("\nVariable Name: " + symbol.getKey() + " = " + symbol.getValue());
        }
    }

    //convert the given list of symbols into string data 
}
