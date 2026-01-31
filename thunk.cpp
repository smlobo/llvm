#include <cstdio>

struct BaseX {
    virtual char value() const {
        return 'X';
    }
};

struct BaseY {
    virtual char value() const {
        return 'Y';
    }
};

struct BaseZ {
    virtual int nonOverloadedValue() const {
        return 1000;
    }
    virtual char value() const {
        return 'Z';
    }
};

struct Derived : BaseX, BaseY, BaseZ {
    char value() const override {
        return 'D';
    }
};

int main() {
    Derived d;
    BaseX* bXPtr = &d;
    printf("bXPtr of d: %c\n", bXPtr->value());
    BaseY* bYPtr = &d;
    printf("bYPtr of d: %c\n", bYPtr->value());
    BaseZ* bZPtr = &d;
    printf("bZPtr of d: %c\n", bZPtr->value());
    printf("bZPtr of d nonOverloadedValue: %d\n", bZPtr->nonOverloadedValue());
}
