# WIP: Bash Function Parametizer
Parameterizes bash commands and turns them into scripts

For example if you want to make a python calculator, create a file called `_functions.txt` and add three lines to it:

```
pcalc
python -c "print(@a @op @c)"
calculates a number
```

and then run `make-function.sh generate`, you will get a bash program called `pcalc` that will check for three parameters, and run the given python command. Of course, in order to run this, you would need to add `$HOME/local/bin/functions` to your path.

To recap:
1) Modify the file ~/.local/make-function/_functions.txt to include a block of three lines. The first line is the name of the function. The second is the actual bash command (could be a change of bash commands). Third is a description.
2) Add `$HOME/local/bin/functions` to your path (you need to only do this once if you add it to your bash setup file).
3) run ./make-function.sh generate (or if you install make-function.sh on your path, just run make-function.sh generate).
