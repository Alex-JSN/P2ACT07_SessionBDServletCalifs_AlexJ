package control;

import dao.DAOUsuario;
import modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SAutenticarUsuario", urlPatterns = {"/Login"}) public class SAutenticarUsuario extends HttpServlet
{
    private final DAOUsuario daoUsuario = new DAOUsuario();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");

        if (esVacio(correo) || esVacio(contrasena))
        {
            request.setAttribute("error", "Ingresa tu correo y tu contraseña.");
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/loginUsuario.jsp").forward(request, response);
            return;
        }

        try
        {
            Usuario usuario = daoUsuario.autenticar(correo.trim().toLowerCase(), contrasena);
            HttpSession session = request.getSession(true);
            session.setAttribute("usuario", usuario);
            session.setAttribute("idUsuario", usuario.getIdUsuario());
            session.setAttribute("tipoUsuario", usuario.getTipoUsuario());
            session.setMaxInactiveInterval(30 * 60); // 30 min

            // TipoUsuario: 'Administrador', 'Profesor' o 'Alumno' (enum de la tabla usuarios)
            switch (usuario.getTipoUsuario())
            {
                case "Administrador":
                    response.sendRedirect(request.getContextPath() + "/PanelAdministrador");
                    break;
                case "Profesor":
                    response.sendRedirect(request.getContextPath() + "/PanelProfesor");
                    break;
                case "Alumno":
                    response.sendRedirect(request.getContextPath() + "/PanelAlumno");
                    break;
                default:
                    // Caso defensivo: un TipoUsuario no contemplado no debería
                    // llegar aquí si el enum de la BD está bien definido,
                    // pero evita mandar a alguien a un panel equivocado.
                    request.setAttribute("error", "Tipo de usuario no reconocido.");
                    request.getRequestDispatcher("/loginUsuario.jsp").forward(request, response);
            }
        }
        catch (DAOUsuario.CredencialesInvalidasException e)
        {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/loginUsuario.jsp").forward(request, response);
        }
        catch (DAOUsuario.CuentaInactivaException e)
        {
            HttpSession session = request.getSession(true);
            session.setAttribute("correoPendienteVerificacion", correo.trim().toLowerCase());
            response.sendRedirect(request.getContextPath() + "/VerificarCuenta");
        }
        catch (DAOUsuario.CuentaRechazadaException e)
        {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/loginUsuario.jsp").forward(request, response);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Ocurrió un error al iniciar sesión. Intenta más tarde.");
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/loginUsuario.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
    }

    private boolean esVacio(String s)
    {
        return s == null || s.trim().isEmpty();
    }
}