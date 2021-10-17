# SpaceAce's dotenv for [fish shell](https://fishshell.com/)
A rough equivalent of sourcing .env files in bash

&nbsp;

# Why?
It is common in Linux and Linux-like shells to store key=value pairs in files which can be easily loaded into the shell's environment. Personally, I deal with dozens of projects on a daily basis which require login credentials, configuration variables, and other information to exist in the shell environment\*. If they do not, the software will not work. When developing those applications, I need an easy way to load the required variables into the shell.

In bash, this is solved by `source .env`. Fish, however, does not use the "key=value" format that bash uses for setting environment variable. If you attempt to `source` a standard .env file in fish, you will generate errors. The fish function in this repository solves that problem.

\* This is for development purposes, and all sensitive information is fake.

&nbsp;

## Setup
1) Clone this repository, or copy/download the file dotenv.fish to your machine.
2) Insert the function into your shell. Any of the following work.
    1) Temporary solutions; these will only exist for the current shell session, and will disappear when you exit the shell or reboot.
        1) `source dotenv.fish`
        - Or
        2) Paste the contents of dotenv.fish directly into your shell.
    2) Permanent solutions
        1) Manual
            1) If it does not already exist, create the directory `[your home folder]/.config/fish/functions`
            2) Copy `dotenv.fish` to the above location
        2) Automatic, sort of
            1) If you have already followed one of the steps under "temporary solutions," you can use `funcsave dotenv` from the command-line to permanently store the function. Fish will put it in the same place as you did in the "manual" steps.

If using the manual solution, you will have to either start a fresh fish shell, or use one of the temporary solutions to load the function into your current session.

&nbsp;


## Options
Dotenv accepts a small number of command-line options to modify its behavior.

- -h
    - Displays a brief overview of its usage
- -q
    - Suppresses error message generated when dotenv cannot locate the environment file(s).
- -u
    - Unsets the variables found in the environment file. This is very useful for cleanup when you no longer want or need the variables hanging around in your shell.
- -x
    - Export the variables and values found in the environment file. This makes them available to sub-processes of the shell. This is probably what you want if you're using the .env file to configure a process you're going to run from the shell.
- .env, .env.dev, etc
    - Anything other than the options above is treated as an environment file. By default, dotenv looks for a file called `.env` in the current directory. However, you can specify any other name(s) you like.

    &nbsp;

## Usage
> dotenv

Reads the file .env in the current directory, and creates shell variables based on what it finds there.

> dotenv -u

Reads the file .env in the current directory, and , rather than setting the variables it finds there, it unsets them, removing them from the current environment.

> dotenv -x

Does the same as `dotenv`, but exports the variables so they are available to sub-processes launched from the current shell.

> dotenv .env.dev .env.local

Does the same as `dotenv`, but reads from the files `.env.dev` and `.env.local` rather than from `.env`, and creates all the variables it finds in both files. If the variables share names, the values in the second file will overwrite the values in the first file.

You may specify as many files as you like, subject to the limits of your computer, and reality as we know it.

> dotenv -x env.local

Sets and exports variable found in `.env.local`

> dotenv -u env.local

Does the same as `dotenv -u`, except it reads the variable names from `.env.local.` rather than from `.env`.

> dotenv .file_that_does_not_exist

Will complain about the missing file.

> dotenv -q .file_that_does_not_exist

Will not complain about the missing file.

&nbsp;

## Don't like the comments in the fish file?
`grep -v '^\s*#' dotenv.fish`

&nbsp;