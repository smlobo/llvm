; vector integer add

declare i32 @printf(ptr, ...)

@fmt = private constant [24 x i8] c"sum = <%d, %d, %d, %d>\0A\00"

; Integer addition
define <4 x i32> @add_i32(<4 x i32> %a, <4 x i32> %b) {
    %result = add <4 x i32> %a, %b
    ret <4 x i32> %result
}

define <4 x i32> @create() {
    ret <4 x i32> <i32 1, i32 2, i32 3, i32 4>
}

define void @print_vector(<4 x i32> %vec) {
    %e0 = extractelement <4 x i32> %vec, i32 0
    %e1 = extractelement <4 x i32> %vec, i32 1
    %e2 = extractelement <4 x i32> %vec, i32 2
    %e3 = extractelement <4 x i32> %vec, i32 3

    call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmt), i32 %e0, 
        i32 %e1, i32 %e2, i32 %e3)
    ret void
}

define i32 @main() {
    %a = call <4 x i32> @create()
    %b = call <4 x i32> @create()
    %r = call <4 x i32> @add_i32(<4 x i32> %a, <4 x i32> %b)
    call void @print_vector(<4 x i32> %r)
    ret i32 0
}
