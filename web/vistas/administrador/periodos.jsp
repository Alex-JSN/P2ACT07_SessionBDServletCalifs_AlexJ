<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Periodo, java.util.*"%>
<%!
    // Escapa caracteres especiales de HTML/atributos para evitar XSS.
    // Usalo siempre que insertes datos de usuario o BD dentro de una expresion de salida,
    // ya sea en el cuerpo del HTML o dentro de un atributo (value="...", data-x="...").
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Periodo> periodos = (List<Periodo>) request.getAttribute("periodos");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel Administrador - Periodos</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="periodos"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Periodos</h1>
                        <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= esc(error)%></div><% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Periodos registrados</h2>
                        <span>Total: <%= (periodos != null) ? periodos.size() : 0%> periodos</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (periodos == null || periodos.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay periodos registrados</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Nombre</th>
                                    <th>Fecha Inicio</th>
                                    <th>Fecha Fin</th>
                                    <th>Estado</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Periodo p : periodos)
                                    {
                                        contador++;
                                        String badgeClase;
                                        switch (p.getEstado())
                                        {
                                            case "Activo":     badgeClase = "badge-success"; break;
                                            case "Cerrado":    badgeClase = "badge-danger";  break;
                                            default:           badgeClase = "badge-warning"; break; // Programado
                                        }
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= esc(p.getNombre())%></strong></td>
                                    <td><%= p.getFechaInicio()%></td>
                                    <td><%= p.getFechaFin()%></td>
                                    <td><span class="badge <%= badgeClase%>"><%= esc(p.getEstado())%></span></td>
                                    <td class="col-acciones">
                                        <!--
                                            Antes: onclick="editarPeriodo(..., '<%= p.getNombre() %>', ...)"
                                            sin escape. Ahora va todo por data-*.
                                        -->
                                        <button class="btn btn-warning btn-sm btn-editar"
                                                data-id="<%= p.getIdPeriodo()%>"
                                                data-nombre="<%= esc(p.getNombre())%>"
                                                data-fecha-inicio="<%= p.getFechaInicio()%>"
                                                data-fecha-fin="<%= p.getFechaFin()%>"
                                                data-estado="<%= esc(p.getEstado())%>"
                                                title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm btn-eliminar"
                                                data-id="<%= p.getIdPeriodo()%>"
                                                title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nuevo Periodo</h3>
                        <form id="formPeriodo" action="${pageContext.request.contextPath}/Periodos" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idPeriodo" name="idPeriodo" value="">

                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" id="nombre" name="nombre" maxlength="45" required
                                       placeholder="Ej: 2026-1 (texto, máx. 45)">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Fecha Inicio</label>
                                    <input type="date" id="fechaInicio" name="fechaInicio" required>
                                </div>
                                <div class="form-group">
                                    <label>Fecha Fin</label>
                                    <input type="date" id="fechaFin" name="fechaFin" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Estado</label>
                                <select id="estado" name="estado" required>
                                    <option value="Programado">Programado</option>
                                    <option value="Activo">Activo</option>
                                    <option value="Cerrado">Cerrado</option>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Guardar</button>
                                <button type="button" class="btn btn-danger" onclick="limpiarFormulario()">Cancelar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            document.querySelectorAll('.btn-editar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    editarPeriodo(
                        this.dataset.id,
                        this.dataset.nombre,
                        this.dataset.fechaInicio,
                        this.dataset.fechaFin,
                        this.dataset.estado
                    );
                });
            });

            document.querySelectorAll('.btn-eliminar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    eliminarPeriodo(this.dataset.id);
                });
            });

            function editarPeriodo(id, nombre, fechaInicio, fechaFin, estado)
            {
                document.getElementById('formTitulo').innerText = 'Editar Periodo';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idPeriodo').value = id;
                document.getElementById('nombre').value = nombre;
                document.getElementById('fechaInicio').value = fechaInicio;
                document.getElementById('fechaFin').value = fechaFin;
                document.getElementById('estado').value = estado;
                document.getElementById('formPanel').scrollIntoView({behavior: 'smooth', block: 'start'});
            }

            function eliminarPeriodo(id)
            {
                if (confirm('⚠️ ¿Eliminar este periodo?\nSe eliminarán también sus grupos e inscripciones asociadas.'))
                { window.location.href = '${pageContext.request.contextPath}/Periodos?accion=eliminar&idPeriodo=' + id; }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nuevo Periodo';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idPeriodo').value = '';
                document.getElementById('formPeriodo').reset();
            }
        </script>
    </body>
</html>