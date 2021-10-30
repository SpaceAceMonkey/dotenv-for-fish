function dotenv
    # Parses commend-line arguments and sets _flag_[xuh] variables. Complains if the user tries to use both -x and -u.
    argparse --name=dotenv -x 'u,x' 'u/unset' 'h/help' 'x/export' 'q/quiet' -- $argv
    
    # If the h or --help flags are set (both can be checked using _flag_h), display help, and ignore everything else.
    if test $_flag_h
      __help_dotenv
    else
        # Any non-option command-line arguments are assumed to be .env files, so we check to see if any are present.
        if set -q argv; and test (count $argv) -gt 0
            set env_files $argv
        # If no environment files are specified on the command-line, we default to .env    
        else
            set env_files .env
        end
        # Loop through all of the specified environment variable files and set any variables found within
        for env_file in $env_files
            if test -r $env_file
                while read -l line
                    # Set variables to be global, otherwise they will not be available in your shell once this script 
                    # has finished running.
                    set set_args "-g"

                    # Remove the "export" directive from the line if present, and set a variable indicating whether or
                    # not it was found. Negate the return value of "string replace" so that 1/true means we found the
                    # export directive. This makes its usage easier to follow in subsequent lines.
                    set trimmed_line (not string replace -r '^\s*export\s+' '' -- $line)
                    set export $status
                    
                    # If we found the export directive in the previous step, or if -x/--export was specified on the
                    # command-line, set the export flag for the upcoming 'set' command.
                    if test $export -eq 1; or begin; set -q _flag_x; and test "$_flag_x" = "-x"; end;
                      set set_args "$set_args"x
                    end
                    
                    # Check to see if the line we are processing is basically sane. The fish set command will ignore
                    # leading white space on the variable name, so we allow it in our check.
                    if string match -q --regex -- '^\s*[a-zA-Z0-9_]+=' "$trimmed_line"
                        # Split the current line into name and value, and store them in $kv. We use -m1 because we only
                        # want to split on the first "=" we encounter. Everything after that, including additional "="
                        # characters, is part of the value.
                        set kv (string split -m 1 = -- $trimmed_line)
                        # If -u/--unset has been specified, erase the variable.
                        if set -q _flag_u; and test "$_flag_u" = "-u"
                            set -e $kv[1]
                        # Otherwise, set the shell variable. The variable $kv contains both the name and the value we
                        # want to set.
                        else
                            set $set_args $kv
                        end
                    end
                # Combined with the `while` keyword, this reads $env_file one line at a time.
                end <$env_file
            else
                if not set -q _flag_q; or test "$_flag_q" != '-q'
                    echo "Unable to locate file $env_file"
                end
            end
        end
    end
    
    # This function will be available to be called directly from the shell, even though it is defined inside of dotenv.
    # I put it into its own function because I think it looks a little cleaner than having a big blob of echoes inside
    # the "if" statement near the top of this function.
    function __help_dotenv
      echo "Usage: dotenv [-u] [files]"
      echo "-h/--help: Display this help message."
      echo "-u/--unset: Read [files] and unset the variables found therein."
      echo "-x/--export: Force variables to be exported, regardless of whether or not they are preceded by 'export' in the env file." 
      echo "[files]: One or more files containing name=value pairs to be read into the environment. Defaults to .env."
      echo ""
    end
end
