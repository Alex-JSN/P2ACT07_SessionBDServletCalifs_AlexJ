<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Asignacion, modelo.Profesor, modelo.Materia, modelo.Grupo, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Asignacion> asignaciones = (List<Asignacion>) request.getAttribute("asignaciones");
    List<Profesor> profesores = (List<Profesor>) request.getAttribute("profesores");
    List<Materia> materias = (List<Materia>) request.getAttribute("materias");
    List<Grupo> grupos = (List<Grupo>) request.getAttribute("grupos");

    boolean faltanDatos = (profesores == null || profesores.isEmpty() || materias == null || materias.isEmpty() || grupos == null || grupos.isEmpty());

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Asignaciones</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="asignaciones"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Asignación de Materias a Profesores</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <% if (faltanDatos) { %>
                <div class="alert alert-error">
                    Necesitas al menos un Profesor, una Materia y un Grupo registrados antes de asignar.
                    <a href="${pageContext.request.contextPath}/GestionProfesores">Profesores</a> |
                    <a href="${pageContext.request.contextPath}/Materias">Materias</a> |
                    <a href="${pageContext.request.contextPath}/Grupos">Grupos</a>
                </div>
                <% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Asignaciones registradas</h2>
                        <span>Total: <%= (asignaciones != null) ? asignaciones.size() : 0%> asignaciones</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (asignaciones == null || asignaciones.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay asignaciones registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Profesor</th>
                                    <th>Materia</th>
                                    <th>Grupo</th>
                                    <th>Periodo</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Asignacion a : asignaciones)
                                    {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><%= a.getNombreProfesor()%></td>
                                    <td><%= a.getNombreMateria()%></td>
                                    <td><%= a.getNombreGrupo()%></td>
                                    <td><%= a.getNombrePeriodo()%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-danger btn-sm" onclick="eliminarAsignacion(<%= a.getIdAsigna()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Nueva Asignación</h3>
                        <form action="${pageContext.request.contextPath}/Asignaciones" method="POST">
                            <div class="form-group">
                                <label>Profesor</label>
                                <select name="idProfesor" required>
                                    <option value="">-- SELECCIONA UN PROFESOR --</option>
                                    <% if (profesores != null) { for (Profesor p : profesores) { %>
                                    <option value="<%= p.getIdProfesor()%>"><%= p.getNombre()%> <%= p.getPaterno()%></option>
                                    <% } } %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Materia</label>
                                <select name="idMateria" required>
                                    <option value="">-- SELECCIONA UNA MATERIA --</option>
                                    <% if (materias != null) { for (Materia m : materias) { %>
                                    <option value="<%= m.getIdMateria()%>"><%= m.getMateria()%> (Cuatri <%= m.getCuatrimestre()%>)</option>
                                    <% } } %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Grupo</label>
                                <select name="idGrupo" required>
                                    <option value="">-- SELECCIONA UN GRUPO --</option>
                                    <% if (grupos != null) { for (Grupo g : grupos) { %>
                                    <option value="<%= g.getIdGrupo()%>"><%= g.getCuatrimestre()%><%= g.getLetra()%> - <%= g.getGeneracion()%></option>
                                    <% } } %>
                                </select>
                            </div>

                            <button type="submit" class="btn btn-primary" <%= faltanDatos ? "disabled" : ""%>>Asignar</button>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            function eliminarAsignacion(id)
            {
                if (confirm('⚠️ ¿Eliminar esta asignación?\nSe eliminarán también las calificaciones capturadas para ella.'))
                { window.location.href = '${pageContext.request.contextPath}/Asignaciones?accion=eliminar&idAsigna=' + id; }
            }
        </script>
    </body>
</html>