package control;

import dao.DAOUsuario;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "VerificarCuenta", urlPatterns = {"/VerificarCuenta"}) public class SVerificarCuenta extends HttpServlet
{
    private final DAOUsuario daoUsuario = new DAOUsuario();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        response.setContentType("text/html;charset=UTF-8");

        String correo = obtenerCorreoSesion(request);
        if (correo == null)
        {
            response.sendRedirect(request.getContextPath() + "/registroUsuario.jsp");
            return;
        }

        request.setAttribute("correo", correo);
        request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String correo = obtenerCorreoSesion(request);
        if (correo == null)
        {
            response.sendRedirect(request.getContextPath() + "/registroUsuario.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if ("reenviar".equals(accion))
        {
            reenviarCodigo(request, response, correo);
            return;
        }

        String codigo = request.getParameter("codigo");

        if (codigo == null || codigo.trim().isEmpty())
        {
            request.setAttribute("error", "Ingresa el código que enviamos a tu correo.");
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
            return;
        }

        try
        {
            DAOUsuario.ResultadoVerificacion resultado = daoUsuario.verificarCodigo(correo, codigo.trim());

            switch (resultado)
            {
                case EXITO:
                    HttpSession session = request.getSession(true);
                    session.removeAttribute("correoPendienteVerificacion");
                    response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp?registro=ok");
                    break;

                case YA_ACTIVA:
                    response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
                    break;

                case CODIGO_EXPIRADO:
                    request.setAttribute("error", "El código expiró. Solicita uno nuevo.");
                    request.setAttribute("correo", correo);
                    request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
                    break;

                case CODIGO_INCORRECTO:
                case CORREO_NO_ENCONTRADO:
                default:
                    request.setAttribute("error", "El código ingresado no es correcto.");
                    request.setAttribute("correo", correo);
                    request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
            }

        }
        catch (SQLException e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Ocurrió un error al verificar tu cuenta. Intenta más tarde.");
            request.setAttribute("correo", correo);
            request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
        }
    }

    private void reenviarCodigo(HttpServletRequest request, HttpServletResponse response, String correo) throws ServletException, IOException
    {
        try
        {
            String[] resultado = daoUsuario.reenviarCodigo(correo);

            if (resultado == null)
            {
                request.setAttribute("error", "No se pudo reenviar el código. Verifica tu correo o tu cuenta ya está activa.");
            }
            else
            {
                String nuevoCodigo = resultado[0];
                String nombre = resultado[1];
                try
                {
                    EmailUtil.enviarCorreoVerificacion(correo, nombre, nuevoCodigo);
                }
                catch (RuntimeException ex)
                {
                    ex.printStackTrace();
                }
                request.setAttribute("mensaje", "Te enviamos un nuevo código a tu correo.");
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Ocurrió un error al reenviar el código. Intenta más tarde.");
        }

        request.setAttribute("correo", correo);
        request.getRequestDispatcher("/verificarCuenta.jsp").forward(request, response);
    }

    private String obtenerCorreoSesion(HttpServletRequest request)
    {
        HttpSession session = request.getSession(false);
        if (session == null)
        {
            return null;
        }
        Object correo = session.getAttribute("correoPendienteVerificacion");
        return correo != null ? correo.toString() : null;
    }
}
