package dao.administrador;

import modelo.Usuario;
import modelo.Calificacion;
import modelo.Materia;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOAdministrador
{
    // ============================================================
    // USUARIOS
    // ============================================================

    public List<Usuario> obtenerTodosLosUsuariosAlumnos()
    {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios WHERE TipoUsuario = 'Alumno' ORDER BY Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                usuarios.add(mapearUsuario(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return usuarios;
    }

    public Usuario obtenerUsuarioPorMatricula(String matricula)
    {
        Usuario usuario = null;
        String sql = "SELECT * FROM usuarios WHERE Matricula = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, matricula);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { usuario = mapearUsuario(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return usuario;
    }

    private Usuario mapearUsuario(ResultSet rs) throws SQLException
    {
        Usuario usuario = new Usuario();
        usuario.setIdUsuario(rs.getInt("IdUsuario"));
        usuario.setMatricula(rs.getString("Matricula"));
        usuario.setNombre(rs.getString("Nombre"));
        usuario.setPaterno(rs.getString("Paterno"));
        usuario.setMaterno(rs.getString("Materno"));
        usuario.setCorreo(rs.getString("Correo"));
        usuario.setTipoUsuario(rs.getString("TipoUsuario"));
        usuario.setEstado(rs.getString("Estado"));
        usuario.setEsProtegido(rs.getBoolean("EsProtegido"));
        usuario.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
        usuario.setFechaActivacion(rs.getTimestamp("FechaActivacion"));
        return usuario;
    }

    // Se actualiza por IdUsuario (viene oculto en el form de edición,
    // porque la Matricula puede cambiar y no sirve como llave estable ahí).
    public boolean actualizarUsuario(Usuario usuario)
    {
        String sql = "UPDATE usuarios SET Matricula = ?, Nombre = ?, Paterno = ?, Materno = ?, Correo = ? WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, usuario.getMatricula());
            ps.setString(2, usuario.getNombre());
            ps.setString(3, usuario.getPaterno());
            ps.setString(4, usuario.getMaterno());
            ps.setString(5, usuario.getCorreo());
            ps.setInt(6, usuario.getIdUsuario());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean cambiarEstadoPorMatricula(String matricula, String nuevoEstado)
    {
        String sql = "UPDATE usuarios SET Estado = ? WHERE Matricula = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, nuevoEstado);
            ps.setString(2, matricula);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminarUsuarioPorMatricula(String matricula)
    {
        // ON DELETE CASCADE en las FK se encarga de alumnos, inscripcion, calificaciones, etc.
        String sql = "DELETE FROM usuarios WHERE Matricula = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, matricula);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ============================================================
    // MATERIAS
    // ============================================================

    public List<Materia> obtenerTodasLasMaterias()
    {
        List<Materia> materias = new ArrayList<>();
        String sql = "SELECT * FROM materias ORDER BY Materia ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                Materia materia = new Materia();
                materia.setIdMateria(rs.getInt("IdMateria"));
                materia.setMateria(rs.getString("Materia"));
                materia.setCuatrimestre(rs.getInt("Cuatrimestre"));
                materia.setIdCarrera(rs.getInt("IdCarrera"));
                materias.add(materia);
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return materias;
    }

    // ============================================================
    // CALIFICACIONES (keyed por Matricula del alumno)
    // ============================================================

    public List<Calificacion> obtenerCalificacionesPorMatricula(String matricula)
    {
        List<Calificacion> calificaciones = new ArrayList<>();
        String sql =
            "SELECT c.*, m.IdMateria AS idMateriaJoin, m.Materia AS nombreMateria, p.Nombre AS nombrePeriodo " +
            "FROM calificaciones c " +
            "JOIN inscripcion i ON c.IdInscripcion = i.IdInscripcion " +
            "JOIN periodos p ON i.IdPeriodo = p.IdPeriodo " +
            "JOIN alumnos a ON i.IdAlumno = a.IdAlumno " +
            "JOIN asigna asg ON c.IdAsigna = asg.IdAsigna " +
            "JOIN materias m ON asg.IdMateria = m.IdMateria " +
            "WHERE a.Matricula = ? " +
            "ORDER BY m.Materia ASC, c.FechaRegistro DESC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, matricula);
            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    Calificacion calif = new Calificacion();
                    calif.setParcial1(rs.getDouble("Parcial1"));
                    calif.setParcial2(rs.getDouble("Parcial2"));
                    calif.setParcial3(rs.getDouble("Parcial3"));
                    calif.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
                    calif.setFechaModificacion(rs.getTimestamp("FechaModificacion"));
                    calif.setIdInscripcion(rs.getInt("IdInscripcion"));
                    calif.setIdAsigna(rs.getInt("IdAsigna"));
                    calif.setIdMateria(rs.getInt("idMateriaJoin"));
                    calif.setNombreMateria(rs.getString("nombreMateria"));
                    calif.setNombrePeriodo(rs.getString("nombrePeriodo"));
                    calif.setMatriculaAlumno(matricula);
                    calificaciones.add(calif);
                }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return calificaciones;
    }

    public boolean guardarCalificacion(String matricula, int idMateria, String nombrePeriodo, Double p1, Double p2, Double p3)
    {
        String sqlGetInscripcion =
            "SELECT i.IdInscripcion FROM inscripcion i " +
            "JOIN alumnos a ON i.IdAlumno = a.IdAlumno " +
            "JOIN periodos p ON i.IdPeriodo = p.IdPeriodo " +
            "WHERE a.Matricula = ? AND p.Nombre = ? AND i.Estado = 'Inscrito'";
        String sqlGetAsigna =
            "SELECT asg.IdAsigna FROM asigna asg " +
            "JOIN grupos g ON asg.IdGrupo = g.IdGrupo " +
            "JOIN alumnos al ON al.IdGrupo = g.IdGrupo " +
            "WHERE al.Matricula = ? AND asg.IdMateria = ?";
        String sqlUpsert =
            "INSERT INTO calificaciones (IdInscripcion, IdAsigna, Parcial1, Parcial2, Parcial3, FechaRegistro) " +
            "VALUES (?, ?, ?, ?, ?, NOW()) " +
            "ON DUPLICATE KEY UPDATE Parcial1 = VALUES(Parcial1), Parcial2 = VALUES(Parcial2), Parcial3 = VALUES(Parcial3), FechaModificacion = NOW()";

        try (Connection conn = ConexionMySQL.getConnection())
        {
            int idInscripcion = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetInscripcion))
            {
                ps.setString(1, matricula);
                ps.setString(2, nombrePeriodo);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next()) { idInscripcion = rs.getInt("IdInscripcion"); }
                    else { return false; } // alumno no inscrito en ese periodo
                }
            }
            int idAsigna = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetAsigna))
            {
                ps.setString(1, matricula);
                ps.setInt(2, idMateria);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next()) { idAsigna = rs.getInt("IdAsigna"); }
                    else { return false; } // materia no asignada al grupo del alumno
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlUpsert))
            {
                ps.setInt(1, idInscripcion);
                ps.setInt(2, idAsigna);
                ps.setDouble(3, p1 != null ? p1 : 0);
                ps.setDouble(4, p2 != null ? p2 : 0);
                ps.setDouble(5, p3 != null ? p3 : 0);
                return ps.executeUpdate() > 0;
            }
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminarCalificacion(String matricula, int idMateria, String nombrePeriodo)
    {
        String sqlGetInscripcion =
            "SELECT i.IdInscripcion FROM inscripcion i " +
            "JOIN alumnos a ON i.IdAlumno = a.IdAlumno " +
            "JOIN periodos p ON i.IdPeriodo = p.IdPeriodo " +
            "WHERE a.Matricula = ? AND p.Nombre = ? AND i.Estado = 'Inscrito'";
        String sqlGetAsigna =
            "SELECT asg.IdAsigna FROM asigna asg " +
            "JOIN grupos g ON asg.IdGrupo = g.IdGrupo " +
            "JOIN alumnos al ON al.IdGrupo = g.IdGrupo " +
            "WHERE al.Matricula = ? AND asg.IdMateria = ?";
        String sqlDelete = "DELETE FROM calificaciones WHERE IdInscripcion = ? AND IdAsigna = ?";

        try (Connection conn = ConexionMySQL.getConnection())
        {
            int idInscripcion = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetInscripcion))
            {
                ps.setString(1, matricula);
                ps.setString(2, nombrePeriodo);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next()) { idInscripcion = rs.getInt("IdInscripcion"); }
                    else { return false; }
                }
            }
            int idAsigna = -1;
            try (PreparedStatement ps = conn.prepareStatement(sqlGetAsigna))
            {
                ps.setString(1, matricula);
                ps.setInt(2, idMateria);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next()) { idAsigna = rs.getInt("IdAsigna"); }
                    else { return false; }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlDelete))
            {
                ps.setInt(1, idInscripcion);
                ps.setInt(2, idAsigna);
                return ps.executeUpdate() > 0;
            }
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }
}