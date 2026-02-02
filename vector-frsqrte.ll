; fp vector fast reciprocal sqrt estimate

declare i32 @printf(ptr, ...)
declare <4 x float> @llvm.aarch64.neon.frsqrte.v4f32(<4 x float>)

@fmt = private constant [36 x i8] c"frsqrte = <%.2f, %.2f, %.2f, %.2f>\0A\00"

define <4 x float> @create() {
    ret <4 x float> <float 1.0, float 4.0, float 9.0, float 16.0>
}

define void @print_vector(<4 x float> %vec) {
    %e0 = extractelement <4 x float> %vec, i32 0
    %e1 = extractelement <4 x float> %vec, i32 1
    %e2 = extractelement <4 x float> %vec, i32 2
    %e3 = extractelement <4 x float> %vec, i32 3

    call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmt), float %e0, 
        float %e1, float %e2, float %e3)
    ret void
}

define i32 @main() {
    %x = call <4 x float> @create()
    %r = call <4 x float> @llvm.aarch64.neon.frsqrte.v4f32(<4 x float> %x)
    call void @print_vector(<4 x float> %r)
    ret i32 0
}
