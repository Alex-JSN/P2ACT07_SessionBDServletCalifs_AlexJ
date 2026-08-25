package control.profesor;
import modelo.Usuario;
import modelo.Calificacion;
import modelo.Materia;
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
public class SPanelProfesor extends HttpServlet
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
        if (!"Profesor".equals(usuarioActual.getTipoUsuario()))
        {
            response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
            return;
        }
        try
        {
            Integer idUsuario = usuarioActual.getIdUsuario();
            // TODO: DAOProfesor necesita resolver IdUsuario -> IdProfesor
            // (tabla profesores.IdUsuario) antes de poder buscar en "asigna".
            //
            // Propuesta de métodos que hacen falta en DAOProfesor:
            //   List<Usuario> obtenerAlumnosPorProfesor(int idUsuario)
            //       -> JOIN asigna (por IdProfesor) -> grupos -> alumnos -> usuarios
            //   Map<Integer,String> obtenerMateriasQueImparte(int idUsuario)
            //       -> JOIN asigna (por IdProfesor) -> materias
//            List<Usuario> misAlumnos = DAOProfesor.obtenerAlumnosPorProfesor(idUsuario);
//            List<Materia> misMaterias = DAOProfesor.obtenerMateriasQueImparte(idUsuario);
//            request.setAttribute("misAlumnos", misAlumnos);
//            request.setAttribute("misMaterias", misMaterias);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar tus alumnos: " + e.getMessage());
        }
        request.getRequestDispatcher("/vistas/profesor/panelProfesor.jsp").forward(request, response);
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
            if ("guardarCalificacion".equals(accion))
            {
                // TODO: falta la lógica real. Necesita, como mínimo:
                //   - Validar que el profesor autenticado SÍ imparte esa materia/grupo
                //     (evitar que capture notas de una materia que no le corresponde).
                //   - int idAlumno = ...
                //   - int idMateria = ...
                //   - String periodo = request.getParameter("periodo");
                //   - Double parcial1/2/3 igual que en SPanelAdmin
                //   - boolean resultado = daoProfesor.guardarCalificacion(...);
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "❌ Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/PanelProfesor");
    }
}