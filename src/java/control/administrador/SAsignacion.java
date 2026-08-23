package control.administrador;

import modelo.Usuario;
import modelo.Asignacion;
import modelo.Profesor;
import modelo.Materia;
import modelo.Grupo;
import dao.administrador.DAOAsignacion;
import dao.administrador.DAOProfesor;
import dao.administrador.DAOMateria;
import dao.administrador.DAOGrupo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SAsignacion", urlPatterns = {"/Asignaciones"})
public class SAsignacion extends HttpServlet
{
    private DAOAsignacion daoAsignacion = new DAOAsignacion();
    private DAOProfesor daoProfesor = new DAOProfesor();
    private DAOMateria daoMateria = new DAOMateria();
    private DAOGrupo daoGrupo = new DAOGrupo();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
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
            if ("eliminar".equals(accion))
            {
                int idAsigna = Integer.parseInt(request.getParameter("idAsigna"));
                boolean ok = daoAsignacion.eliminar(idAsigna);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Asignación eliminada exitosamente" : "No se pudo eliminar");
                response.sendRedirect(request.getContextPath() + "/Asignaciones");
                return;
            }

            List<Asignacion> asignaciones = daoAsignacion.listar();
            List<Profesor> profesores = daoProfesor.listar();
            List<Materia> materias = daoMateria.listar();
            List<Grupo> grupos = daoGrupo.listar();

            request.setAttribute("asignaciones", asignaciones);
            request.setAttribute("profesores", profesores);
            request.setAttribute("materias", materias);
            request.setAttribute("grupos", grupos);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/asignaciones.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        try
        {
            int idProfesor = Integer.parseInt(request.getParameter("idProfesor"));
            int idMateria = Integer.parseInt(request.getParameter("idMateria"));
            int idGrupo = Integer.parseInt(request.getParameter("idGrupo"));

            boolean resultado = daoAsignacion.insertar(idProfesor, idMateria, idGrupo);
            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Asignación creada exitosamente" : "Error al asignar (verifica que esa materia no esté ya asignada a ese grupo)");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Asignaciones");
    }
}