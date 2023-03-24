

static class TableUtils {
  static public void printNRowFromTable(Table t, int n) {
    // Set n eqaul to or less than the number of rows
    if(t.getRowCount() < n) {
      n = t.getRowCount();
    }
    
    // Iterate the table rows
    for (int r=0; r<n; r++) {
      TableRow rowValues = t.getRow(r);
      
      // Print column's names
      if (r == 0) {
        for (int c=0; c<t.getColumnCount(); c++) {
          print(rowValues.getColumnTitle(c));
          if( c< t.getColumnCount()-1) {
            print(", ");
          } else {
            println();
          }
        }
      }
      
      // Print values for each column
      for (int c=0; c<t.getColumnCount(); c++) {
        print(rowValues.getString(c));
        if (c < t.getColumnCount()-1) {
          print(", ");
        }
      }
    }
  }

  static float findMinFloatInColumn(Table t, int column) {
    float[] values = t.getFloatColumn(column);
    float min = values[0];
    for (int i=0; i<values.length; i++) {
      if (values[i] < min) {
        min = values[i]; 
      }
    }
    return min;
  }

  static float findMinFloatInColumn(Table t, String columnName) {
    return findMinFloatInColumn(t, t.getColumnIndex(columnName));
  }
  
  static float findMaxFloatInColumn(Table t, int column) {
    float[] values = t.getFloatColumn(column);
    float max = values[0];
    for (int i=0; i<values.length; i++) {
      if (values[i] > max) {
        max = values[i]; 
      }
    }
    return max;
  }

  static float findMaxFloatInColumn(Table t, String columnName) {
    return findMaxFloatInColumn(t, t.getColumnIndex(columnName));
  }
}
