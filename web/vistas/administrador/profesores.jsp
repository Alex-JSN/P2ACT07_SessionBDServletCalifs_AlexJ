<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Profesor, java.util.*"%>
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
        <title>Panel Administrador - Profesores</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdmin.jsp"><jsp:param name="seccion" value="profesores"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Profesores</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

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
                                    <th>Matrícula</th>
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
                                    <td><strong><%= p.getMatricula()%></strong></td>
                                    <td><%= p.getNombre()%> <%= p.getPaterno()%> <%= p.getMaterno() != null ? p.getMaterno() : ""%></td>
                                    <td><%= p.getCorreo()%></td>
                                    <td><%= p.getCedula() != null ? p.getCedula() : "—"%></td>
                                    <td><span class="badge <%= "Activo".equals(p.getEstado()) ? "badge-success" : "badge-danger"%>"><%= p.getEstado()%></span></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarProfesor(<%= p.getIdProfesor()%>, <%= p.getIdUsuario()%>, '<%= p.getNombre()%>', '<%= p.getPaterno()%>', '<%= p.getMaterno() != null ? p.getMaterno() : ""%>', '<%= p.getCedula() != null ? p.getCedula() : ""%>', '<%= p.getCorreo()%>')" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarProfesor(<%= p.getIdUsuario()%>)" title="Eliminar">🗑️</button>
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
                                <label>Matrícula</label>
                                <input type="text" id="matricula" name="matricula" maxlength="13" required placeholder="PROF001">
                            </div>
                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" id="nombre" name="nombre" maxlength="45" required>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Apellido Paterno</label>
                                    <input type="text" id="paterno" name="paterno" maxlength="45" required>
                                </div>
                                <div class="form-group">
                                    <label>Apellido Materno</label>
                                    <input type="text" id="materno" name="materno" maxlength="45">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Correo</label>
                                <input type="email" id="correo" name="correo" maxlength="100" required>
                            </div>
                            <div class="form-group">
                                <label>Cédula profesional</label>
                                <input type="text" id="cedula" name="cedula" maxlength="45">
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

                // La matrícula no se edita aquí (pertenece al usuario ya creado)
                document.getElementById('grupoMatricula').style.display = 'none';
                document.getElementById('matricula').required = false;

                document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'});
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