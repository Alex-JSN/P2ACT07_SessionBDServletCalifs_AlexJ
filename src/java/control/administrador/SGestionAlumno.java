package control.administrador;

import modelo.Usuario;
import modelo.Alumno;
import modelo.Carrera;
import modelo.Grupo;
import modelo.Calificacion;
import dao.administrador.DAOAlumno;
import dao.administrador.DAOCarrera;
import dao.administrador.DAOGrupo;
import dao.administrador.DAOAdministrador;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SGestionAlumno", urlPatterns = {"/Alumnos"})
public class SGestionAlumno extends HttpServlet {

    private DAOAlumno daoAlumno = new DAOAlumno();
    private DAOCarrera daoCarrera = new DAOCarrera();
    private DAOGrupo daoGrupo = new DAOGrupo();
    private DAOAdministrador daoAdmin = new DAOAdministrador();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
        if (!"Administrador".equals(usuarioActual.getTipoUsuario())) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        String matricula = request.getParameter("matricula");

        try {
            if ("eliminar".equals(accion) && matricula != null) {
                boolean ok = daoAlumno.eliminarPorMatricula(matricula);
                session.setAttribute(ok ? "mensaje" : "error",
                        ok ? "Alumno eliminado exitosamente" : "No se pudo eliminar el alumno");
                response.sendRedirect(request.getContextPath() + "/Alumnos");
                return;
            }

            List<Alumno> alumnos = daoAlumno.listar();
            List<Carrera> carreras = daoCarrera.listar();
            List<Grupo> grupos = daoGrupo.listar();

            for (Alumno a : alumnos) {
                List<Calificacion> califs = daoAdmin.obtenerCalificacionesPorMatricula(a.getMatricula());
                request.setAttribute("califs_" + a.getMatricula(), califs);
            }

            request.setAttribute("alumnos", alumnos);
            request.setAttribute("carreras", carreras);
            request.setAttribute("grupos", grupos);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/alumnos.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        try {
            Alumno alumno = new Alumno();
            alumno.setMatricula(request.getParameter("matriculaNueva"));
            alumno.setNombre(request.getParameter("nombre"));
            alumno.setPaterno(request.getParameter("paterno"));
            alumno.setMaterno(request.getParameter("materno"));
            alumno.setCorreo(request.getParameter("correo"));
            alumno.setIdCarrera(Integer.parseInt(request.getParameter("idCarrera")));

            String idGrupoParam = request.getParameter("idGrupo");
            alumno.setIdGrupo((idGrupoParam != null && !idGrupoParam.isEmpty()) ? Integer.parseInt(idGrupoParam) : 0);

            boolean resultado;
            if ("actualizarAlumno".equals(accion)) {
                alumno.setIdAlumno(Integer.parseInt(request.getParameter("idAlumno")));
                resultado = daoAlumno.actualizar(alumno);
            } else {
                resultado = daoAlumno.insertar(alumno);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                    resultado ? "Alumno guardado exitosamente" : "Error al guardar. Verifica que la matrícula/correo no estén repetidos.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Alumnos");
    }
}
