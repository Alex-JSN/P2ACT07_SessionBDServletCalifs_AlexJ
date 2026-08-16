package control;

import modelo.Usuario;
import modelo.Carrera;
import dao.DAOCarrera;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SCarrera", urlPatterns = {"/Carreras"})
public class SCarrera extends HttpServlet
{
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
                int idCarrera = Integer.parseInt(request.getParameter("idCarrera"));
                boolean ok = daoCarrera.eliminar(idCarrera);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Carrera eliminada exitosamente" : "No se pudo eliminar la carrera");
                response.sendRedirect(request.getContextPath() + "/Carreras");
                return;
            }

            if ("editar".equals(accion))
            {
                int idCarrera = Integer.parseInt(request.getParameter("idCarrera"));
                Carrera carreraEditar = daoCarrera.obtenerPorId(idCarrera);
                request.setAttribute("carreraEditar", carreraEditar);
            }

            List<Carrera> carreras = daoCarrera.listar();
            request.setAttribute("carreras", carreras);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/carreras.jsp").forward(request, response);
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
            Carrera carrera = new Carrera();
            carrera.setClave(request.getParameter("clave"));
            carrera.setCarrera(request.getParameter("carrera"));
            carrera.setTotalCuatrimestres(Integer.parseInt(request.getParameter("totalCuatrimestres")));
            carrera.setCuatrimestreEstadia(Integer.parseInt(request.getParameter("cuatrimestreEstadia")));

            boolean resultado;
            if ("actualizar".equals(accion))
            {
                carrera.setIdCarrera(Integer.parseInt(request.getParameter("idCarrera")));
                resultado = daoCarrera.actualizar(carrera);
            }
            else
            {
                resultado = daoCarrera.insertar(carrera);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Carrera guardada exitosamente" : "Error al guardar. Verifica que la clave no esté repetida.");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Carreras");
    }
}