package dao.administrador;

import modelo.Alumno;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOAlumno
{
    // Incluye EstadoCuenta: si ya tiene IdUsuario vinculado, "Activo"/lo que diga usuarios.Estado;
    // si IdUsuario es NULL, el alumno está pre-registrado pero aún no se auto-registró -> "Pendiente".
    public List<Alumno> listar()
    {
        List<Alumno> alumnos = new ArrayList<>();
        String sql = "SELECT a.*, c.Carrera AS nombreCarrera, " +
                     "COALESCE(u.Estado, 'Pendiente') AS estadoCuenta " +
                     "FROM alumnos a " +
                     "JOIN carreras c ON a.IdCarrera = c.IdCarrera " +
                     "LEFT JOIN usuarios u ON a.IdUsuario = u.IdUsuario " +
                     "ORDER BY a.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                alumnos.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return alumnos;
    }

    public Alumno obtenerPorMatricula(String matricula)
    {
        Alumno alumno = null;
        String sql = "SELECT a.*, c.Carrera AS nombreCarrera, " +
                     "COALESCE(u.Estado, 'Pendiente') AS estadoCuenta " +
                     "FROM alumnos a " +
                     "JOIN carreras c ON a.IdCarrera = c.IdCarrera " +
                     "LEFT JOIN usuarios u ON a.IdUsuario = u.IdUsuario " +
                     "WHERE a.Matricula = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, matricula);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { alumno = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return alumno;
    }

    // Pre-registro: crea la fila en "alumnos" SIN cuenta de usuario todavía.
    // El alumno se auto-registrará después haciendo match por Matricula+Correo
    // (flujo que ya maneja tu SRegistrarUsuario).
    public boolean insertar(Alumno alumno)
    {
        String sql = "INSERT INTO alumnos (Matricula, Nombre, Paterno, Materno, Correo, FechaRegistro, IdCarrera) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, alumno.getMatricula());
            ps.setString(2, alumno.getNombre());
            ps.setString(3, alumno.getPaterno());
            ps.setString(4, alumno.getMaterno());
            ps.setString(5, alumno.getCorreo());
            ps.setInt(6, alumno.getIdCarrera());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Alumno alumno)
    {
        String sql = "UPDATE alumnos SET Matricula = ?, Nombre = ?, Paterno = ?, Materno = ?, Correo = ?, IdCarrera = ? WHERE IdAlumno = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, alumno.getMatricula());
            ps.setString(2, alumno.getNombre());
            ps.setString(3, alumno.getPaterno());
            ps.setString(4, alumno.getMaterno());
            ps.setString(5, alumno.getCorreo());
            ps.setInt(6, alumno.getIdCarrera());
            ps.setInt(7, alumno.getIdAlumno());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminarPorMatricula(String matricula)
    {
        // Si el alumno ya tiene cuenta (IdUsuario), lo correcto es eliminar desde "usuarios"
        // para que el cascade limpie todo. Si aún no tiene cuenta, se borra directo de "alumnos".
        String sqlBuscarUsuario = "SELECT IdUsuario FROM alumnos WHERE Matricula = ?";
        try (Connection conn = ConexionMySQL.getConnection())
        {
            Integer idUsuario = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlBuscarUsuario))
            {
                ps.setString(1, matricula);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next())
                    {
                        int val = rs.getInt("IdUsuario");
                        if (!rs.wasNull()) { idUsuario = val; }
                    }
                }
            }

            String sqlDelete = (idUsuario != null)
                ? "DELETE FROM usuarios WHERE IdUsuario = ?"
                : "DELETE FROM alumnos WHERE Matricula = ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlDelete))
            {
                if (idUsuario != null) { ps.setInt(1, idUsuario); }
                else { ps.setString(1, matricula); }
                return ps.executeUpdate() > 0;
            }
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Alumno mapear(ResultSet rs) throws SQLException
    {
        Alumno a = new Alumno();
        a.setIdAlumno(rs.getInt("IdAlumno"));
        a.setMatricula(rs.getString("Matricula"));
        a.setNombre(rs.getString("Nombre"));
        a.setPaterno(rs.getString("Paterno"));
        a.setMaterno(rs.getString("Materno"));
        a.setCorreo(rs.getString("Correo"));
        a.setIdCarrera(rs.getInt("IdCarrera"));
        int idUsuario = rs.getInt("IdUsuario");
        a.setIdUsuario(rs.wasNull() ? 0 : idUsuario);
        int idGrupo = rs.getInt("IdGrupo");
        a.setIdGrupo(rs.wasNull() ? 0 : idGrupo);
        return a;
    }
}