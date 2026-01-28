declare i32 @printf(ptr, ...)

@fmt = private constant [13 x i8] c"result = %d\0A\00"

define i32 @main() {
entry:
  %res = add i32 40, 2
  %fmtptr = getelementptr [13 x i8], ptr @fmt, i32 0, i32 0
  call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %res)
  ret i32 0
}
