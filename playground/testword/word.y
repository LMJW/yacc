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
    word string
    ch byte
}

%token <ch> DING  DONG  DELL
%type <word> begin rhyme sound place

%%
begin   : rhyme
{
    fmt.Printf("--%s--",$1);
};

rhyme   : sound place
{
    $$ = cov($1, $2)
};

sound   : DING  DONG
{
    $$ = cat($1, $2)
};

place   : DELL
{
    $$ = cat($1)
};

%%

type Result struct{
    s1 string
    p2 string
}

type WordLex struct{
    s string
    pos int
    result Result
    err error
}

func cov(sss ...string) string{
    var res string
    for _, n := range sss{
        res += n
    }
    return res
}

func cat(bytes ...byte) string {
	var out string
	for _, b := range bytes {
		out += string(b)
	}
	return out
}

func (l *WordLex) Lex(lval *WordSymType)int{
    var c rune = ' '
    for c == ' ' {
		if l.pos == len(l.s) {
			return 0
		}
		c = rune(l.s[l.pos])
		l.pos += 1
	}
    // fmt.Printf("%v-%v\n%v\n",lval.ch, lval.word,lval)
	if unicode.IsDigit(c) {
        fmt.Println("Ding")
        lval.word += string(c)
		return DING
	} else if unicode.IsLower(c) {
        lval.word += string(c)
        fmt.Println("Dong")
		return DONG
	}else if unicode.IsUpper(c){
        fmt.Println("Dell")
        lval.word += string(c)
		return DELL
    }
	return 0
}

func (l *WordLex) Error(s string) {
    fmt.Printf("syntax error: %s\n", s)
}

func main() {
	fi := bufio.NewReader(os.NewFile(0, "stdin"))

	for {
		var eqn string
		var ok bool

		fmt.Printf("input: ")
		if eqn, ok = readline(fi); ok {
			WordParse(&WordLex{s: eqn})
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