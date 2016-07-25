/**
 * Scanner that tokenizes Ethereum Virtual Machine (EVM) assembly language.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.assembler.scanner;

import std.ascii;
import std.bigint;
import std.range;
import std.string;

import phlogiston.assembler.token;

/**
 * This predicate indicates whether or not the given character is a newline
 * character.
 *
 * Params:
 *     c = The character to test
 * 
 * Returns: true if the character is a newline, false otherwise.
 */
pure nothrow @nogc @safe bool isNewline(immutable dchar c) {
    return c == '\n';
}

///
unittest {
    assert(isNewline('\n'));
    assert(!isNewline('a'));
    assert(!isNewline(' '));
}

/// Exception raised when an invalid character is encountered in input range.
class InvalidTokenException : Exception {
    @safe pure nothrow this(string msg,
                            string file = __FILE__,
                            size_t line = __LINE__,
                            Throwable next = null)
        {
            super(msg, file, line, next);
        }
}

/// Scans the input stream provided into a series of tokens.
class Scanner {
    /// The input stream of characters.
    private ubyte[] m_charStream;
    /// The current line number in the input range.
    private size_t m_lineNumber;
    /// The current column number in the input range.
    private size_t m_columnNumber;
    /// The current token from the input range.
    private Token m_currentToken;

    this(ubyte[] charStream) {
        this.m_charStream = charStream;
        this.m_lineNumber = 1;
        this.m_columnNumber = 1;
        this.m_currentToken = null;
    }

    /**
     * Returns: The current line number.
     */
    public @property const size_t lineNumber() {
        return m_lineNumber;
    }

    ///
    unittest {
        auto scanner = new Scanner(cast(ubyte[])"\n\n\r\n".representation);
        assert(scanner.lineNumber == 1);
    }

    /**
     * Returns: The current column number.
     */
    public @property const size_t columnNumber() {
        return m_columnNumber;
    }

    ///
    unittest {
        auto scanner = new Scanner(cast(ubyte[])"abcd ".representation);
        assert(scanner.columnNumber == 1);
    }

    /**
     * Returns: The most recent token from the input stream, or null if no
     * tokens have yet been retrieved.
     */
    public @property Token currentToken() {
        return m_currentToken;
    }

    ///
    unittest {
        ubyte[] fixture = cast(ubyte[])"PUSH 1".representation;
        auto scanner = new Scanner(fixture);
        assert(scanner.currentToken is null);
    }

    /**
     * This routine consumes the input stream, returning the next token found.
     * If a token could not be found, then an error is raised.
     *
     * Returns: Next token in the input character stream.
     */
    public Token nextToken() {
        if (m_charStream.empty) {
            m_currentToken = new EndOfStream;
        } else if (isWhite(m_charStream.front)) {
            skipWhitespace();
            m_currentToken = new Whitespace;
        } else if (isAlpha(m_charStream.front)) {
            m_currentToken = parseOpcode();
        } else if (isDigit(m_charStream.front)) {
            m_currentToken = parseNumber();
        } else {
            throw new InvalidTokenException(
                format("Invalid token '%c' (Line %d, Column %d)",
                       m_charStream.front,
                       m_lineNumber,
                       m_columnNumber));
        }

        return m_currentToken;
    }

    /**
     * This routine skips ahead in the input range until the first
     * non-whitespace character or the end of the range is encountered.
     */
    private void skipWhitespace() {
        while (!m_charStream.empty && isWhite(m_charStream.front)) {
            if (isNewline(m_charStream.front)) {
                m_lineNumber += 1;
                m_columnNumber = 1;
            } else {
                m_columnNumber += 1;

            }
            m_charStream.popFront();
        }
    }

    /**
     * This routin parses a hexadecimal number from the input range.
     *
     * Returns: The token for the parsed number.
     */
    private Token parseNumber() {
        if (m_charStream[0..2] == "0x") {
            return parseHexNumber();
        }

        return parseDecimalNumber();
    }

    /**
     * This routine parses a hexadecimal number from the input range.
     *
     * Return: The token from the parsed input stream.
     */
    private Token parseHexNumber() {
        ubyte[] hexNumber;

        while (!m_charStream.empty &&
               (isHexDigit(m_charStream.front) || m_charStream.front == 'x')) {
            hexNumber ~= m_charStream.front;

            m_columnNumber += 1;
            m_charStream.popFront();
        }

        return new Number(BigInt(hexNumber.assumeUTF));
    }

    /**
     * This routine parses a decimal number from the input range.
     *
     * Returns: The parsed number from the input range.
     */
    private Token parseDecimalNumber() {
        ubyte[] number;

        while (!m_charStream.empty && isDigit(m_charStream.front)) {
            number ~= m_charStream.front;

            m_columnNumber += 1;
            m_charStream.popFront();
        }

        return new Number(BigInt(number.assumeUTF));
    }

    /**
     * This routine parses an opcode from the input range.
     *
     * Returns: The token for the parsed opcode.
     */
    private Token parseOpcode() {
        if (m_charStream.length >= 4 && m_charStream[0..4] == "PUSH") {
            return parsePushOpcode();
        }

        return parseStackOpcode();
    }

    /**
     * This routine parses a push opcode from the input range.
     *
     * Returns: Token for the push opcode.
     */   
    private Token parsePushOpcode() {
        ubyte[] opcode;

        while (!m_charStream.empty &&
               (isAlpha(m_charStream.front) || 
                isDigit(m_charStream.front))) {
            opcode ~= m_charStream.front();

            m_columnNumber += 1;
            m_charStream.popFront();
        }

        return new PushOpcode(opcode.assumeUTF);
    }

    /**
     * This routine parses a stack opcode from the input range.
     *
     * Returns: Token for the stack opcode.
     */
    private Token parseStackOpcode() {
        ubyte[] opcode;

        while (!m_charStream.empty &&
               (isAlpha(m_charStream.front) || isDigit(m_charStream.front))) {
            opcode ~= m_charStream.front();

            m_columnNumber += 1;
            m_charStream.popFront();
        }

        return new StackOpcode(opcode.assumeUTF);
    }
 }

///
unittest {
    auto scanner = new Scanner(cast(ubyte[])"".representation);
    assert(cast(EndOfStream)scanner.nextToken());

    scanner = new Scanner(cast(ubyte[])"\n\n\r\n  ".representation);
    assert(cast(Whitespace)scanner.nextToken());
    assert(scanner.lineNumber == 4);
    assert(scanner.columnNumber == 3);

    scanner = new Scanner(cast(ubyte[])"STOP".representation);
    StackOpcode stackToken = cast(StackOpcode)scanner.nextToken();
    assert(stackToken.m_opcode == "STOP");

    scanner = new Scanner(cast(ubyte[])"PUSH1 0xa".representation);
    PushOpcode pushToken = cast(PushOpcode)scanner.nextToken();
    assert(pushToken.m_opcode == "PUSH1");
    assert(cast(Whitespace)scanner.nextToken());
    Number number = cast(Number)scanner.nextToken();
    assert(number.m_value == BigInt(10));

    scanner = new Scanner(cast(ubyte[])"PUSH1 1234".representation);
    pushToken = cast(PushOpcode)scanner.nextToken();
    assert(pushToken.m_opcode == "PUSH1");
    assert(cast(Whitespace)scanner.nextToken());
    number = cast(Number)scanner.nextToken();
    assert(number.m_value == BigInt("1234"));
}
