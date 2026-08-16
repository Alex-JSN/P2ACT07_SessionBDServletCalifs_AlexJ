package control;

import modelo.Usuario;
import modelo.Calificacion;
import modelo.Materia;
import dao.DAOAdministrador;
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
                daoAdmin.eliminarUsuarioPorMatricula(matricula);
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
                Usuario usuario = daoAdmin.obtenerUsuarioPorMatricula(matricula);
                List<Calificacion> calificaciones = daoAdmin.obtenerCalificacionesPorMatricula(matricula);
                request.setAttribute("usuarioEditar", usuario);
                request.setAttribute("calificacionesEditar", calificaciones);
            }

            List<Usuario> usuarios = daoAdmin.obtenerTodosLosUsuariosAlumnos();
            List<Materia> materias = daoAdmin.obtenerTodasLasMaterias();

            for (Usuario usuario : usuarios)
            {
                List<Calificacion> califs = daoAdmin.obtenerCalificacionesPorMatricula(usuario.getMatricula());
                request.setAttribute("califs_" + usuario.getMatricula(), califs);
            }

            request.setAttribute("usuarios", usuarios);
            request.setAttribute("materias", materias);
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
            if ("guardarCalificacion".equals(accion))
            {
                String matricula = request.getParameter("matriculaAlumno");
                int idMateria = Integer.parseInt(request.getParameter("idMateria"));
                String periodo = request.getParameter("periodo");

                String p1 = request.getParameter("parcial1");
                String p2 = request.getParameter("parcial2");
                String p3 = request.getParameter("parcial3");

                Double parcial1 = (p1 != null && !p1.isEmpty()) ? Double.parseDouble(p1) : null;
                Double parcial2 = (p2 != null && !p2.isEmpty()) ? Double.parseDouble(p2) : null;
                Double parcial3 = (p3 != null && !p3.isEmpty()) ? Double.parseDouble(p3) : null;

                boolean resultado = daoAdmin.guardarCalificacion(matricula, idMateria, periodo, parcial1, parcial2, parcial3);
                session.setAttribute(resultado ? "mensaje" : "error",
                    resultado ? "Calificación guardada exitosamente" : "Error al guardar la calificación (revisa que el alumno esté inscrito y tenga esa materia asignada)");
            }
            else if ("eliminarCalificacion".equals(accion))
            {
                String matricula = request.getParameter("matriculaAlumno");
                int idMateria = Integer.parseInt(request.getParameter("idMateria"));
                String periodo = request.getParameter("periodo");

                boolean resultado = daoAdmin.eliminarCalificacion(matricula, idMateria, periodo);
                session.setAttribute(resultado ? "mensaje" : "error",
                    resultado ? "Calificación eliminada exitosamente" : "Error al eliminar la calificación");
            }
            else if ("actualizarUsuario".equals(accion))
            {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(Integer.parseInt(request.getParameter("idUsuario")));
                usuario.setMatricula(request.getParameter("matricula"));
                usuario.setNombre(request.getParameter("nombre"));
                usuario.setPaterno(request.getParameter("paterno"));
                usuario.setMaterno(request.getParameter("materno"));
                usuario.setCorreo(request.getParameter("correo"));

                boolean resultado = daoAdmin.actualizarUsuario(usuario);
                session.setAttribute(resultado ? "mensaje" : "error",
                    resultado ? "Usuario actualizado exitosamente" : "Error al actualizar el usuario");
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/PanelAdministrador");
    }
}