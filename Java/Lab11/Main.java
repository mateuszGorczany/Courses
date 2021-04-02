import java.util.*;

public class Main
{

    public static void main(String[] args)
    {
        if (args.length != 2)
            throw new IllegalArgumentException("No arguments or wrong provided!");

        int n = Integer.parseInt(args[0]);
        int m = Integer.parseInt(args[1]);

        if (n < 2 || m < 1 || m > n)
            throw new IllegalArgumentException("Wrong arguments!");

        System.out.println("Losowanie " + n + " lancuchow.");
        String[] t1 = new DrawArray(n).fillRandom()
                                      .getArray();

        String[] t2 = new DrawArray(m).fillWithStringsInArray(t1)
                                      .getArray();

        String[] t3 = new DrawArray(m).fillWithStringsNotInArray(t1)
                                      .getArray();

        ArrayList<String> arrayList = new ArrayList<>();
        LinkedList<String> linkedList = new LinkedList<>();
        TreeMap<String, Integer> treeMap = new TreeMap<>();
        HashMap<String, Integer> hashMap = new HashMap<>();

        // measurements:
        System.out.println("Testowanie dla " + m + " lancuchow.");
        System.out.print("Generate: ");
        Measurements.measureFill(t1, arrayList, linkedList, treeMap, hashMap);
        System.out.println();

        System.out.print("Poczatek, ");
        Measurements.measureSizes(arrayList, linkedList, treeMap, hashMap);

        System.out.print("Search: ");
        Measurements.measureSearch(t2, arrayList, linkedList, treeMap, hashMap);
        System.out.println();

        System.out.print("SearchNOT: ");
        Measurements.measureSearch(t3, arrayList, linkedList, treeMap, hashMap);
        Measurements.measureLoops(arrayList, linkedList);
        System.out.println();

        System.out.print("Remove: ");
        Measurements.measureRemoval(arrayList, linkedList, treeMap, hashMap);
        System.out.println();

        System.out.print("Koniec, ");
        Measurements.measureSizes(arrayList, linkedList, treeMap, hashMap);
    }
}

class Measurements
{
    static private void measurementTemplate(double arrayListTime,
                                            double linkedListTime,
                                            double treeMapTime,
                                            double hashMapTime)
    {
        System.out.println("ArrayList(" + arrayListTime + " ms), "
                        +  "LinkedList(" + linkedListTime + " ms), "
                        +  "TreeMap(" + treeMapTime + " ms), "
                        +  "HashMap(" + hashMapTime + " ms)");
    }

