declare i32 @printf(ptr, ...)

@fmt = private constant [7 x i8] c"%d %d\0A\00"

%Point = type { i32, i32 }

@i32Array = constant [4 x i32] [i32 10, i32 20, i32 30, i32 40]

define i32 @main() {
entry:
    ; allocate struct on stack
    %p = alloca %Point

    ; get pointers to fields
    %pIndex0Ptr = getelementptr {i32, i32}, ptr %p, i32 0, i32 0
    %pIndex1Ptr = getelementptr {i32, i32}, ptr %p, i32 0, i32 1

    ; store values
    store i32 11, ptr %pIndex0Ptr
    store i32 22, ptr %pIndex1Ptr

    ; load values
    %pIndex0Val = load i32, ptr %pIndex0Ptr
    %pIndex1Val = load i32, ptr %pIndex1Ptr

    ; print values
    %fmtptr = getelementptr [7 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %pIndex0Val, i32 %pIndex1Val)

    ret i32 0
}

