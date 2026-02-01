#include <cstdio>

struct BaseX {
    int x;
    virtual void makePolymorphic() {}
};

struct BaseY {
    int x;
    virtual void makePolymorphic() {}
};

struct Derived : BaseX, BaseY {
    int x;                  // Derived::x hides Base::x & Base::y
    void makePolymorphic() override {}
};

int baseX(BaseX* b) {
    return b->x;
}

int baseXdynamicDerived(BaseX* b) {
    if (Derived *d = dynamic_cast<Derived*>(b)) {
        return d->x;
    }
    return b->x;
}

int baseXstaticDerived(BaseX* b) {
    return static_cast<Derived*>(b)->x;
}

int baseY(BaseY* b) {
    return b->x;
}

int baseYdynamicDerived(BaseY* b) {
    if (Derived *d = dynamic_cast<Derived*>(b)) {
        return d->x;
    }
    return b->x;
}

int baseYstaticDerived(BaseY* b) {
    return static_cast<Derived*>(b)->x;
}

int main() {
    BaseX b = BaseX {};
    b.x = 10;
    printf("baseX = %d, baseXdynamicDerived = %d\n", baseX(&b), baseXdynamicDerived(&b));
    Derived d = Derived {};
    d.x = 100;
    d.BaseX::x = 101;
    d.BaseY::x = 102;
    printf("baseX = %d, baseXdynamicDerived = %d, baseXstaticDerived = %d, "
        "baseY = %d, baseYdynamicDerived = %d, baseYstaticDerived = %d\n", 
        baseX(&d), baseXdynamicDerived(&d), baseXstaticDerived(&d), 
        baseY(&d), baseYdynamicDerived(&d), baseYstaticDerived(&d));
}
