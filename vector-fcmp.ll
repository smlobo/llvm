; fp vector compare

declare i32 @printf(ptr, ...)

@fmt = private constant [25 x i8] c"fcmp = <%d, %d, %d, %d>\0A\00"

define <4 x float> @create() {
    ret <4 x float> <float 0.0, float 1.0, float 2.0, float 3.0>
}

define <4 x float> @create_zeros() {
  ret <4 x float> zeroinitializer
}

define void @print_vector(<4 x i1> %vec) {
    %e0 = extractelement <4 x i1> %vec, i32 0
    %e1 = extractelement <4 x i1> %vec, i32 1
    %e2 = extractelement <4 x i1> %vec, i32 2
    %e3 = extractelement <4 x i1> %vec, i32 3

    %int0 = zext i1 %e0 to i32
    %int1 = zext i1 %e1 to i32
    %int2 = zext i1 %e2 to i32
    %int3 = zext i1 %e3 to i32

    call i32 (ptr, ...) @printf(ptr @fmt, i32 %int0, i32 %int1, i32 %int2, 
        i32 %int3)
    ret void
}

define i32 @main() {
    %x = call <4 x float> @create()
    %z = call <4 x float> @create_zeros()
    %r = fcmp oeq <4 x float> %x, %z
    call void @print_vector(<4 x i1> %r)

    ret i32 0
}
