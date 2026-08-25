package control.alumno;
import dao.alumno.DAOAlumno;
import modelo.Usuario;
import modelo.Calificacion;
import modelo.Materia;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
@WebServlet(name = "SPanelAlumno", urlPatterns = {"/PanelAlumno"})
public class SPanelAlumno extends HttpServlet
{
    private DAOAlumno daoAlumno = new DAOAlumno();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null)
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (!"Alumno".equals(usuario.getTipoUsuario()))
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }
        try
        {
            Integer idUsuario = usuario.getIdUsuario();
            if (idUsuario != null && idUsuario > 0)
            {
                List<Calificacion> calificaciones = daoAlumno.obtenerCalificacionesPorAlumno(idUsuario);
                List<Materia> materias = daoAlumno.obtenerTodasLasMaterias();
                request.setAttribute("calificaciones", calificaciones);
                request.setAttribute("materias", materias);
            }
            else
            {
                request.setAttribute("error", "No se encontró información del alumno");
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar las calificaciones: " + e.getMessage());
        }
        request.getRequestDispatcher("/vistas/alumno/panelAlumno.jsp").forward(request, response);
    }
}