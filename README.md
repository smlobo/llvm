# llvm
LLVM IR & MIR code

## Run
```
lli <name>.ll
```

## Create a binary
```
clang <name>.ll
```

## Assemble to target specific instructions
```
clang -S <name>.ll
```

## MIR
Several options for MIR after running the pipeline of passes (early to later 
pass)

| Option | Stage |
| --- | --- |
| `-stop-after=finalize-isel` | After instruction selection |
| `-stop-after=postrapseudos` | After post-allocation pseudo expansion |
| `-stop-after=unpack-mi-bundles` | After unpacking machine instruction bundles |

### Execution steps
```
llc -stop-after=finalize-isel -simplify-mir <name>.ll -o <name>.mir
llc -filetype=obj <name>.mir -o <name>.o
clang <name>.o
./a.out
```