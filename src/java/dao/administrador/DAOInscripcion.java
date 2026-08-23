package dao.administrador;

import modelo.Inscripcion;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOInscripcion
{
    public List<Inscripcion> listar()
    {
        List<Inscripcion> inscripciones = new ArrayList<>();
        String sql = "SELECT i.*, a.Matricula AS matriculaAlumno, " +
                     "CONCAT(a.Nombre, ' ', a.Paterno) AS nombreAlumno, p.Nombre AS nombrePeriodo " +
                     "FROM inscripcion i " +
                     "JOIN alumnos a ON i.IdAlumno = a.IdAlumno " +
                     "JOIN periodos p ON i.IdPeriodo = p.IdPeriodo " +
                     "ORDER BY p.Nombre DESC, a.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                inscripciones.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return inscripciones;
    }

    // Para llenar el combo de "alumnos sin inscribir en este periodo"
    public List<Object[]> alumnosSinInscribirEnPeriodo(int idPeriodo)
    {
        List<Object[]> resultado = new ArrayList<>();
        String sql = "SELECT a.IdAlumno, a.Matricula, a.Nombre, a.Paterno FROM alumnos a " +
                     "WHERE a.IdAlumno NOT IN (" +
                     "  SELECT i.IdAlumno FROM inscripcion i WHERE i.IdPeriodo = ? AND i.Estado = 'Inscrito'" +
                     ") ORDER BY a.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idPeriodo);
            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    resultado.add(new Object[]{
                        rs.getInt("IdAlumno"),
                        rs.getString("Matricula"),
                        rs.getString("Nombre") + " " + rs.getString("Paterno")
                    });
                }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return resultado;
    }

    public boolean inscribir(int idAlumno, int idPeriodo, String cuatrimestre)
    {
        String sql = "INSERT INTO inscripcion (Cuatrimestre, FechaInscripcion, Estado, IdAlumno, IdPeriodo) " +
                     "VALUES (?, NOW(), 'Inscrito', ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, cuatrimestre);
            ps.setInt(2, idAlumno);
            ps.setInt(3, idPeriodo);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean cambiarEstado(int idInscripcion, String nuevoEstado)
    {
        String sql = "UPDATE inscripcion SET Estado = ? WHERE IdInscripcion = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idInscripcion);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idInscripcion)
    {
        // ON DELETE CASCADE limpia también sus calificaciones
        String sql = "DELETE FROM inscripcion WHERE IdInscripcion = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idInscripcion);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Inscripcion mapear(ResultSet rs) throws SQLException
    {
        Inscripcion i = new Inscripcion();
        i.setIdInscripcion(rs.getInt("IdInscripcion"));
        i.setCuatrimestre(rs.getString("Cuatrimestre"));
        i.setFechaInscripcion(rs.getTimestamp("FechaInscripcion"));
        i.setEstado(rs.getString("Estado"));
        i.setIdAlumno(rs.getInt("IdAlumno"));
        i.setIdPeriodo(rs.getInt("IdPeriodo"));
        i.setMatriculaAlumno(rs.getString("matriculaAlumno"));
        i.setNombreAlumno(rs.getString("nombreAlumno"));
        i.setNombrePeriodo(rs.getString("nombrePeriodo"));
        return i;
    }
}