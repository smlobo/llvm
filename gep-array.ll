declare i32 @printf(ptr, ...)

@fmt = private constant [13 x i8] c"result = %d\0A\00"

@i32Array = constant [4 x i32] [i32 10, i32 20, i32 30, i32 40]

define i32 @main() {
entry:
  %i32ArrayIndex2Ptr = getelementptr [4 x i32], ptr @i32Array, i32 0, i32 2
  %i32ArrayIndex2Val = load i32, ptr %i32ArrayIndex2Ptr
  %fmtptr = getelementptr [13 x i8], ptr @fmt, i32 0, i32 0
  call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %i32ArrayIndex2Val)
  ret i32 0
}

