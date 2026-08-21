<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Profesor, java.util.*"%>
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

    List<Profesor> profesores = (List<Profesor>) request.getAttribute("profesores");

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
        <title>Panel Administrador - Profesores</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="profesores"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Profesores</h1>
                        <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= esc(error)%></div><% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Profesores registrados</h2>
                        <span>Total: <%= (profesores != null) ? profesores.size() : 0%> profesores</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (profesores == null || profesores.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay profesores registrados</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Clave</th>
                                    <th>Nombre Completo</th>
                                    <th>Correo</th>
                                    <th>Cédula</th>
                                    <th>Estado</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Profesor p : profesores)
                                    {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= esc(p.getMatricula())%></strong></td>
                                    <td><%= esc(p.getNombre())%> <%= esc(p.getPaterno())%> <%= p.getMaterno() != null ? esc(p.getMaterno()) : ""%></td>
                                    <td><%= esc(p.getCorreo())%></td>
                                    <td><%= p.getCedula() != null ? esc(p.getCedula()) : "—"%></td>
                                    <td><span class="badge <%= "Activo".equals(p.getEstado()) ? "badge-success" : "badge-danger"%>"><%= esc(p.getEstado())%></span></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm btn-editar"
                                                data-id-profesor="<%= p.getIdProfesor()%>"
                                                data-id-usuario="<%= p.getIdUsuario()%>"
                                                data-nombre="<%= esc(p.getNombre())%>"
                                                data-paterno="<%= esc(p.getPaterno())%>"
                                                data-materno="<%= p.getMaterno() != null ? esc(p.getMaterno()) : ""%>"
                                                data-cedula="<%= p.getCedula() != null ? esc(p.getCedula()) : ""%>"
                                                data-correo="<%= esc(p.getCorreo())%>"
                                                title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm btn-eliminar"
                                                data-id-usuario="<%= p.getIdUsuario()%>"
                                                title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nuevo Profesor</h3>
                        <form id="formProfesor" action="${pageContext.request.contextPath}/GestionProfesores" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idProfesor" name="idProfesor" value="">
                            <input type="hidden" id="idUsuario" name="idUsuario" value="">

                            <div class="form-group" id="grupoMatricula">
                                <label>Clave de Profesor</label>
                                <input type="text" id="matricula" name="matricula" maxlength="13" required
                                       placeholder="Ej: PROF001 (máx. 13 caracteres)">
                                <small>Identificador único del profesor. Se usará también como contraseña inicial.</small>
                            </div>
                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" id="nombre" name="nombre" maxlength="45" required
                                       placeholder="Ej: Juan (texto, máx. 45)">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Apellido Paterno</label>
                                    <input type="text" id="paterno" name="paterno" maxlength="45" required
                                           placeholder="Ej: Pérez (texto, máx. 45)">
                                </div>
                                <div class="form-group">
                                    <label>Apellido Materno</label>
                                    <input type="text" id="materno" name="materno" maxlength="45"
                                           placeholder="Ej: García (opcional, texto)">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Correo</label>
                                <input type="email" id="correo" name="correo" maxlength="100" required
                                       placeholder="Ej: nombre@dominio.com (máx. 100)">
                            </div>
                            <div class="form-group">
                                <label>Cédula profesional</label>
                                <input type="text" id="cedula" name="cedula" maxlength="45" pattern="[0-9]{6,45}"
                                       placeholder="Ej: 12345678 (opcional, numérico, máx. 45)"
                                       title="Solo números, entre 6 y 45 dígitos">
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
                    editarProfesor(
                        this.dataset.idProfesor,
                        this.dataset.idUsuario,
                        this.dataset.nombre,
                        this.dataset.paterno,
                        this.dataset.materno,
                        this.dataset.cedula,
                        this.dataset.correo
                    );
                });
            });

            document.querySelectorAll('.btn-eliminar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    eliminarProfesor(this.dataset.idUsuario);
                });
            });

            function editarProfesor(idProfesor, idUsuario, nombre, paterno, materno, cedula, correo)
            {
                document.getElementById('formTitulo').innerText = 'Editar Profesor';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idProfesor').value = idProfesor;
                document.getElementById('idUsuario').value = idUsuario;
                document.getElementById('nombre').value = nombre;
                document.getElementById('paterno').value = paterno;
                document.getElementById('materno').value = materno;
                document.getElementById('cedula').value = cedula;
                document.getElementById('correo').value = correo;

                document.getElementById('grupoMatricula').style.display = 'none';
                document.getElementById('matricula').required = false;

                document.getElementById('formPanel').scrollIntoView({behavior: 'smooth', block: 'start'});
            }

            function eliminarProfesor(idUsuario)
            {
                if (confirm('⚠️ ¿Eliminar este profesor?\nSe eliminará también su cuenta de usuario y sus materias asignadas.'))
                { window.location.href = '${pageContext.request.contextPath}/GestionProfesores?accion=eliminar&idUsuario=' + idUsuario; }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nuevo Profesor';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idProfesor').value = '';
                document.getElementById('idUsuario').value = '';
                document.getElementById('grupoMatricula').style.display = '';
                document.getElementById('matricula').required = true;
                document.getElementById('formProfesor').reset();
            }
        </script>
    </body>
</html>