; vector fuzed multiply add of fp vectors

declare i32 @printf(ptr, ...)

@fmt = private constant [32 x i8] c"sum = <%.2f, %.2f, %.2f, %.2f>\0A\00"

define <4 x float> @create() {
    ret <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0>
}

define void @print_vector(<4 x float> %vec) {
    %e0 = extractelement <4 x float> %vec, i32 0
    %e1 = extractelement <4 x float> %vec, i32 1
    %e2 = extractelement <4 x float> %vec, i32 2
    %e3 = extractelement <4 x float> %vec, i32 3

    %fmtptr = getelementptr [24 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, float %e0, float %e1, float %e2, 
        float %e3)
    ret void
}

define i32 @main() {
    %x = call <4 x float> @create()
    %r = call <4 x float> @llvm.fma.v4f32(<4 x float> %x, <4 x float> %x, <4 x float> %x)
    call void @print_vector(<4 x float> %r)
    ret i32 0
}
