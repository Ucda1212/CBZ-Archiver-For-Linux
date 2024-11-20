#!/bin/bash

# Exit immediately on unset variables or errors
set -euo pipefail

# Ask for the input directory
read -p "Enter the path to the folder containing the image folders: " base_dir
base_dir=$(realpath "$base_dir")  # Convert to absolute path

# Validate input directory
if [ ! -d "$base_dir" ]; then
    echo "Error: The directory '$base_dir' does not exist."
    exit 1
fi

# Ask for the output directory
read -p "Enter the path where you want to save the CBZ files: " output_dir
output_dir=$(realpath "$output_dir")  # Convert to absolute path

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Ask if the user wants to delete the original files after conversion
read -p "Do you want to delete the original folders after conversion? (yes/no): " delete_choice

# Validate the delete_choice input
if [[ "$delete_choice" != "yes" && "$delete_choice" != "no" ]]; then
    echo "Invalid choice. Please enter 'yes' or 'no'."
    exit 1
fi

# If the user chose to delete, confirm twice
if [ "$delete_choice" == "yes" ]; then
    echo "You chose to delete the original folders after conversion."
    read -p "Are you absolutely sure you want to delete ALL original folders after conversion? (yes/no): " confirm_once
    if [ "$confirm_once" != "yes" ]; then
        echo "Deletion canceled. Original folders will NOT be deleted."
        delete_choice="no"
    else
        read -p "Final confirmation: Are you REALLY sure you want to delete ALL original folders? (yes/no): " confirm_final
        if [ "$confirm_final" != "yes" ]; then
            echo "Deletion canceled. Original folders will NOT be deleted."
            delete_choice="no"
        else
            echo "Confirmed: Original folders will be deleted after conversion."
        fi
    fi
fi

# Loop through each folder in the base directory
for folder in "$base_dir"/*; do
    # Skip if it's not a directory
    if [ ! -d "$folder" ]; then
        echo "Skipping $folder: Not a directory."
        continue
    fi

    # Skip folders containing .cbz files
    if find "$folder" -maxdepth 1 -type f -name "*.cbz" | grep -q "."; then
        echo "Skipping $folder: contains .cbz files."
        continue
    fi

    # Get the name of the folder
    folder_name=$(basename "$folder")
    output_file="$output_dir/$folder_name.cbz"

    # Create a CBZ file for the folder
    echo "Creating CBZ: $output_file"
    zip -r "$output_file" "$folder" > /dev/null 2>&1
    echo "Converted $folder to $output_file"

    # If user confirmed deletion, remove the original folder
    if [ "$delete_choice" == "yes" ]; then
        rm -rf "$folder"
        echo "Deleted original folder: $folder"
    fi
done

echo "All done! CBZ files are saved in $output_dir."
if [ "$delete_choice" == "no" ]; then
    echo "Original folders were not deleted as per your choice."
fi
