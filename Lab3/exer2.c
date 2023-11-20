#include <stdio.h>

int f(int n, int m);

int main(int argc, char *argv[]) {
    int res = f(3, 5);

    printf("%d\n", res);
}

int f(int n, int m) {
    if(m == 0)
        return n;

    if(n == 0)
        return m;

    return f(n - 1, m) + f(n, m - 1);
}
