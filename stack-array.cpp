#include <cstdio>

struct Point {
    unsigned x;
    unsigned y;
};

int main() {
    Point points[3];
    points[0] = {1, 2};
    points[1] = {10, 20};
    points[2] = {100, 200};

    for (int i = 0; i < 3; i++) {
        printf("[%d] %d, %d\n", i, points[i].x, points[i].y);
    }

    return 0;
}