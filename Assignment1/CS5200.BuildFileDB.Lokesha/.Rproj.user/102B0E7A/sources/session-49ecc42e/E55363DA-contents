## ---------------------------
## Script name:  FileDB-Lokesha
## Purpose of script: To create a hierarchical database
## Author: Chandresh Lokesha
## Date Submitted: 2023-01-27
## ---------------------------
## Notes: To create a file system based database in form of hierarchy
## ---------------------------


#' Root directory to create DB
rootDir <- "docDB"

#' This is the main function to test the functions
main <- function()
{
  # all program code starts here
  print ("Hello, World")
  
  #clear Initail Items
  clearDB(rootDir)
  
  configDB(rootDir)
  
  # Test for configDB
  path = ""
  rootPath <- file.path(getwd(), rootDir)
  if(!dir.exists(rootDir)) {
    stop("configDB() without parameter failed!")
  }
  
  # Test for configDB with parameters
  configDB(rootDir, "../")
  rootPath <- file.path(path, rootDir)
  if(!dir.exists(rootDir)) {
    stop("configDB() with path parameter failed!")
  }
  
  # Test for getExtension and getFileStem
  fileName <- "CampusAtNight.png"
  fileNameD <- "CampusAtNight.doc"
  fileNameDx <- "CampusAtNight.docx"
  
  extPNGResult <- getExtension(fileName)
  stemPNGResult <- getFileStem(fileName)
  
  extDOCResult <- getExtension(fileNameD)
  stemDOCResult <- getFileStem(fileNameD)
  
  extDOCXResult <- getExtension(fileNameDx)
  stemDOCXResult <- getFileStem(fileNameDx)
  
  if(extPNGResult != "PNG" ||
     extDOCResult != "DOC" || 
     extDOCXResult != "DOCX" ) {
    print("getExtension() failed!")
  }
  
  if (stemPNGResult != "CampusAtNight" ||
      stemDOCResult != "CampusAtNight" ||
      stemDOCXResult != "CampusAtNight") {
    print("stemExtension() failed!")
  }
  
  # Test for genObjPath
  root <- "docDB.FileDB"
  tag1 <- "example.1.jpg"
  tag2 <- "document.docx"
  tag3 <- "document.doc"
  
  result1 <- genObjPath(root, tag1)
  result2 <- genObjPath(root, tag2)
  result3 <- genObjPath(root, tag3)
  
  if(result1 != "docDB.FileDB/JPG" || 
     result2 != "docDB.FileDB/DOC" || 
     result3 != "docDB.FileDB/DOC") {
    stop("genObjPath failed!")
  }
  
  folder <- "../TestFolder"
  root <- "./docDB"
  
  # Test for storeObjs
  storeObjs(folder, root, TRUE)
  
  allItems <- list.files(root, full.names = TRUE, recursive = TRUE)
  filesToCheck <- allItems[file.info(allItems)$isdir == FALSE]
  
  allTestItems <- list.files(folder, full.names = TRUE)
  filesExpected <- allTestItems[file.info(allTestItems)$isdir == FALSE]
  
  if(length(filesExpected) != length(filesToCheck)) {
    stop("failed to copy all the items")
  }
  
  # Test for clearDB
  clearDB(root)
  
  allItems <- list.files(root, full.names = TRUE, recursive = TRUE)
  
  if(length(allItems) != 0) {
    stop("failed to clear the DB")
  }
  
  # Final result
  print("All testCases passed")
  
}

#########################################################

#' Configure the database
#' 
#' This function configures the database by creating the root folder if it 
#' doesn't exist.
#' 
#' @param root The root directory name.
#' @param path An optional parameter specifying the path of the root directory.
#'             If not provided, the current working directory will be used.
#' @return Invisibly returns the path to the root directory.
#' @seealso \code{\link{clearDB}}
#' @examples
#' configDB("docDB")
#' configDB("docDB", "../")
configDB <- function(root, path="") {
  if(path == "") {
    rootPath <- file.path(getwd(), root)
  }
  else {
    rootPath <- file.path(path, root)
  }
  
  # Create the root folder if it doesn't exist
  if (!dir.exists(rootPath)) {
    dir.create(rootPath, recursive = TRUE)
  }
  
}

