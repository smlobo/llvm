; fp vector dot product

declare i32 @printf(ptr, ...)

@fmt = private constant [20 x i8] c"dot product = %.2f\0A\00"

define <4 x float> @create() {
    ret <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0>
}

define i32 @main() {
    %x = call <4 x float> @create()
    %mul = fmul <4 x float> %x, %x
    %r = call float @llvm.vector.reduce.fadd.v4f32(float 0.0, <4 x float> %mul)
    call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmt), float %r) 
    ret i32 0
}
