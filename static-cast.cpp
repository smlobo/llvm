#include <cstdio>

struct BaseX {
    int a;
};

struct BaseY {
    int a;
};

struct Derived : BaseX, BaseY {
    int a;                  // Derived::a hides BaseX::a & BaseY::a
};

int baseXstaticDerived(BaseX* b) {
    return static_cast<Derived*>(b)->a;
}

int baseYstaticDerived(BaseY* b) {
    return static_cast<Derived*>(b)->a;
}

int main() {
    Derived d = Derived {};
    d.a = 100;
    d.BaseX::a = 101;
    d.BaseY::a = 102;
    printf("baseXstaticDerived = %d, baseYstaticDerived = %d\n", 
        baseXstaticDerived(&d), baseYstaticDerived(&d));
}
