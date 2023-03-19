


Table pm25Table;
Table windTable;

void setup() {
 loadRawDataTables(); 
}

void draw() {
 
}

void loadRawDataTables() {
  // Load the pm25 table
  pm25Table = loadTable("daily_88101_2020.csv", "header");
  println("pm25 table:", pm25Table.getRowCount(), "x", pm25Table.getColumnCount());
  // Print several rows of the pm25 table
  TableUtils.printNRowFromTable(pm25Table, 3);
  
  println();
  println();
  println();
  
  // Load the wind table
  windTable = loadTable("daily_WIND_2020.csv", "header");
  println("wind table:", windTable.getRowCount(), "x", windTable.getColumnCount());
  // Print several rows of the pm25 table
  TableUtils.printNRowFromTable(windTable, 3);
}
