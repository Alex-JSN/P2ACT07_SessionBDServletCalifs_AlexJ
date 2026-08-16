package dao;

import modelo.Grupo;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DAOGrupo
{
    public List<Grupo> listar()
    {
        List<Grupo> grupos = new ArrayList<>();
        String sql = "SELECT * FROM grupos ORDER BY Generacion DESC, Cuatrimestre ASC, Letra ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                grupos.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return grupos;
    }

    public Grupo obtenerPorId(int idGrupo)
    {
        Grupo grupo = null;
        String sql = "SELECT * FROM grupos WHERE IdGrupo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idGrupo);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next()) { grupo = mapear(rs); }
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return grupo;
    }

    public boolean insertar(Grupo grupo)
    {
        String sql = "INSERT INTO grupos (Generacion, Cuatrimestre, Letra, IdCarrera, IdPeriodo) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, grupo.getGeneracion());
            ps.setInt(2, grupo.getCuatrimestre());
            ps.setString(3, grupo.getLetra());
            ps.setInt(4, grupo.getIdCarrera());
            ps.setInt(5, grupo.getIdPeriodo());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean actualizar(Grupo grupo)
    {
        String sql = "UPDATE grupos SET Generacion = ?, Cuatrimestre = ?, Letra = ?, IdCarrera = ?, IdPeriodo = ? WHERE IdGrupo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, grupo.getGeneracion());
            ps.setInt(2, grupo.getCuatrimestre());
            ps.setString(3, grupo.getLetra());
            ps.setInt(4, grupo.getIdCarrera());
            ps.setInt(5, grupo.getIdPeriodo());
            ps.setInt(6, grupo.getIdGrupo());
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean eliminar(int idGrupo)
    {
        // ON DELETE CASCADE en asigna/alumnos que referencian este grupo
        String sql = "DELETE FROM grupos WHERE IdGrupo = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idGrupo);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Grupo mapear(ResultSet rs) throws SQLException
    {
        Grupo g = new Grupo();
        g.setIdGrupo(rs.getInt("IdGrupo"));
        g.setGeneracion(rs.getString("Generacion"));
        g.setCuatrimestre(rs.getInt("Cuatrimestre"));
        g.setLetra(rs.getString("Letra"));
        g.setIdCarrera(rs.getInt("IdCarrera"));
        g.setIdPeriodo(rs.getInt("IdPeriodo"));
        return g;
    }
}