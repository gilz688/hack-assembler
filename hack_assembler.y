%{
    #include <stdio.h>
	#include "symtable.h"
	
	int yylex(void);
	int line = 0;
	int pass = 0;
	
	char fDest[4];
	char fJump[4];
	char fComp[8];
	char binadr[16];
	
    void yyerror(char *);
	void new_table(hashtab[]);
	void strbin(char *str, int decNum);
	extern int fline;
	extern FILE *yyin;
	extern FILE *yyout;
%}

%start program

%token a_instr
%token REG_MD REG_AM REG_AD REG_AMD JGT JEQ JGE JLT JNE JLE JMP

%%

program:
        program statement '\n'
        | 
        ;

statement:	
		c_instr { line++; if( pass == 1 ) { fprintf(yyout,"111%s%s%s\n", fComp, fDest, fJump); } }
		| a_instr { line++; if( pass == 1 ) { strbin(binadr,$1); fprintf(yyout, "0%s\n", binadr); } } 
		|
		;

c_instr:
		dest '=' comp 			{ strcpy(fJump,"000"); }
		|dest '=' comp ';' jump
		| comp					{ strcpy(fDest,"000"); strcpy(fJump,fDest); }
		| comp ';' jump			{ strcpy(fDest,"000"); }
		;

comp:
		'0'						{ strcpy(fComp,"0101010"); }
		|'1'					{ strcpy(fComp,"0111111"); }
		|'-' '1'		 		{ strcpy(fComp,"0111010"); }
		|'D'					{ strcpy(fComp,"0001100"); }
		|'A'					{ strcpy(fComp,"0110000"); }
		|'!' 'D'				{ strcpy(fComp,"0001101"); }
		|'!' 'A'				{ strcpy(fComp,"0110001"); }
		|'-' 'D'				{ strcpy(fComp,"0001111"); }
		|'-' 'A'				{ strcpy(fComp,"0110011"); }
		|'D' '+' '1'			{ strcpy(fComp,"0011111"); }
		|'A' '+' '1'			{ strcpy(fComp,"0110111"); }
		|'D' '-' '1'			{ strcpy(fComp,"0001110"); }
		|'A' '-' '1'			{ strcpy(fComp,"0110010"); }
		|'D' '+' 'A'			{ strcpy(fComp,"0000010"); }
		|'D' '-' 'A'			{ strcpy(fComp,"0010011"); }
		|'A' '-' 'D'			{ strcpy(fComp,"0000111"); }
		|'D' '&' 'A'			{ strcpy(fComp,"0000000"); }
		|'D' '|' 'A'			{ strcpy(fComp,"0010101"); }	
		|'M'					{ strcpy(fComp,"1110000"); }
		|'!' 'M'				{ strcpy(fComp,"1110001"); }
		|'-' 'M'				{ strcpy(fComp,"1110011"); }
		|'M' '+' '1'			{ strcpy(fComp,"1110111"); }
		|'M' '-' '1'			{ strcpy(fComp,"1110010"); }
		|'D' '+' 'M'			{ strcpy(fComp,"1000010"); }
		|'D' '-' 'M'			{ strcpy(fComp,"1010011"); }
		|'M' '-' 'D'			{ strcpy(fComp,"1000111"); }
		|'D' '&' 'M'			{ strcpy(fComp,"1000000"); }
		|'D' '|' 'M'			{ strcpy(fComp,"1010101"); }
		;

dest:
		'M'						{ strcpy(fDest,"001"); }
		|'D'					{ strcpy(fDest,"010"); }
		|REG_MD					{ strcpy(fDest,"011"); }
		|'A'					{ strcpy(fDest,"100"); }
		|REG_AM					{ strcpy(fDest,"101"); }
		|REG_AD					{ strcpy(fDest,"110"); }
		|REG_AMD				{ strcpy(fDest,"111"); }
		;

jump:
		JGT						{ strcpy(fJump,"001"); }
		|JEQ					{ strcpy(fJump,"010"); }
		|JGE					{ strcpy(fJump,"011"); }
		|JLT					{ strcpy(fJump,"100"); }
		|JNE					{ strcpy(fJump,"101"); }
		|JLE					{ strcpy(fJump,"110"); }
		|JMP					{ strcpy(fJump,"111"); }
		;
		
%%

void yyerror(char *s) {
    fprintf(stderr, "%s at line %d\n", s, fline);
}

int main(int argc, char* argv[]) {
	if(argc == 3){
		FILE *src = fopen(argv[1], "r");
		if(!src){
			printf("Cannot open file %s", argv[1]);
			return -1;
		}
		FILE *bin = fopen(argv[2], "w");
		if(!bin){
			printf("Cannot create file %s", argv[1]);
			fclose(src);
			return -1;
		}
		yyin = src;
		yyout = bin;
	}
	else{
		puts("Syntax: hack_assembler [input.asm] [output.hack]");
		return 1;
	}
	
	new_table(Symbol_Table);
	addentry(Symbol_Table,"SP",0);
	addentry(Symbol_Table,"LCL",1);
	addentry(Symbol_Table,"ARG",2);
	addentry(Symbol_Table,"THIS",3);
	addentry(Symbol_Table,"THAT",4);
	addentry(Symbol_Table,"SCREEN",16384);
	addentry(Symbol_Table,"R0",0);
	addentry(Symbol_Table,"R1",1);
	addentry(Symbol_Table,"R2",2);
	addentry(Symbol_Table,"R3",3);
	addentry(Symbol_Table,"R4",4);
	addentry(Symbol_Table,"R5",5);
	addentry(Symbol_Table,"R6",6);
	addentry(Symbol_Table,"R7",7);
	addentry(Symbol_Table,"R8",8);
	addentry(Symbol_Table,"R9",9);
	addentry(Symbol_Table,"R10",10);
	addentry(Symbol_Table,"R11",11);
	addentry(Symbol_Table,"R12",12);
	addentry(Symbol_Table,"R13",13);
	addentry(Symbol_Table,"R14",14);
	addentry(Symbol_Table,"R15",15);
	
	yyparse();
	pass = 1;
	if(!yynerrs){
		line = fline = 0;
		rewind(yyin);
		yyparse();
	}
	
	fclose(yyout);
	fclose(yyin);
	
    return 0;
}

void strbin(char *str, int decNum){
	int i;
	char binStr[16];
	for(i=0;i<15;i++){
		if(decNum & 16384)
			binStr[i] = '1';
		else
			binStr[i] = '0';
		decNum = decNum << 1;
	}
	binStr[15] = 0;
	strcpy(str,binStr);
}

void new_table(hashtab H[]){
    int i;
    for(i=0; i<HASH_SIZE; i++)
        H[i] = NULL;
}