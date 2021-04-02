public class StudentWFiIS3 extends Student
{
    private StudentUSOS stud;

    StudentWFiIS3(String name,
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
        stud = new StudentWFiIS2(year, courseOne, courseTwo, courseThree);
    }

    public double srednia()
    {
        return super.average();
    }

    public void listaPrzedmiotow()
    {
        for (int i = 0; i < ((StudentWFiIS2)stud).getCourseNumber(); i++)
        {
            System.out.println("    " + (i+1) + ". " + ((StudentWFiIS2)stud).getCourse(i) + ": " + super.getGrade(i));
        }
    }

    @Override
    public String toString()
    {
        return "[" + ((StudentWFiIS2)stud).getRok() + "] " + super.toString();
    }
}