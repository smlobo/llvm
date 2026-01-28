declare i32 @printf(ptr, ...)

@fmt = private constant [10 x i8] c"{%d, %d}\0A\00"
@fmtLoop = private constant [6 x i8] c"[%d] \00"

%Point = type { i32, i32 }

@PointArray = constant [4 x %Point] [
    %Point {i32 1, i32 2},
    %Point {i32 10, i32 20},
    %Point {i32 100, i32 200},
    %Point {i32 1000, i32 2000}
]

define void @printPoint(ptr %pointPtr) {
entry:
    %point0Ptr = getelementptr %Point, ptr %pointPtr, i32 0, i32 0
    %point1Ptr = getelementptr %Point, ptr %pointPtr, i32 0, i32 1

    ; load values
    %point0Val = load i32, ptr %point0Ptr
    %point1Val = load i32, ptr %point1Ptr

    ; print values
    %fmtPtr = getelementptr [10 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtPtr, i32 %point0Val, i32 %point1Val)

    ret void
}

define i32 @main() {
entry:
    br label %loopBegin

loopBegin:
    %index = phi i8 [0, %entry], [%nextIndex, %loopBody]
    %done = icmp sgt i8 %index, 3
    br i1 %done, label %loopEnd, label %loopBody

loopBody:
    ; print index
    %fmtLoopPtr = getelementptr [6 x i8], ptr @fmtLoop, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtLoopPtr, i8 %index)

    ; print Point
    %pointArrayPtr = getelementptr [4 x %Point], ptr @PointArray, i32 0, 
        i8 %index
    call void @printPoint(ptr %pointArrayPtr)

    ; increment index
    %nextIndex = add i8 %index, 1
    br label %loopBegin

loopEnd:
    ret i32 0
}
