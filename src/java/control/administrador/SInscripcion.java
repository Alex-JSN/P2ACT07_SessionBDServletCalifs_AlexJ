package control.administrador;

import modelo.Usuario;
import modelo.Inscripcion;
import modelo.Periodo;
import dao.administrador.DAOInscripcion;
import dao.administrador.DAOPeriodo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SInscripcion", urlPatterns = {"/Inscripciones"})
public class SInscripcion extends HttpServlet
{
    private DAOInscripcion daoInscripcion = new DAOInscripcion();
    private DAOPeriodo daoPeriodo = new DAOPeriodo();

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
            if ("baja".equals(accion))
            {
                int idInscripcion = Integer.parseInt(request.getParameter("idInscripcion"));
                boolean ok = daoInscripcion.cambiarEstado(idInscripcion, "Baja");
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Alumno dado de baja del periodo" : "No se pudo actualizar");
                response.sendRedirect(request.getContextPath() + "/Inscripciones");
                return;
            }

            if ("reactivar".equals(accion))
            {
                int idInscripcion = Integer.parseInt(request.getParameter("idInscripcion"));
                boolean ok = daoInscripcion.cambiarEstado(idInscripcion, "Inscrito");
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Inscripción reactivada" : "No se pudo actualizar");
                response.sendRedirect(request.getContextPath() + "/Inscripciones");
                return;
            }

            if ("eliminar".equals(accion))
            {
                int idInscripcion = Integer.parseInt(request.getParameter("idInscripcion"));
                boolean ok = daoInscripcion.eliminar(idInscripcion);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Inscripción eliminada" : "No se pudo eliminar");
                response.sendRedirect(request.getContextPath() + "/Inscripciones");
                return;
            }

            List<Inscripcion> inscripciones = daoInscripcion.listar();
            List<Periodo> periodos = daoPeriodo.listar();

            request.setAttribute("inscripciones", inscripciones);
            request.setAttribute("periodos", periodos);

            String idPeriodoParam = request.getParameter("idPeriodo");
            if (idPeriodoParam != null && !idPeriodoParam.isEmpty())
            {
                int idPeriodo = Integer.parseInt(idPeriodoParam);
                request.setAttribute("alumnosDisponibles", daoInscripcion.alumnosSinInscribirEnPeriodo(idPeriodo));
                request.setAttribute("idPeriodoSeleccionado", idPeriodo);
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/inscripciones.jsp").forward(request, response);
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
            int idAlumno = Integer.parseInt(request.getParameter("idAlumno"));
            int idPeriodo = Integer.parseInt(request.getParameter("idPeriodo"));
            String cuatrimestre = request.getParameter("cuatrimestre");

            boolean resultado = daoInscripcion.inscribir(idAlumno, idPeriodo, cuatrimestre);
            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Alumno inscrito exitosamente" : "Error al inscribir (verifica que no esté ya inscrito en este periodo)");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Inscripciones");
    }
}