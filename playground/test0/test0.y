%{
package main

import (
	"bufio"
	"fmt"
	"os"
	"unicode"
)


var regs = make([]int, 26)
%}

%union{
    val int
}

%type <val> expr number
%token <val> DIGIT LETTER

%left '+'

%%

list : //
    | list stat '\n' ;

stat : expr
    {
        fmt.Printf("%d\n", $1);
    }
    | LETTER '=' expr
    {
        regs[$1] =$3;
        fmt.Printf("%s = %d\n", $1, $3);
    }
    ;

expr : number
    | expr '+' expr {$$ = $1+$3}
    | LETTER {$$=regs[$1]}
    ;

number : DIGIT
    {
        $$ = $1
    }
    | number DIGIT
    {
        {$$ = 10*$1 + $2}
    }
    ;

%%

type CalcLex struct{
    s string
    pos int
}

func (l *CalcLex) Lex(lv *CalcSymType) int{
    var c = ' '
    for c == ' '{
        if l.pos == len(l.s){
            return 0
        }
        c = rune(l.s[l.pos])
        l.pos++
    }

    if unicode.IsDigit(c){
        lv.val = int(c) - '0'
        return DIGIT
    }else if unicode.IsLower(c){
        lv.val = int(c) - 'a'
        return LETTER
    }
    lv.val = int(c)
    return lv.val
}

func (l *CalcLex) Error(s string) {
    fmt.Printf("syntax error: %s\n", s)
}

func main() {
	fi := bufio.NewReader(os.NewFile(0, "stdin"))

	for {
		var eqn string
		var ok bool

		fmt.Printf("equation: ")
		if eqn, ok = readline(fi); ok {
			CalcParse(&CalcLex{s: eqn})
		} else {
			break
		}
	}
}

func readline(fi *bufio.Reader) (string, bool) {
	s, err := fi.ReadString('\n')
	if err != nil {
		return "", false
	}
	return s, true
}
