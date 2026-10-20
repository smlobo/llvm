declare i32 @printf(ptr, ...)

%Point = type { i32, i32 }

@.str = private constant [13 x i8] c"[%d] %d, %d\0A\00"

define i32 @main() #0 {
entry:
    ; Allocate stack space
    %2 = alloca [3 x %Point], align 4

    ; Assign values to index 0
    %i0f0Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 0, i32 0
    store i32 1, ptr %i0f0Ptr, align 4
    %i0f1Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 0, i32 1
    store i32 2, ptr %i0f1Ptr, align 4
    %i1f0Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 1, i32 0
    store i32 10, ptr %i1f0Ptr, align 4
    %i1f1Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 1, i32 1
    store i32 20, ptr %i1f1Ptr, align 4
    %i2f0Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 2, i32 0
    store i32 100, ptr %i2f0Ptr, align 4
    %i2f1Ptr = getelementptr [3 x %Point], ptr %2, i32 0, i32 2, i32 1
    store i32 200, ptr %i2f1Ptr, align 4
    br label %loopBegin

loopBegin:
    %index = phi i8 [0, %entry], [%nextIndex, %loopBody]
    %done = icmp sgt i8 %index, 2
    br i1 %done, label %loopEnd, label %loopBody

loopBody:
    ; pointer to element in the array
    %arrayElementPtr = getelementptr [3 x %Point], ptr %2, i32 0, i8 %index

    ; pointers to each field
    %field0Ptr = getelementptr %Point, ptr %arrayElementPtr, i32 0, i32 0
    %field1Ptr = getelementptr %Point, ptr %arrayElementPtr, i32 0, i32 1

    ; load values
    %field0Val = load i32, ptr %field0Ptr
    %field1Val = load i32, ptr %field1Ptr

    ; print
    call i32 (ptr, ...) @printf(ptr @.str, i8 %index, i32 %field0Val, 
        i32 %field1Val)

    ; increment index
    %nextIndex = add i8 %index, 1
    br label %loopBegin

loopEnd:
    ret i32 0
}
