import std.conv;
import std.file;
import std.stdio;
import std.string;

import phlogiston.assembler.parser;
import phlogiston.assembler.scanner;

int main(string[] args) {
    if (args.length < 3) {
        writeln("Usage: phlogiston [INPUT] [OUTPUT]");
        writeln("Converts the given EVM assembly laguage file into EVM");
        writeln("bytecode");
        return 1;
    }

    auto inputFile = args[1];
    if (!inputFile.exists) {
        writefln("error: could not find INPUTFILE '%s'", inputFile);
        return 1;
    }

    auto outputFile = args[2];
    if (outputFile.exists) {
        writefln("error: OUTPUTFILE '%s' already exists", outputFile);
        return 1;
    }

    string vmBytes = readText(inputFile);
    Parser parser = new Parser;
    ubyte[] byteChars = cast(ubyte[])vmBytes.representation;
    Scanner scanner = new Scanner(byteChars);

    auto bytecode = parser.parse(scanner);
    foreach (val; bytecode) {
        writef("%02x", val);
    }
    
    write('\n');

    return 0;
}
