package project.prototype;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;


public class MatFileWriter{

    public static StringBuffer csvContent = new StringBuffer();;

    public MatFileWriter(){
        //empty constructor...
    }

    public static void clearExportData(){
        csvContent.setLength(0);//clears the string buffer
    }


    public static void addNewLine(){
        csvContent.append(System.getProperty("line.separator"));
    }

    //clear some space between objects in the csv (3 lines)
    public static void addSpaceForNewItem(){
        if(csvContent.length() > 0){
            addNewLine(); addNewLine(); addNewLine();
        }
    }

    public static void addRepresentationOfDouble(double val){
        if(val % 1 == 0 ) csvContent.append(String.valueOf((int)val));
        else csvContent.append(String.valueOf(Math.round(val*100.0)/100.0));
    }


    public static void addMatrixToFile(String symbol, double[][] matrix){
        addSpaceForNewItem();
        csvContent.append(symbol);
        addNewLine();

        for(int i = 0; i < matrix.length; i++){
            for(int j = 0; j < matrix[0].length - 1; j++){
                addRepresentationOfDouble(matrix[i][j]);
                csvContent.append(", ");
            }
            //no trailing comma for the last element in the row
            addRepresentationOfDouble(matrix[i][matrix[0].length-1]);
            addNewLine();
        }
    }

    public static void addScalarValueToFile(String symbol, double val){
        addSpaceForNewItem();
        csvContent.append(symbol + ",");
        addRepresentationOfDouble(val);
    }


    public static void saveCsvContent(String fileName){
        //use BufferedWriter to write the contents of the string buffer
        try{
            BufferedWriter br = new BufferedWriter(new FileWriter(new File(System.getProperty("user.dir") + "/" + fileName + ".csv")));
            br.write(csvContent.toString());
            br.flush();
            br.close();
            System.out.println("\nFile " + fileName + ".csv was written successfully");
        }
        catch(IOException e){
            System.out.println("\nThere was an Error in saving the file " + fileName + ".csv");
        }
    }



}
