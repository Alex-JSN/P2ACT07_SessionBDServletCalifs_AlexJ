package dao;

import conexion.ConexionMySQL;
import modelo.Usuario;
import util.PasswordUtil;
import util.TokenUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class DAOUsuario {

    /**
     * Registra un nuevo usuario en la base de datos. - El primer usuario
     * siempre es Administrador y se crea con estado 'Activo'. - Los alumnos se
     * crean con estado 'Inactivo' y se les genera un token de verificación. -
     * Si el alumno no existe en la tabla 'alumnos', lanza
     * AlumnoNoEncontradoException.
     *
     * @return el token de activación si el estado es 'Inactivo', o null si es
     * 'Activo'.
     */
    public String registrar(Usuario usuario) throws SQLException, CorreoDuplicadoException, MatriculaDuplicadaException, AlumnoNoEncontradoException {
        System.out.println("=== INICIO REGISTRO ===");
        System.out.println("Matricula: " + usuario.getMatricula());
        System.out.println("Correo: " + usuario.getCorreo());

        if (existeCorreo(usuario.getCorreo())) {
            throw new CorreoDuplicadoException("Ya existe una cuenta registrada con ese correo.");
        }

        boolean esPrimerUsuario = esPrimerRegistro();
        System.out.println("¿Es primer usuario?: " + esPrimerUsuario);

        Integer idAlumno = null;
        String estadoInicial;
        String tipoUsuario;

        if (esPrimerUsuario) {
            estadoInicial = "Activo";
            tipoUsuario = "Administrador";
            idAlumno = null;
            System.out.println("PRIMER USUARIO - Administrador creado sin validación de matrícula");
        } else {
            // Buscar al alumno en la tabla alumnos (debe existir previamente)
            idAlumno = buscarIdAlumnoPorMatriculaYCorreo(usuario.getMatricula(), usuario.getCorreo());
            if (idAlumno == null) {
                throw new AlumnoNoEncontradoException(
                        "La matrícula y/o el correo no coinciden con ningún alumno registrado. "
                        + "Verifica tus datos o contacta al administrador.");
            }
            tipoUsuario = "Alumno";
            // Siempre inactivo hasta que verifique su correo (o el administrador lo active)
            estadoInicial = "Inactivo";
            System.out.println("ALUMNO - IdAlumno: " + idAlumno + ", Estado: " + estadoInicial);

            // Validar que la matrícula no esté ya registrada en usuarios
            if (existeMatricula(usuario.getMatricula())) {
                throw new MatriculaDuplicadaException("Ya existe una cuenta registrada con esa matrícula.");
            }
        }

        String hash = PasswordUtil.hashear(usuario.getContrasena());

        String codigo = null;
        Timestamp expiracion = null;

        if ("Inactivo".equals(estadoInicial)) {
            codigo = TokenUtil.generarCodigo();
            expiracion = Timestamp.valueOf(LocalDateTime.now().plusMinutes(TokenUtil.MINUTOS_EXPIRACION));
            System.out.println("Token generado para verificación: " + codigo);
        } else {
            System.out.println("Usuario con estado '" + estadoInicial + "' - No se genera token");
        }

        // COLUMNAS REALES DE LA TABLA usuarios:
        // Matricula, Nombre, Paterno, Materno, Correo, Contrasena, TipoUsuario,
        // Estado, EsProtegido, TokenActivacion, TokenExpiracion, RequiereCambioContrasena, FechaRegistro
        String sql = "INSERT INTO usuarios "
                + "(Matricula, Nombre, Paterno, Materno, Correo, Contrasena, TipoUsuario, "
                + "Estado, EsProtegido, TokenActivacion, TokenExpiracion, RequiereCambioContrasena, FechaRegistro) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            // 1. Matricula
            if (esPrimerUsuario) {
                ps.setString(1, "ADMIN"); // Matrícula especial para el administrador
            } else {
                ps.setString(1, usuario.getMatricula());
            }
            // 2. Nombre
            ps.setString(2, usuario.getNombre());
            // 3. Paterno
            ps.setString(3, usuario.getPaterno());
            // 4. Materno
            ps.setString(4, usuario.getMaterno());
            // 5. Correo
            ps.setString(5, usuario.getCorreo());
            // 6. Contrasena (hash)
            ps.setString(6, hash);
            // 7. TipoUsuario
            ps.setString(7, tipoUsuario);
            // 8. Estado
            ps.setString(8, estadoInicial);
            // 9. EsProtegido (boolean)
            ps.setBoolean(9, esPrimerUsuario);
            // 10. TokenActivacion (puede ser null)
            if ("Inactivo".equals(estadoInicial)) {
                ps.setString(10, codigo);
            } else {
                ps.setNull(10, java.sql.Types.VARCHAR);
            }
            // 11. TokenExpiracion (puede ser null)
            if ("Inactivo".equals(estadoInicial)) {
                ps.setTimestamp(11, expiracion);
            } else {
                ps.setNull(11, java.sql.Types.TIMESTAMP);
            }
            // 12. RequiereCambioContrasena (por defecto false)
            ps.setBoolean(12, false);

            int filas = ps.executeUpdate();
            System.out.println("Filas insertadas en usuarios: " + filas);

            // Obtener el IdUsuario generado
            int idUsuarioGenerado = 0;
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    idUsuarioGenerado = generatedKeys.getInt(1);
                    System.out.println("IdUsuario generado: " + idUsuarioGenerado);
                }
            }

            // Si es alumno (no admin), actualizar la tabla alumnos con el IdUsuario
            if (!esPrimerUsuario && idAlumno != null && idUsuarioGenerado > 0) {
                String updateAlumno = "UPDATE alumnos SET IdUsuario = ? WHERE IdAlumno = ?";
                try (PreparedStatement psUpdate = con.prepareStatement(updateAlumno)) {
                    psUpdate.setInt(1, idUsuarioGenerado);
                    psUpdate.setInt(2, idAlumno);
                    int rows = psUpdate.executeUpdate();
                    System.out.println("Vinculado alumno (IdAlumno=" + idAlumno + ") con usuario (IdUsuario=" + idUsuarioGenerado + "). Filas actualizadas: " + rows);
                }
            }

            System.out.println("=== FIN REGISTRO ===");
        } catch (SQLException e) {
            System.err.println("Error SQL al registrar: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }

        return "Activo".equals(estadoInicial) ? null : codigo;
    }

    /**
     * Verifica si es el primer registro de usuario en la base de datos.
     */
    public boolean esPrimerRegistro() throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios";
        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) == 0;
            }
            return true;
        }
    }

    /**
     * Busca el IdAlumno a partir de la matrícula y correo en la tabla alumnos.
     */
    private Integer buscarIdAlumnoPorMatriculaYCorreo(String matricula, String correo) throws SQLException {
        String sql = "SELECT IdAlumno FROM alumnos WHERE Matricula = ? AND Correo = ?";
        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, matricula);
            ps.setString(2, correo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("IdAlumno");
                }
                return null;
            }
        }
    }

    /**
     * Autentica a un usuario por correo y contraseña.
     */
    public Usuario autenticar(String correo, String contrasenaPlana) throws SQLException, CredencialesInvalidasException, CuentaInactivaException, CuentaRechazadaException {
        String sql = "SELECT * FROM usuarios WHERE Correo = ? LIMIT 1";

        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new CredencialesInvalidasException("Correo o contraseña incorrectos.");
                }

                String hashGuardado = rs.getString("Contrasena");
                if (!PasswordUtil.verificar(contrasenaPlana, hashGuardado)) {
                    throw new CredencialesInvalidasException("Correo o contraseña incorrectos.");
                }

                String estado = rs.getString("Estado");

                if ("Rechazado".equals(estado)) {
                    throw new CuentaRechazadaException("Tu cuenta fue rechazada por un administrador.");
                }

                if ("Inactivo".equals(estado)) {
                    throw new CuentaInactivaException("Tu cuenta aún no está verificada. Revisa el código que enviamos a tu correo.");
                }

                return mapearUsuario(rs);
            }
        }
    }

    /**
     * Verifica el código de activación de una cuenta.
     */
    public ResultadoVerificacion verificarCodigo(String correo, String codigoIngresado) throws SQLException {
        // IMPORTANTE: la columna en la BD se llama TokenExpiracion, no FechaExpiracionToken
        String sqlSelect = "SELECT IdUsuario, TokenActivacion, TokenExpiracion, Estado FROM usuarios WHERE Correo = ?";
        String sqlUpdate = "UPDATE usuarios SET Estado = 'Activo', FechaActivacion = NOW(), "
                + "TokenActivacion = NULL, TokenExpiracion = NULL WHERE IdUsuario = ?";

        try (Connection con = ConexionMySQL.getConnection()) {
            int idUsuario;
            String tokenGuardado;
            Timestamp expiracion;
            String estado;

            try (PreparedStatement ps = con.prepareStatement(sqlSelect)) {
                ps.setString(1, correo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return ResultadoVerificacion.CORREO_NO_ENCONTRADO;
                    }
                    idUsuario = rs.getInt("IdUsuario");
                    tokenGuardado = rs.getString("TokenActivacion");
                    expiracion = rs.getTimestamp("TokenExpiracion"); // CORREGIDO
                    estado = rs.getString("Estado");
                }
            }

            if ("Activo".equals(estado)) {
                return ResultadoVerificacion.YA_ACTIVA;
            }
            if (tokenGuardado == null || !tokenGuardado.equals(codigoIngresado)) {
                return ResultadoVerificacion.CODIGO_INCORRECTO;
            }
            if (expiracion == null || expiracion.before(new Timestamp(System.currentTimeMillis()))) {
                return ResultadoVerificacion.CODIGO_EXPIRADO;
            }

            try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                ps.setInt(1, idUsuario);
                ps.executeUpdate();
            }

            return ResultadoVerificacion.EXITO;
        }
    }

    /**
     * Reenvía un nuevo código de activación al correo del usuario.
     */
    public String[] reenviarCodigo(String correo) throws SQLException {
        String sqlSelect = "SELECT IdUsuario, Estado, Nombre FROM usuarios WHERE Correo = ?";
        String sqlUpdate = "UPDATE usuarios SET TokenActivacion = ?, TokenExpiracion = ? WHERE IdUsuario = ?";

        try (Connection con = ConexionMySQL.getConnection()) {
            int idUsuario;
            String estado;
            String nombre;

            try (PreparedStatement ps = con.prepareStatement(sqlSelect)) {
                ps.setString(1, correo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    idUsuario = rs.getInt("IdUsuario");
                    estado = rs.getString("Estado");
                    nombre = rs.getString("Nombre");
                }
            }

            if ("Activo".equals(estado)) {
                return null;
            }

            String nuevoCodigo = TokenUtil.generarCodigo();
            Timestamp expiracion = Timestamp.valueOf(LocalDateTime.now().plusMinutes(TokenUtil.MINUTOS_EXPIRACION));

            try (PreparedStatement ps = con.prepareStatement(sqlUpdate)) {
                ps.setString(1, nuevoCodigo);
                ps.setTimestamp(2, expiracion);
                ps.setInt(3, idUsuario);
                ps.executeUpdate();
            }

            return new String[]{nuevoCodigo, nombre};
        }
    }

    /**
     * Activa una cuenta por parte del administrador (sin código de
     * verificación).
     */
    public boolean activarPorAdministrador(int idUsuario) throws SQLException {
        String sql = "UPDATE usuarios SET Estado = 'Activo', FechaActivacion = NOW(), "
                + "TokenActivacion = NULL, TokenExpiracion = NULL WHERE IdUsuario = ?";

        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);
            return ps.executeUpdate() == 1;
        }
    }

    // ==================== MÉTODOS PRIVADOS AUXILIARES ====================
    private boolean existeCorreo(String correo) throws SQLException {
        String sql = "SELECT 1 FROM usuarios WHERE Correo = ?";
        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean existeMatricula(String matricula) throws SQLException {
        String sql = "SELECT 1 FROM usuarios WHERE Matricula = ?";
        try (Connection con = ConexionMySQL.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, matricula);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("IdUsuario"));
        u.setMatricula(rs.getString("Matricula"));
        u.setNombre(rs.getString("Nombre"));
        u.setPaterno(rs.getString("Paterno"));
        u.setMaterno(rs.getString("Materno"));
        u.setCorreo(rs.getString("Correo"));
        u.setEstado(rs.getString("Estado"));
        u.setTipoUsuario(rs.getString("TipoUsuario"));
        u.setEsProtegido(rs.getInt("EsProtegido") == 1);
        u.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
        u.setFechaActivacion(rs.getTimestamp("FechaActivacion"));
        // También podemos setear TokenExpiracion si lo necesitamos
        u.setTokenExpiracion(rs.getTimestamp("TokenExpiracion"));
        return u;
    }

    // ==================== ENUMS Y EXCEPCIONES ====================
    public enum ResultadoVerificacion {
        EXITO, CODIGO_INCORRECTO, CODIGO_EXPIRADO, YA_ACTIVA, CORREO_NO_ENCONTRADO
    }

    public static class CorreoDuplicadoException extends Exception {

        public CorreoDuplicadoException(String m) {
            super(m);
        }
    }

    public static class MatriculaDuplicadaException extends Exception {

        public MatriculaDuplicadaException(String m) {
            super(m);
        }
    }

    public static class AlumnoNoEncontradoException extends Exception {

        public AlumnoNoEncontradoException(String m) {
            super(m);
        }
    }

    public static class CredencialesInvalidasException extends Exception {

        public CredencialesInvalidasException(String m) {
            super(m);
        }
    }

    public static class CuentaInactivaException extends Exception {

        public CuentaInactivaException(String m) {
            super(m);
        }
    }

    public static class CuentaRechazadaException extends Exception {

        public CuentaRechazadaException(String m) {
            super(m);
        }
    }
}
