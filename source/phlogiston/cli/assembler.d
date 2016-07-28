/**
 * Application interface for assembler command-line tool.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.cli.assembler;

import std.file;
import std.stdio;

import phlogiston.assembler.assembler;

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
        Assembler assembler = new Assembler;

        try {
            ubyte[] bytecode = assembler.assemble(assemblyCode);
            writeBytecodeToFile(bytecode, outputFile);
        } catch(AssemblerError ae) {
            writeln("error: ", ae.msg);
            return;
        }
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
