<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Materia, modelo.Carrera, java.util.*"%>
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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel Administrador - Materias</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="materias"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Materias</h1>
                        <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= esc(error)%></div><% } %>

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
                                    <td><strong><%= esc(m.getMateria())%></strong></td>
                                    <td><%= m.getCuatrimestre()%>°</td>
                                    <td><%= esc(nombreCarrera)%></td>
                                    <td class="col-acciones">
                                        <!--
                                            Antes: onclick="editarMateria(..., '<%= m.getMateria().replace("'", "\\'") %>', ...)"
                                            El .replace() solo escapaba comillas simples, pero no comillas dobles
                                            ni caracteres HTML (<, >, &), así que seguía siendo vulnerable a XSS
                                            si el nombre de la materia contenía esos caracteres.
                                            Ahora se usa data-* con esc(), que cubre todos los casos.
                                        -->
                                        <button class="btn btn-warning btn-sm btn-editar"
                                                data-id="<%= m.getIdMateria()%>"
                                                data-materia="<%= esc(m.getMateria())%>"
                                                data-cuatrimestre="<%= m.getCuatrimestre()%>"
                                                data-id-carrera="<%= m.getIdCarrera()%>"
                                                title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm btn-eliminar"
                                                data-id="<%= m.getIdMateria()%>"
                                                title="Eliminar">🗑️</button>
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
                                <input type="text" id="materiaNombre" name="materia" maxlength="255" required
                                       placeholder="Ej: Programación Web (texto, máx. 255)">
                            </div>
                            <div class="form-group">
                                <label>Cuatrimestre</label>
                                <input type="number" id="cuatrimestre" name="cuatrimestre" min="1" max="20" required
                                       placeholder="Ej: 3 (entero, entre 1 y 20)">
                            </div>
                            <div class="form-group">
                                <label>Carrera</label>
                                <select id="idCarrera" name="idCarrera" required>
                                    <option value="">-- SELECCIONA UNA CARRERA --</option>
                                    <% if (carreras != null) { for (Carrera c : carreras) { %>
                                    <option value="<%= c.getIdCarrera()%>"><%= esc(c.getCarrera())%></option>
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
            document.querySelectorAll('.btn-editar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    editarMateria(
                        this.dataset.id,
                        this.dataset.materia,
                        this.dataset.cuatrimestre,
                        this.dataset.idCarrera
                    );
                });
            });

            document.querySelectorAll('.btn-eliminar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    eliminarMateria(this.dataset.id);
                });
            });

            function editarMateria(id, materia, cuatrimestre, idCarrera)
            {
                document.getElementById('formTitulo').innerText = 'Editar Materia';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idMateria').value = id;
                document.getElementById('materiaNombre').value = materia;
                document.getElementById('cuatrimestre').value = cuatrimestre;
                document.getElementById('idCarrera').value = idCarrera;
                document.getElementById('formPanel').scrollIntoView({behavior: 'smooth', block: 'start'});
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