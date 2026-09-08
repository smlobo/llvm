; Two 2x2 i32 matrices stored as column-major flat vectors:
; A = [ [1, 2],       flat: [1, 3, 2, 4]
;       [3, 4] ]
;
; B = [ [5, 6],       flat: [5, 7, 6, 8]
;       [7, 8] ]
;
; C = A * B = [ [19, 22],   flat: [19, 43, 22, 50]
;               [43, 50] ]
; Needs to be lowered:
; opt -passes='lower-matrix-intrinsics' vector-transpose.ll -S -o 
;     vector-transpose-lowered.ll

@fmt = private constant [13 x i8] c"%d %d\0A%d %d\0A\00"

declare i32 @printf(ptr, ...)
declare <4 x i32> @llvm.matrix.multiply.v4i32.v4i32.v4i32(
  <4 x i32>, <4 x i32>, i32 immarg, i32 immarg, i32 immarg
)

define i32 @main() {
entry:
  ; Allocate and initialize matrices in memory.
  %a.mem = alloca <4 x i32>, align 16
  %b.mem = alloca <4 x i32>, align 16

  store <4 x i32> <i32 1, i32 3, i32 2, i32 4>, ptr %a.mem, align 16
  store <4 x i32> <i32 5, i32 7, i32 6, i32 8>, ptr %b.mem, align 16

  ; Load the flat matrix vectors from memory.
  %a = load <4 x i32>, ptr %a.mem, align 16
  %b = load <4 x i32>, ptr %b.mem, align 16

  ; C = A * B: rows(A)=2, columns(A)=rows(B)=2, columns(B)=2.
  %c = call <4 x i32> @llvm.matrix.multiply.v4i32.v4i32.v4i32(
    <4 x i32> %a, <4 x i32> %b,
    i32 2, i32 2, i32 2
  )

  ; Display the column-major result in row-major order.
  %c00 = extractelement <4 x i32> %c, i32 0 ; 19
  %c01 = extractelement <4 x i32> %c, i32 2 ; 22
  %c10 = extractelement <4 x i32> %c, i32 1 ; 43
  %c11 = extractelement <4 x i32> %c, i32 3 ; 50

  %format = getelementptr inbounds [13 x i8], ptr @fmt, i64 0, i64 0
  call i32 (ptr, ...) @printf(ptr %format, i32 %c00, i32 %c01, i32 %c10, i32 %c11)

  ret i32 0
}