#' Get file extension
#' 
#' This function extracts the file extension from a given filename.
#' 
#' @param filename A character string representing the filename.
#' @return A character string containing the file extension in uppercase.
#' @examples
#' getExtension("example.txt")
getExtension <- function(filename) {
  
  extension <- tools::file_ext(filename)
  
  return( toupper(extension) )
  
}

#' Get file stem
#' 
#' This function extracts the stem (filename without extension) 
#' from a given filename.
#' 
#' @param fileName A character string representing the filename.
#' @return A character string containing the stem of the filename.
#' @examples
#' getFileStem("example.txt")
getFileStem <- function(fileName) {
  # Extract the stem from the file name
  stem <- tools::file_path_sans_ext(fileName)
  
  return(stem)
}

#' Generate object path
#' 
#' This function generates the path for storing an object based on the root
#' directory and tag (filename).
#' 
#' @param root A character string representing the root directory.
#' @param tag A character string representing the filename (tag) of the object.
#' @return A character string representing the path for storing the object.
#' @examples
#' genObjPath("docDB.FileDB", "example.jpg")
genObjPath <- function(root, tag) {
  # Extract the extension from the tag
  extension <- tools::file_ext(tag)
  
  # Convert the extension to uppercase
  uppercaseExtension <- toupper(extension)
  
  # Handling DOC and DOCX
  if (uppercaseExtension %in% c("DOC", "DOCX")) {
    uppercaseExtension <- "DOC"
  }
  
  # Generate the path by concatenating root and uppercaseExtension
  path <- file.path(root, uppercaseExtension)
  
  return(path)
}

#' Store objects in the database
#' 
#' This function iterates through files in a folder, extracts information about
#' the file, and stores it in the database based on the root directory.
#' 
#' @param folder A character string representing the folder 
#'        containing the files.
#' @param root A character string representing the root directory.
#' @param verbose A logical indicating whether to print verbose information 
#'        during the process.
#' @return Invisibly returns NULL.
#' @seealso \code{\link{clearDB}}
#' @examples
#' storeObjs("../TestFolder", "./docDB", TRUE)
storeObjs <- function(folder, root, verbose=FALSE) {
  
  if (!dir.exists(folder)) {
    stop(paste("No source directory to copy:", folder))
  }
  
  # List all files in the folder
  files <- list.files(folder, full.names = TRUE)
  # Iterate through each file
  for (file in files) {
    
    extension <- getExtension(basename(file))
    # Check if the file has an extension
    if (nchar(extension) > 0) {
      # Get the extension and stem
      stem <- getFileStem(file)
      
      # Generate the destination folder path
      destination <- genObjPath(root, file)
      
      # Create the destination folder if it doesn't exist
      if (!dir.exists(destination)) {
        dir.create(destination, recursive = TRUE)
      }
      
      if(verbose) {
        cat("Copying", stem, "to folder", extension, "\n")
      }
      
      # Copy the file to the destination folder
      file.copy(file, file.path(destination, basename(file)))
      
    }
  }
}

#' Clear the database
#' 
#' This function removes all files and folders within the 
#' specified root directory.
#' 
#' @param root A character string representing the root directory.
#' @return Invisibly returns NULL.
#' @examples
#' clearDB("docDB")
clearDB <- function(root) {
  # List all files and folders in the root directory
  allItems <- list.files(root, full.names = TRUE)
  
  # Remove all files
  filesToRemove <- allItems[file.info(allItems)$isdir == FALSE]
  file.remove(filesToRemove)
  
  # Remove all folders
  foldersToRemove <- allItems[file.info(allItems)$isdir]
  sapply(foldersToRemove, function(folder) unlink(folder, recursive = TRUE))
}

#########################################################

main()
