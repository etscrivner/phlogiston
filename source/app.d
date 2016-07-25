/**
 * Application entry point for Phlogiston command-line tool.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
import std.conv;
import std.file;
import std.stdio;
import std.string;

import phlogiston.disassembler.disassembler;
import phlogiston.assembler.parser;
import phlogiston.assembler.scanner;

/// Interface for the assembler app.
class AssemblerApp {
    /**
     * This routine executes the assembler application.
     *
     * Params:
     *     inputFile = The file to read assembly language code from.
     *     outputFile = The file to write the bytecode string into.
     */
    public void execute(string inputFile, string outputFile) {
        string assemblyCode = readText(inputFile);
        ubyte[] assemblyCodeBytes = cast(ubyte[])assemblyCode.representation;

        Scanner scanner = new Scanner(assemblyCodeBytes);
        Parser parser = new Parser;
        ubyte[] bytecode = parser.parse(scanner);

        writeBytecodeToFile(bytecode, outputFile);
    }

    /**
     * This routine writes the given series of bytes to the given output file.
     *
     * Params:
     *     bytecode = The bytecode to be written.
     *     outputFile = The file to write the bytecode into.
     */
    private void writeBytecodeToFile(ref ubyte[] bytecode, string outputFile) {
        File file = File(outputFile, "w");
        foreach (val; bytecode) {
            file.writef("%02x", val);
        }
    
        file.write('\n');
        file.close();
    }
}

/// Interface for the disassembler app.
class DisassemblerApp {
    public void execute(string inputFile, string outputFile) {
        string vmBytes = readText(inputFile);

        Disassembler disassembler = new Disassembler;
        auto assemblyCode = disassembler.disassemble(vmBytes);

        File file = File(outputFile, "w");

        foreach (codeLine; assemblyCode) {
            file.writeln(codeLine);
        }

        file.close();
    }
}

int main(string[] args) {
    if (args.length < 4) {
        writeln("Usage: phlogiston [assemble|disassemble] [INPUT] [OUTPUT]");
        writeln("The assembler converts an EVM assembly language file into a");
        writeln("file containing a bytecode string. The disassembler converts");
        writeln("an EVM bytecode file into an assembly language file.");
        return 1;
    }

    auto mode = args[1];
    if (mode != "assemble" && mode != "disassemble") {
        writefln("error: unknown mode '%s'", mode);
        writeln("valid modes are 'assemble' and 'disassemble'");
        return 1;
    }

    auto inputFile = args[2];
    if (!inputFile.exists) {
        writefln("error: could not find INPUTFILE '%s'", inputFile);
        return 1;
    }

    auto outputFile = args[3];
    if (outputFile.exists) {
        writefln("error: OUTPUTFILE '%s' already exists", outputFile);
        return 1;
    }

    if (mode == "assemble") {
        auto assemblerApp = new AssemblerApp();
        assemblerApp.execute(inputFile, outputFile);
    } else {
        auto disassemblerApp = new DisassemblerApp();
        disassemblerApp.execute(inputFile, outputFile);
    }

    return 0;
}
