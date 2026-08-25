<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");

    if (usuarioActual == null || !"Profesor".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
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
                                    <td class="col-acciones"><button type="button" class="btn btn-primary btn-sm" onclick="seleccionarAlumno('<%= alumno.getMatricula()%>', '<%= alumno.getNombre()%> <%= alumno.getPaterno()%>')">Calificar</button></td>
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
                                <select id="idMateria" name="idMateria" required>
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
                                <select id="periodo" name="periodo" required>
                                    <option value="">-- Selecciona --</option>
                                    <option value="2026-1">2026-1</option>
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

                <!-- SECCIÓN DE CAMBIO DE CONTRASEÑA -->
                <section id="seccionSeguridad" style="margin-top: 30px; border-top: 2px solid var(--border); padding-top: 20px;">
                    <div class="title-section">
                        <div class="left">
                            <h2>Cambiar contraseña</h2>
                        </div>
                    </div>

                    <div class="form-panel" style="max-width:420px;">
                        <form action="${pageContext.request.contextPath}/CambiarContrasena" method="POST" id="formCambioContrasena">
                            <input type="hidden" name="accion" value="cambiarContrasena">

                            <div class="form-group">
                                <label for="contrasenaActual">Contraseña actual</label>
                                <input type="password" id="contrasenaActual" name="contrasenaActual" required>
                            </div>

                            <div class="form-group">
                                <label for="contrasenaNueva">Contraseña nueva</label>
                                <input type="password" id="contrasenaNueva" name="contrasenaNueva" minlength="8" required>
                            </div>

                            <div class="form-group">
                                <label for="contrasenaConfirmar">Confirmar contraseña nueva</label>
                                <input type="password" id="contrasenaConfirmar" name="contrasenaConfirmar" minlength="8" required>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Actualizar contraseña</button>
                            </div>
                        </form>
                    </div>
                </section>
            </main>
        </div>

        <script>
            function seleccionarAlumno(matricula, nombre)
            {
                document.getElementById('matriculaAlumno').value = matricula;
                document.getElementById('nombreAlumnoSel').value = nombre + ' (' + matricula + ')';
                document.getElementById('formPanel').scrollIntoView({ behavior: 'smooth', block: 'center' });
            }

            function limpiarFormulario()
            {
                document.getElementById('formCalificacion').reset();
                document.getElementById('nombreAlumnoSel').value = '';
                document.getElementById('matriculaAlumno').value = '';
            }

            document.getElementById('formCalificacion').addEventListener('submit', function(e) {
                const matricula = document.getElementById('matriculaAlumno').value.trim();
                if (matricula === '') {
                    e.preventDefault();
                    alert('Por favor, selecciona un alumno de la tabla.');
                }
            });

            document.getElementById('formCambioContrasena').addEventListener('submit', function(e) {
                const actual = document.getElementById('contrasenaActual').value.trim();
                const nueva = document.getElementById('contrasenaNueva').value.trim();
                const confirmar = document.getElementById('contrasenaConfirmar').value.trim();

                if (actual === '') {
                    e.preventDefault();
                    alert('Debes ingresar tu contraseña actual.');
                    return;
                }

                if (nueva.length < 8) {
                    e.preventDefault();
                    alert('La contraseña nueva debe tener al menos 8 caracteres.');
                    return;
                }

                if (nueva !== confirmar) {
                    e.preventDefault();
                    alert('La contraseña nueva y la confirmación no coinciden.');
                    return;
                }

                if (actual === nueva) {
                    e.preventDefault();
                    alert('La contraseña nueva debe ser diferente a la actual.');
                    return;
                }
            });
        </script>
    </body>
</html>