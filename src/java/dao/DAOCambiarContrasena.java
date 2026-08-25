package dao;

import conexion.ConexionMySQL;
import util.PasswordUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DAOCambiarContrasena
{
    public boolean verificarContrasenaActual(int idUsuario, String contrasenaPlana) throws SQLException
    {
        String sql = "SELECT Contrasena FROM usuarios WHERE IdUsuario = ?";
        
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setInt(1, idUsuario);
            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next())
                {
                    String hashAlmacenado = rs.getString("Contrasena");
                    return PasswordUtil.verificar(contrasenaPlana, hashAlmacenado);
                }
                return false;
            }
        }
    }
    
    public boolean actualizarContrasena(int idUsuario, String nuevaContrasena) throws SQLException
    {
        String sql = "UPDATE usuarios SET Contrasena = ?, RequiereCambioContrasena = true WHERE IdUsuario = ?";
        
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            String hash = PasswordUtil.hashear(nuevaContrasena);
            ps.setString(1, hash);
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        }
    }
}