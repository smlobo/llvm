declare i32 @printf(ptr, ...)

@fmt = private constant [15 x i8] c"result = %.2f\0A\00"

define float @add(float %a, float %b) {
entry:
    %sum = fadd float %a, %b
    ret float %sum
}

define i32 @main() {
entry:
    ; Note: float must not be double like 1.1
    ; store 1 float on stack
    %f1p = alloca float
    store float 2.25, ptr %f1p
    %f1 = load float, ptr %f1p

    ; add stack float + constant float
    %res = call float @add(float %f1, float 1.125)

    ; print
    %fmtptr = getelementptr [15 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, float %res)

    ret i32 0
}
