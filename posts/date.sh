#!/usr/bin/env bash

################################
# Variables and Helper functions
################################

# Script summary:
#  - [modified] variable in frontmatter holds the last time script is run on a file
#  - [modified] is added if script is being run on the file for the first time
#  - If file has been updated (according to Unix time stamp)  since [modified] -
#    the last time the script was run - prompt the user about updating the [date]
#  - [modified] always holds the last day the script is run. [date] holds the
#    the "last modified date" that is shown on the website and in the filename
#    in _posts

# Color codes and variables
export RESET="\033[0m"
export YELLOW="\033[0;33m"
ANS=""

print_question() {
    # Print output in yellow
    printf "%b  [?] $1%b\n" "${YELLOW}" "${RESET}";
    read

    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        ANS="yes"
    else
        ANS="no"
    fi
}

# ISO time to seconds since epoch
iso_to_sec() {
    date -d "$1" +%s
}

# Gets the root git directory
JEKYLL_DIR="$(git rev-parse --show-toplevel)"
last_modified_unix=""


# Updates frontmatter: concatenates new frontmatter with page contents and
# writes it into $file
update_frontmatter() {
    page=$(sed '1 { /^---/ { :a N; /\n---/! ba; d} }' "$file")
    frontmatter="---\n${frontmatter}\n---\n"
    echo -e "$frontmatter$page" > "$file"
}

################################
# Main Program
################################

# Delete all contents in _posts directory (overwritten every time)
rm "$JEKYLL_DIR"/_posts/*

# Copy each file in posts to _posts, while adding date to file name and checking
# if it needs to be updated
for file in "$JEKYLL_DIR"/posts/*; do
    # Copy each file in directory except for the script
    if [[ "$(basename "$file")" != "$(basename "$0")" ]]; then

        # Get last last modified Unix last modified time
        last_modified_unix=$(stat -c "%y" "$file" | awk '{print $1}')
        # Get frontmatter
        frontmatter=$(sed -n '/---/,/---/{/---/b;/---/b;p}' "$file")

        # If modified (last time script was run)  not found in frontmatter, add it
        echo "$frontmatter" | grep -q "modified:"
        if [[ $? != 0 ]]; then
            last_modified_yaml=$last_modified_unix
            last_modified=$last_modified_yaml
            frontmatter="${frontmatter}\nmodified: ${last_modified_yaml}"
            update_frontmatter
        else

            last_modified_yaml=$(echo "$frontmatter" | grep "modified" | awk '{print $2}')

            # If modified is found, then test to see if it matches filesystem last modified timestamp
            if [[ $(iso_to_sec "$last_modified_yaml") -lt $(iso_to_sec "$last_modified_unix") ]]; then
                last_modified_yaml=$last_modified_unix
                frontmatter=$(echo "$frontmatter" | sed "/modified: /c\modified: $last_modified_yaml")
                ANS=""
                print_question "$(basename "$file") has been updated. Do you want to update the date timestamp (y/n)?"
                # If file has been modified, prompt the user about updating timestamp
                if [[ "$ANS" == "yes" ]]; then
                    frontmatter=$(echo "$frontmatter" | sed "/date: /c\date: $last_modified_yaml")
                fi
                update_frontmatter
            fi

            last_modified=$(echo "$frontmatter" | grep "date:" | awk '{print $2}')
        fi
        cp -vT --preserve=all "$file" "$JEKYLL_DIR"/_posts/"$last_modified"-"$(basename "$file")"
    fi
done
