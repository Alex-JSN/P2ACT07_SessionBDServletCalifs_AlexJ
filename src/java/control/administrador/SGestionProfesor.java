package control.administrador;

import modelo.Usuario;
import modelo.Profesor;
import dao.administrador.DAOProfesor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SGestionProfesor", urlPatterns = {"/GestionProfesores"})
public class SGestionProfesor extends HttpServlet
{
    private DAOProfesor daoProfesor = new DAOProfesor();

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
                boolean ok = daoProfesor.eliminar(idUsuario);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Profesor eliminado exitosamente" : "No se pudo eliminar el profesor");
                response.sendRedirect(request.getContextPath() + "/GestionProfesores");
                return;
            }

            if ("editar".equals(accion))
            {
                int idProfesor = Integer.parseInt(request.getParameter("idProfesor"));
                Profesor profesorEditar = daoProfesor.obtenerPorId(idProfesor);
                request.setAttribute("profesorEditar", profesorEditar);
            }

            List<Profesor> profesores = daoProfesor.listar();
            request.setAttribute("profesores", profesores);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/profesores.jsp").forward(request, response);
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

        String accion = request.getParameter("accion");

        try
        {
            Profesor profesor = new Profesor();
            profesor.setNombre(request.getParameter("nombre"));
            profesor.setPaterno(request.getParameter("paterno"));
            profesor.setMaterno(request.getParameter("materno"));
            profesor.setCedula(request.getParameter("cedula"));
            String correo = request.getParameter("correo");

            boolean resultado;
            if ("actualizar".equals(accion))
            {
                profesor.setIdProfesor(Integer.parseInt(request.getParameter("idProfesor")));
                profesor.setIdUsuario(Integer.parseInt(request.getParameter("idUsuario")));
                resultado = daoProfesor.actualizar(profesor, correo);
            }
            else
            {
                String matricula = request.getParameter("matricula");
                resultado = daoProfesor.insertar(profesor, matricula, correo);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Profesor guardado exitosamente" : "Error al guardar. Verifica que la matrícula/correo no estén repetidos.");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/GestionProfesores");
    }
}