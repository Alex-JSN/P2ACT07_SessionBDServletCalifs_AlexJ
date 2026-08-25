package control.administrador;

import modelo.Usuario;
import dao.administrador.DAOCuenta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SCuenta", urlPatterns = {"/Cuentas"})
public class SCuenta extends HttpServlet
{
    private DAOCuenta daoCuenta = new DAOCuenta();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }

        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        if (!"Administrador".equals(usuarioActual.getTipoUsuario()))
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        try
        {
            if ("eliminar".equals(accion))
            {
                int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
                boolean ok = daoCuenta.eliminar(idUsuario);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Cuenta eliminada exitosamente" : "No se pudo eliminar (cuenta protegida o inexistente)");
                response.sendRedirect(request.getContextPath() + "/Cuentas");
                return;
            }

            if ("cambiarEstado".equals(accion))
            {
                int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
                String nuevoEstado = request.getParameter("estado");
                daoCuenta.cambiarEstado(idUsuario, nuevoEstado);
                response.sendRedirect(request.getContextPath() + "/Cuentas");
                return;
            }

            List<Usuario> usuarios = daoCuenta.listar();
            request.setAttribute("usuarios", usuarios);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/cuentas.jsp").forward(request, response);
    }
    
    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
{
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("usuario") == null)
    {
        response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
        return;
    }

    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (!"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    String accion = request.getParameter("accion");

    try
    {
        if ("cambiarContrasena".equals(accion))
        {
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            String nuevaContrasena = request.getParameter("nuevaContrasena");

            if (nuevaContrasena == null || nuevaContrasena.trim().length() < 8)
            {
                session.setAttribute("error", "La contraseña debe tener al menos 8 caracteres.");
            }
            else
            {
                boolean ok = daoCuenta.cambiarContrasena(idUsuario, nuevaContrasena.trim());
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Contraseña actualizada. Se pedirá cambiarla en el próximo inicio de sesión." : "No se pudo actualizar la contraseña.");
            }
        }
    }
    catch (Exception e)
    {
        e.printStackTrace();
        session.setAttribute("error", "Error: " + e.getMessage());
    }

    response.sendRedirect(request.getContextPath() + "/Cuentas");
}
}