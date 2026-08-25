<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, java.util.*"%>
<%!
    private String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Profesor".equals(usuarioActual.getTipoUsuario())) {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Object[]> asignaciones = (List<Object[]>) request.getAttribute("asignaciones");
    List<Object[]> alumnosCalificar = (List<Object[]>) request.getAttribute("alumnosCalificar");
    Integer idAsignaSeleccionado = (Integer) request.getAttribute("idAsignaSeleccionado");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
    String errorCarga = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Profesor</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuProfesor.jsp"><jsp:param name="seccion" value="calificaciones"/></jsp:include>

                <main class="content-area">
                    <div class="panel-header">
                        <div class="left">
                            <h1>Mis Materias</h1>
                            <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) {%><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) {%><div class="alert alert-error"><%= esc(error)%></div><% } %>
                <% if (errorCarga != null) {%><div class="alert alert-error"><%= esc(errorCarga)%></div><% } %>

                <% if (asignaciones == null || asignaciones.isEmpty()) { %>
                <div class="alert alert-error">
                    Aún no tienes materias asignadas. Contacta al administrador para que te asigne un grupo.
                </div>
                <% } else {%>

                <div class="title-section">
                    <div class="left">
                        <h2>Materias que impartes</h2>
                        <span>Total: <%= asignaciones.size()%></span>
                    </div>
                </div>

                <div class="main-content" style="grid-template-columns: 320px 1fr;">
                    <div class="table-container" style="padding:8px;">
                        <% for (Object[] a : asignaciones) {
                                int idAsigna = (int) a[0];
                                String nombreMateria = (String) a[1];
                                String nombreGrupo = (String) a[2];
                                String nombrePeriodo = (String) a[3];
                                boolean seleccionado = idAsignaSeleccionado != null && idAsignaSeleccionado == idAsigna;
                        %>
                        <a href="${pageContext.request.contextPath}/PanelProfesor?idAsigna=<%= idAsigna%>"
                           style="display:block; padding:12px 14px; margin-bottom:8px; border-radius:10px; text-decoration:none;
                           border:1px solid var(--border); <%= seleccionado ? "background:#EEF0FE; border-color:var(--steel-light);" : "background:var(--white);"%>">
                            <strong style="display:block; color:var(--navy); font-size:13.5px;"><%= esc(nombreMateria)%></strong>
                            <span style="display:block; font-size:12px; color:var(--ink-soft);"><%= esc(nombreGrupo)%> · <%= esc(nombrePeriodo)%></span>
                        </a>
                        <% } %>
                    </div>

                    <div class="table-container">
                        <% if (idAsignaSeleccionado == null) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">Selecciona una materia de la izquierda para capturar calificaciones.</p>
                        </div>
                        <% } else if (alumnosCalificar == null || alumnosCalificar.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay alumnos inscritos en este grupo para el periodo correspondiente.</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Matrícula</th>
                                    <th>Alumno</th>
                                    <th style="width:70px;">P1</th>
                                    <th style="width:70px;">P2</th>
                                    <th style="width:70px;">P3</th>
                                    <th class="col-acciones">Guardar</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Object[] al : alumnosCalificar) {
                                        contador++;
                                        int idInscripcion = (int) al[0];
                                        String matricula = (String) al[1];
                                        String nombreCompleto = (String) al[2];
                                        Double p1 = (Double) al[3];
                                        Double p2 = (Double) al[4];
                                        Double p3 = (Double) al[5];
                                        String formId = "formCalif" + idInscripcion;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= esc(matricula)%></strong></td>
                                    <td><%= esc(nombreCompleto)%></td>
                                    <td colspan="4" style="padding:0;">
                                        <form id="<%= formId%>" action="${pageContext.request.contextPath}/PanelProfesor" method="POST"
                                              style="display:flex; align-items:center; gap:6px; padding:6px 8px;">
                                            <input type="hidden" name="accion" value="guardarCalificacion">
                                            <input type="hidden" name="idInscripcion" value="<%= idInscripcion%>">
                                            <input type="hidden" name="idAsigna" value="<%= idAsignaSeleccionado%>">
                                            <input type="number" name="parcial1" min="0" max="10" step="0.1" style="width:60px;" value="<%= p1 != null ? p1 : ""%>">
                                            <input type="number" name="parcial2" min="0" max="10" step="0.1" style="width:60px;" value="<%= p2 != null ? p2 : ""%>">
                                            <input type="number" name="parcial3" min="0" max="10" step="0.1" style="width:60px;" value="<%= p3 != null ? p3 : ""%>">
                                            <button type="submit" class="btn btn-primary btn-sm">💾</button>
                                        </form>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>
                </div>
                <% }%>
            </main>
        </div>
    </body>
</html>