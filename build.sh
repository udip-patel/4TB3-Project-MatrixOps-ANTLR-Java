#comile grammar and put generated source into parser package
java -cp antlr-4.6-complete.jar org.antlr.v4.Tool -o src/project/prototype/parser -no-listener Mat.g4

#create directory for output
mkdir build

#compile the Java source file
javac -cp "antlr-4.6-complete.jar" -d build -sourcepath src src/project/prototype/Mat.java

#bundle the compiled classes into a jar
jar cfm Mat.jar src/META-INF/MANIFEST.MF -C build .

#program can now be run like so: "java -jar Mat.jar < sampleInput.txt"
