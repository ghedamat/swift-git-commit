# git-ticket-commit
another simple Swift experiment

stores you current working pivotal ticket id into your home directory and appends that to every commit message

```
Usage: git-commit [options]
  -t, --ticket:
      set current ticket number
  -p, --print:
      print current ticket number
  -c, --commit:
      commit with current ticket
  -h, --help:
      Prints a help message.
```

suggested aliases:
```
alias gt="git-commit -t"
alias gp="git-commit -p"
alias gc="git-commit -c"
```

## build
run
```
xcodebuild install
```
in the project directory
