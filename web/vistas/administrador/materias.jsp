<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Materia, modelo.Carrera, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Materia> materias = (List<Materia>) request.getAttribute("materias");
    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");

    // Mapa auxiliar idCarrera -> nombreCarrera, para pintar la tabla sin otro JOIN en el JSP
    Map<Integer, String> nombreCarreraPorId = new HashMap<>();
    if (carreras != null)
    {
        for (Carrera c : carreras) { nombreCarreraPorId.put(c.getIdCarrera(), c.getCarrera()); }
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Materias</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdmin.jsp"><jsp:param name="seccion" value="materias"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Materias</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <% if (carreras == null || carreras.isEmpty()) { %>
                <div class="alert alert-error">
                    Necesitas registrar al menos una carrera antes de poder crear materias.
                    <a href="${pageContext.request.contextPath}/Carreras">Ir a Carreras</a>
                </div>
                <% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Materias registradas</h2>
                        <span>Total: <%= (materias != null) ? materias.size() : 0%> materias</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (materias == null || materias.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay materias registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Materia</th>
                                    <th>Cuatrimestre</th>
                                    <th>Carrera</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Materia m : materias)
                                    {
                                        contador++;
                                        String nombreCarrera = nombreCarreraPorId.getOrDefault(m.getIdCarrera(), "—");
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= m.getMateria()%></strong></td>
                                    <td><%= m.getCuatrimestre()%>°</td>
                                    <td><%= nombreCarrera%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarMateria(<%= m.getIdMateria()%>, '<%= m.getMateria().replace("'", "\\'")%>', <%= m.getCuatrimestre()%>, <%= m.getIdCarrera()%>)" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarMateria(<%= m.getIdMateria()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nueva Materia</h3>
                        <form id="formMateria" action="${pageContext.request.contextPath}/Materias" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idMateria" name="idMateria" value="">

                            <div class="form-group">
                                <label>Nombre de la materia</label>
                                <input type="text" id="materiaNombre" name="materia" maxlength="255" required placeholder="Programación Web">
                            </div>
                            <div class="form-group">
                                <label>Cuatrimestre</label>
                                <input type="number" id="cuatrimestre" name="cuatrimestre" min="1" max="20" required>
                            </div>
                            <div class="form-group">
                                <label>Carrera</label>
                                <select id="idCarrera" name="idCarrera" required>
                                    <option value="">-- SELECCIONA UNA CARRERA --</option>
                                    <% if (carreras != null) { for (Carrera c : carreras) { %>
                                    <option value="<%= c.getIdCarrera()%>"><%= c.getCarrera()%></option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary" <%= (carreras == null || carreras.isEmpty()) ? "disabled" : ""%>>Guardar</button>
                                <button type="button" class="btn btn-danger" onclick="limpiarFormulario()">Cancelar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            function editarMateria(id, materia, cuatrimestre, idCarrera)
            {
                document.getElementById('formTitulo').innerText = 'Editar Materia';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idMateria').value = id;
                document.getElementById('materiaNombre').value = materia;
                document.getElementById('cuatrimestre').value = cuatrimestre;
                document.getElementById('idCarrera').value = idCarrera;
                document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'});
            }

            function eliminarMateria(id)
            {
                if (confirm('⚠️ ¿Eliminar esta materia?\nSe eliminarán también sus asignaciones a grupos.'))
                { window.location.href = '${pageContext.request.contextPath}/Materias?accion=eliminar&idMateria=' + id; }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nueva Materia';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idMateria').value = '';
                document.getElementById('formMateria').reset();
            }
        </script>
    </body>
</html>