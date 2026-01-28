declare i32 @printf(ptr, ...)

@fmt = private constant [18 x i8] c"max(%d, %d) = %d\0A\00"

define i32 @max(i32 %a, i32 %b) {
entry:
    %cond = icmp sgt i32 %a, %b
    br i1 %cond, label %then, label %else
then:
    ret i32 %a
else:
    ret i32 %b
}

define i32 @main() {
entry:
    %ap = alloca i32
    store i32 10, ptr %ap
    %a = load i32, ptr %ap
    %bp = alloca i32
    store i32 20, ptr %bp
    %b = load i32, ptr %bp
    %r = call i32 @max(i32 %a, i32 %b)
    %fmtptr = getelementptr [18 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %a, i32 %b, i32 %r)
    ret i32 0
}
