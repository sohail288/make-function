# WIP: Bash Function Parametizer
Parameterizes bash commands and turns them into bash functions

For example if you want to make a python calculator, create a file called `_functions.txt` and add three lines to it:

```
pcalc
python -c "print(@a @op @c)"
calculates a number
```

and then run `make-function.sh generate`, you will get a bash "program" called `pcalc` that will check for three parameters, and run the given python command as `pcalc 1 + 2` (yes, you can do more than just arithmetic here). Of course, in order to run this, you would need to source `$HOME/local/bin/_functions` as in `source $HOME/local/bin/_functions`.

To recap:
1) Modify the file ~/.local/make-function/_functions.txt to include a block of three lines. The first line is the name of the function. The second is the actual bash command (could be a change of bash commands). Third is a description. __Each of these blocks is separated by an empty line__.
2) run ./make-function.sh generate (or if you install make-function.sh on your path, just run make-function.sh generate).
3) do `source $HOME/local/bin/_functions`.

The main benefit derived is the ability to parameterize certain bash invocations such as generating gifs, converting images, creating ssl certs, and so on. I guess it allows you to easily create wrappers command line tools.

NOTE: sh does not support the `-` character in a function name. A lot of programs subprocess to sh. When the functions get exported, sh complains. So avoid using it in your function names.

TODO: currently the `_functions.txt` file is a temporary solution for storing function data. I do not want to rely on any dependency that parses a standard file such as json or yaml.
