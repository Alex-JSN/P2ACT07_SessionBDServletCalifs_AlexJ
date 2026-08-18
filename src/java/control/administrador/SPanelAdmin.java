package control.administrador;

import modelo.Usuario;
import modelo.Alumno;
import modelo.Calificacion;
import modelo.Carrera;
import dao.administrador.DAOAdministrador;
import dao.administrador.DAOAlumno;
import dao.administrador.DAOCarrera;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SPanelAdmin", urlPatterns = {"/PanelAdministrador"})
public class SPanelAdmin extends HttpServlet
{
    private DAOAdministrador daoAdmin = new DAOAdministrador();
    private DAOAlumno daoAlumnoAdmin = new DAOAlumno();
    private DAOCarrera daoCarrera = new DAOCarrera();

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
        String matricula = request.getParameter("matricula");

        try
        {
            if ("eliminar".equals(accion) && matricula != null)
            {
                boolean ok = daoAlumnoAdmin.eliminarPorMatricula(matricula);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Alumno eliminado exitosamente" : "No se pudo eliminar el alumno");
                response.sendRedirect(request.getContextPath() + "/PanelAdministrador");
                return;
            }

            if ("cambiarEstado".equals(accion) && matricula != null)
            {
                String nuevoEstado = request.getParameter("estado");
                daoAdmin.cambiarEstadoPorMatricula(matricula, nuevoEstado);
                response.sendRedirect(request.getContextPath() + "/PanelAdministrador");
                return;
            }

            if ("editar".equals(accion) && matricula != null)
            {
                Alumno alumnoEditar = daoAlumnoAdmin.obtenerPorMatricula(matricula);
                request.setAttribute("alumnoEditar", alumnoEditar);
            }

            List<Alumno> alumnos = daoAlumnoAdmin.listar();
            List<Carrera> carreras = daoCarrera.listar();

            // Solo lectura: para mostrar el promedio/avance de cada alumno en la tabla
            for (Alumno alumno : alumnos)
            {
                List<Calificacion> califs = daoAdmin.obtenerCalificacionesPorMatricula(alumno.getMatricula());
                request.setAttribute("califs_" + alumno.getMatricula(), califs);
            }

            request.setAttribute("alumnos", alumnos);
            request.setAttribute("carreras", carreras);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/panelAdministrador.jsp").forward(request, response);
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

        String accion = request.getParameter("accion");

        try
        {
            Alumno alumno = new Alumno();
            alumno.setMatricula(request.getParameter("matriculaNueva"));
            alumno.setNombre(request.getParameter("nombre"));
            alumno.setPaterno(request.getParameter("paterno"));
            alumno.setMaterno(request.getParameter("materno"));
            alumno.setCorreo(request.getParameter("correo"));
            alumno.setIdCarrera(Integer.parseInt(request.getParameter("idCarrera")));

            boolean resultado;
            if ("actualizarAlumno".equals(accion))
            {
                alumno.setIdAlumno(Integer.parseInt(request.getParameter("idAlumno")));
                resultado = daoAlumnoAdmin.actualizar(alumno);
            }
            else
            {
                resultado = daoAlumnoAdmin.insertar(alumno);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Alumno guardado exitosamente" : "Error al guardar. Verifica que la matrícula/correo no estén repetidos.");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/PanelAdministrador");
    }
}