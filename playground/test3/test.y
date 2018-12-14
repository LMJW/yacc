%{
package main

import (
    "fmt"
    "bufio"
    "os"
    "regexp"
    "unicode"
)

type ASTnode struct{
    left *ASTnode
    right *ASTnode
    op string
    label string
}

func createnode(left, right *ASTnode, op string) *ASTnode{
    var res = ASTnode{}
    res.left = left
    res.right = right
    res.op = op
    return &res
}

func(n *ASTnode) View(){
    fmt.Println(n.op, n.label)
    if n.left!=nil{
        n.left.View()
    }
    if n.right!=nil{
        n.right.View()
    }
}

%}

%union{
    node *ASTnode
}

%token <node> ID ATTR
%token '=' '.'
%type <node> expr object start

%%

start:
    expr
    {
        $$=$1;
        $1.View()
    }
;

expr:
    object '=' object
    {
        $$ = createnode($1,$3,"=")
    }
;

object:
    ID '.' ATTR
    {
        $$ = createnode($1,$3,".")
    }
;


%%

type TestLex struct{
    input []string
    pos int
}

func (l *TestLex) Lex(lval *TestSymType) int{
    for {
        c := l.nextToken(lval)
        return c
    }
}

func (l *TestLex) nextToken(lv *TestSymType) int{
    if l.pos >= len(l.input){
        return 0
    }
    c := l.input[l.pos]
    l.pos++
    switch{
    case isTitle(c):
        lv.node = &ASTnode{label:c}
        return ID
    case isAttr(c):
        lv.node = &ASTnode{label:c}
        return ATTR
    case c == "=":
        return int('=')
    case c == ".":
        return int('.')
    }
    return 0
}

func isTitle(s string) bool{
    if len(s) == 0{
        return false
    }
    return unicode.IsUpper(rune(s[0]))
}

func isAttr(s string) bool {
    if len(s) == 0{
        return false
    }
    return unicode.IsLower(rune(s[0]))
}

func (l *TestLex) Error(s string){
    fmt.Printf("syntax error: %s\n", s)
}

func main() {
	fi := bufio.NewReader(os.NewFile(0, "stdin"))
    re := regexp.MustCompile(`\w+|[\.=]`)
	for {
		var eqn string
		var ok bool

		fmt.Printf("> ")
		if eqn, ok = readline(fi); ok {
			TestParse(&TestLex{input: re.FindAllString(eqn, -1)})
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
