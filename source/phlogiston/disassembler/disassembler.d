/**
 * Disassembler for convert Ethereum Virtual Machine (EVM) bytecode to EVM
 * assembly language.
 *
 * Copyright © 2016, Eric Scrivner
 *
 * License: Subject to the terms of the MIT license, as written in the included
 * LICENSE.txt file.
 * Authors: Eric Scrivner
 */
module phlogiston.disassembler.disassembler;

import std.algorithm;
import std.bigint;
import std.conv;
import std.range;
import std.string;

import phlogiston.evm.opcodes;

/// Converts a stream of bytes into EVM assembly code.
class Disassembler {
    /**
     * This routine converts the given EVM bytecode into a string containing
     * EVM assembly language code.
     *
     * Params:
     *     vmBytes = The string containing EVM bytecode.
     *
     * Returns: An array EVM assembly language code opcodes.
     */
    public string[] disassemble(string vmBytes) {
        ubyte[] bytecode = hexStringToByteArray(vmBytes.strip());

        string[] results;
        auto nameForOpcode = generateBytecodeToOpcodeNameMap();

        for (size_t pc = 0; pc < bytecode.length; pc++) {
            auto opcode = bytecode[pc];

            switch(opcode) {
            case Opcode.PUSH1:
            case Opcode.PUSH2:
            case Opcode.PUSH3:
            case Opcode.PUSH4:
            case Opcode.PUSH5:
            case Opcode.PUSH6:
            case Opcode.PUSH7:
            case Opcode.PUSH8:
            case Opcode.PUSH9:
            case Opcode.PUSH10:
            case Opcode.PUSH11:
            case Opcode.PUSH12:
            case Opcode.PUSH13:
            case Opcode.PUSH14:
            case Opcode.PUSH15:
            case Opcode.PUSH16:
            case Opcode.PUSH17:
            case Opcode.PUSH18:
            case Opcode.PUSH19:
            case Opcode.PUSH20:
            case Opcode.PUSH21:
            case Opcode.PUSH22:
            case Opcode.PUSH23:
            case Opcode.PUSH24:
            case Opcode.PUSH25:
            case Opcode.PUSH26:
            case Opcode.PUSH27:
            case Opcode.PUSH28:
            case Opcode.PUSH29:
            case Opcode.PUSH30:
            case Opcode.PUSH31:
            case Opcode.PUSH32:
                size_t numBytes = getPushOpcodeBytes(opcode);
                BigInt number = BigInt(0);

                // Iterate through the bytes for the argument and consolidate them into
                // a single integer value.
                for (ubyte i = 1; i <= numBytes; i++) {
                    number <<= 8;
                    if (pc + i < bytecode.length) {
                        number |= bytecode[pc + i];
                    }
                }

                results ~= format("%s 0x%02x", nameForOpcode[opcode], number);
                // Ensure that we skip past the bytes for the argument
                pc += numBytes;
                break;
            default:
                if (opcode in nameForOpcode) {
                    results ~= nameForOpcode[opcode];
                }
                break;
            }
        }

        return results;
    }

    /**
     * Returns: The number of bytes in the argument for a push opcode.
     */
    private size_t getPushOpcodeBytes(const uint opcode) {
        // Get the number of bytes for the argument by doing some math on the
        // opcode. Produces a number in range [1, 32].
        return (opcode - Opcode.PUSH1 + 1);
    }

    /**
     * Converts a long hexadecimal string into an array of bytes.
     *
     * Params:
     *      hexString = A string containing hexadecimal bytes.
     *
     * Returns: An array of bytes in the same order they appear in the string.
     */
    private ubyte[] hexStringToByteArray(string hexString) {
        ubyte[] results;

        foreach (nextByte; chunks(hexString, 2)) {
            results ~= parse!ubyte(nextByte, 16);
        }

        return results;
    }
}
