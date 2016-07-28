/**
 * Application entry point for Phlogiston command-line tool.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
import std.file;
import std.stdio;

import phlogiston.cli.assembler;
import phlogiston.cli.disassembler;

version(unittest) {
} else {
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
}
