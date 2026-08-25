<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Alumno, modelo.Carrera, modelo.Grupo, modelo.Calificacion, java.util.*"%>
<%!
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

    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");
    List<Grupo> grupos = (List<Grupo>) request.getAttribute("grupos");

    Map<Integer, String> nombreCarreraPorId = new HashMap<>();
    if (carreras != null) { for (Carrera c : carreras) { nombreCarreraPorId.put(c.getIdCarrera(), c.getCarrera()); } }

    Map<Integer, String> nombreGrupoPorId = new HashMap<>();
    if (grupos != null) { for (Grupo g : grupos) { nombreGrupoPorId.put(g.getIdGrupo(), g.getCuatrimestre() + g.getLetra() + " - " + g.getGeneracion()); } }

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
                        <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) { %><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) { %><div class="alert alert-error"><%= esc(error)%></div><% } %>

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
                                    <th>Grupo</th>
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
                                        String nombreGrupo = a.getIdGrupo() > 0 ? nombreGrupoPorId.getOrDefault(a.getIdGrupo(), "—") : "Sin grupo";
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
                                    <td><strong><%= esc(a.getMatricula())%></strong></td>
                                    <td><%= esc(a.getNombre())%> <%= esc(a.getPaterno())%> <%= a.getMaterno() != null ? esc(a.getMaterno()) : ""%></td>
                                    <td><%= esc(a.getCorreo())%></td>
                                    <td><%= esc(nombreCarrera)%></td>
                                    <td><%= esc(nombreGrupo)%></td>
                                    <td><%= promGeneral != null ? String.format("%.1f", promGeneral) : "—"%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm btn-editar"
                                                data-id="<%= a.getIdAlumno()%>"
                                                data-matricula="<%= esc(a.getMatricula())%>"
                                                data-nombre="<%= esc(a.getNombre())%>"
                                                data-paterno="<%= esc(a.getPaterno())%>"
                                                data-materno="<%= a.getMaterno() != null ? esc(a.getMaterno()) : ""%>"
                                                data-correo="<%= esc(a.getCorreo())%>"
                                                data-id-carrera="<%= a.getIdCarrera()%>"
                                                data-nombre-carrera="<%= esc(nombreCarrera)%>"
                                                data-id-grupo="<%= a.getIdGrupo()%>"
                                                data-nombre-grupo="<%= a.getIdGrupo() > 0 ? esc(nombreGrupo) : ""%>"
                                                title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm btn-eliminar" data-matricula="<%= esc(a.getMatricula())%>" title="Eliminar">🗑️</button>
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
                                <label>Carrera</label>
                                <div class="combo-buscable" id="comboCarrera">
                                    <input type="text" class="combo-input sin-seleccion" id="carreraTexto"
                                           placeholder="Escribe para buscar una carrera..." autocomplete="off" readonly>
                                    <input type="hidden" id="idCarrera" name="idCarrera" required>
                                    <div class="combo-lista" id="carreraLista"></div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Grupo <small style="font-weight:400;">(opcional, puede asignarse después)</small></label>
                                <div class="combo-buscable" id="comboGrupo">
                                    <input type="text" class="combo-input sin-seleccion" id="grupoTexto"
                                           placeholder="Escribe para buscar un grupo..." autocomplete="off" readonly>
                                    <input type="hidden" id="idGrupo" name="idGrupo" value="">
                                    <div class="combo-lista" id="grupoLista"></div>
                                </div>
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
            function normalizarTexto(texto)
            {
                return (texto || "")
                    .normalize("NFD")
                    .replace(/[\u0300-\u036f]/g, "")
                    .toLowerCase();
            }

            var opcionesCarrera = [
                <% if (carreras != null) { boolean primero = true; for (Carrera c : carreras) { if (!primero) { out.print(","); } primero = false; %>
                { id: <%= c.getIdCarrera()%>, nombre: "<%= esc(c.getCarrera()).replace("\"", "\\\"")%>" }
                <% } } %>
            ];
            var opcionesGrupo = [
                <% if (grupos != null) { boolean primero = true; for (Grupo g : grupos) { if (!primero) { out.print(","); } primero = false; %>
                { id: <%= g.getIdGrupo()%>, nombre: "<%= g.getCuatrimestre()%><%= esc(g.getLetra())%> - <%= esc(g.getGeneracion()).replace("\"", "\\\"")%>" }
                <% } } %>
            ];

            function crearComboBuscable(idContenedor, idTexto, idOculto, idLista, opciones)
            {
                var contenedor = document.getElementById(idContenedor);
                var inputTexto = document.getElementById(idTexto);
                var inputOculto = document.getElementById(idOculto);
                var lista = document.getElementById(idLista);

                function renderLista(filtro)
                {
                    var filtroNormalizado = normalizarTexto(filtro);
                    var filtradas = opciones.filter(function (op) {
                        return normalizarTexto(op.nombre).indexOf(filtroNormalizado) !== -1;
                    });

                    lista.innerHTML = "";

                    if (filtradas.length === 0)
                    {
                        var vacio = document.createElement("div");
                        vacio.className = "combo-opcion sin-resultados";
                        vacio.textContent = "Sin resultados";
                        lista.appendChild(vacio);
                        return;
                    }

                    filtradas.forEach(function (op) {
                        var item = document.createElement("div");
                        item.className = "combo-opcion";
                        item.textContent = op.nombre;
                        item.addEventListener("mousedown", function (e) {
                            e.preventDefault();
                            seleccionar(op);
                        });
                        lista.appendChild(item);
                    });
                }

                function seleccionar(op)
                {
                    inputTexto.value = op.nombre;
                    inputTexto.classList.remove("sin-seleccion");
                    inputOculto.value = op.id;
                    cerrarLista();
                }

                function abrirLista()
                {
                    inputTexto.readOnly = false;
                    lista.classList.add("abierta");
                    renderLista(inputOculto.value ? "" : inputTexto.value);
                }

                function cerrarLista()
                {
                    lista.classList.remove("abierta");
                    inputTexto.readOnly = true;
                }

                inputTexto.addEventListener("click", function () {
                    inputTexto.value = "";
                    abrirLista();
                });

                inputTexto.addEventListener("input", function () {
                    renderLista(inputTexto.value);
                });

                inputTexto.addEventListener("blur", function () {
                    setTimeout(function () {
                        if (!inputOculto.value)
                        {
                            inputTexto.value = "";
                            inputTexto.classList.add("sin-seleccion");
                        }
                        else if (inputTexto.value === "")
                        {
                            var actual = opciones.find(function (o) { return String(o.id) === String(inputOculto.value); });
                            if (actual) { inputTexto.value = actual.nombre; }
                        }
                        cerrarLista();
                    }, 150);
                });

                contenedor.setSeleccion = function (id, nombre)
                {
                    inputOculto.value = id;
                    inputTexto.value = nombre;
                    inputTexto.classList.remove("sin-seleccion");
                };

                contenedor.limpiar = function ()
                {
                    inputOculto.value = "";
                    inputTexto.value = "";
                    inputTexto.classList.add("sin-seleccion");
                };
            }

            crearComboBuscable("comboCarrera", "carreraTexto", "idCarrera", "carreraLista", opcionesCarrera);
            crearComboBuscable("comboGrupo", "grupoTexto", "idGrupo", "grupoLista", opcionesGrupo);

            document.querySelectorAll('.btn-editar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    editarAlumno(
                        this.dataset.id, this.dataset.matricula, this.dataset.nombre, this.dataset.paterno,
                        this.dataset.materno, this.dataset.correo,
                        this.dataset.idCarrera, this.dataset.nombreCarrera,
                        this.dataset.idGrupo, this.dataset.nombreGrupo
                    );
                });
            });

            document.querySelectorAll('.btn-eliminar').forEach(function (btn) {
                btn.addEventListener('click', function () { eliminarAlumno(this.dataset.matricula); });
            });

            function editarAlumno(idAlumno, matricula, nombre, paterno, materno, correo, idCarrera, nombreCarrera, idGrupo, nombreGrupo)
            {
                document.getElementById('formTitulo').innerText = 'Editar Alumno';
                document.getElementById('accion').value = 'actualizarAlumno';
                document.getElementById('idAlumno').value = idAlumno;
                document.getElementById('matriculaNueva').value = matricula;
                document.getElementById('nombre').value = nombre;
                document.getElementById('paterno').value = paterno;
                document.getElementById('materno').value = materno;
                document.getElementById('correo').value = correo;

                document.getElementById('comboCarrera').setSeleccion(idCarrera, nombreCarrera);

                if (idGrupo && idGrupo !== "0")
                { document.getElementById('comboGrupo').setSeleccion(idGrupo, nombreGrupo); }
                else
                { document.getElementById('comboGrupo').limpiar(); }

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
                document.getElementById('comboCarrera').limpiar();
                document.getElementById('comboGrupo').limpiar();
            }
        </script>
    </body>
</html>