/*************************************************************************
*
* PURPOSE: Placeholder class for parsing CSV files until we shift
*          to a Heroku/Apache POI based solution
*
* CLASS: CsvParser
* CREATED: 3/27/2012 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/

public with sharing class CsvParser {
	public static String ESCAPE_MODE_DOUBLED = 'doubled';
	public static String ESCAPE_MODE_BACKSLASH = 'backslash';

	
	public String textQualifier { get; set; }
	public String delimiter { get; set; }
	public String escapeMode { get; set; }
	public String contents { get; set; }
	
	public CsvParser(String contents) {
		textQualifier = '"';
		delimiter = ',';
		escapeMode = ESCAPE_MODE_DOUBLED;
		this.contents = contents;

	}

	public Integer getTotalLines() {
		List<String> lines = contents.split('[\n\r]+');
		return lines.size();
	}

	public List<List<String>> parse(Integer startIndex, Integer endIndex) {
		return parse(startIndex, endIndex, true);
	}

	public List<List<String>> parse(Integer startIndex, Integer endIndex, Boolean offsetIndexes) {
		List<List<String>> allFields = new List<List<String>>();
		
		List<String> lines = contents.split('[\n\r]+');

		if (offsetIndexes) {
			// Add one to start and end index to get offset within file after putting in the header line
			startIndex++;
			endIndex++;

			// Parse first line to get the headers
			parseLine(lines[0], allFields);
		}

		for (Integer i = startIndex; i < lines.size() && i <= endIndex; i++) {
			parseLine(lines[i], allFields);
		}


		return allFields;
	}

	
	public List<List<String>> parse() {
		List<String> lines = contents.split('[\n\r]+');
		return parse(0, lines.size()-1, false);
	}

	private void parseLine(String line, List<List<String>> allFields) {
		line = line.trim();
			
		Integer length = line.length();
		
		Integer i;
		Boolean isQulifing = false;
		Boolean isEscaping = false;
		String currentField = '';
		Boolean isBeginningOfField = false;
		
		List<String> lineFields = new List<String>();
		for (i = 0; i < length; i++) {
			String achar = line.substring(i,i+1);
			
			if (achar.equals(delimiter)) {
				// the delimiter
				if (isQulifing) {
					currentField = currentField + delimiter;
					isBeginningOfField = false;
				} else {
					lineFields.add(currentField);
					currentField = '';
					isQulifing = false;
					isEscaping = false;
					isBeginningOfField = true;
				}
				
			} else if (escapeMode.equals(ESCAPE_MODE_BACKSLASH) && achar.equals('\\')) {
				// the escape char
				if (isEscaping) {
					isEscaping = false;
					currentField = currentField + '\\';
				} else {
					isEscaping = true;
				}
				
			} else if (achar.equals(textQualifier)) {
				// the qualifier
				if (isEscaping) {
					isEscaping = false;
					currentField = currentField + textQualifier;
				} else {
					String nextchar = 'NEVEREQUAL';
					if (i < length-1) {
						nextchar = line.substring(i+1,i+2);
					}
					if (escapeMode.equals(ESCAPE_MODE_DOUBLED) && nextchar.equals(textQualifier) && (! isBeginningOfField)) {
						isEscaping = true;
						
					} else {
						if(isQulifing){
							isQulifing = false;
						}else{
							isQulifing = true;
						}
						
					}
				}
				
			} else {
				// general char
				currentField = currentField + achar;
				
			}
			
			if (!achar.equals(delimiter)) {
				isBeginningOfField = false;
			}
			
		}
		
		if (currentField.length() > 0) {
			// the last field
			lineFields.add(currentField);
		}
		
		if (!lineFields.isEmpty()) {
			allFields.add(lineFields);
		}
	}
	
	
	/****************************
	 * CSV Holder helper object *
	 ****************************/
	  
	public class CsvHolder {
		
		public List<String> headers { get; set; }
		public List<List<String>> fileLines { get; set; }
		
		public Map<String, Integer> columnIndexes { get; set; }
		
		
		/**
		 * Store the file lines and parse the headers for easy access later on
		 * @param fileLines - The full contents of the CSV file to operate on
		 */
		public CsvHolder(List<List<String>> fileLines) {
			headers = fileLines[0];
			
			this.fileLines = fileLines;
			
			columnIndexes = new Map<String, Integer>();
			
			for (Integer i = 0; i < headers.size(); i++) {
				String header = headers[i].trim();
				columnIndexes.put(header, i);
			}
		}
		
		/**
		 * Create an Empty CSV Holder to put values in and get a CSV out later on
		 * @param rowCount - Number of rows in the CSV
		 * @param columnHeaders - Headers of the CSV in order as they appear on the spreadsheet
		 */
		public CsvHolder(Integer rowCount, List<String> columnHeaders) {
			Integer columnCount = columnHeaders.size();
			columnIndexes = new Map<String, Integer>();
			fileLines = new List<List<String>>();
			
			headers = columnHeaders;
			
			for (Integer i = 0; i < headers.size(); i++) {
				String header = headers[i].trim();
				columnIndexes.put(header, i);
			}
			
			// Add the header row
			fileLines.add(new List<String>());
			for (Integer i = 0; i < columnHeaders.size(); i++) {
				fileLines[0].add(columnHeaders[i]);
			}
			
			
			for (Integer i = 1; i < rowCount+1; i++) {
				fileLines.add(new String[columnCount]);
			}
		}
		
		/**
		 * Convenience method to get value from CSV based on column name
		 * @param row - The row to get (minus one to allow zero-indexed when headers are present)
		 * @param column - The column header of the column to get
		 * @returns The value at the row/column specified
		 */
		public String getVal(Integer row, String column) { 
			return fileLines[row+1][columnIndexes.get(column)];
		}
		
		/**
		 * Convenience method to get value from CSV based on column index
		 * @param row - The row to get (minus one to allow zero-indexed when headers are present)
		 * @param column - The index of the column to get
		 * @returns The value at the row/column specified
		 */
		public String getVal(Integer row, Integer column) {
			return fileLines[row+1][column];
		}
		
		/**
		 * Number of lines minus one to account for header row
		 */
		public Integer getLineCount() {
			return fileLines.size()-1;
		}
		
		public Integer getIndexOfColumn(String column) {
			if (columnIndexes.containsKey(column.trim())) {
				return columnIndexes.get(column.trim());
			}
			
			return -1;
		}
		
		public void putVal(String value, Integer rowNum, String column) {
			try {
				String[] row = fileLines[rowNum+1];
				row[columnIndexes.get(column)] = value;
				
			} catch (Exception e) {
				System.debug(LoggingLevel.ERROR, '### ERROR while putting value "' + value + '" at column "' + column + '":' + e);
			}
			//---TODO Account for out of range values, expand if necessary
			//if (fileLines.size() < row || !columnIndexes.containsKey(column)) {
			//	System.debug(LoggingLevel.ERROR, 'Tried to put value of of range: ' + value + ' at ' + row + ':' + column);
			//}
			

		}
		
		public String toCsvString() {
			String result = '';
			
			Integer rowCount = fileLines.size();
			for (Integer row = 0; row < rowCount; row++) {
				if (row != 0) result += '\r\n';
				
				Integer columnCount = fileLines[row].size();
				for (Integer column = 0; column < columnCount; column++) {
					if (column != 0) result += ',';
					
					String sVal = fileLines[row][column] == null ? '' : fileLines[row][column];
					result += sVal.replace(',', '');
				}
			}
			
			System.debug(LoggingLevel.INFO, '### INFO Csv String is: ' + result);
			return result;
		}
		
		public void appendColumn(String columnName) {
			List<String> columnHeaders = fileLines[0];
			Set<String> colSet = new Set<String>();
			colSet.addAll(columnHeaders);
			if(!colSet.contains(columnName)) {
				columnHeaders.add(columnName);
				for (Integer i = 1; i < fileLines.size(); i++) {
					fileLines[i].add('');
				}
				columnIndexes.put(columnName, columnHeaders.size()-1);
			}		
		}
	}
}