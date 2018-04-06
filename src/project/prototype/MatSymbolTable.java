package project.prototype;

import java.util.*;

public class MatSymbolTable{

    public HashMap<String, ArrayList<List<Double>>> ST;

    //constructor - init the ST
    public MatSymbolTable(){
        ST = new HashMap<String, ArrayList<List<Double>>>();
    }


    /*  - does not need scope functions, all matrices are in a global scope
        - does not need a find function, since the hashMap provides an optimized get function based on the string index (which will hold the symbol the user wanted to assign to the matrix)
    */


    //initializes an empty matrix with the key symbol
    public boolean addItem(String symbol){
        if(!ST.containsKey(symbol)){
            ST.put(symbol, new ArrayList<List<Double>>());
            return true;
        }
        else return false;
    }

    //add a symbol along with its matrix
    public boolean addItem(String symbol, ArrayList<List<Double>> matrix){
        //..todoLater..
        return false;
    }

    //add rowData to the tail of the 'matrix' with symbol, used for loading matrices from an input file
    public void addRowToMatrix(String symbol, List<Double> rowData){
        if(ST.containsKey(symbol)){
            ST.get(symbol).add(new ArrayList<Double>(rowData));
        }
    }



    //print the symbol table (mostly for testing)
    public void printST(){
        Iterator it = ST.entrySet().iterator();
        while(it.hasNext()){
            Map.Entry matrix = (Map.Entry)it.next();
            System.out.println(matrix.getKey());
            System.out.println(matrix.getValue());
        }
    }
}
