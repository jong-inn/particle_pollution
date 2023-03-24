
import javax.swing.*;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

String prompt(String s) {
    println(s);
    String entry = JOptionPane.showInputDialog(s);
    if (entry == null) {
        return null;
    }
    println(entry);
    return entry;
}

String getString(String s) {
    return prompt(s);
}

LocalDate getLocalDate(String s) {
    while (true) {
        try {
            LocalDate date = LocalDate.parse(prompt(s));
            return date;
        } catch (DateTimeParseException e) {
            println("Please try again.");
        }
    }
}