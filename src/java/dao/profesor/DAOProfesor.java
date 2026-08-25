package dao.profesor;

import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOProfesor
{
    public int obtenerIdProfesorPorIdUsuario(int idUsuario)
    {
        String sql = "SELECT IdProfesor FROM profesores WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { return rs.getInt("IdProfesor"); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    // Cada fila: {IdAsigna, NombreMateria, NombreGrupo, NombrePeriodo}
    public List<Object[]> obtenerAsignaciones(int idProfesor)
    {
        List<Object[]> resultado = new ArrayList<>();
        String sql = "SELECT asg.IdAsigna, m.Materia AS nombreMateria, " +
                     "CONCAT(g.Cuatrimestre, g.Letra, ' - ', g.Generacion) AS nombreGrupo, " +
                     "per.Nombre AS nombrePeriodo " +
                     "FROM asigna asg " +
                     "JOIN materias m ON asg.IdMateria = m.IdMateria " +
                     "JOIN grupos g ON asg.IdGrupo = g.IdGrupo " +
                     "JOIN periodos per ON g.IdPeriodo = per.IdPeriodo " +
                     "WHERE asg.IdProfesor = ? " +
                     "ORDER BY per.Nombre DESC, m.Materia ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idProfesor);
            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    resultado.add(new Object[]{
                        rs.getInt("IdAsigna"),
                        rs.getString("nombreMateria"),
                        rs.getString("nombreGrupo"),
                        rs.getString("nombrePeriodo")
                    });
                }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return resultado;
    }

    public boolean perteneceAProfesor(int idAsigna, int idProfesor)
    {
        String sql = "SELECT 1 FROM asigna WHERE IdAsigna = ? AND IdProfesor = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idAsigna);
            ps.setInt(2, idProfesor);
            try (ResultSet rs = ps.executeQuery())
            {
                return rs.next();
            }
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Cada fila: {IdInscripcion, Matricula, NombreCompleto, Parcial1(Double|null), Parcial2, Parcial3}
    // Solo trae alumnos del grupo de esa asignación que SÍ estén inscritos en el periodo correspondiente.
    public List<Object[]> obtenerAlumnosParaCalificar(int idAsigna)
    {
        List<Object[]> resultado = new ArrayList<>();
        String sql = "SELECT i.IdInscripcion, a.Matricula, CONCAT(a.Nombre, ' ', a.Paterno) AS nombreCompleto, " +
                     "c.Parcial1, c.Parcial2, c.Parcial3 " +
                     "FROM asigna asg " +
                     "JOIN grupos g ON asg.IdGrupo = g.IdGrupo " +
                     "JOIN alumnos a ON a.IdGrupo = g.IdGrupo " +
                     "JOIN inscripcion i ON i.IdAlumno = a.IdAlumno AND i.IdPeriodo = g.IdPeriodo AND i.Estado = 'Inscrito' " +
                     "LEFT JOIN calificaciones c ON c.IdInscripcion = i.IdInscripcion AND c.IdAsigna = asg.IdAsigna " +
                     "WHERE asg.IdAsigna = ? " +
                     "ORDER BY a.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idAsigna);
            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    Double p1 = rs.getObject("Parcial1") != null ? rs.getDouble("Parcial1") : null;
                    Double p2 = rs.getObject("Parcial2") != null ? rs.getDouble("Parcial2") : null;
                    Double p3 = rs.getObject("Parcial3") != null ? rs.getDouble("Parcial3") : null;

                    resultado.add(new Object[]{
                        rs.getInt("IdInscripcion"),
                        rs.getString("Matricula"),
                        rs.getString("nombreCompleto"),
                        p1, p2, p3
                    });
                }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return resultado;
    }

    public boolean guardarCalificacion(int idInscripcion, int idAsigna, Double p1, Double p2, Double p3)
    {
        String sql = "INSERT INTO calificaciones (IdInscripcion, IdAsigna, Parcial1, Parcial2, Parcial3, FechaRegistro) " +
                     "VALUES (?, ?, ?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE Parcial1 = VALUES(Parcial1), Parcial2 = VALUES(Parcial2), Parcial3 = VALUES(Parcial3), FechaModificacion = NOW()";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idInscripcion);
            ps.setInt(2, idAsigna);
            if (p1 != null) { ps.setDouble(3, p1); } else { ps.setNull(3, Types.DECIMAL); }
            if (p2 != null) { ps.setDouble(4, p2); } else { ps.setNull(4, Types.DECIMAL); }
            if (p3 != null) { ps.setDouble(5, p3); } else { ps.setNull(5, Types.DECIMAL); }
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }
}