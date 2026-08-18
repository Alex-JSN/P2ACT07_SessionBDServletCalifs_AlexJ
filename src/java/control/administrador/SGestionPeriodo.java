package control.administrador;

import modelo.Usuario;
import modelo.Periodo;
import dao.administrador.DAOPeriodo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "SPeriodo", urlPatterns = {"/Periodos"})
public class SGestionPeriodo extends HttpServlet
{
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
                int idPeriodo = Integer.parseInt(request.getParameter("idPeriodo"));
                boolean ok = daoPeriodo.eliminar(idPeriodo);
                session.setAttribute(ok ? "mensaje" : "error",
                    ok ? "Periodo eliminado exitosamente" : "No se pudo eliminar el periodo");
                response.sendRedirect(request.getContextPath() + "/Periodos");
                return;
            }

            if ("editar".equals(accion))
            {
                int idPeriodo = Integer.parseInt(request.getParameter("idPeriodo"));
                Periodo periodoEditar = daoPeriodo.obtenerPorId(idPeriodo);
                request.setAttribute("periodoEditar", periodoEditar);
            }

            List<Periodo> periodos = daoPeriodo.listar();
            request.setAttribute("periodos", periodos);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
        }

        request.getRequestDispatcher("/vistas/administrador/periodos.jsp").forward(request, response);
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
            Periodo periodo = new Periodo();
            periodo.setNombre(request.getParameter("nombre"));
            periodo.setFechaInicio(Date.valueOf(request.getParameter("fechaInicio")));
            periodo.setFechaFin(Date.valueOf(request.getParameter("fechaFin")));
            periodo.setEstado(request.getParameter("estado"));

            boolean resultado;
            if ("actualizar".equals(accion))
            {
                periodo.setIdPeriodo(Integer.parseInt(request.getParameter("idPeriodo")));
                resultado = daoPeriodo.actualizar(periodo);
            }
            else
            {
                resultado = daoPeriodo.insertar(periodo);
            }

            session.setAttribute(resultado ? "mensaje" : "error",
                resultado ? "Periodo guardado exitosamente" : "Error al guardar. Verifica que el nombre no esté repetido.");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/Periodos");
    }
}