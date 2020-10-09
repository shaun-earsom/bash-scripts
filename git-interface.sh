#!/bin/bash
# Use: git-interface.sh

# What I learned:
# 1. I learned how to build a menu. Nifty!
# 2. Prompt Statements and how to use the right one for the job.
# 3. Creating the repository on the github side requires using the API as well as an Oauth style key.
#    It may be easier to go to the website for one-offs, however if you need to make a bunch, this is the way.
# 4. No matter what directory manipulation you do in a script, once the script ends, you're back to the directory you started in.
# 5. QUOTES MATTER IN GIT API!!  "{\"name\":\"$repo_name\"}" is correct.  '{\"name\":\"$repo_name\"}' is not.

 
title() # Display the title
{
    echo "    ------------------------------
    -- Super Lazy Git Interface --
    ------------------------------
    - For when you just... can't -
    ------------------------------"
}

menu() # Display the menu
{
    echo "    -------------Menu-------------
    1) New repository
    2) Connect to an existing repository
    3) Push files up to git
    4) Pull files down to this machine
    5) Exit out of this madness..."
}

repoInfo() # Define local repo path and name
{
    echo "What do you want to call your new repository?"
    read -e repo_name
    printf "Which local directory should contain your repository?\n(NOTE: using \"~\" won't work use \"/home/USERNAME\" instead.)\n"
    read -e repo_dir
    echo "What is your git username?"
    read -e git_username
}

dirVerify() # Check if local repository folder exists
{
    read -r -p "Do you need to make a new local folder? [y/n]: " yesNo #doing it this way here because it's a simple yes/no. the other reads have longer answers
    case $yesNo in
        [yY][eE][sS]|[yY])
            repoInfo
            mkdir $repo_name
            ;;
        [nN][oO]|[nN])
            if [ ! -d $repo_dir/$repo_name ]
            then
                echo "--$repo_dir/$repo_name does not exist, please select yes."
                dirVerify
            fi
        ;;
        *) echo "Invalid option $REPLY";;
    cd $repo_dir/$repo_name
}

localDirSetup() # Does the local setup.
{
        echo "--Making generic README.md."
    echo "# $repo_name" >> README.md
    echo "--Setting up local directory for use."
    git init
    echo "--Wrapping up and pushing first commit."
    git add README.md
    git commit -m "git-interface.sh:first commit"
    git branch -M main
    git remote add origin https://github.com/$git_username/$repo_name.git
    git push -u origin main # You'll have to type your username and password here... it's fine...
    echo "--Done! Back to the menu."
}

newRepository() # Create a new repository
{
    repoInfo
    dirVerify
    echo "Please provide your github key."
    read -e git_key
    echo "--Creating repo on github.com."
    curl -H "Authorization: token $git_key" -d "{\"name\":\"$repo_name\"}" https://api.github.com/user/repos
    loalDirSetup
    title
    menu
}

existRepository() # Connect to an existing repository.
{
    repoInfo
    dirVerify
    localSetup
    echo "--Done! Back to the menu."
    title
    menu
}

main() # Run the main program
{
    PS3='Your Selection: '
    options=("New repository" "Connect to an existing repository" "Push files up to git" "Pull files down to this machine" "Exit out of this madness...")
    select sel in "${options[@]}"
    do
        case $sel in
            "New repository")
                echo "--Create a new repository"
                newRepository
                ;;
            "Connect to an existing repository")
                echo "--Connect a folder to an existing repository"
                existRepository
                ;;
            "Push files up to git")
                echo "--Push files up to git"
                ;;
            "Pull files down to this machine")
                echo "--Pull files down to this machine"
                ;;
            "Exit out of this madness...")
                echo "--Exiting out of this madness..."
                exit
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
}

title
main