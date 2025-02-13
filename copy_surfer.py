import shutil
import os
import subprocess

def copy_folder(src, dst):
    """
    Copy a folder and its contents from src to dst.
    
    :param src: Source folder path
    :param dst: Destination folder path
    """
    if not os.path.exists(src):
        print(f"Source folder '{src}' does not exist. Skipping...")
        return
    
    if os.path.exists(dst):
        print(f"Destination folder '{dst}' already exists. Skipping...")
        return
    
    try:
        # Use sudo since /Applications requires admin permissions
        subprocess.run(["sudo", "cp", "-R", src, dst], check=True)
        print(f"✅ Folder successfully copied from '{src}' to '{dst}'.")
    except Exception as e:
        print(f"❌ Error copying folder '{src}' to '{dst}': {e}")

# Define paths
source_base = "/Volumes/T7/AMPB/analysis"
destination_base = "/Applications/freesurfer/7.4.1/subjects"

# List of subject IDs
subject_folders = [
    "sub-EBxGxCCx1986", "sub-EBxGxEYx1965", "sub-EBxGxPEx1959", "sub-EBxGxYZx1949",
    "sub-EBxGxZAx1990", "sub-EBxLxHHx1949", "sub-EBxLxQPx1957", "sub-EBxLxTZx1956",
    "sub-NSxGxBAx1970", "sub-NSxGxBYx1981", "sub-NSxGxHKx1965", "sub-NSxGxHNx1952",
    "sub-NSxGxIFx1991", "sub-NSxGxNXx1990", "sub-NSxGxRFx1978", "sub-NSxGxXJx1998",
    "sub-NSxGxYRx1992", "sub-NSxLxATx1954", "sub-NSxLxBNx1985", "sub-NSxLxIUx1994",
    "sub-NSxLxPQx1973", "sub-NSxLxQFx1997", "sub-NSxLxQUx1953", "sub-NSxLxVDx1987",
    "sub-NSxLxVJx1998", "sub-NSxLxYKx1964", "sub-NSxLxYNx1999"
]

# Copy `surf` folder for each subject
for subject in subject_folders:
    src_path = os.path.join(source_base, subject, "surf")
    subject_dest = os.path.join(destination_base, subject)

    # Create subject directory if it doesn't exist
    if not os.path.exists(subject_dest):
        try:
            subprocess.run(["sudo", "mkdir", "-p", subject_dest], check=True)
            print(f"📁 Created subject folder: {subject_dest}")
        except Exception as e:
            print(f"❌ Error creating folder '{subject_dest}': {e}")
            continue

    dst_path = os.path.join(subject_dest, "surf")

    # Copy surf folder
    copy_folder(src_path, dst_path)

print("\n🎉 All subjects processed successfully!")



# import shutil
# import os

# def copy_folder(src, dst):
#     """
#     Copy a folder and its contents from src to dst.
    
#     :param src: Source folder path
#     :param dst: Destination folder path
#     """
#     if not os.path.exists(src):
#         print(f"Source folder '{src}' does not exist. Skipping...")
#         return
    
#     if os.path.exists(dst):
#         print(f"Destination folder '{dst}' already exists. Skipping...")
#         return
    
#     try:
#         shutil.copytree(src, dst)
#         print(f"✅ Folder successfully copied from '{src}' to '{dst}'.")
#     except Exception as e:
#         print(f"❌ Error copying folder '{src}' to '{dst}': {e}")

# # Define paths
# source_base = "/Volumes/T7/AMPB/derivatives/freesurfer"
# destination_base = "/Volumes/T7/AMPB/analysis"

# # List of subject IDs
# subject_folders = [
#     "sub-EBxGxCCx1986", "sub-EBxGxEYx1965", "sub-EBxGxPEx1959", "sub-EBxGxYZx1949",

#     "sub-EBxGxZAx1990", "sub-EBxLxHHx1949", "sub-EBxLxQPx1957", "sub-EBxLxTZx1956",
#     "sub-NSxGxBAx1970", "sub-NSxGxBYx1981", "sub-NSxGxHKx1965", "sub-NSxGxHNx1952",
#     "sub-NSxGxIFx1991", "sub-NSxGxNXx1990", "sub-NSxGxRFx1978", "sub-NSxGxXJx1998",
#     "sub-NSxGxYRx1992", "sub-NSxLxATx1954", "sub-NSxLxBNx1985", "sub-NSxLxIUx1994",
#     "sub-NSxLxPQx1973", "sub-NSxLxQFx1997", "sub-NSxLxQUx1953", "sub-NSxLxVDx1987",
#     "sub-NSxLxVJx1998", "sub-NSxLxYKx1964", "sub-NSxLxYNx1999"
# ]

# # Copy `surf` folder for each subject
# for subject in subject_folders:
#     src_path = os.path.join(source_base, subject, "surf")
#     dst_path = os.path.join(destination_base, subject, "surf")

#     copy_folder(src_path, dst_path)

# print("\n🎉 All subjects processed successfully!")
