; fp vector fuzed multiply add

declare i32 @printf(ptr, ...)

@fmt = private constant [32 x i8] c"fma = <%.2f, %.2f, %.2f, %.2f>\0A\00"

define <4 x float> @create() {
    ret <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0>
}

define void @print_vector(<4 x float> %vec) {
    %e0 = extractelement <4 x float> %vec, i32 0
    %e1 = extractelement <4 x float> %vec, i32 1
    %e2 = extractelement <4 x float> %vec, i32 2
    %e3 = extractelement <4 x float> %vec, i32 3
    %d0 = fpext float %e0 to double
    %d1 = fpext float %e1 to double
    %d2 = fpext float %e2 to double
    %d3 = fpext float %e3 to double

    call i32 (ptr, ...) @printf(ptr @fmt, double %d0, double %d1, double %d2,
        double %d3)
    ret void
}

define i32 @main() {
    %x = call <4 x float> @create()
    %r = call <4 x float> @llvm.fma.v4f32(<4 x float> %x, <4 x float> %x, 
        <4 x float> %x)
    call void @print_vector(<4 x float> %r)
    ret i32 0
}
