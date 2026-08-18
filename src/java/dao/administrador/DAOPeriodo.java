package dao.administrador;

import modelo.Periodo;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOPeriodo
{
    public List<Periodo> listar()
    {
        List<Periodo> periodos = new ArrayList<>();
        String sql = "SELECT * FROM periodos ORDER BY FechaInicio DESC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                periodos.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return periodos;
    }

    public Periodo obtenerPorId(int idPeriodo)
    {
        Periodo periodo = null;
        String sql = "SELECT * FROM periodos WHERE IdPeriodo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idPeriodo);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { periodo = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return periodo;
    }

    public boolean insertar(Periodo periodo)
    {
        String sql = "INSERT INTO periodos (Nombre, FechaInicio, FechaFin, Estado) VALUES (?, ?, ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, periodo.getNombre());
            ps.setDate(2, periodo.getFechaInicio());
            ps.setDate(3, periodo.getFechaFin());
            ps.setString(4, periodo.getEstado());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Periodo periodo)
    {
        String sql = "UPDATE periodos SET Nombre = ?, FechaInicio = ?, FechaFin = ?, Estado = ? WHERE IdPeriodo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, periodo.getNombre());
            ps.setDate(2, periodo.getFechaInicio());
            ps.setDate(3, periodo.getFechaFin());
            ps.setString(4, periodo.getEstado());
            ps.setInt(5, periodo.getIdPeriodo());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idPeriodo)
    {
        // ON DELETE CASCADE en grupos/inscripcion/apertura_calificaciones que referencian este periodo
        String sql = "DELETE FROM periodos WHERE IdPeriodo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idPeriodo);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Periodo mapear(ResultSet rs) throws SQLException
    {
        Periodo p = new Periodo();
        p.setIdPeriodo(rs.getInt("IdPeriodo"));
        p.setNombre(rs.getString("Nombre"));
        p.setFechaInicio(rs.getDate("FechaInicio"));
        p.setFechaFin(rs.getDate("FechaFin"));
        p.setEstado(rs.getString("Estado"));
        return p;
    }
}