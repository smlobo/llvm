; C++ code
; struct Point {
;     int x;
;     int y;
;     int sum() const {
;         return x + y;
;     }
; };

; int main() {
;     Point p = Point {11, 22};
;     printf("{%d, %d}.sum = %d\n", p.x, p.y, p.sum());
; }

declare i32 @printf(ptr, ...)

@fmt = private constant [19 x i8] c"{%d, %d}.sum = %d\0A\00"

%Point = type { i32, i32 }

define i32 @sum(ptr %this) {
entry:
    ; get pointers to fields
    %xPtr = getelementptr %Point, ptr %this, i32 0, i32 0
    %yPtr = getelementptr %Point, ptr %this, i32 0, i32 1

    ; load values
    %x = load i32, ptr %xPtr
    %y = load i32, ptr %yPtr

    ; add
    %r = add i32 %x, %y
    ret i32 %r
}

define i32 @main() {
entry:
    ; allocate struct on stack
    %p = alloca %Point

    ; get pointers to fields
    %xPtr = getelementptr %Point, ptr %p, i32 0, i32 0
    %yPtr = getelementptr %Point, ptr %p, i32 0, i32 1

    ; store values
    store i32 11, ptr %xPtr
    store i32 22, ptr %yPtr

    ; load values
    %x = load i32, ptr %xPtr
    %y = load i32, ptr %yPtr

    ; call p.sum()
    %r = call i32 @sum(ptr %p)

    ; print values
    %fmtptr = getelementptr [19 x i8], ptr @fmt, i32 0, i32 0
    call i32 (ptr, ...) @printf(ptr %fmtptr, i32 %x, i32 %y, i32 %r)

    ret i32 0
}
