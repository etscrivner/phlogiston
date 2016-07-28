/**
 * Application interface for disassembler command-line tool.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.cli.disassembler;

import std.file;
import std.stdio;

import phlogiston.disassembler.disassembler;

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
