<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");

    if (usuarioActual == null || !"Profesor".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Usuario> misAlumnos = (List<Usuario>) request.getAttribute("misAlumnos");
    Map<Integer, String> misMaterias = (Map<Integer, String>) request.getAttribute("misMaterias");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
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

            <jsp:include page="menuProfesor.jsp"/>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Mis alumnos</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Alumnos asignados</h2>
                        <span>Total: <%= (misAlumnos != null) ? misAlumnos.size() : 0%> alumnos</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (misAlumnos == null || misAlumnos.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No tienes alumnos asignados todavía</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th class="col-matricula">Matrícula</th>
                                    <th class="col-nombre">Nombre completo</th>
                                    <th class="col-correo">Correo</th>
                                    <th class="col-acciones">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Usuario alumno : misAlumnos)
                                    {
                                        contador++;
                                %>
                                <tr onclick="seleccionarAlumno('<%= alumno.getMatricula()%>', '<%= alumno.getNombre()%> <%= alumno.getPaterno()%>')" style="cursor:pointer;">
                                    <td class="col-num"><%= contador%></td>
                                    <td class="col-matricula"><strong><%= alumno.getMatricula()%></strong></td>
                                    <td class="col-nombre"><%= alumno.getNombre()%> <%= alumno.getPaterno()%> <%= alumno.getMaterno() != null ? alumno.getMaterno() : ""%></td>
                                    <td class="col-correo"><%= alumno.getCorreo()%></td>
                                    <td class="col-acciones"><button type="button" class="btn btn-primary btn-sm">Calificar</button></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Asignar calificación</h3>
                        <form id="formCalificacion" action="${pageContext.request.contextPath}/PanelProfesor" method="POST">
                            <input type="hidden" name="accion" value="guardarCalificacion">
                            <input type="hidden" id="matriculaAlumno" name="matriculaAlumno">

                            <div class="form-group">
                                <label>Alumno seleccionado</label>
                                <input type="text" id="nombreAlumnoSel" readonly placeholder="Selecciona un alumno de la tabla">
                            </div>

                            <div class="form-group">
                                <label>Materia</label>
                                <select id="idMateria" name="idMateria">
                                    <option value="">-- Selecciona --</option>
                                    <%
                                        if (misMaterias != null)
                                        {
                                            for (Map.Entry<Integer, String> m : misMaterias.entrySet())
                                            {
                                    %>
                                    <option value="<%= m.getKey()%>"><%= m.getValue()%></option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Periodo</label>
                                <select id="periodo" name="periodo">
                                    <option value="2026-1" selected>2026-1</option>
                                    <option value="2026-2">2026-2</option>
                                </select>
                            </div>

                            <div class="form-row">
                                <div class="form-group"><label>Parcial 1</label><input type="number" name="parcial1" min="0" max="10" step="0.1" placeholder="8"></div>
                                <div class="form-group"><label>Parcial 2</label><input type="number" name="parcial2" min="0" max="10" step="0.1" placeholder="9"></div>
                            </div>
                            <div class="form-group"><label>Parcial 3</label><input type="number" name="parcial3" min="0" max="10" step="0.1" placeholder="10"></div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Guardar</button>
                                <button type="button" class="btn btn-danger" onclick="limpiarFormulario()">Limpiar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            function seleccionarAlumno(matricula, nombre)
            {
                document.getElementById('matriculaAlumno').value = matricula;
                document.getElementById('nombreAlumnoSel').value = nombre + ' (' + matricula + ')';
            }

            function limpiarFormulario()
            {
                document.getElementById('formCalificacion').reset();
                document.getElementById('nombreAlumnoSel').value = '';
                document.getElementById('matriculaAlumno').value = '';
            }
        </script>
    </body>
</html>