package helpers;

import java.security.SecureRandom;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Generates dynamic, unique test data.
 * Unique data avoids collisions on the shared public API (for example, a duplicate email).
 */
public final class DataGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALFANUMERICO =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    private static final String[] NOMBRES = {
            "Lucía", "Mateo", "Valentina", "Santiago", "Camila", "Sebastián",
            "Isabella", "Diego", "Mariana", "Andrés", "Daniela", "Gabriel"
    };
    private static final String[] APELLIDOS = {
            "García", "Rodríguez", "Martínez", "López", "Torres", "Ramírez",
            "Flores", "Rojas", "Vargas", "Castillo", "Mendoza", "Quispe"
    };

    private DataGenerator() {
    }

    public static String nombre() {
        return NOMBRES[RANDOM.nextInt(NOMBRES.length)] + " "
                + APELLIDOS[RANDOM.nextInt(APELLIDOS.length)];
    }

    /** Unique email: qa.<uuid>@serverest-qa.com */
    public static String email() {
        String unico = UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        return "qa." + unico + "@serverest-qa.com";
    }

    public static String password() {
        return "Qa" + alfanumerico(10);
    }

    /** Valid user payload for POST/PUT /usuarios. */
    public static Map<String, Object> usuario(boolean administrador) {
        Map<String, Object> usuario = new LinkedHashMap<>();
        usuario.put("nome", nombre());
        usuario.put("email", email());
        usuario.put("password", password());
        usuario.put("administrador", String.valueOf(administrador));
        return usuario;
    }

    public static Map<String, Object> usuarioAdministrador() {
        return usuario(true);
    }

    public static Map<String, Object> usuarioComun() {
        return usuario(false);
    }

    /** ID with a valid format (16 alphanumeric characters) that does not exist. */
    public static String idInexistente() {
        return alfanumerico(16);
    }

    /** Valid product payload (used to prepare a cart). */
    public static Map<String, Object> producto() {
        Map<String, Object> producto = new LinkedHashMap<>();
        producto.put("nome", "Producto QA " + UUID.randomUUID().toString().substring(0, 8));
        producto.put("preco", 100 + RANDOM.nextInt(900));
        producto.put("descricao", "Producto generado por la suite de pruebas automatizadas");
        producto.put("quantidade", 50);
        return producto;
    }

    private static String alfanumerico(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(ALFANUMERICO.charAt(RANDOM.nextInt(ALFANUMERICO.length())));
        }
        return sb.toString();
    }
}
