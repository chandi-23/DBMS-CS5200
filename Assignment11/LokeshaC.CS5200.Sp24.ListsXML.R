library(XML)

# Load the XML file
xml_data <- xmlParse("LokeshaC.CS5200.List.xml", useInternalNodes = TRUE, validate = TRUE)

# Run an XPath query to count the number of items in a specific list
count_items <- xpathSApply(xml_data, "//list[@name='Groceries']", xmlSize)
# print(count_items)

total_items <- sum(count_items)

# Display the result
print(paste("Total number of todo items in the 'Groceries' list:", total_items))

