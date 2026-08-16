<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Materia, modelo.Calificacion, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    List<Materia> materias = (List<Materia>) request.getAttribute("materias");

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdmin.jsp"><jsp:param name="seccion" value="alumnos"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Alumnos</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Alumnos registrados</h2>
                        <span>Total: <%= (usuarios != null) ? usuarios.size() : 0%> alumnos</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay alumnos registrados</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th class="col-matricula">Matrícula</th>
                                    <th class="col-nombre">Nombre Completo</th>
                                    <th class="col-correo">Correo</th>
                                    <th class="col-estado">Estado</th>
                                    <th>Prom. Gral.</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Usuario usuario : usuarios)
                                    {
                                        contador++;
                                        String rowClass = "Inactivo".equals(usuario.getEstado()) ? "inactivo" : "";
                                        List<Calificacion> califsFila = (List<Calificacion>) request.getAttribute("califs_" + usuario.getMatricula());
                                        Double promGeneral = null;
                                        if (califsFila != null && !califsFila.isEmpty())
                                        {
                                            double suma = 0; int cnt = 0;
                                            for (Calificacion c : califsFila)
                                            {
                                                Double p = c.getPromedio();
                                                if (p != null) { suma += p; cnt++; }
                                            }
                                            if (cnt > 0) { promGeneral = suma / cnt; }
                                        }
                                %>
                                <tr class="<%= rowClass%>" onclick="seleccionarAlumno('<%= usuario.getMatricula()%>')" style="cursor:pointer;">
                                    <td class="col-num"><%= contador%></td>
                                    <td class="col-matricula"><strong><%= usuario.getMatricula()%></strong></td>
                                    <td class="col-nombre"><%= usuario.getNombre()%> <%= usuario.getPaterno()%> <%= usuario.getMaterno() != null ? usuario.getMaterno() : ""%></td>
                                    <td class="col-correo"><%= usuario.getCorreo()%></td>
                                    <td class="col-estado"><span class="badge <%= "Activo".equals(usuario.getEstado()) ? "badge-success" : "badge-danger"%>"><%= usuario.getEstado()%></span></td>
                                    <td><%= promGeneral != null ? String.format("%.1f", promGeneral) : "—"%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="event.stopPropagation(); editarAlumno('<%= usuario.getMatricula()%>')" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="event.stopPropagation(); eliminarAlumno('<%= usuario.getMatricula()%>')" title="Eliminar">🗑️</button>
                                        <button class="btn btn-sm <%= "Activo".equals(usuario.getEstado()) ? "btn-danger" : "btn-success"%>" onclick="event.stopPropagation(); toggleEstado('<%= usuario.getMatricula()%>', '<%= usuario.getEstado()%>')" title="<%= "Activo".equals(usuario.getEstado()) ? "Desactivar" : "Activar"%>"><%= "Activo".equals(usuario.getEstado()) ? "🔴" : "🟢"%></button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Asignar Calificaciones</h3>
                        <form id="formCalificacion" action="${pageContext.request.contextPath}/PanelAdministrador" method="POST">
                            <input type="hidden" name="accion" value="guardarCalificacion">
                            <input type="hidden" id="matriculaAlumno" name="matriculaAlumno">

                            <div class="form-group">
                                <label>Alumno Seleccionado</label>
                                <select id="selectAlumno" class="select-alumno" onchange="cargarAlumno(this.value)">
                                    <option value="">-- SELECCIONA UN ALUMNO --</option>
                                    <% if (usuarios != null) { for (Usuario usuario : usuarios) { %>
                                    <option value="<%= usuario.getMatricula()%>">
                                        <%= usuario.getNombre()%> <%= usuario.getPaterno()%> - <%= usuario.getMatricula()%>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Materia</label>
                                <select id="idMateria" name="idMateria" onchange="autocompletarCalificacion()">
                                    <option value="">-- SELECCIONA UNA MATERIA --</option>
                                    <% if (materias != null) { for (Materia materia : materias) { %>
                                    <option value="<%= materia.getIdMateria()%>"><%= materia.getMateria()%></option>
                                    <% } } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>Periodo</label>
                                <select id="periodo" name="periodo" onchange="autocompletarCalificacion()">
                                    <option value="2026-1" selected>2026-1</option>
                                    <option value="2026-2">2026-2</option>
                                </select>
                            </div>

                            <div class="form-row">
                                <div class="form-group"><label>Parcial 1</label><input type="number" id="parcial1" name="parcial1" min="0" max="10" step="0.1" placeholder="8"></div>
                                <div class="form-group"><label>Parcial 2</label><input type="number" id="parcial2" name="parcial2" min="0" max="10" step="0.1" placeholder="9"></div>
                            </div>
                            <div class="form-group"><label>Parcial 3</label><input type="number" id="parcial3" name="parcial3" min="0" max="10" step="0.1" placeholder="10"></div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">Guardar</button>
                                <button type="button" class="btn btn-danger" onclick="limpiarFormulario()">Limpiar</button>
                            </div>
                        </form>

                        <form id="formEliminarCalif" action="${pageContext.request.contextPath}/PanelAdministrador" method="POST">
                            <input type="hidden" name="accion" value="eliminarCalificacion">
                            <input type="hidden" id="elimMatriculaAlumno" name="matriculaAlumno">
                            <input type="hidden" id="elimIdMateria" name="idMateria">
                            <input type="hidden" id="elimPeriodo" name="periodo">
                            <button type="submit" class="btn btn-danger btn-eliminar-calif" onclick="return confirm('¿Eliminar esta calificación?')">Eliminar Calificación</button>
                        </form>
                    </div>
                </div>
            </main>
        </div>

        <script>
            // Mapa: "matricula|idMateria|periodo" -> {p1,p2,p3}, para autocompletar el form
            // al elegir alumno+materia+periodo que ya tienen calificación guardada.
            var calificacionesData = {};
            <%
                if (usuarios != null)
                {
                    for (Usuario usuario : usuarios)
                    {
                        List<Calificacion> califsJs = (List<Calificacion>) request.getAttribute("califs_" + usuario.getMatricula());
                        if (califsJs != null)
                        {
                            for (Calificacion c : califsJs)
                            {
                                String key = usuario.getMatricula() + "|" + c.getIdMateria() + "|" + c.getNombrePeriodo();
            %>
            calificacionesData["<%= key%>"] = {
                p1: <%= c.getParcial1() != null ? c.getParcial1() : "null"%>,
                p2: <%= c.getParcial2() != null ? c.getParcial2() : "null"%>,
                p3: <%= c.getParcial3() != null ? c.getParcial3() : "null"%>
            };
            <%
                            }
                        }
                    }
                }
            %>

            function cargarAlumno(matricula)
            {
                if (!matricula) { limpiarFormulario(); return; }
                document.getElementById('matriculaAlumno').value = matricula;
                document.getElementById('elimMatriculaAlumno').value = matricula;
                autocompletarCalificacion();
            }

            function autocompletarCalificacion()
            {
                var matricula = document.getElementById('selectAlumno').value;
                var idMateria = document.getElementById('idMateria').value;
                var periodo = document.getElementById('periodo').value;

                document.getElementById('elimIdMateria').value = idMateria;
                document.getElementById('elimPeriodo').value = periodo;

                if (!matricula || !idMateria) { return; }

                var key = matricula + "|" + idMateria + "|" + periodo;
                var existente = calificacionesData[key];

                document.getElementById('parcial1').value = existente && existente.p1 !== null ? existente.p1 : '';
                document.getElementById('parcial2').value = existente && existente.p2 !== null ? existente.p2 : '';
                document.getElementById('parcial3').value = existente && existente.p3 !== null ? existente.p3 : '';
            }

            function seleccionarAlumno(matricula)
            {
                document.getElementById('selectAlumno').value = matricula;
                cargarAlumno(matricula);
                if (window.innerWidth <= 1100) { document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'}); }
            }

            function editarAlumno(matricula)
            {
                window.location.href = '${pageContext.request.contextPath}/PanelAdministrador?accion=editar&matricula=' + matricula;
            }

            function eliminarAlumno(matricula)
            {
                if (confirm('⚠️ ¿Estás seguro de eliminar este alumno?\nSe eliminarán también sus calificaciones.'))
                { window.location.href = '${pageContext.request.contextPath}/PanelAdministrador?accion=eliminar&matricula=' + matricula; }
            }

            function toggleEstado(matricula, estadoActual)
            {
                const nuevoEstado = estadoActual === 'Activo' ? 'Inactivo' : 'Activo';
                const mensaje = nuevoEstado === 'Activo' ? '¿Activar este usuario?' : '¿Desactivar este usuario?';
                if (!confirm(mensaje)) return;
                window.location.href = '${pageContext.request.contextPath}/PanelAdministrador?accion=cambiarEstado&matricula=' + matricula + '&estado=' + nuevoEstado;
            }

            function limpiarFormulario()
            {
                document.getElementById('selectAlumno').value = '';
                document.getElementById('idMateria').value = '';
                document.getElementById('matriculaAlumno').value = '';
                document.getElementById('elimMatriculaAlumno').value = '';
                document.getElementById('parcial1').value = '';
                document.getElementById('parcial2').value = '';
                document.getElementById('parcial3').value = '';
            }
        </script>
    </body>
</html>