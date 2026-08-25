package control.alumno;

import conexion.ConexionMySQL;
import modelo.Usuario;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "SGestionCambioContrasena", urlPatterns = {"/CambiarContrasena"})
public class SGestionCambioContrasena extends HttpServlet
{
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }

        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        String tipoUsuario = usuarioActual.getTipoUsuario();

        String contrasenaActual = request.getParameter("contrasenaActual");
        String contrasenaNueva = request.getParameter("contrasenaNueva");
        String contrasenaConfirmar = request.getParameter("contrasenaConfirmar");

        // Validaciones
        if (contrasenaActual == null || contrasenaActual.trim().isEmpty())
        {
            session.setAttribute("error", "Debes ingresar tu contraseña actual.");
            redirigirSegunTipo(request, response, tipoUsuario);
            return;
        }

        if (contrasenaNueva == null || contrasenaNueva.trim().length() < 8)
        {
            session.setAttribute("error", "La contraseña nueva debe tener al menos 8 caracteres.");
            redirigirSegunTipo(request, response, tipoUsuario);
            return;
        }

        if (!contrasenaNueva.equals(contrasenaConfirmar))
        {
            session.setAttribute("error", "La contraseña nueva y la confirmación no coinciden.");
            redirigirSegunTipo(request, response, tipoUsuario);
            return;
        }

        if (contrasenaActual.equals(contrasenaNueva))
        {
            session.setAttribute("error", "La contraseña nueva debe ser diferente a la actual.");
            redirigirSegunTipo(request, response, tipoUsuario);
            return;
        }

        try
        {
            // Verificar contraseña actual
            if (!verificarContrasena(usuarioActual.getIdUsuario(), contrasenaActual))
            {
                session.setAttribute("error", "La contraseña actual es incorrecta.");
                redirigirSegunTipo(request, response, tipoUsuario);
                return;
            }

            // Actualizar contraseña
            if (actualizarContrasena(usuarioActual.getIdUsuario(), contrasenaNueva))
            {
                session.setAttribute("mensaje", "¡Contraseña actualizada exitosamente!");
            }
            else
            {
                session.setAttribute("error", "No se pudo actualizar la contraseña.");
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error al actualizar la contraseña.");
        }

        redirigirSegunTipo(request, response, tipoUsuario);
    }

    private boolean verificarContrasena(int idUsuario, String contrasenaPlana) throws SQLException
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
                    return PasswordUtil.verificar(contrasenaPlana, rs.getString("Contrasena"));
                }
                return false;
            }
        }
    }

    private boolean actualizarContrasena(int idUsuario, String nuevaContrasena) throws SQLException
    {
        String sql = "UPDATE usuarios SET Contrasena = ? WHERE IdUsuario = ?";
        try (Connection conn = ConexionMySQL.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql))
        {
            ps.setString(1, PasswordUtil.hashear(nuevaContrasena));
            ps.setInt(2, idUsuario);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        redirigirSegunTipo(request, response, usuario.getTipoUsuario());
    }

    private void redirigirSegunTipo(HttpServletRequest request, HttpServletResponse response, String tipoUsuario) throws IOException
    {
        if ("Alumno".equals(tipoUsuario))
        {
            response.sendRedirect(request.getContextPath() + "/PanelAlumno");
        }
        else if ("Profesor".equals(tipoUsuario))
        {
            response.sendRedirect(request.getContextPath() + "/PanelProfesor");
        }
        else
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
        }
    }
}