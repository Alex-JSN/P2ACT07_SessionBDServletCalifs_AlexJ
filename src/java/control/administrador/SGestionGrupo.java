package control.administrador;

import modelo.Usuario;
import modelo.Grupo;
import modelo.Carrera;
import modelo.Periodo;
import dao.administrador.DAOGrupo;
import dao.administrador.DAOCarrera;
import dao.administrador.DAOPeriodo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SGrupo", urlPatterns = {"/Grupos"})
public class SGestionGrupo extends HttpServlet
{
    private DAOGrupo daoGrupo = new DAOGrupo();
    private DAOCarrera daoCarrera = new DAOCarrera();
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
            if ("eliminar".equals(accion))
            {
                int idGrupo = Integer.parseInt(request.getParameter("idGrupo"));
                boolean ok = daoGrupo.eliminar(idGrupo);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Grupo eliminado exitosamente" : "No se pudo eliminar el grupo");
                response.sendRedirect(request.getContextPath() + "/Grupos");
                return;
            }

            if ("editar".equals(accion))
            {
                int idGrupo = Integer.parseInt(request.getParameter("idGrupo"));
                Grupo grupoEditar = daoGrupo.obtenerPorId(idGrupo);
                request.setAttribute("grupoEditar", grupoEditar);
            }

            List<Grupo> grupos = daoGrupo.listar();
            List<Carrera> carreras = daoCarrera.listar();
            List<Periodo> periodos = daoPeriodo.listar();

            request.setAttribute("grupos", grupos);
            request.setAttribute("carreras", carreras);
            request.setAttribute("periodos", periodos);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/grupos.jsp").forward(request, response);
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
            Grupo grupo = new Grupo();
            grupo.setGeneracion(request.getParameter("generacion"));
            grupo.setCuatrimestre(Integer.parseInt(request.getParameter("cuatrimestre")));
            grupo.setLetra(request.getParameter("letra"));
            grupo.setIdCarrera(Integer.parseInt(request.getParameter("idCarrera")));
            grupo.setIdPeriodo(Integer.parseInt(request.getParameter("idPeriodo")));

            boolean resultado;
            if ("actualizar".equals(accion))
            {
                grupo.setIdGrupo(Integer.parseInt(request.getParameter("idGrupo")));
                resultado = daoGrupo.actualizar(grupo);
            }
            else
            {
                resultado = daoGrupo.insertar(grupo);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Grupo guardado exitosamente" : "Error al guardar. Verifica que no exista ya ese grupo (misma generación, cuatrimestre, letra, carrera y periodo).");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Grupos");
    }
}