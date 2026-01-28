declare i32 @printf(ptr, ...)
declare void @srand(i32)
declare i32 @time(ptr)
declare i32 @rand()

@fmt = private constant [18 x i8] c"result = %d / %d\0A\00"

define i32 @increment(i32 %x) {
entry:
    %r = add i32 %x, 1
    ret i32 %r
}

define i32 @decrement(i32 %x) {
entry:
    %r = sub i32 %x, 1
    ret i32 %r
}

define i32 @main() {
entry:
    ; generate a random number based on time
    %t = call i32 @time(ptr null)
    call void @srand(i32 %t)
    %random = call i32 @rand()

    ; if even increment, else decrement
    %odd = urem i32 %random, 2
    %cond = icmp ne i32 %odd, 0
    br i1 %cond, label %then, label %else
then:
    %incPtr = bitcast ptr @decrement to ptr
    br label %fi
else:
    %decPtr = bitcast ptr @increment to ptr
    br label %fi
fi:
    %fPtr = phi ptr [%incPtr, %then], [%decPtr, %else]
    %r = call i32 %fPtr(i32 0)

    ; print result
    %fmtptr = getelementptr [18 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %random, i32 %r)
    ret i32 0
}
