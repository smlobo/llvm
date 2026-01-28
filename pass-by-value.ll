declare i32 @printf(ptr, ...)

@fmt = private constant [10 x i8] c"{%d, %d}\0A\00"
@beforeMsg = private constant [9 x i8] c"main(): \00"
@passByValMsg = private constant [14 x i8] c"pass-by-val: \00"

%Point = type { i32, i32 }

define void @printPointByVal(%Point %p) {
entry:
    %x = extractvalue %Point %p, 0
    %y = extractvalue %Point %p, 1

    ; print
    %passByValMsgPtr = getelementptr [14 x i8], ptr @passByValMsg, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %passByValMsgPtr)
    %fmtptr = getelementptr [10 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %x, i32 %y)

    ret void
}

define i32 @main() {
entry:
    ; create the struct
    %p = insertvalue %Point undef, i32 10, 0
    %p2 = insertvalue %Point %p, i32 20, 1

    ; print in main
    %x = extractvalue %Point %p2, 0
    %y = extractvalue %Point %p2, 1
    %beforeMsgPtr = getelementptr [9 x i8], ptr @beforeMsg, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %beforeMsgPtr)
    %fmtptr = getelementptr [10 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %x, i32 %y)

    ; call by val
    call void @printPointByVal(%Point %p2)

    ret i32 0
}
