# bash-scripts
## git-interface.sh
Description: 
This is a simple text interactive interface for some of the basic functions of Git.
I made this using VS Code, tied to my copy of WSL2 which is running Ubuntu with Git installed.
This seemed like a good idea to help refresh myself on Git and build out my bash portfollio.

What I learned:
1. I learned how to build a menu. Nifty!
2. Prompt Statements and how to use the right one for the job.
3. Creating the repository on the github side requires using the API as well as an Oauth style key.  It may be easier to go to the website for one-offs.
4. No matter what directory manipulation you do in a script, once the script ends, you're back to the directory you started in.
5. QUOTES MATTER IN GIT API!!  "{\"name\":\"$repo_name\"}" is correct.  '{\"name\":\"$repo_name\"}' is not.

## filemaker.sh
Description:
This short little script takes a few arguements and generates a file with the desired name.
It is scalable, using Arguement1 you can specify any number of files you want made.  The first file will be named whatever Arguement2 is.
Successive files will be named Whatever Arguement2 is, but will also have a number apended to the end. So if you wanted three files named test, you would get back "test, test2, test3".  I made this because it's actually a good example of a more complex for loop.

What I learned:
1. Getting a for loop to be both an index and a variable is tricky and c-like. https://tldp.org/LDP/abs/html/dblparens.html
2. Spaces in the if statement are super important, especially those spaces around the square brackets.
3. Semicolon at the end of the if statement appears to not be needed. However if you had it, you could move 'then' up to that line.
