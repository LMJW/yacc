1. begin with "parser.y" file
2. compile this file with `goyacc -l -o parser.go parser.y`
3. run `go test -v .`

The `lex.go`, `parser.y` and `parser_test.go` is written. The `parser.go` is compiled file.