public class StudentWFiIS2 implements StudentUSOS
{
    private String[] przedmioty;
    private int rok;
    private Student stud;

    public StudentWFiIS2(String name,
                         String surname,
                         int index,
                         int year,
                         String courseOne,
                         double gradeOne,
                         String courseTwo,
                         double gradeTwo,
                         String courseThree,
                         double gradeThree)
    {
        przedmioty = new String[]{courseOne, courseTwo, courseThree};
        rok = year;
        stud = new Student(name, surname, index, gradeOne,gradeTwo, gradeThree);
    }

    public StudentWFiIS2(int year, String courseOne, String courseTwo, String courseThree)
    {
        przedmioty = new String[]{courseOne, courseTwo, courseThree};
        rok = year;
        stud = null;
    }

    @Override
    public double srednia()
    {
        return stud.average();
    }

    @Override
    public void listaPrzedmiotow()
    {
        for (int i = 0; i < przedmioty.length; i++)
        {
            System.out.println("    " + (i+1) + ". " + przedmioty[i] + ": " + stud.getGrade(i));
        }
    }

    @Override
    public String toString()
    {
        return "[" + rok + "] " + stud.toString();
    }

    public int getRok()
    {
        return rok;
    }

    public String getCourse(int i)
    {
        return przedmioty[i];
    }

    public int getCourseNumber()
    {
        return przedmioty.length;
    }
}
