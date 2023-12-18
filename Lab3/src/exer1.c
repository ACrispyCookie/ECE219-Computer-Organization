#include <stdio.h>
#include <string.h>

int is_symmetric_str(char *s, int length);

int main(int argc, char *argv[]) {

    char str[1000];
    printf("Please, give a string of characters: ");
    scanf("%s", str);
    
    int result = is_symmetric_str(str, strlen(str));
    if (result) {
        printf("String \"%s\" is symmetric.\n", str);
    } else {
        printf("String \"%s\" is not symmetric.\n", str);
    }

    return 0;
}

int is_symmetric_str(char *s, int length) {
    if(length <= 0)
        return 1;
    
    char first = s[0];
    char last = s[length - 1];

    if(first == last) {
        return is_symmetric_str(s + 1, length - 2);
    } else {
        return 0;
    }
}

