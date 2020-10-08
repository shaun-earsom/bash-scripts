#!/bin/bash
# Use: git-interface.sh

# What I learned:
# 1. I learned how to build a menu. Nifty!
# 2. Prompt Statements and how to use the right one for the job.
# 3. Creating the repository on the github side requires using the API as well as an Oauth style key.
#    It may be easier to go to the website for one-offs, however if you need to make a bunch, this is the way.

 
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

dirMoveTo() # Gets current directory, moves to correct directory, creates dir if needed.
{
    if [ ! -d "$repo_dir" ]
    then
        mkdir $repo_name # TODO: Consider fixing this loop so it can create multiple dirs if needed.
    fi
    cd $repo_dir
}

newRepository() # Create a new repository
{
    echo "What do you want to call your new repository?"
    read repo_name
    echo "Which local directory should contain your repository? (will create if it doesn't exist)"
    read repo_dir
    echo "What is your git username?"
    read git_username
    echo "Please provide your github key."
    read git_key
    echo "--Creating repository directory if it doesn't exist. Moving to the directory."
    dirMoveTo
    echo "--Creating repo on github.com."
    curl -H "Authorization: token $git_key" --data '{"name":"$repo_name"}' https://api.github.com/user/repos
    echo "--Making generic README.md."
    echo "# $repo_name" >> README.md
    echo "--Setting up local directory for use."
    git init
    echo "--Wrapping up and pushing first commit."
    git add README.md
    git commit -m "git-interface.sh:first commit"
    git branch -M main
    git remote add origin https://github.com/$git_username/$repo_name.git
    git push -u origin main
    echo "--Done! Back to the menu."
    title
    menu
}

main() # Run the main program
{
    PS3='Your Selection: '
    options=("New repository" "Connect to existing repository" "Push files up to git" "Pull files down to this machine" "Exit out of this madness...")
    select sel in "${options[@]}"; do
        case $sel in
            "New repository")
                echo "--Create a new repository"
                newRepository
                ;;
            "Connect to an existing repository")
                echo "--Connect a folder to an existing repository"
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