/**
 * Interface for assembling a string of assembly containing into bytecode.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.assembler.assembler;

import std.exception;
import std.string;

import phlogiston.assembler.parser;
import phlogiston.assembler.scanner;

/// Error raised if an error is encountered while assembling code.
class AssemblerError : Exception {
    @safe pure nothrow this(string msg,
                            string file = __FILE__,
                            size_t line = __LINE__,
                            Throwable next = null)
        {
            super(msg, file, line, next);
        }
}

/// Interface for parsing assembly code into bytecode
class Assembler {
    /**
     * This routine takes a string of assembly code and produces the bytecode
     * corresponding to it.
     *
     * Throws: AssemblerError if an error is encountered during assembly.
     *
     * Params:
     *     assemblyCode = The assembly code
     *
     * Returns: The bytecode resulting from compiling the assembly code.
     */
    public ubyte[] assemble(ref string assemblyCode) {
        ubyte[] byteRepresentation = cast(ubyte[])assemblyCode.representation;

        Scanner scanner = new Scanner(byteRepresentation);
        Parser parser = new Parser;

        try {
            return parser.parse(scanner);
        } catch(InvalidTokenException ite) {
            throw new AssemblerError(ite.msg);
        } catch(ParseError pe) {
            throw new AssemblerError(pe.msg);
        }
    }
}
