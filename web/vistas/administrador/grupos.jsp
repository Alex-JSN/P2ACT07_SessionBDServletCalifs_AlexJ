<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Grupo, modelo.Carrera, modelo.Periodo, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Grupo> grupos = (List<Grupo>) request.getAttribute("grupos");
    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");
    List<Periodo> periodos = (List<Periodo>) request.getAttribute("periodos");

    Map<Integer, String> nombreCarreraPorId = new HashMap<>();
    if (carreras != null) { for (Carrera c : carreras) { nombreCarreraPorId.put(c.getIdCarrera(), c.getCarrera()); } }

    Map<Integer, String> nombrePeriodoPorId = new HashMap<>();
    if (periodos != null) { for (Periodo p : periodos) { nombrePeriodoPorId.put(p.getIdPeriodo(), p.getNombre()); } }

    boolean faltanDatos = (carreras == null || carreras.isEmpty() || periodos == null || periodos.isEmpty());

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Grupos</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdmin.jsp"><jsp:param name="seccion" value="grupos"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Grupos</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <% if (faltanDatos) { %>
                <div class="alert alert-error">
                    Necesitas al menos una carrera y un periodo registrados antes de crear grupos.
                    <a href="${pageContext.request.contextPath}/Carreras">Ir a Carreras</a> |
                    <a href="${pageContext.request.contextPath}/Periodos">Ir a Periodos</a>
                </div>
                <% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Grupos registrados</h2>
                        <span>Total: <%= (grupos != null) ? grupos.size() : 0%> grupos</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (grupos == null || grupos.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay grupos registrados</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Grupo</th>
                                    <th>Generación</th>
                                    <th>Carrera</th>
                                    <th>Periodo</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Grupo g : grupos)
                                    {
                                        contador++;
                                        String nombreCarrera = nombreCarreraPorId.getOrDefault(g.getIdCarrera(), "—");
                                        String nombrePeriodo = nombrePeriodoPorId.getOrDefault(g.getIdPeriodo(), "—");
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= g.getCuatrimestre()%><%= g.getLetra()%></strong></td>
                                    <td><%= g.getGeneracion()%></td>
                                    <td><%= nombreCarrera%></td>
                                    <td><%= nombrePeriodo%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarGrupo(<%= g.getIdGrupo()%>, '<%= g.getGeneracion()%>', <%= g.getCuatrimestre()%>, '<%= g.getLetra()%>', <%= g.getIdCarrera()%>, <%= g.getIdPeriodo()%>)" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarGrupo(<%= g.getIdGrupo()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nuevo Grupo</h3>
                        <form id="formGrupo" action="${pageContext.request.contextPath}/Grupos" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idGrupo" name="idGrupo" value="">

                            <div class="form-group">
                                <label>Generación</label>
                                <input type="text" id="generacion" name="generacion" maxlength="45" required placeholder="2024-2027">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Cuatrimestre</label>
                                    <input type="number" id="cuatrimestre" name="cuatrimestre" min="1" max="20" required>
                                </div>
                                <div class="form-group">
                                    <label>Letra</label>
                                    <input type="text" id="letra" name="letra" maxlength="1" required placeholder="A">
                                </div>
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
                            <div class="form-group">
                                <label>Periodo</label>
                                <select id="idPeriodo" name="idPeriodo" required>
                                    <option value="">-- SELECCIONA UN PERIODO --</option>
                                    <% if (periodos != null) { for (Periodo p : periodos) { %>
                                    <option value="<%= p.getIdPeriodo()%>"><%= p.getNombre()%></option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary" <%= faltanDatos ? "disabled" : ""%>>Guardar</button>
                                <button type="button" class="btn btn-danger" onclick="limpiarFormulario()">Cancelar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            function editarGrupo(id, generacion, cuatrimestre, letra, idCarrera, idPeriodo)
            {
                document.getElementById('formTitulo').innerText = 'Editar Grupo';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idGrupo').value = id;
                document.getElementById('generacion').value = generacion;
                document.getElementById('cuatrimestre').value = cuatrimestre;
                document.getElementById('letra').value = letra;
                document.getElementById('idCarrera').value = idCarrera;
                document.getElementById('idPeriodo').value = idPeriodo;
                document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'});
            }

            function eliminarGrupo(id)
            {
                if (confirm('⚠️ ¿Eliminar este grupo?\nSe eliminarán también sus asignaciones de materias y se desvincularán sus alumnos.'))
                { window.location.href = '${pageContext.request.contextPath}/Grupos?accion=eliminar&idGrupo=' + id; }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nuevo Grupo';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idGrupo').value = '';
                document.getElementById('formGrupo').reset();
            }
        </script>
    </body>
</html>