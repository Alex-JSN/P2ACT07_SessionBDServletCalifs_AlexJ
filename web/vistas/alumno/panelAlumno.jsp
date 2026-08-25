<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Calificacion, modelo.Materia, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");

    if (usuarioActual == null || !"Alumno".equals(usuarioActual.getTipoUsuario())) {
        response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
        return;
    }

    List<Calificacion> calificaciones = (List<Calificacion>) request.getAttribute("calificaciones");
    List<Materia> materias = (List<Materia>) request.getAttribute("materias");

    String error = (String) session.getAttribute("error");
    String mensaje = (String) session.getAttribute("mensaje");
    if (error != null) { session.removeAttribute("error"); }
    if (mensaje != null) { session.removeAttribute("mensaje"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Alumno</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAlumno.jsp"/>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Mi panel</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (error != null) { %>
                    <div class="alert alert-error"><%= error%></div>
                <% } %>
                <% if (mensaje != null) { %>
                    <div class="alert alert-success"><%= mensaje%></div>
                <% } %>

                <section id="seccionCalificaciones">
                    <div class="title-section">
                        <div class="left">
                            <h2>Mis calificaciones</h2>
                            <span>Total: <%= (calificaciones != null) ? calificaciones.size() : 0%> registros</span>
                        </div>
                    </div>

                    <div class="table-container" style="height:auto; max-height:320px; margin-bottom:24px;">
                        <% if (calificaciones == null || calificaciones.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">Aún no tienes calificaciones registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-calif">P1</th>
                                    <th class="col-calif">P2</th>
                                    <th class="col-calif">P3</th>
                                    <th class="col-prom">Promedio</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (Calificacion c : calificaciones) {
                                        String p1 = c.getParcial1() != null ? String.valueOf(c.getParcial1()) : "-";
                                        String p2 = c.getParcial2() != null ? String.valueOf(c.getParcial2()) : "-";
                                        String p3 = c.getParcial3() != null ? String.valueOf(c.getParcial3()) : "-";
                                        Double prom = c.getPromedio();
                                        String promClass = prom != null ? (prom >= 8 ? "calif-aprobado" : "calif-reprobado") : "calif-sin";
                                        String promDisplay = prom != null ? String.format("%.1f", prom) : "-";
                                %>
                                <tr>
                                    <td class="col-calif"><%= p1%></td>
                                    <td class="col-calif"><%= p2%></td>
                                    <td class="col-calif"><%= p3%></td>
                                    <td class="col-prom <%= promClass%>"><%= promDisplay%></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>
                </section>

                <!-- SECCIÓN DE CAMBIO DE CONTRASEÑA - SIEMPRE VISIBLE -->
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