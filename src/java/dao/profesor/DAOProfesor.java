package dao.profesor;

import modelo.Profesor;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOProfesor
{
    public List<Profesor> listar()
    {
        List<Profesor> profesores = new ArrayList<>();
        String sql = "SELECT p.*, u.Matricula, u.Correo, u.Estado FROM profesores p " +
                     "JOIN usuarios u ON p.IdUsuario = u.IdUsuario " +
                     "ORDER BY p.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                profesores.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return profesores;
    }

    public Profesor obtenerPorId(int idProfesor)
    {
        Profesor profesor = null;
        String sql = "SELECT p.*, u.Matricula, u.Correo, u.Estado FROM profesores p " +
                     "JOIN usuarios u ON p.IdUsuario = u.IdUsuario " +
                     "WHERE p.IdProfesor = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idProfesor);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { profesor = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return profesor;
    }

    // Inserta en usuarios + profesores dentro de una sola transacción.
    // Si falla el segundo insert, se revierte el primero (no queda usuario huérfano).
    public boolean insertar(Profesor profesor, String matricula, String correo)
    {
        String sqlUsuario = "INSERT INTO usuarios " +
            "(Matricula, Nombre, Paterno, Materno, Correo, Contrasena, TipoUsuario, Estado, EsProtegido, FechaRegistro, RequiereCambioContrasena) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'Profesor', 'Activo', 0, NOW(), 1)";
        String sqlProfesor = "INSERT INTO profesores (Nombre, Paterno, Materno, Cedula, IdUsuario) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        try
        {
            conn = ConexionMySQL.getConnection();
            conn.setAutoCommit(false);

            int idUsuarioGenerado;
            try (PreparedStatement psUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS))
            {
                psUsuario.setString(1, matricula);
                psUsuario.setString(2, profesor.getNombre());
                psUsuario.setString(3, profesor.getPaterno());
                psUsuario.setString(4, profesor.getMaterno());
                psUsuario.setString(5, correo);
                // TODO: alinear con el hash de contraseñas que uses en SRegistrarUsuario.
                // Por ahora: contraseña temporal = matrícula, con cambio obligatorio al primer login.
                psUsuario.setString(6, matricula);
                psUsuario.executeUpdate();

                try (ResultSet rs = psUsuario.getGeneratedKeys())
                {
                    if (!rs.next()) { conn.rollback(); return false; }
                    idUsuarioGenerado = rs.getInt(1);
                }
            }

            try (PreparedStatement psProfesor = conn.prepareStatement(sqlProfesor))
            {
                psProfesor.setString(1, profesor.getNombre());
                psProfesor.setString(2, profesor.getPaterno());
                psProfesor.setString(3, profesor.getMaterno());
                psProfesor.setString(4, profesor.getCedula());
                psProfesor.setInt(5, idUsuarioGenerado);
                psProfesor.executeUpdate();
            }

            conn.commit();
            return true;
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            return false;
        }
        finally
        {
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); } }
        }
    }

    // Actualiza datos propios de profesor + datos básicos del usuario asociado (nombre/correo).
    public boolean actualizar(Profesor profesor, String correo)
    {
        String sqlProfesor = "UPDATE profesores SET Nombre = ?, Paterno = ?, Materno = ?, Cedula = ? WHERE IdProfesor = ?";
        String sqlUsuario = "UPDATE usuarios SET Nombre = ?, Paterno = ?, Materno = ?, Correo = ? WHERE IdUsuario = ?";

        Connection conn = null;
        try
        {
            conn = ConexionMySQL.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sqlProfesor))
            {
                ps.setString(1, profesor.getNombre());
                ps.setString(2, profesor.getPaterno());
                ps.setString(3, profesor.getMaterno());
                ps.setString(4, profesor.getCedula());
                ps.setInt(5, profesor.getIdProfesor());
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlUsuario))
            {
                ps.setString(1, profesor.getNombre());
                ps.setString(2, profesor.getPaterno());
                ps.setString(3, profesor.getMaterno());
                ps.setString(4, correo);
                ps.setInt(5, profesor.getIdUsuario());
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            if (conn != null) { try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } }
            return false;
        }
        finally
        {
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); } }
        }
    }

    // Se elimina por IdUsuario: el ON DELETE CASCADE en profesores.IdUsuario
    // se encarga de borrar también la fila de "profesores" y sus "asigna".
    public boolean eliminar(int idUsuario)
    {
        String sql = "DELETE FROM usuarios WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idUsuario);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Profesor mapear(ResultSet rs) throws SQLException
    {
        Profesor p = new Profesor();
        p.setIdProfesor(rs.getInt("IdProfesor"));
        p.setNombre(rs.getString("Nombre"));
        p.setPaterno(rs.getString("Paterno"));
        p.setMaterno(rs.getString("Materno"));
        p.setCedula(rs.getString("Cedula"));
        p.setIdUsuario(rs.getInt("IdUsuario"));
        p.setMatricula(rs.getString("Matricula"));
        p.setCorreo(rs.getString("Correo"));
        p.setEstado(rs.getString("Estado"));
        return p;
    }
}