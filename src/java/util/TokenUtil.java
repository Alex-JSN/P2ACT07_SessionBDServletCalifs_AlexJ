package util;

import java.security.SecureRandom;
import java.util.UUID;

public class TokenUtil
{
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String generarToken()
    {
        return UUID.randomUUID().toString();
    }

    public static String generarCodigo()
    {
        int numero = RANDOM.nextInt(1_000_000);
        return String.format("%06d", numero);
    }

    public static final int MINUTOS_EXPIRACION = 15;
}