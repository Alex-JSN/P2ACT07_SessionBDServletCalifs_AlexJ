<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Periodo, java.util.*"%>
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
        <title>Panel Administrador - Periodos</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdmin.jsp"><jsp:param name="seccion" value="periodos"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Periodos</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

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
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= p.getNombre()%></strong></td>
                                    <td><%= p.getFechaInicio()%></td>
                                    <td><%= p.getFechaFin()%></td>
                                    <td><span class="badge badge-success"><%= p.getEstado()%></span></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarPeriodo(<%= p.getIdPeriodo()%>, '<%= p.getNombre()%>', '<%= p.getFechaInicio()%>', '<%= p.getFechaFin()%>', '<%= p.getEstado()%>')" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarPeriodo(<%= p.getIdPeriodo()%>)" title="Eliminar">🗑️</button>
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
                                <input type="text" id="nombre" name="nombre" maxlength="45" required placeholder="2026-1">
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
            function editarPeriodo(id, nombre, fechaInicio, fechaFin, estado)
            {
                document.getElementById('formTitulo').innerText = 'Editar Periodo';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idPeriodo').value = id;
                document.getElementById('nombre').value = nombre;
                document.getElementById('fechaInicio').value = fechaInicio;
                document.getElementById('fechaFin').value = fechaFin;
                document.getElementById('estado').value = estado;
                document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'});
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