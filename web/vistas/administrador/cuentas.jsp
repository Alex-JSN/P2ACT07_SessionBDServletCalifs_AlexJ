<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Cuentas</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
        <style>
            /* Esta vista no usa panel lateral (no hay formulario visible que
               justifique 2 columnas), así que forzamos una sola columna
               a ancho completo sin tocar el CSS global compartido. */
            .main-content.full-width {
                display: block;
                width: 100%;
            }
            .full-width .table-container {
                width: 100%;
            }
            .col-acciones {
                min-width: 160px;
                white-space: nowrap;
            }
            .col-acciones .btn {
                margin-right: 4px;
            }
        </style>
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="cuentas"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Cuentas</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Cuentas registradas</h2>
                        <span>Total: <%= (usuarios != null) ? usuarios.size() : 0%> cuentas</span>
                    </div>
                </div>

                <div class="main-content full-width">
                    <div class="table-container">
                        <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay cuentas registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Matrícula</th>
                                    <th>Nombre Completo</th>
                                    <th>Correo</th>
                                    <th>Tipo</th>
                                    <th>Estado</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Usuario u : usuarios)
                                    {
                                        contador++;
                                        String rowClass = "Inactivo".equals(u.getEstado()) ? "inactivo" : "";
                                %>
                                <tr class="<%= rowClass%>">
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= u.getMatricula() != null ? u.getMatricula() : "—"%></strong></td>
                                    <td><%= u.getNombre()%> <%= u.getPaterno()%> <%= u.getMaterno() != null ? u.getMaterno() : ""%></td>
                                    <td><%= u.getCorreo()%></td>
                                    <td><span class="badge"><%= u.getTipoUsuario()%></span></td>
                                    <td><span class="badge <%= "Activo".equals(u.getEstado()) ? "badge-success" : "badge-danger"%>"><%= u.getEstado()%></span></td>
                                    <td class="col-acciones">
                                        <% if (u.isEsProtegido()) { %>
                                        <span style="font-size:12px; color:#a0aec0;">Cuenta protegida</span>
                                        <% } else { %>
                                        <button class="btn btn-sm <%= "Activo".equals(u.getEstado()) ? "btn-danger" : "btn-success"%>" onclick="toggleEstado(<%= u.getIdUsuario()%>, '<%= u.getEstado()%>')" title="<%= "Activo".equals(u.getEstado()) ? "Desactivar" : "Activar"%>"><%= "Activo".equals(u.getEstado()) ? "🔴" : "🟢"%></button>
                                        <button class="btn btn-warning btn-sm" onclick="cambiarContrasena(<%= u.getIdUsuario()%>, '<%= u.getNombre()%>')" title="Restablecer contraseña">🔑</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarCuenta(<%= u.getIdUsuario()%>)" title="Eliminar">🗑️</button>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>
                </div>
            </main>
        </div>

        <form id="formCambiarContrasena" action="${pageContext.request.contextPath}/Cuentas" method="POST" style="display:none;">
            <input type="hidden" name="accion" value="cambiarContrasena">
            <input type="hidden" id="idUsuarioContrasena" name="idUsuario" value="">
            <input type="hidden" id="nuevaContrasenaInput" name="nuevaContrasena" value="">
        </form>

        <script>
            function toggleEstado(idUsuario, estadoActual)
            {
                const nuevoEstado = estadoActual === 'Activo' ? 'Inactivo' : 'Activo';
                const mensaje = nuevoEstado === 'Activo' ? '¿Activar esta cuenta?' : '¿Desactivar esta cuenta?';
                if (!confirm(mensaje)) return;
                window.location.href = '${pageContext.request.contextPath}/Cuentas?accion=cambiarEstado&idUsuario=' + idUsuario + '&estado=' + nuevoEstado;
            }

            function eliminarCuenta(idUsuario)
            {
                if (confirm('⚠️ ¿Eliminar esta cuenta?\nEsto también eliminará sus datos asociados (alumno/profesor, calificaciones, etc.).'))
                { window.location.href = '${pageContext.request.contextPath}/Cuentas?accion=eliminar&idUsuario=' + idUsuario; }
            }

            function cambiarContrasena(idUsuario, nombre)
            {
                const nueva = prompt('Nueva contraseña para ' + nombre + ' (mínimo 8 caracteres):');
                if (nueva === null) return; // canceló
                if (nueva.trim().length < 8)
                {
                    alert('La contraseña debe tener al menos 8 caracteres.');
                    return;
                }
                document.getElementById('idUsuarioContrasena').value = idUsuario;
                document.getElementById('nuevaContrasenaInput').value = nueva.trim();
                document.getElementById('formCambiarContrasena').submit();
            }
        </script>
    </body>
</html>