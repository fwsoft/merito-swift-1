# Swift Programming Fundamentals

Course materials. The PDFs are in Polish.

## Lectures

| | topic |
|---|---|
| [Lecture 1](wyklady/wyklad1.pdf) | introduction, tooling, variables and data types |
| [Lecture 2](wyklady/wyklad2.pdf) | conditionals: `if`, `guard`, `switch`, enumerations |

## Example project

The [`example/`](example) directory is the untouched output of `swift package init --type executable` (Swift 6.3) run in a folder named `example`, plus optional editor and environment config: `.editorconfig`, `.swift-format` (`swift format lint -r Sources Tests`) and a Nix flake with direnv (`flake.nix`, `.envrc`). Compare your project against it: file and directory names follow the folder name (e.g. `lab2` gives `Sources/lab2/lab2.swift` and `Tests/lab2Tests/lab2Tests.swift`).

```
example/
├── .editorconfig
├── .envrc
├── .gitignore
├── .swift-format
├── flake.nix
├── flake.lock
├── Package.swift
├── Sources/example/example.swift
└── Tests/exampleTests/exampleTests.swift
```

A correctly generated project gives:

```
$ swift run
...
Build of product 'example' complete!
Hello, world!

$ swift test
...
✔ Test example() passed after 0.001 seconds.
✔ Test run with 1 test in 0 suites passed after 0.001 seconds.
```
