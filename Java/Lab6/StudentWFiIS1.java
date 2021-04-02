public class StudentWFiIS1 extends Student implements StudentUSOS
{
    private String[] przedmioty;
    private int rok;

    public StudentWFiIS1(String name,
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
        super(name, surname, index, gradeOne, gradeTwo, gradeThree);
        przedmioty = new String[]{courseOne, courseTwo, courseThree};
        rok = year;
    }

    @Override
    public double srednia()
    {
        return super.average();
    }

    @Override
    public void listaPrzedmiotow()
    {
        for (int i = 0; i < przedmioty.length; i++)
        {
            System.out.println("    " + (i+1) + ". " + przedmioty[i] + ": " + getGrade(i));
        }
    }

    @Override
    public String toString()
    {
        return "[" + rok + "] " + super.toString();
    }

}
