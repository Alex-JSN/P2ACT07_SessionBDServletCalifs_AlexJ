package dao.administrador;

import modelo.Asignacion;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOAsignacion
{
    public List<Asignacion> listar()
    {
        List<Asignacion> asignaciones = new ArrayList<>();
        String sql = "SELECT a.*, " +
                     "CONCAT(pr.Nombre, ' ', pr.Paterno) AS nombreProfesor, " +
                     "m.Materia AS nombreMateria, " +
                     "CONCAT(g.Cuatrimestre, g.Letra, ' - ', g.Generacion) AS nombreGrupo, " +
                     "per.Nombre AS nombrePeriodo " +
                     "FROM asigna a " +
                     "JOIN profesores pr ON a.IdProfesor = pr.IdProfesor " +
                     "JOIN materias m ON a.IdMateria = m.IdMateria " +
                     "JOIN grupos g ON a.IdGrupo = g.IdGrupo " +
                     "JOIN periodos per ON g.IdPeriodo = per.IdPeriodo " +
                     "ORDER BY per.Nombre DESC, pr.Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                asignaciones.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return asignaciones;
    }

    // Solo materias de la carrera del grupo, para que el combo no muestre
    // materias que no tienen sentido para ese grupo.
    public boolean insertar(int idProfesor, int idMateria, int idGrupo)
    {
        String sql = "INSERT INTO asigna (IdProfesor, IdMateria, IdGrupo) VALUES (?, ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idProfesor);
            ps.setInt(2, idMateria);
            ps.setInt(3, idGrupo);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idAsigna)
    {
        // ON DELETE CASCADE limpia también sus calificaciones asociadas
        String sql = "DELETE FROM asigna WHERE IdAsigna = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idAsigna);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Asignacion mapear(ResultSet rs) throws SQLException
    {
        Asignacion a = new Asignacion();
        a.setIdAsigna(rs.getInt("IdAsigna"));
        a.setIdProfesor(rs.getInt("IdProfesor"));
        a.setIdMateria(rs.getInt("IdMateria"));
        a.setIdGrupo(rs.getInt("IdGrupo"));
        a.setNombreProfesor(rs.getString("nombreProfesor"));
        a.setNombreMateria(rs.getString("nombreMateria"));
        a.setNombreGrupo(rs.getString("nombreGrupo"));
        a.setNombrePeriodo(rs.getString("nombrePeriodo"));
        return a;
    }
}