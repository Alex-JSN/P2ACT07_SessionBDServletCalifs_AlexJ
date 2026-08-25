package control.administrador;

import modelo.Usuario;
import dao.administrador.DAOAlumno;
import dao.administrador.DAOProfesor;
import dao.administrador.DAOMateria;
import dao.administrador.DAOCarrera;
import dao.administrador.DAOGrupo;
import dao.administrador.DAOPeriodo;
import dao.administrador.DAOInscripcion;
import dao.administrador.DAOAsignacion;
import dao.administrador.DAOCuenta;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "SPanelAdmin", urlPatterns = {"/PanelAdministrador"})
public class SPanelAdmin extends HttpServlet
{
    private DAOAlumno daoAlumno = new DAOAlumno();
    private DAOProfesor daoProfesor = new DAOProfesor();
    private DAOMateria daoMateria = new DAOMateria();
    private DAOCarrera daoCarrera = new DAOCarrera();
    private DAOGrupo daoGrupo = new DAOGrupo();
    private DAOPeriodo daoPeriodo = new DAOPeriodo();
    private DAOInscripcion daoInscripcion = new DAOInscripcion();
    private DAOAsignacion daoAsignacion = new DAOAsignacion();
    private DAOCuenta daoCuenta = new DAOCuenta();

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

        try
        {
            request.setAttribute("totalAlumnos", daoAlumno.listar().size());
            request.setAttribute("totalProfesores", daoProfesor.listar().size());
            request.setAttribute("totalMaterias", daoMateria.listar().size());
            request.setAttribute("totalCarreras", daoCarrera.listar().size());
            request.setAttribute("totalGrupos", daoGrupo.listar().size());
            request.setAttribute("totalPeriodos", daoPeriodo.listar().size());
            request.setAttribute("totalInscripciones", daoInscripcion.listar().size());
            request.setAttribute("totalAsignaciones", daoAsignacion.listar().size());
            request.setAttribute("totalCuentas", daoCuenta.listar().size());
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/vistas/administrador/panelAdministrador.jsp").forward(request, response);
    }
}