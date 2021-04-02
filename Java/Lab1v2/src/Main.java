import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Main {

    public static void main(String[] args)
    {
        if (args.length == 0)
            throw new RuntimeException("No arguments provided.");

        RSA rsa = new RSA(397, 103);
        var publicKey = rsa.getPublicKey();
        var privateKey = rsa.getPrivateKey();
        System.out.println(
                "Klucz publiczny: "
                 + publicKey.toString()
                 + "\nKlucz prywatny: "
                 + privateKey.toString()
                 + "\n"
                );

        MessageEncryptor encryptor = new MessageEncryptor(publicKey);
        System.out.println("Zakodowana wiadomość:");
        var message = encryptor.encrypt(args[0]);
        System.out.println(message);

        var decryptor = new MessageDecryptor(privateKey);
        System.out.println("Zdekodowana wiadomość:");
        System.out.println(decryptor.decrypt(message));
    }
}

class MessageDecryptor
{
    private final Map<String, BigInteger> privateKey;

    MessageDecryptor(Map<String, BigInteger> privateKey)
    {
        this.privateKey = privateKey;
    }

    public String decrypt(String encryptedMessage)
    {
        ArrayList<Character> messageArray = new ArrayList<>();
        for(int i = 0; i < encryptedMessage.length(); ++i)
        {
            int letterAsInt= encryptedMessage.charAt(i);
            var letterAsBigInt= BigInteger.valueOf(letterAsInt);
            var decryptedLetter = letterAsBigInt.
                    modPow(privateKey.get("d"), privateKey.get("n")).
                    intValue();

            messageArray.add((char)decryptedLetter);
        }

        StringBuilder builder = new StringBuilder(messageArray.size());

        for(Character ch: messageArray)
            builder.append(ch);

        return builder.toString();
    }
}

class MessageEncryptor
{
    private final Map<String, BigInteger> publicKey;

    MessageEncryptor(Map<String, BigInteger> publicKey)
    {
        this.publicKey = publicKey;
    }

    public String encrypt(String message)
    {
        ArrayList<Character> messageArray = new ArrayList<>();
        for(int i = 0; i < message.length(); ++i)
        {
            int letterAsInt= message.charAt(i);
            var letterAsBigInt= BigInteger.valueOf(letterAsInt);
            var encryptedLetter = letterAsBigInt.
                    modPow(publicKey.get("e"), publicKey.get("n")).
                    intValue();

            messageArray.add((char)encryptedLetter);
        }

        StringBuilder builder = new StringBuilder(messageArray.size());

        for(Character ch: messageArray)
            builder.append(ch);

        return builder.toString();
    }
}

class RSA
{
    private final BigInteger phi;
    BigInteger n;
    BigInteger e;
    BigInteger d;

    RSA(int p_val, int q_val)
    {
        BigInteger p = BigInteger.valueOf(p_val);
        BigInteger q = BigInteger.valueOf(q_val);
        n = p.multiply(q);
        phi = p.subtract(BigInteger.ONE).
                multiply( q.subtract(BigInteger.ONE) );
        e = findE();
        d = extendedEuclidAlgorithm(e, phi);

    }

    private BigInteger findE()
    {
        BigInteger gcd = BigInteger.ZERO;
        BigInteger te = BigInteger.ONE;

        while(!gcd.equals(BigInteger.ONE))
        {
            te = te.add(BigInteger.TWO);
            gcd = phi.gcd(te);
        }

        return te;
    }

    private BigInteger extendedEuclidAlgorithm(BigInteger a, BigInteger b)
    {
        var x0 = BigInteger.ONE;
        var x = BigInteger.ZERO;
        var b0 = b;
        BigInteger q;

        while(!b.equals(BigInteger.ZERO))
        {
            q = a.divide(b);
            var tmp = x;
            x = x0.subtract(q.multiply(x));
            x0 = tmp;
            tmp = a.mod(b);
            a = b;
            b = tmp;
        }

        if(x0.compareTo(BigInteger.ZERO) < 0)
        {
            x0 = x0.add(b0);
        }

        return x0;
    }

    public Map<String, BigInteger> getPublicKey()
    {
        Map<String, BigInteger> publicKey = new HashMap<>();
        publicKey.put("e", e);
        publicKey.put("n", n);

        return publicKey;
    }

    public Map<String, BigInteger> getPrivateKey()
    {
        Map<String, BigInteger> privateKey = new HashMap<>();
        privateKey.put("d", d);
        privateKey.put("n", n);

        return privateKey;
    }
}