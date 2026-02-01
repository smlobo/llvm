#include <cstdio>

struct BaseX {
    int a;
    virtual void makePolymorphic() {}
};

struct BaseY {
    int a;
    virtual void makePolymorphic() {}
};

struct Derived : BaseX, BaseY {
    int a;                  // Derived::a hides BaseX::a & BaseY::a
};

int baseXdynamicDerived(BaseX* b) {
    return dynamic_cast<Derived*>(b)->a;
}

int baseYdynamicDerived(BaseY* b) {
    return dynamic_cast<Derived*>(b)->a;
}

int main() {
    Derived d = Derived {};
    d.a = 100;
    d.BaseX::a = 101;
    d.BaseY::a = 102;
    printf("baseXdynamicDerived = %d, baseYdynamicDerived = %d\n", 
        baseXdynamicDerived(&d), baseYdynamicDerived(&d));
}
