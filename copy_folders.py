import shutil
import os

def copy_folder(src, dst):
    """
    Copy a folder and its contents from src to dst.
    
    :param src: Source folder path
    :param dst: Destination folder path
    """
    if not os.path.exists(src):
        print(f"Source folder '{src}' does not exist.")
        return
    
    try:
        shutil.copytree(src, dst)
        print(f"Folder successfully copied from '{src}' to '{dst}'.")
    except FileExistsError:
        print(f"Destination folder '{dst}' already exists.")
    except Exception as e:
        print(f"Error copying folder: {e}")

# Example usage
source_path = "/Volumes/Extreme SSD/AMPB/data/analysis"
destination_path = "/Volumes/T7/AMPB/analysis"
subject_folders = [
    "sub-EBxGxCCx1986", "sub-EBxGxEYx1965", "sub-EBxGxPEx1959", "sub-EBxGxYZx1949",
    "sub-EBxGxZAx1990", "sub-EBxLxHHx1949", "sub-EBxLxQPx1957", "sub-EBxLxTZx1956",
    "sub-NSxGxBAx1970", "sub-NSxGxBYx1981", "sub-NSxGxHKx1965", "sub-NSxGxHNx1952",
    "sub-NSxGxIFx1991", "sub-NSxGxNXx1990", "sub-NSxGxRFx1978", "sub-NSxGxXJx1998",
    "sub-NSxGxYRx1992", "sub-NSxLxATx1954", "sub-NSxLxBNx1985", "sub-NSxLxIUx1994",
    "sub-NSxLxPQx1973", "sub-NSxLxQFx1997", "sub-NSxLxQUx1953", "sub-NSxLxVDx1987",
    "sub-NSxLxVJx1998", "sub-NSxLxYKx1964", "sub-NSxLxYNx1999"
]
folders_to_copy = ["func", "anat", "roi"]

for subject in subject_folders:
    for folder in folders_to_copy:
        src = os.path.join(source_path, subject, folder)
        dst = os.path.join(destination_path, subject, folder)
        copy_folder(src, dst)
