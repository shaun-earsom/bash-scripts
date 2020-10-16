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
