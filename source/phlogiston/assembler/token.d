/**
 * Token types for Ethereum Virtual Machine (EVM) assembler scanner.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.assembler.token;

import std.bigint;
import std.conv;
import std.string;
import std.traits;

/**
 * Base class for all token types
 */
interface Token {
}

/// Opcode representing whitespace
class Whitespace : Token {
    public override string toString() {
        return "Whitespace";
    }
}

///
unittest {
    auto token = new Whitespace();
    assert(token.toString() == "Whitespace");
}

/// Opcode representing end of the input stream
class EndOfStream : Token {
    public override string toString() {
        return "EndOfStream";
    }
}

///
unittest {
    auto token = new EndOfStream();
    assert(token.toString() == "EndOfStream");
}

/// Represents a numerical value
class Number : Token {
    /// The numerical value
    public BigInt m_value;

    this(BigInt value) {
        this.m_value = value;
    }

    public override string toString() {
        return format("Number(0x%x)", m_value);
    }
}

///
unittest {
    BigInt value = BigInt("0x1234");
    auto token = new Number(value);
    assert(token.toString() == "Number(0x1234)");
    assert(token.m_value == value);
}

/**
 * Represents an opcode that works only with the EVM stack, and therefore has
 * no arguments.
 */
class StackOpcode : Token {
    /// The stack-based opcode
    public string m_opcode;

    this(string opcode) {
        this.m_opcode = opcode;
    }

    public override string toString() {
        return format("StackOpcode(%s)", m_opcode);
    }
}

///
unittest {
    auto token = new StackOpcode("STOP");
    assert(token.toString() == "StackOpcode(STOP)");
    assert(token.m_opcode == "STOP");
}

/**
 * Represents an opcode that pushes values onto the EVM stack and so takes an
 * argument.
 */
class PushOpcode : Token {
    /// The push opcode
    public string m_opcode;

    this(string opcode) {
        this.m_opcode = opcode;
    }

    public override string toString() {
        return format("PushOpcode(%s)", m_opcode);
    }
}

///
unittest {
    auto token = new PushOpcode("PUSH1");
    assert(token.toString() == "PushOpcode(PUSH1)");
    assert(token.m_opcode == "PUSH1");
}
