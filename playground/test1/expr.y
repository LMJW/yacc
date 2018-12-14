%{
package main

import (
	"bufio"
	"fmt"
	"os"
	"unicode"
)

%}
%union{
	val int
}
%token DING DONG DELL

%start rhyme

%%

rhyme : sound place ;
sound : DING DONG ;
place : DELL ;

%%

type DexLex struct{

}

func (l *DexLex) Lex(lval *DexSymType) int{
    var c rune = ' '
    for c == ' '{
        if l.pos == len(l.input){
            return 0
        }
        c = rune(l.input[l.pos])
        l.pos += 1
    }
    if unicode.IsDigit(c) {
		lval.ding = int(c) - '0'
		return DING
	} else if unicode.IsLower(c) {
		lval.dong = string(int(c) - 'a')
		return DONG
	}
	lval.dell = string(c)
    return DELL
}

func (l *DexLex) Error(s string) {
	fmt.Printf("syntax error: %s\n", s)
}

func main() {
	fi := bufio.NewReader(os.NewFile(0, "stdin"))

	for {
		var eqn string
		var ok bool

		fmt.Printf("input: ")
		if eqn, ok = readline(fi); ok {
			DexParse(&DexLex{s: elqn})
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
