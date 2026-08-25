package control.profesor;

import modelo.Usuario;
import dao.profesor.DAOProfesor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SPanelProfesor", urlPatterns = {"/PanelProfesor"})
public class SPanelProfesor extends HttpServlet {

    private DAOProfesor daoProfesor = new DAOProfesor();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        if (!"Profesor".equals(usuarioActual.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        try {
            int idProfesor = daoProfesor.obtenerIdProfesorPorIdUsuario(usuarioActual.getIdUsuario());
            if (idProfesor <= 0) {
                request.setAttribute("error", "No se encontró tu perfil de profesor. Contacta al administrador.");
            } else {
                List<Object[]> asignaciones = daoProfesor.obtenerAsignaciones(idProfesor);
                request.setAttribute("asignaciones", asignaciones);

                String idAsignaParam = request.getParameter("idAsigna");
                if (idAsignaParam != null && !idAsignaParam.isEmpty()) {
                    int idAsigna = Integer.parseInt(idAsignaParam);
                    if (daoProfesor.perteneceAProfesor(idAsigna, idProfesor)) {
                        List<Object[]> alumnos = daoProfesor.obtenerAlumnosParaCalificar(idAsigna);
                        request.setAttribute("alumnosCalificar", alumnos);
                        request.setAttribute("idAsignaSeleccionado", idAsigna);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar tu información: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/profesor/panelProfesor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        String accion = request.getParameter("accion");
        int idAsigna = 0;

        try {
            if ("guardarCalificacion".equals(accion)) {
                int idProfesor = daoProfesor.obtenerIdProfesorPorIdUsuario(usuarioActual.getIdUsuario());
                idAsigna = Integer.parseInt(request.getParameter("idAsigna"));

                // Verificación de seguridad: que esta materia/grupo sí le pertenezca a este profesor
                if (!daoProfesor.perteneceAProfesor(idAsigna, idProfesor)) {
                    session.setAttribute("error", "No tienes permiso para calificar esta materia.");
                    response.sendRedirect(request.getContextPath() + "/PanelProfesor");
                    return;
                }

                int idInscripcion = Integer.parseInt(request.getParameter("idInscripcion"));

                String p1 = request.getParameter("parcial1");
                String p2 = request.getParameter("parcial2");
                String p3 = request.getParameter("parcial3");

                Double parcial1 = (p1 != null && !p1.isEmpty()) ? Double.parseDouble(p1) : null;
                Double parcial2 = (p2 != null && !p2.isEmpty()) ? Double.parseDouble(p2) : null;
                Double parcial3 = (p3 != null && !p3.isEmpty()) ? Double.parseDouble(p3) : null;

                boolean resultado = daoProfesor.guardarCalificacion(idInscripcion, idAsigna, parcial1, parcial2, parcial3);
                session.setAttribute(resultado ? "mensaje" : "error",
                        resultado ? "Calificación guardada" : "Error al guardar la calificación");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/PanelProfesor" + (idAsigna > 0 ? "?idAsigna=" + idAsigna : ""));
    }
}
