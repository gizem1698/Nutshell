%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.

    // for definitions
#include <string.h>
#include "global.h"
#include "nutparser.tab.h"

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}

%}

%array
%option noyywrap
%x string_condition

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);}

    
[ ]                 { }
bye                 { return BYE; }
cd		            { return CD;}
alias               { return ALIAS; }
setenv              { return SETENV; }
unsetenv            { return UNSETENV; }
ls                  { return LS; }
pwd                 { return PWD; }
mkdir               { return MKDIR;}
rmdir               { return RMDIR;}
cat                 { return CAT; }
echo                { return ECH; }
printenv            { return PRINTENV; }
printvar            { return PRINTVAR;}
"\n"		        { return END; }
[\"]                { BEGIN(string_condition); }
{CHAR}+             {
                        if (isFirstWord && ifAlias(yytext)) {
                            printf("1-yytext: %s\n", yytext);
                            char *yycopy = strdup( subAliases(yytext) );
                            for (int i = strlen(subAliases(yytext)) - 1; i >= 0; --i)
                                     unput(yycopy[i]);
                        
                            free(yycopy);
                        } else {
                            printf("2-yytext: %s\n", yytext);
                            yylval.string = strdup(yytext);
                            return STRING;
                        };                    
                    }


%%

    // C functions code that you use in the action
