package control.administrador;

import modelo.Usuario;
import modelo.Materia;
import modelo.Carrera;
import dao.administrador.DAOMateria;
import dao.administrador.DAOCarrera;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SMateria", urlPatterns = {"/Materias"})
public class SGestionMateria extends HttpServlet
{
    private DAOMateria daoMateria = new DAOMateria();
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

        try
        {
            if ("eliminar".equals(accion))
            {
                int idMateria = Integer.parseInt(request.getParameter("idMateria"));
                boolean ok = daoMateria.eliminar(idMateria);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Materia eliminada exitosamente" : "No se pudo eliminar la materia");
                response.sendRedirect(request.getContextPath() + "/Materias");
                return;
            }

            if ("editar".equals(accion))
            {
                int idMateria = Integer.parseInt(request.getParameter("idMateria"));
                Materia materiaEditar = daoMateria.obtenerPorId(idMateria);
                request.setAttribute("materiaEditar", materiaEditar);
            }

            List<Materia> materias = daoMateria.listar();
            List<Carrera> carreras = daoCarrera.listar(); // para el combo del form

            request.setAttribute("materias", materias);
            request.setAttribute("carreras", carreras);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/materias.jsp").forward(request, response);
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
            Materia materia = new Materia();
            materia.setMateria(request.getParameter("materia"));
            materia.setCuatrimestre(Integer.parseInt(request.getParameter("cuatrimestre")));
            materia.setIdCarrera(Integer.parseInt(request.getParameter("idCarrera")));

            boolean resultado;
            if ("actualizar".equals(accion))
            {
                materia.setIdMateria(Integer.parseInt(request.getParameter("idMateria")));
                resultado = daoMateria.actualizar(materia);
            }
            else
            {
                resultado = daoMateria.insertar(materia);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Materia guardada exitosamente" : "Error al guardar. Verifica que no exista ya esa materia en esa carrera.");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Materias");
    }
}