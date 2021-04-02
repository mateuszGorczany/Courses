public class Lab6 {
    public static void main(String[] args) {
        StudentUSOS s1 = new StudentWFiIS1("Marek", "Styczen", 211150, 5, "Java", 4.5, "Fizyka", 3.0, "Elektronika", 5.0);
        StudentUSOS s2 = new StudentWFiIS1("Darek", "Luty", 305459, 2, "Java", 5.0, "Matematyka", 4.5, "Elektronika", 4.0);
        info(s1);
        info(s2);

        System.out.println("--------------------------------------------------------------------");

        StudentUSOS s3 = new StudentWFiIS2("Marek", "Styczen", 211150, 5, "Java", 4.5, "Fizyka", 3.0, "Elektronika", 5.0);
        StudentUSOS s4 = new StudentWFiIS2("Darek", "Luty", 305459, 2, "Java", 5.0, "Matematyka", 4.5, "Elektronika", 4.0);
        info(s3);
        info(s4);

        System.out.println("--------------------------------------------------------------------");

        StudentWFiIS3 s5 = new StudentWFiIS3("Marek", "Styczen", 211150, 5, "Java", 4.5, "Fizyka", 3.0, "Elektronika", 5.0);
        StudentWFiIS3 s6 = new StudentWFiIS3("Darek", "Luty", 305459, 2, "Java", 5.0, "Matematyka", 4.5, "Elektronika",  4.0);
        info(s5);
        info(s6);

    }

    public static void info(StudentUSOS s) {
        System.out.println(s);
        System.out.println("\tSrednia: " + s.srednia());
        s.listaPrzedmiotow();
    }

    public static void info(StudentWFiIS3 s) {
        System.out.println(s);
        System.out.println("\tSrednia: " + s.srednia());
        s.listaPrzedmiotow();
    }
}