import java.util.Arrays;

class Student extends Man {
	private int id;
	private double[] grades = new double[3];

	Student(String n, String s, int id, double... o) {
		super(n, s);
		this.id = id;
		for (int i = 0; i < o.length && i < grades.length; ++i)
			grades[i] = o[i];
	}

	public String toString() {
		return super.toString() + ", id number: " + id + ", grades: " + Arrays.toString(grades);
	}

	public double average() {
		double s = 0.;
		for (var el : grades)
			s += el;
		return s / grades.length;
	}

	public double getGrade(int i) {
		if (i < grades.length)
			return grades[i];
		else
			return 0;
	}
}