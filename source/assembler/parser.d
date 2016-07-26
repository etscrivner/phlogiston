/**
 * Parser for the Ethereum Virtual Machine (EVM) assembler.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.assembler.parser;

import std.algorithm;
import std.bigint;
import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import phlogiston.assembler.scanner;
import phlogiston.assembler.token;
import phlogiston.evm.opcodes;

/// Error raised whenever an issue in parsing is encountered
class ParseError : Exception {
    @safe pure nothrow this(string msg,
                            string file = __FILE__,
                            size_t line = __LINE__,
                            Throwable next = null)
        {
            super(msg, file, line, next);
        }
}

/// Converts a token stream from a scanner into EVM bytecode.
class Parser {
    /**
     * Parses the given token stream into a sequence of bytes representing an
     * EVM bytecode program.
     *
     * Params:
     *     scanner = The scanner used for tokenizing input.
     *
     * Returns: Bytes corresponding to EVM bytecode.
     */
    public ubyte[] parse(ref Scanner scanner) {
        Token currentToken = scanner.nextToken();
        auto opcodeNameToBytecode = generateOpcodeNameToBytecodeMap();

        ubyte[] bytecodeProgram;

        while (!cast(EndOfStream)currentToken) {
            if (cast(Whitespace)currentToken) {
                currentToken = scanner.nextToken();
                continue;
            } else if (cast(StackOpcode)currentToken) {
                StackOpcode stackOpcode = cast(StackOpcode)currentToken;
                bytecodeProgram ~= opcodeNameToBytecode[stackOpcode.m_opcode];
            } else if (cast(PushOpcode)currentToken) {
                PushOpcode pushOpcode = cast(PushOpcode)currentToken;

                // Add opcode to bytecode stream
                ubyte pushBytecode = opcodeNameToBytecode[pushOpcode.m_opcode];
                bytecodeProgram ~= pushBytecode;

                expectToken!Whitespace(scanner);
                expectToken!Number(scanner);

                size_t expectedNumBytes = (pushBytecode - Opcode.PUSH1 + 1);

                // Add argument to bytecode stream
                Number argumentToken = cast(Number)scanner.currentToken;
                auto pushArgumentBytes = encodeNumberAsBytes(
                    argumentToken, expectedNumBytes);

                if (pushArgumentBytes.length > expectedNumBytes) {
                    throw new ParseError(
                        format("Number 0x%x is too big for opcode PUSH%d" ~
                               " (Line %d, Column %d)",
                               argumentToken.m_value,
                               expectedNumBytes,
                               scanner.lineNumber,
                               scanner.columnNumber));
                }

                pushArgumentBytes.each!(
                    (argByte) => bytecodeProgram ~= argByte);
            }

            currentToken = scanner.nextToken();
        }

        return bytecodeProgram;
    }

    /**
     * This routine asserts that the next token in the stream has the expected
     * type.
     *
     * Params:
     *     scanner = The scanner for retrieving the next token.
     */
    private void expectToken(T)(ref Scanner scanner) {
        scanner.nextToken();
        assert(cast(T)scanner.currentToken);
    }
    
    /**
     * This routine converts the given number into a big-endian encoded range
     * of bytes.
     *
     * Params:
     *     number = The number to be encoded.
     *     expectedNumBytes = The number of bytes that should compose number.
     *
     * Returns: byte range containing big-endian encoding of number.
     */
    private ubyte[] encodeNumberAsBytes(Number number,
                                        size_t expectedNumBytes) {
        ubyte[] result;

        // Convert to hex, remove underscores, and create range of two
        // character chunks.
        auto reverseHexBytes = chunks(
            number.m_value.toHex().replace("_", ""), 2);

        foreach (nextByte; reverseHexBytes) {
            dchar[] byteChars = nextByte.array();
            result ~= std.conv.parse!ubyte(byteChars, 16);
        }

        return result;
    }
}

///
unittest {
    // Simple single opcode
    auto scanner = new Scanner(cast(ubyte[])"ADD");
    auto parser = new Parser();
    auto bytecode = parser.parse(scanner);
    assert(bytecode == [0x01]);

    // Multiple opcodes
    scanner = new Scanner(cast(ubyte[])"PUSH1 0xfa\nPUSH1 0xab");
    bytecode = parser.parse(scanner);
    assert(bytecode == [Opcode.PUSH1, 0xfa, Opcode.PUSH1, 0xab]);

    // Mixed stack and push opcodes
    scanner = new Scanner(cast(ubyte[])"PUSH1 0xfa\nDUP1\nMUL\nPUSH1 0x60\n");
    bytecode = parser.parse(scanner);
    assert(bytecode == [Opcode.PUSH1, 0xfa,
                        Opcode.DUP1,
                        Opcode.MUL,
                        Opcode.PUSH1, 0x60]);

    // Properly ignores all sorts of whitespace
    scanner = new Scanner(cast(ubyte[])"  \r\nPUSH1\t0xfa\r\nDUP1\n\r\t    ");
    bytecode = parser.parse(scanner);
    assert(bytecode == [Opcode.PUSH1, 0xfa, Opcode.DUP1]);
}

unittest {
    // Number is too big for opcode
    auto scanner = new Scanner(cast(ubyte[])"PUSH2 0xabcdef");
    auto parser = new Parser();
    assertThrown!ParseError(parser.parse(scanner));
}
