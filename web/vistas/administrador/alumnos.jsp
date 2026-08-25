<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Alumno, modelo.Carrera, modelo.Calificacion, java.util.*"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");

    Map<Integer, String> nombreCarreraPorId = new HashMap<>();
    if (carreras != null) { for (Carrera c : carreras) { nombreCarreraPorId.put(c.getIdCarrera(), c.getCarrera()); } }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) { session.removeAttribute("mensaje"); }
    if (error != null) { session.removeAttribute("error"); }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Alumnos</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="alumnos"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Gestión de Alumnos</h1>
                        <span class="welcome-text">Bienvenido, <%= usuarioActual.getNombre()%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= mensaje%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= error%></div><% } %>

                <% if (carreras == null || carreras.isEmpty()) { %>
                <div class="alert alert-error">
                    Necesitas registrar al menos una carrera antes de dar de alta alumnos.
                    <a href="${pageContext.request.contextPath}/Carreras">Ir a Carreras</a>
                </div>
                <% } %>

                <div class="title-section">
                    <div class="left">
                        <h2>Alumnos registrados</h2>
                        <span>Total: <%= (alumnos != null) ? alumnos.size() : 0%> alumnos</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (alumnos == null || alumnos.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay alumnos registrados</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Matrícula</th>
                                    <th>Nombre Completo</th>
                                    <th>Correo</th>
                                    <th>Carrera</th>
                                    <th>Prom. Gral.</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Alumno a : alumnos)
                                    {
                                        contador++;
                                        String nombreCarrera = nombreCarreraPorId.getOrDefault(a.getIdCarrera(), "—");
                                        List<Calificacion> califsFila = (List<Calificacion>) request.getAttribute("califs_" + a.getMatricula());
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
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= a.getMatricula()%></strong></td>
                                    <td><%= a.getNombre()%> <%= a.getPaterno()%> <%= a.getMaterno() != null ? a.getMaterno() : ""%></td>
                                    <td><%= a.getCorreo()%></td>
                                    <td><%= nombreCarrera%></td>
                                    <td><%= promGeneral != null ? String.format("%.1f", promGeneral) : "—"%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm" onclick="editarAlumno(<%= a.getIdAlumno()%>, '<%= a.getMatricula()%>', '<%= a.getNombre()%>', '<%= a.getPaterno()%>', '<%= a.getMaterno() != null ? a.getMaterno() : ""%>', '<%= a.getCorreo()%>', <%= a.getIdCarrera()%>)" title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarAlumno('<%= a.getMatricula()%>')" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } %>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Registrar Alumno</h3>
                        <form id="formAlumno" action="${pageContext.request.contextPath}/Alumnos" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crearAlumno">
                            <input type="hidden" id="idAlumno" name="idAlumno" value="">

                            <div class="form-group">
                                <label>Matrícula</label>
                                <input type="text" id="matriculaNueva" name="matriculaNueva" maxlength="13" placeholder="Ej: 57231900100_i" required>
                            </div>
                            <div class="form-group">
                                <label>Nombre</label>
                                <input type="text" id="nombre" name="nombre" maxlength="45" placeholder="Ej: Chanchito Feliz" required>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Apellido Paterno</label>
                                    <input type="text" id="paterno" name="paterno" maxlength="45" placeholder="Ej: Santos" required>
                                </div>
                                <div class="form-group">
                                    <label>Apellido Materno</label>
                                    <input type="text" id="materno" name="materno" maxlength="45" placeholder="Ej: Nava">
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Correo</label>
                                <input type="email" id="correo" name="correo" maxlength="100" placeholder="Ej: 57231900100_i@utrng.edu.mx" required>
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
            function editarAlumno(idAlumno, matricula, nombre, paterno, materno, correo, idCarrera)
            {
                document.getElementById('formTitulo').innerText = 'Editar Alumno';
                document.getElementById('accion').value = 'actualizarAlumno';
                document.getElementById('idAlumno').value = idAlumno;
                document.getElementById('matriculaNueva').value = matricula;
                document.getElementById('nombre').value = nombre;
                document.getElementById('paterno').value = paterno;
                document.getElementById('materno').value = materno;
                document.getElementById('correo').value = correo;
                document.getElementById('idCarrera').value = idCarrera;
                document.getElementById('formPanel').scrollIntoView({behavior:'smooth', block:'start'});
            }

            function eliminarAlumno(matricula)
            {
                if (confirm('⚠️ ¿Eliminar este alumno?\nSe eliminarán también sus calificaciones e inscripciones.'))
                { window.location.href = '${pageContext.request.contextPath}/Alumnos?accion=eliminar&matricula=' + matricula; }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Registrar Alumno';
                document.getElementById('accion').value = 'crearAlumno';
                document.getElementById('idAlumno').value = '';
                document.getElementById('formAlumno').reset();
            }
        </script>
    </body>
</html>