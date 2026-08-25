package dao.alumno;
import modelo.Calificacion;
import modelo.Materia;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class DAOAlumno
{
    // Recibe el IdUsuario de la sesión (usuario.getIdUsuario()), no el IdAlumno.
    // El JOIN resuelve internamente qué alumno corresponde a ese usuario.
    public List<Calificacion> obtenerCalificacionesPorAlumno(int idUsuario)
    {
        List<Calificacion> calificaciones = new ArrayList<>();
        String sql =
            "SELECT c.*, m.Materia AS nombreMateria " +
            "FROM calificaciones c " +
            "JOIN inscripcion i ON c.IdInscripcion = i.IdInscripcion " +
            "JOIN alumnos a ON i.IdAlumno = a.IdAlumno " +
            "JOIN asigna asg ON c.IdAsigna = asg.IdAsigna " +
            "JOIN materias m ON asg.IdMateria = m.IdMateria " +
            "WHERE a.IdUsuario = ? " +
            "ORDER BY m.Materia ASC, c.FechaRegistro DESC";
        try (Connection conn = ConexionMySQL.getConnection(); PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idUsuario);
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
                    calif.setNombreMateria(rs.getString("nombreMateria"));
                    calificaciones.add(calif);
                }
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
        return calificaciones;
    }
    public List<Materia> obtenerTodasLasMaterias()
    {
        List<Materia> materias = new ArrayList<>();
        String sql = "SELECT * FROM materias ORDER BY Materia ASC";
        try (Connection conn = ConexionMySQL.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery())
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
        catch (SQLException e) 
        {
            e.printStackTrace();
        }
        return materias;
    }
}