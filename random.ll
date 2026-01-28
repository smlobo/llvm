declare i32 @printf(ptr, ...)
declare void @srand(i32)
declare i32 @time(ptr)
declare i32 @rand()

@fmt = private constant [13 x i8] c"random = %d\0A\00"

define i32 @main() {
entry:
    %t = call i32 @time(ptr null)
    call void @srand(i32 %t)
    %random = call i32 @rand()
    %fmtptr = getelementptr [13 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %random)
    ret i32 0
}
