package dao;

import modelo.Carrera;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOCarrera
{
    public List<Carrera> listar()
    {
        List<Carrera> carreras = new ArrayList<>();
        String sql = "SELECT * FROM carreras ORDER BY Carrera ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                carreras.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return carreras;
    }

    public Carrera obtenerPorId(int idCarrera)
    {
        Carrera carrera = null;
        String sql = "SELECT * FROM carreras WHERE IdCarrera = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idCarrera);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { carrera = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return carrera;
    }

    public boolean insertar(Carrera carrera)
    {
        String sql = "INSERT INTO carreras (Clave, Carrera, TotalCuatrimestres, CuatrimestreEstadia) VALUES (?, ?, ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, carrera.getClave());
            ps.setString(2, carrera.getCarrera());
            ps.setInt(3, carrera.getTotalCuatrimestres());
            ps.setInt(4, carrera.getCuatrimestreEstadia());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Carrera carrera)
    {
        String sql = "UPDATE carreras SET Clave = ?, Carrera = ?, TotalCuatrimestres = ?, CuatrimestreEstadia = ? WHERE IdCarrera = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, carrera.getClave());
            ps.setString(2, carrera.getCarrera());
            ps.setInt(3, carrera.getTotalCuatrimestres());
            ps.setInt(4, carrera.getCuatrimestreEstadia());
            ps.setInt(5, carrera.getIdCarrera());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idCarrera)
    {
        // ON DELETE CASCADE en grupos/materias/alumnos que referencian esta carrera
        String sql = "DELETE FROM carreras WHERE IdCarrera = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idCarrera);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Carrera mapear(ResultSet rs) throws SQLException
    {
        Carrera c = new Carrera();
        c.setIdCarrera(rs.getInt("IdCarrera"));
        c.setClave(rs.getString("Clave"));
        c.setCarrera(rs.getString("Carrera"));
        c.setTotalCuatrimestres(rs.getInt("TotalCuatrimestres"));
        c.setCuatrimestreEstadia(rs.getInt("CuatrimestreEstadia"));
        return c;
    }
}