package dao;

import modelo.Materia;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOMateria
{
    public List<Materia> listar()
    {
        List<Materia> materias = new ArrayList<>();
        String sql = "SELECT m.*, c.Carrera AS nombreCarrera FROM materias m " +
                     "JOIN carreras c ON m.IdCarrera = c.IdCarrera " +
                     "ORDER BY c.Carrera ASC, m.Cuatrimestre ASC, m.Materia ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                materias.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return materias;
    }

    public Materia obtenerPorId(int idMateria)
    {
        Materia materia = null;
        String sql = "SELECT m.*, c.Carrera AS nombreCarrera FROM materias m " +
                     "JOIN carreras c ON m.IdCarrera = c.IdCarrera " +
                     "WHERE m.IdMateria = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idMateria);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { materia = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return materia;
    }

    public List<Materia> listarPorCarrera(int idCarrera)
    {
        List<Materia> materias = new ArrayList<>();
        String sql = "SELECT m.*, c.Carrera AS nombreCarrera FROM materias m " +
                     "JOIN carreras c ON m.IdCarrera = c.IdCarrera " +
                     "WHERE m.IdCarrera = ? ORDER BY m.Cuatrimestre ASC, m.Materia ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idCarrera);
            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next()) { materias.add(mapear(rs)); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return materias;
    }

    public boolean insertar(Materia materia)
    {
        String sql = "INSERT INTO materias (Materia, Cuatrimestre, IdCarrera) VALUES (?, ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, materia.getMateria());
            ps.setInt(2, materia.getCuatrimestre());
            ps.setInt(3, materia.getIdCarrera());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Materia materia)
    {
        String sql = "UPDATE materias SET Materia = ?, Cuatrimestre = ?, IdCarrera = ? WHERE IdMateria = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, materia.getMateria());
            ps.setInt(2, materia.getCuatrimestre());
            ps.setInt(3, materia.getIdCarrera());
            ps.setInt(4, materia.getIdMateria());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idMateria)
    {
        String sql = "DELETE FROM materias WHERE IdMateria = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idMateria);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Materia mapear(ResultSet rs) throws SQLException
    {
        Materia m = new Materia();
        m.setIdMateria(rs.getInt("IdMateria"));
        m.setMateria(rs.getString("Materia"));
        m.setCuatrimestre(rs.getInt("Cuatrimestre"));
        m.setIdCarrera(rs.getInt("IdCarrera"));
        return m;
    }
}