%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "y.tab.h"
	#include "symtable.h"
	
	int fline = 1;
	int alloc = 16;
	char label[50];
	
	extern int line;
	extern int pass;
	extern int yynerrs;
	
	void addentry(hashtab H[],char *s, int val);
	int hash_function(char *s);
	void view_table(hashtab H[]);
	int getaddress(hashtab H[], char *s);
	
	void yyerror(char *);
%}

%%
			
@[0-9]+ 	{
				yylval = atoi(yytext+1);
				return a_instr;
			}
			
@[A-Za-z0-9_$.]+	{
						if(pass == 1){
							yylval = getaddress(Symbol_Table, yytext+1);
							if(yylval == -1){
								yylval = alloc;
								addentry(Symbol_Table, yytext+1, alloc++);
							}
						}
						return a_instr;
					}
					
[01]		return *yytext;
		
"JGE"		return JGE;
"JGT"		return JGT;
"JEQ"		return JEQ;
"JLT"		return JLT;
"JNE"		return JNE;
"JLE"		return JLE;
"JMP"		return JMP;

"MD"		return REG_MD;
"AM"		return REG_AM;
"AD"		return REG_AD;
"AMD"		return REG_AMD;

[-+=&|!();ADM]    return *yytext;

"//"[^\n]* 	; /* skip comment */
		
[ \t]	   ;  /* skip whitespace */

\n			{
				fline++;
				return *yytext;
			}
			
"("[A-Za-z:_$.][A-Za-z0-9:_$.]*")"	if(pass == 0){
										strcpy(label,yytext+1);
										label[strlen(label)-1] = 0;
										addentry(Symbol_Table, label, line);
									}
						
.          	if(pass == 1){
				yynerrs++;
				fprintf(stderr, "invalid char \'%c\' at line %d\n", *yytext, fline);
			}

%%

int yywrap(void){
   return 1;
}

void addentry(hashtab H[], char *s, int val){
    int INDEX;
    hashtab p,t;
    INDEX = hash_function(s);
    if (H[INDEX] == NULL){
        p=(hashtab)malloc(sizeof(hashnode));
        strcpy(p->name,s);
        p->value = val;
        p->next = H[INDEX];
        H[INDEX]=p;
    }
    else{
        t=H[INDEX];
        while(1){
            if(!strcmp(t->name,s)){
                t->value = val;
                return;
            }

            if(t->next==NULL){
                p =(hashtab) malloc(sizeof(hashnode));
                strcpy(p->name,s);
                p->value = val;
                p->next = t->next;
        
        t->next = p;
            }

            t=t->next;
        }
    }
}

int hash_function(char *s){
	// Weiss' Hash function algo
    unsigned int hash_val = 0;
    while( *s != '\0' )
        hash_val = (hash_val << 5) + *s++;
    return(hash_val % HASH_SIZE);
}

int getaddress(hashtab H[], char *s){
    int i;
    hashtab p = H[hash_function(s)];
    while(p!=NULL){
        if(!strcmp(p->name,s))
            return p->value;
        else
             p=p->next;
    }
    return -1;
}