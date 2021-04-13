%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <string.h>
#include <sys/stat.h>

int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
int runListAliases();
int runSetAlias(char *name, char *word);
int runSetEnv(char *var, char *word);
int runPrintEnv(void);
int runEnvVarExpansion(char *s);
int runUnsetEnv(char *var);
int printVarTable();
int runUnAlias(char *name);
int cdHome(char *s);
int listfiles(char *param);
int print_dir();
int echo_cmd(char *param);
int cat_cmd(char *param);
int mk_dir(char *file);
int rm_dir(char *file);
int runCatchAll();


%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS SETENV UNALIAS UNSETENV EXP PRINTENV PRINTVAR END
%token <string> LS PWD ECH CAT DIR RMDIR MKDIR SORT MV

%%

cmd_line    :
	BYE END		                	{exit(1); return 1; }
    | CD STRING END               	{runCD($2); return 1;}
	| CD END						{runCD("EMPTY"); return 1;}
	| ALIAS END						{runListAliases(); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2,$3); return 1;}	
	| LS STRING END 				{listfiles($2); return 1;}
	| MKDIR STRING END				{listfiles($2); return 1; }
	| RMDIR STRING END				{listfiles($2); return 1;}
	| LS END 						{listfiles("EMPTY"); return 1;}
	| PWD END						{print_dir(); return 1;}
	| CAT STRING END				{cat_cmd($2); return 1;}
	| ECH STRING END				{echo_cmd($2); return 1;}	
	| SETENV STRING STRING END		{runSetEnv($2,$3); return 1;}
	| UNALIAS STRING END			{runUnAlias($2); return 1; }
	| UNSETENV STRING END 			{runUnsetEnv($2); return 1;}
	| EXP STRING END                {runEnvVarExpansion($2); return 1;}
	| PRINTENV END					{runPrintEnv(); return 1;}
	| STRING END					{ runCatchAll(); return 1;}
	| PRINTVAR END 					{printVarTable(); return 1;}

    
%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
 }

int runCatchAll() {
	printf("Command not found\n");

	return 1;
}

int listfiles(char *param) { 
	//getcwd(cwd, sizeof(cwd));
	pid_t pid;
	pid = fork();
	wait(NULL);
	if (pid == 0) { // child
	if (param == "EMPTY") { 
		execl("/bin/ls", "ls", NULL);
		return 1;
	}
	if (param[0] == '-') { 
		execl("/bin/ls","ls", param,NULL);
		return 1;
	}
	
	// must add for: ls testdir
	// also ls f?.txt *.c
}
	return 1;
}

int cat_cmd(char *param) { 
	pid_t pid;
	pid = fork();
	wait(NULL);
	// if txt file isnt there return error msg
	if(pid == 0) {
		execl("/bin/cat", "cat",param, NULL);
		return 1;
	}
	return 1;
}
int echo_cmd(char*param) { 
	pid_t pid;
	pid = fork();
	wait(NULL);
	if(pid == 0) {
		execl("/bin/echo", "echo",param, NULL);
		return 1;
	}
	return 1;
}
/*
int mk_dir(char *file) { 
	pid_t pid;
	pid = fork();
	wait(NULL);
	strcat(, file);
	if (pid == 0) { 
		if(mkdir(file) == 0) {
			printf("created a directory");
			return 1;
		}
		else { 
			printf("%s is already a directory",file);
			return 1;
		}
	}
	return 1;
}

int rm_dir(char *file) { 
	pid_t pid;
	pid = fork();
	wait(NULL);
	if (pid == 0) { 
		if(rmdir(file) == 0) {
			return 1;
		}
		else { 
			printf("%s is not a directory",file);
			return 1;
		}
	}
	return 1;
}
*/

int print_dir() { 	
	printf("%s\n", varTable.word[0]);
	return 1;
}

int runCD(char* arg) {
	if (arg == "EMPTY")
	{
		strcpy(varTable.word[0], varTable.word[1]);
		return 1;
	}
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");		
		strcat(varTable.word[0], arg);

		if (chdir(varTable.word[0]) == 0) {
			return 1;
		}		
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	
	else{ // arg is absolute path goes to the root
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
	return 1;
}

int runListAliases()
{
	for (int i=0; i < aliasIndex; i++)
	{
		printf("%s\n",aliasTable.name[i], aliasTable.word[i]);
    }

	return 1;
}
int printVarTable() 
{
	for (int i = 0; i < varIndex; i++)
	{
		printf("Var Array: %s \n", varTable.var[i]);
	}
	for (int i = 0; i < varIndex; i++)
	{
		printf("Name Array: %s \n", varTable.word[i]);
	}
	return 1;
}

int runSetAlias(char *name, char *word) {
	if (strcmp(name, word) == 0) {
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
		return 1;
	}

	for (int i = 0; i < aliasIndex; i++) {
		if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0) ||
		(strcmp(aliasTable.word[i], name) == 0) && (strcmp(aliasTable.name[i], word) == 0)) {
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int runUnAlias(char *name) {
	for (int i = 0; i < aliasIndex; i++) {
		if (strcmp(aliasTable.name[i], name) == 0) {
			while (i+1 < aliasIndex) {
				strcpy(aliasTable.name[i], aliasTable.name[i+1]);
				strcpy(aliasTable.word[i], aliasTable.word[i+1]);
				i++;
			}			
			aliasIndex--;
			return 1;		
		}
	}
	
	// ignore the command
	return 1;

}

int runSetEnv(char *var, char *word) {

	strcpy(varTable.var[varIndex], var);
	strcpy(varTable.word[varIndex], word);
	varIndex++;

	return 1;
}

int runPrintEnv(void)
{
	for (int i =0; i < varIndex; i++)
	{
			printf("%s=%s\n", varTable.var[i], varTable.word[i]);
	}
	return 1;
}

int runUnsetEnv(char *var) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(varTable.var[i], var) == 0) {
			while (i+1 < varIndex) {
				strcpy(varTable.var[i], varTable.var[i+1]);
				strcpy(varTable.word[i], varTable.word[i+1]);
				i++;
			}			
			varIndex--;
			return 1;		
		}
	}
	
	// ignore the command
	return 1;
}

int runEnvVarExpansion(char *s) {
	for (int i = 0; i < varIndex; i++) {
		if (strcmp(s, varTable.var[i]) == 0) {
			printf("Expansion of \"%s\" is \"%s\".\n", varTable.var[i], varTable.word[i]);
			return 1;
		}
	}

	printf("%s: No such environment variable.\n", s);
	return 1;
}
