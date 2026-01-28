declare i32 @printf(ptr, ...)

@beforeMsg = private constant [15 x i8] c"Sent {%d, %d}\0A\00"
@afterMsg = private constant [19 x i8] c"Received {%d, %d}\0A\00"

%Point = type { i32, i32 }

define %Point @incrementPoint(%Point %p) {
entry:
    ; extract values
    %x = extractvalue %Point %p, 0
    %y = extractvalue %Point %p, 1

    ; increment
    %xIncr = add i32 %x, 1
    %yIncr = add i32 %y, 1

    ; create the return struct
    %p1 = insertvalue %Point undef, i32 %xIncr, 0
    %p2 = insertvalue %Point %p1, i32 %yIncr, 1

    ret %Point %p2
}

define i32 @main() {
entry:
    ; create the struct
    %p = insertvalue %Point undef, i32 10, 0
    %p2 = insertvalue %Point %p, i32 20, 1

    ; print before call
    %x = extractvalue %Point %p2, 0
    %y = extractvalue %Point %p2, 1
    %beforeMsgPtr = getelementptr [15 x i8], ptr @beforeMsg, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %beforeMsgPtr, i32 %x, i32 %y)

    ; call by val
    %p3 = call %Point @incrementPoint(%Point %p2)

    ; print after call
    %x3 = extractvalue %Point %p3, 0
    %y3 = extractvalue %Point %p3, 1
    %afterMsgPtr = getelementptr [15 x i8], ptr @afterMsg, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %afterMsgPtr, i32 %x3, i32 %y3)

    ret i32 0
}
