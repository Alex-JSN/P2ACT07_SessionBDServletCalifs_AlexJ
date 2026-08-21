<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Carrera, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario())) {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");
    Carrera carreraEditar = (Carrera) request.getAttribute("carreraEditar");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Carreras</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="carreras"/></jsp:include>

                <main class="content-area">
                    <div class="panel-header">
                        <div class="left">
                            <h1>Gestión de Carreras</h1>
                            <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) {%><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) {%><div class="alert alert-error"><%= error%></div><% }%>

                <div class="title-section">
                    <div class="left">
                        <h2>Carreras registradas</h2>
                        <span>Total: <%= (carreras != null) ? carreras.size() : 0%> carreras</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (carreras == null || carreras.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay carreras registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Clave</th>
                                    <th>Carrera</th>
                                    <th>Total Cuatrimestres</th>
                                    <th>Cuatrimestre Estadía</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Carrera c : carreras) {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= c.getClave()%></strong></td>
                                    <td><%= c.getCarrera()%></td>
                                    <td><%= c.getTotalCuatrimestres()%></td>
                                    <td><%= c.getCuatrimestreEstadia()%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarCarrera(<%= c.getIdCarrera()%>, '<%= c.getClave()%>', '<%= c.getCarrera()%>', <%= c.getTotalCuatrimestres()%>, <%= c.getCuatrimestreEstadia()%>)" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarCarrera(<%= c.getIdCarrera()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% }%>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nueva Carrera</h3>
                        <form id="formCarrera" action="${pageContext.request.contextPath}/Carreras" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idCarrera" name="idCarrera" value="">

                            <div class="form-group">
                                <label>Clave</label>
                                <input type="text" id="clave" name="clave" maxlength="10" required placeholder="TIC">
                            </div>
                            <div class="form-group">
                                <label>Nombre de la carrera</label>
                                <input type="text" id="carreraNombre" name="carrera" maxlength="100" required placeholder="Tecnologías de la Información">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Total Cuatrimestres</label>
                                    <input type="number" id="totalCuatrimestres" name="totalCuatrimestres" min="1" max="20" required>
                                </div>
                                <div class="form-group">
                                    <label>Cuatrimestre Estadía</label>
                                    <input type="number" id="cuatrimestreEstadia" name="cuatrimestreEstadia" min="1" max="20" required>
                                </div>
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
            function editarCarrera(id, clave, carrera, totalCuatrimestres, cuatrimestreEstadia)
            {
                document.getElementById('formTitulo').innerText = 'Editar Carrera';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idCarrera').value = id;
                document.getElementById('clave').value = clave;
                document.getElementById('carreraNombre').value = carrera;
                document.getElementById('totalCuatrimestres').value = totalCuatrimestres;
                document.getElementById('cuatrimestreEstadia').value = cuatrimestreEstadia;
                document.getElementById('formPanel').scrollIntoView({behavior: 'smooth', block: 'start'});
            }

            function eliminarCarrera(id)
            {
                if (confirm('⚠️ ¿Eliminar esta carrera?\nSe eliminarán también sus grupos, materias y alumnos asociados.'))
                {
                    window.location.href = '${pageContext.request.contextPath}/Carreras?accion=eliminar&idCarrera=' + id;
                }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nueva Carrera';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idCarrera').value = '';
                document.getElementById('formCarrera').reset();
            }
        </script>
    </body>
</html>