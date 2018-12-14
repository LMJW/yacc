%{
package main

import (
    "bufio"
    "fmt"
    "os"
    "unicode"
)
type Indicator interface{
    getIPs()
}

var rules = make(map[string]func (Indicator))

%}

%union{
    val int
    word string
    buf []rune
}

%token <val> LETTER DIGIT OPERATOR

%%

list : //
    | list stat '\n'
    ;

stat : logicl
    ;

logic :expr
    |'!' expr
    | expr 'x' expr
    | expr '>' expr
    ;

expr : object '=' number
    | object '=' object
    ;

object : word '.' word
    ;

word : LETTER
    | word LETTER
    | word DIGIT
    ;

number : DIGIT
    | number DIGIT
    ;

%% /* start of programs */

type RuleLex struct{
    s string
    pos int
}

func (l *RuleLex) Lex(lval *RuleSymType) int{
    var c rune = ' '
	for c == ' ' {
		if l.pos == len(l.s) {
			return 0
		}
		c = rune(l.s[l.pos])
		l.pos += 1
	}
	if unicode.IsDigit(c) {
		lval.val = int(c) - '0'
		return DIGIT
	} else if unicode.IsLetter(c) {
		lval.buf = append(lval.buf, c)
		return LETTER
	} else if c == '&' || c == '|'{
        lval.buf = append(lval.buf, c)
        return OPERATOR
    }
	return int(c)
}

func (l *RuleLex) Error(s string){
    fmt.Printf("Syntax error: %s \n", s)
}

func main() {
	fi := bufio.NewReader(os.NewFile(0, "stdin"))

	for {
		fmt.Printf("expression: ")
		if eqn, ok := readline(fi); ok {
			RuleParse(&RuleLex{s:eqn})
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
