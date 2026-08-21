<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Inscripcion, modelo.Periodo, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Inscripcion> inscripciones = (List<Inscripcion>) request.getAttribute("inscripciones");
    List<Periodo> periodos = (List<Periodo>) request.getAttribute("periodos");
    List<Object[]> alumnosDisponibles = (List<Object[]>) request.getAttribute("alumnosDisponibles");
    Integer idPeriodoSeleccionado = (Integer) request.getAttribute("idPeriodoSeleccionado");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Inscripciones</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="inscripciones"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Inscripciones</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <% if (periodos == null || periodos.isEmpty()) { %>
                <div class="alert alert-error">
                    Necesitas registrar al menos un periodo antes de inscribir alumnos.
                    <a href="${pageContext.request.contextPath}/Periodos">Ir a Periodos</a>
                </div>
                <% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Inscripciones registradas</h2>
                        <span>Total: <%= (inscripciones != null) ? inscripciones.size() : 0%> inscripciones</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (inscripciones == null || inscripciones.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay inscripciones registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Alumno</th>
                                    <th>Matrícula</th>
                                    <th>Periodo</th>
                                    <th>Cuatrimestre</th>
                                    <th>Estado</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Inscripcion i : inscripciones)
                                    {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><%= i.getNombreAlumno()%></td>
                                    <td><strong><%= i.getMatriculaAlumno()%></strong></td>
                                    <td><%= i.getNombrePeriodo()%></td>
                                    <td><%= i.getCuatrimestre()%></td>
                                    <td><span class="badge <%= "Inscrito".equals(i.getEstado()) ? "badge-success" : "badge-danger"%>"><%= i.getEstado()%></span></td>
                                    <td class="col-acciones">
                                        <% if ("Inscrito".equals(i.getEstado())) { %>
                                        <button class="btn btn-danger btn-sm" onclick="darBaja(<%= i.getIdInscripcion()%>)" title="Dar de baja">🔴</button>
                                        <% } else { %>
                                        <button class="btn btn-success btn-sm" onclick="reactivar(<%= i.getIdInscripcion()%>)" title="Reactivar">🟢</button>
                                        <% } %>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarInscripcion(<%= i.getIdInscripcion()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Inscribir Alumno</h3>

                        <form method="GET" action="${pageContext.request.contextPath}/Inscripciones" style="margin-bottom:16px;">
                            <div class="form-group">
                                <label>1. Selecciona el Periodo</label>
                                <select name="idPeriodo" onchange="this.form.submit()">
                                    <option value="">-- SELECCIONA UN PERIODO --</option>
                                    <% if (periodos != null) { for (Periodo p : periodos) { %>
                                    <option value="<%= p.getIdPeriodo()%>" <%= (idPeriodoSeleccionado != null && idPeriodoSeleccionado == p.getIdPeriodo()) ? "selected" : ""%>><%= p.getNombre()%></option>
                                    <% } } %>
                                </select>
                            </div>
                        </form>

                        <% if (idPeriodoSeleccionado != null) { %>
                        <form action="${pageContext.request.contextPath}/Inscripciones" method="POST">
                            <input type="hidden" name="idPeriodo" value="<%= idPeriodoSeleccionado%>">

                            <div class="form-group">
                                <label>2. Alumno a inscribir</label>
                                <select name="idAlumno" required>
                                    <option value="">-- SELECCIONA UN ALUMNO --</option>
                                    <% if (alumnosDisponibles != null) { for (Object[] a : alumnosDisponibles) { %>
                                    <option value="<%= a[0]%>"><%= a[2]%> - <%= a[1]%></option>
                                    <% } } %>
                                </select>
                                <% if (alumnosDisponibles != null && alumnosDisponibles.isEmpty()) { %>
                                <small>Todos los alumnos ya están inscritos en este periodo.</small>
                                <% } %>
                            </div>

                            <div class="form-group">
                                <label>Cuatrimestre</label>
                                <input type="text" name="cuatrimestre" maxlength="45" required placeholder="9">
                            </div>

                            <button type="submit" class="btn btn-primary">Inscribir</button>
                        </form>
                        <% } else { %>
                        <p style="color:#718096; font-size:14px;">Selecciona un periodo para ver los alumnos disponibles.</p>
                        <% } %>
                    </div>
                </div>
            </main>
        </div>

        <script>
            function darBaja(id)
            {
                if (confirm('¿Dar de baja esta inscripción?\nEl alumno ya no podrá recibir calificaciones en este periodo.'))
                { window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=baja&idInscripcion=' + id; }
            }

            function reactivar(id)
            {
                if (confirm('¿Reactivar esta inscripción?'))
                { window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=reactivar&idInscripcion=' + id; }
            }

            function eliminarInscripcion(id)
            {
                if (confirm('⚠️ ¿Eliminar esta inscripción?\nSe eliminarán también sus calificaciones asociadas.'))
                { window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=eliminar&idInscripcion=' + id; }
            }
        </script>
    </body>
</html>