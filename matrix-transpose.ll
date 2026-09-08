; fp vector transpose
; Needs to be lowered:
; opt -passes='lower-matrix-intrinsics' vector-transpose.ll -S -o 
;     vector-transpose-lowered.ll
;
; This example uses <4 x float> so a 2x2 matrix fits in one 128-bit NEON/SSE register.
; Wider LLVM vectors, such as <8 x float>, are legal on all targets, but may be
; split into multiple instructions on 128-bit NEON or SSE targets.
;
; AArch64 NEON: 128-bit registers (4 x float, 2 x double)
; x86 SSE:      128-bit registers
; x86 AVX:      256-bit registers (8 x float, 4 x double)
; x86 AVX-512:  512-bit registers (16 x float, 8 x double)

declare i32 @printf(ptr, ...)
declare <4 x float> @llvm.matrix.transpose.v4f32(<4 x float>, i32, i32)

@fmt = private constant [14 x i8] c"<%.2f, %.2f>\0A\00"
@fmtO = private constant [13 x i8] c"Original = \0A\00"
@fmtT = private constant [15 x i8] c"Transposed = \0A\00"

define <4 x float> @create() {
  ret <4 x float> <float 1.0, float 2.0, float 3.0, float 4.0>
}

define void @print_vector(<4 x float> %vec) {
  %e0 = extractelement <4 x float> %vec, i32 0
  %e1 = extractelement <4 x float> %vec, i32 1
  %e2 = extractelement <4 x float> %vec, i32 2
  %e3 = extractelement <4 x float> %vec, i32 3

  call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmt), float %e0, 
    float %e1)
  call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmt), float %e2, 
    float %e3)
  ret void
}

define i32 @main() {
  %x = call <4 x float> @create()

  call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmtO))
  call void @print_vector(<4 x float> %x)
  %r = call <4 x float> (<4 x float>, i32, i32) 
    @llvm.matrix.transpose.v4f32(<4 x float> %x, i32 2, i32 2)
  call i32 (ptr, ...) @printf(ptr getelementptr (ptr, ptr @fmtT))
  call void @print_vector(<4 x float> %r)
  ret i32 0
}
