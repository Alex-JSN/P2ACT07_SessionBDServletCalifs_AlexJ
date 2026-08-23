package dao.administrador;

import modelo.Usuario;
import conexion.ConexionMySQL;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.PasswordUtil;

public class DAOCuenta
{
    public List<Usuario> listar()
    {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuarios ORDER BY TipoUsuario ASC, Nombre ASC";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                usuarios.add(mapear(rs));
            }
        }
        catch (SQLException e) { e.printStackTrace(); }
        return usuarios;
    }

    public boolean cambiarEstado(int idUsuario, String nuevoEstado)
    {
        String sql = "UPDATE usuarios SET Estado = ? WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // No se permite eliminar cuentas "protegidas" (EsProtegido=1),
    // como el administrador principal, para evitar quedarse sin acceso al sistema.
    public boolean eliminar(int idUsuario)
    {
        String sqlCheck = "SELECT EsProtegido FROM usuarios WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection())
        {
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck))
            {
                ps.setInt(1, idUsuario);
                try (ResultSet rs = ps.executeQuery())
                {
                    if (rs.next() && rs.getBoolean("EsProtegido"))
                    {
                        return false; // cuenta protegida, no se elimina
                    }
                }
            }

            String sqlDelete = "DELETE FROM usuarios WHERE IdUsuario = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDelete))
            {
                ps.setInt(1, idUsuario);
                return ps.executeUpdate() > 0;
            }
        }
        catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private Usuario mapear(ResultSet rs) throws SQLException
    {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("IdUsuario"));
        u.setMatricula(rs.getString("Matricula"));
        u.setNombre(rs.getString("Nombre"));
        u.setPaterno(rs.getString("Paterno"));
        u.setMaterno(rs.getString("Materno"));
        u.setCorreo(rs.getString("Correo"));
        u.setTipoUsuario(rs.getString("TipoUsuario"));
        u.setEstado(rs.getString("Estado"));
        u.setEsProtegido(rs.getBoolean("EsProtegido"));
        u.setFechaRegistro(rs.getTimestamp("FechaRegistro"));
        u.setFechaActivacion(rs.getTimestamp("FechaActivacion"));
        return u;
    }
    
    // Restablece la contraseña de una cuenta. Marca RequiereCambioContrasena=1
// para forzar que el usuario la cambie por una propia en su próximo login.
public boolean cambiarContrasena(int idUsuario, String nuevaContrasenaPlano)
{
    String sql = "UPDATE usuarios SET Contrasena = ?, RequiereCambioContrasena = 1 WHERE IdUsuario = ?";
    try (Connection conn = ConexionMySQL.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql))
    {
        ps.setString(1, PasswordUtil.hashear(nuevaContrasenaPlano));
        ps.setInt(2, idUsuario);
        return ps.executeUpdate() > 0;
    }
    catch (SQLException e) { e.printStackTrace(); return false; }
}
}