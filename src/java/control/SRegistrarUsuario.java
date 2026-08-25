package control;

import dao.DAOUsuario;
import modelo.Usuario;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SRegistrarUsuario", urlPatterns = {"/Registro"})
public class SRegistrarUsuario extends HttpServlet
{
    private final DAOUsuario daoUsuario = new DAOUsuario();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String matricula    = request.getParameter("matricula");
        String correo       = request.getParameter("correo");
        String nombre       = request.getParameter("nombre");
        String paterno      = request.getParameter("paterno");
        String materno      = request.getParameter("materno");
        String contrasena   = request.getParameter("contrasena");
        String confirmarContrasena = request.getParameter("confirmarContrasena");

        if (esVacio(correo) || esVacio(nombre) || esVacio(paterno) || esVacio(contrasena))
        {
            reenviarConError(request, response, "Todos los campos son obligatorios.", matricula, correo, nombre, paterno, materno);
            return;
        }

        if (!contrasena.equals(confirmarContrasena))
        {
            reenviarConError(request, response, "Las contraseñas no coinciden.", matricula, correo, nombre, paterno, materno);
            return;
        }

        if (contrasena.length() < 8)
        {
            reenviarConError(request, response, "La contraseña debe tener al menos 8 caracteres.", matricula, correo, nombre, paterno, materno);
            return;
        }

        boolean esPrimerUsuario;
        try
        {
            esPrimerUsuario = daoUsuario.esPrimerRegistro();
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            reenviarConError(request, response, "Error al verificar el sistema. Intenta más tarde.", matricula, correo, nombre, paterno, materno);
            return;
        }

        Usuario usuario = new Usuario();
        usuario.setCorreo(correo.trim().toLowerCase());
        usuario.setNombre(nombre.trim());
        usuario.setPaterno(paterno.trim());
        usuario.setMaterno(materno.trim());
        usuario.setContrasena(contrasena);

        if (!esPrimerUsuario)
        {
            if (esVacio(matricula)) 
            {
                reenviarConError(request, response, "La matrícula es obligatoria para alumnos.", matricula, correo, nombre, paterno, materno);
                return;
            }
            usuario.setMatricula(matricula.trim());
            usuario.setTipoUsuario("Alumno");
        }
        else
        {
            usuario.setMatricula(null);
            usuario.setTipoUsuario("Administrador");
        }

        try
        {
            String codigo = daoUsuario.registrar(usuario);
            HttpSession session = request.getSession(true);

            if (codigo != null)
            {
                try 
                {
                    EmailUtil.enviarCorreoVerificacion(usuario.getCorreo(), usuario.getNombre(), codigo);
                }
                catch (RuntimeException ex)
                {
                    ex.printStackTrace();
                }

                session.setAttribute("correoPendienteVerificacion", usuario.getCorreo());
                session.setAttribute("mensajeExito", "Cuenta creada. Revisa tu correo para activarla.");
                response.sendRedirect(request.getContextPath() + "/VerificarCuenta");
            }
            else
            {
                if (usuario.getTipoUsuario().equals("Administrador"))
                {
                    session.setAttribute("mensajeExito", "¡Bienvenido Administrador! Has sido registrado exitosamente. Ahora puedes iniciar sesión.");
                }
                else
                {
                    session.setAttribute("mensajeExito", "¡Cuenta activada exitosamente! Ahora puedes iniciar sesión.");
                }

                // ✅ CORREGIDO: Redirige directamente a login
                response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            }

        } catch (DAOUsuario.CorreoDuplicadoException | DAOUsuario.MatriculaDuplicadaException | DAOUsuario.AlumnoNoEncontradoException e)
        {
            reenviarConError(request, response, e.getMessage(), matricula, correo, nombre, paterno, materno);
        } 
        catch (SQLException e)
        {
            e.printStackTrace();
            reenviarConError(request, response, "Ocurrió un error al registrar tu cuenta. Intenta más tarde.", matricula, correo, nombre, paterno, materno);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        response.sendRedirect(request.getContextPath() + "/vistas/registroUsuario.jsp");
    }

    private void reenviarConError(HttpServletRequest request, HttpServletResponse response, String error, String matricula, String correo, String nombre, String paterno, String materno) throws ServletException, IOException
    {
        request.setAttribute("error", error);
        request.setAttribute("matricula", matricula);
        request.setAttribute("correo", correo);
        request.setAttribute("nombre", nombre);
        request.setAttribute("paterno", paterno);
        request.setAttribute("materno", materno);
        request.getRequestDispatcher("/vistas/registroUsuario.jsp").forward(request, response);
    }

    private boolean esVacio(String s)
    {
        return s == null || s.trim().isEmpty();
    }
}