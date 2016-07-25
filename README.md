# Phlogiston

An assembler and disassembler for the Ethereum Virtual Machine (EVM).

## Building

To build this package assuming you have
[DUB Package Manager](https://github.com/dlang/dub) installed you can do the
following:

```shell
$ dub build
```

## Assembler Usage

The following is a simple contract:

```
PUSH1 0x60
PUSH1 0x40
MSTORE
PUSH1 0x0a
DUP1
PUSH1 0x10
PUSH1 0x00
CODECOPY
PUSH1 0x00
RETURN
PUSH1 0x60
PUSH1 0x40
MSTORE
PUSH1 0x08
JUMP
JUMPDEST
STOP
```

To compile it you would write:

```
$ phlogiston assemble input.evm output.txt
```

When we examine output.txt we will find:

```
6060604052600a8060106000396000f360606040526008565b00
```

## Disassembler Usage

Given the bytecode file we just previously entered:

```
6060604052600a8060106000396000f360606040526008565b00
```

To disassemble it you would write:

```
$ phlogiston disassemble output.txt result.evm
```

When we example `result.evm` we will find:

```
PUSH1 0x60
PUSH1 0x40
MSTORE
PUSH1 0x0a
DUP1
PUSH1 0x10
PUSH1 0x00
CODECOPY
PUSH1 0x00
RETURN
PUSH1 0x60
PUSH1 0x40
MSTORE
PUSH1 0x08
JUMP
JUMPDEST
STOP
```
