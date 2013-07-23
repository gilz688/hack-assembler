#define HASH_SIZE 500
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct p
{
    char name[50];
    int value;
    struct p *next;
} hashnode;

typedef hashnode *hashtab;

hashtab Symbol_Table[HASH_SIZE];