    static public void measureFill(String[] t1,
                                   ArrayList<String> arrayList,
                                   LinkedList<String> linkedList,
                                   TreeMap<String, Integer> treeMap,
                                   HashMap<String, Integer> hashMap)
    {
        int n = t1.length;
        long start, stop;
        double arrayListTime, linkedListTime, treeMapTime, hashMapTime;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            arrayList.add(t1[i]);
        stop = System.nanoTime();
        arrayListTime =  (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            linkedList.add(t1[i]);
        stop = System.nanoTime();
        linkedListTime = (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            treeMap.put(t1[i], 0);
        stop = System.nanoTime();
        treeMapTime = (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            hashMap.put(t1[i], 0);
        stop = System.nanoTime();
        hashMapTime = (stop - start)/1e6;

        measurementTemplate(arrayListTime, linkedListTime, treeMapTime, hashMapTime);
    }

    static public void measureSearch(String[] array,
                                     ArrayList<String> arrayList,
                                     LinkedList<String> linkedList,
                                     TreeMap<String, Integer> treeMap,
                                     HashMap<String, Integer> hashMap)
    {
        int n = array.length;
        long start, stop;
        double arrayListTime, linkedListTime, treeMapTime, hashMapTime;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            arrayList.contains(array[i]);
        stop = System.nanoTime();
        arrayListTime = (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            linkedList.contains(array[i]);
        stop = System.nanoTime();
        linkedListTime = (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            treeMap.containsKey(array[i]);
        stop = System.nanoTime();
        treeMapTime = (stop - start)/1e6;

        start = System.nanoTime();
        for(int i = 0; i < n; ++i)
            hashMap.containsKey(array[i]);
        stop = System.nanoTime();
        hashMapTime = (stop - start)/1e6;

        measurementTemplate(arrayListTime, linkedListTime, treeMapTime, hashMapTime);
    }

    static public void measureLoops(ArrayList<String> arrayList,
                                    LinkedList<String> linkedList)
    {
        long start, stop;
        double arrayListTimeFor, arrayListTimeForEach, arrayListTimeIterator,
                linkedListTimeFor, linkedListTimeForEach, linkedListTimeIterator;

        start = System.nanoTime();
        for(int i = 0; i < arrayList.size(); ++i)
            arrayList.get(i);
        stop = System.nanoTime();
        arrayListTimeFor = (stop - start)/1e6;

        start = System.nanoTime();
        for (String element: arrayList)
        stop = System.nanoTime();
        arrayListTimeForEach = (stop - start)/1e6;

        Iterator<String> arrayListIterator = arrayList.iterator();
        start = System.nanoTime();
        while(arrayListIterator.hasNext())
            arrayListIterator.next();
        stop = System.nanoTime();
        arrayListTimeIterator = (stop - start)/1e6;

        System.out.println("java.util.ArrayList: "
                        +  "for(" + arrayListTimeFor + " ms), "
                        +  "for-each(" + arrayListTimeForEach + " ms), "
                        +  "iterator(" + arrayListTimeIterator + " ms)");

        start = System.nanoTime();
        for(int i = 0; i < linkedList.size(); ++i)
            linkedList.get(i);
        stop = System.nanoTime();
        linkedListTimeFor = (stop - start)/1e6;

        start = System.nanoTime();
        for (String element: linkedList)
        stop = System.nanoTime();
        linkedListTimeForEach = (stop - start)/1e6;

        Iterator<String> linkedListIterator = linkedList.iterator();
        start = System.nanoTime();
        while(linkedListIterator.hasNext())
            linkedListIterator.next();
        stop = System.nanoTime();
        linkedListTimeIterator = (stop - start)/1e6;


        System.out.println("java.util.LinkedList: "
                        +  "for(" + linkedListTimeFor + " ms), "
                        +  "for-each(" + linkedListTimeForEach + " ms), "
                        +  "iterator(" + linkedListTimeIterator + " ms)");
    }

    static public void measureRemoval(ArrayList<String> arrayList,
                                      LinkedList<String> linkedList,
                                      TreeMap<String, Integer> treeMap,
                                      HashMap<String, Integer> hashMap)
    {
        long start, stop;
        double arrayListTime, linkedListTime, treeMapTime, hashMapTime;

        start = System.nanoTime();
        arrayList.clear();
        stop = System.nanoTime();
        arrayListTime = (stop - start)/1e6;

        start = System.nanoTime();
        linkedList.clear();
        stop = System.nanoTime();
        linkedListTime = (stop - start)/1e6;

        start = System.nanoTime();
        treeMap.clear();
        stop = System.nanoTime();
        treeMapTime = (stop - start)/1e6;

        start = System.nanoTime();
        hashMap.clear();
        stop = System.nanoTime();
        hashMapTime = (stop - start)/1e6;

        measurementTemplate(arrayListTime, linkedListTime, treeMapTime, hashMapTime);

    }

    static public void measureSizes(ArrayList<String> arrayList,
                                    LinkedList<String> linkedList,
                                    TreeMap<String, Integer> treeMap,
                                    HashMap<String, Integer> hashMap)
    {
        System.out.println("rozmiary: "
                        +  arrayList.size() + " "
                        +  linkedList.size() + " "
                        +  treeMap.size() + " "
                        +  hashMap.size() );
    }

}

class DrawString
{
    private final int leftBound = 5;
    private final int rightBound = 20;
    private final int range;
    private Random random;

    DrawString()
    {
        range = rightBound - leftBound;
        random = new Random();
    }

    private char[] randomLenArray()
    {
        int randLength = random.nextInt(range) + leftBound;
        char[] randomString = new char[randLength];
        return randomString;
    }

    public String generateString()
    {
        char[] array = randomLenArray();
        char[] eligibleChars = "QWERTYUIOPASDFGHJKLZXCVBNM".toCharArray();
        double threshold = 0.5;

        for(int i = 0; i < array.length; ++i)
        {
            int randomIndex = random.nextInt(eligibleChars.length);
            boolean toLower = random.nextDouble() < threshold;

            array[i] = eligibleChars[randomIndex];
            if(toLower)
                array[i] = java.lang.Character.toLowerCase(array[i]);
        }

        return new String(array);
    }
}

class DrawArray
{
    String[] array;

    DrawArray(int len)
    {
        array = new String[len];
    }

    public DrawArray fillRandom()
    {
        DrawString generator = new DrawString();
        for(int i = 0; i < array.length; ++i)
        {
            array[i] = generator.generateString();
        }

        return this;
    }

    public DrawArray fillWithStringsInArray(String[] sarray)
    {
        Random random = new Random();
        int randomIndex;

        for(int i = 0; i < array.length; ++i)
        {
            randomIndex = random.nextInt(sarray.length);
            array[i] = sarray[randomIndex];
        }

        return this;
    }

    public DrawArray fillWithStringsNotInArray(String[] sarray)
    {
        DrawString generator = new DrawString();
        Set<String> stringSet = Set.of(sarray);
        for(int i = 0; i < array.length; ++i)
        {
            String string = generator.generateString();
            if(stringSet.contains(string))
                --i;
            else
                array[i] = string;
        }

        return this;
    }

    String[] getArray() { return array; }
}