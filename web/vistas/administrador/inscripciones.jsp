<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Inscripcion, modelo.Periodo, java.util.*"%>
<%!
    private String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario())) {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    List<Inscripcion> inscripciones = (List<Inscripcion>) request.getAttribute("inscripciones");
    List<Periodo> periodos = (List<Periodo>) request.getAttribute("periodos");
    List<Object[]> alumnosDisponibles = (List<Object[]>) request.getAttribute("alumnosDisponibles");
    Integer idPeriodoSeleccionado = (Integer) request.getAttribute("idPeriodoSeleccionado");

    String nombrePeriodoSeleccionado = "";
    if (idPeriodoSeleccionado != null && periodos != null) {
        for (Periodo p : periodos) {
            if (p.getIdPeriodo() == idPeriodoSeleccionado) {
                nombrePeriodoSeleccionado = p.getNombre();
                break;
            }
        }
    }

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
        <title>Panel Administrador - Inscripciones</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="inscripciones"/></jsp:include>

                <main class="content-area">
                    <div class="panel-header">
                        <div class="left">
                            <h1>Gestión de Inscripciones</h1>
                            <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) {%><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) {%><div class="alert alert-error"><%= esc(error)%></div><% } %>

                <% if (periodos == null || periodos.isEmpty()) { %>
                <div class="alert alert-error">
                    Necesitas registrar al menos un periodo antes de inscribir alumnos.
                    <a href="${pageContext.request.contextPath}/Periodos">Ir a Periodos</a>
                </div>
                <% }%>

                <div class="title-section">
                    <div class="left">
                        <h2>Inscripciones registradas</h2>
                        <span>Total: <%= (inscripciones != null) ? inscripciones.size() : 0%> inscripciones</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (inscripciones == null || inscripciones.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay inscripciones registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Alumno</th>
                                    <th>Matrícula</th>
                                    <th>Periodo</th>
                                    <th>Cuatrimestre</th>
                                    <th>Estado</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Inscripcion i : inscripciones) {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><%= esc(i.getNombreAlumno())%></td>
                                    <td><strong><%= esc(i.getMatriculaAlumno())%></strong></td>
                                    <td><%= esc(i.getNombrePeriodo())%></td>
                                    <td><%= esc(i.getCuatrimestre())%></td>
                                    <td><span class="badge <%= "Inscrito".equals(i.getEstado()) ? "badge-success" : "badge-danger"%>"><%= esc(i.getEstado())%></span></td>
                                    <td class="col-acciones">
                                        <% if ("Inscrito".equals(i.getEstado())) {%>
                                        <button class="btn btn-danger btn-sm" onclick="darBaja(<%= i.getIdInscripcion()%>)" title="Dar de baja">🔴</button>
                                        <% } else {%>
                                        <button class="btn btn-success btn-sm" onclick="reactivar(<%= i.getIdInscripcion()%>)" title="Reactivar">🟢</button>
                                        <% }%>
                                        <button class="btn btn-danger btn-sm" onclick="eliminarInscripcion(<%= i.getIdInscripcion()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% }%>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Inscribir Alumno</h3>

                        <form id="formSeleccionPeriodo" method="GET" action="${pageContext.request.contextPath}/Inscripciones" style="margin-bottom:16px;">
                            <div class="form-group">
                                <label>1. Selecciona el Periodo</label>
                                <div class="combo-buscable" id="comboPeriodo">
                                    <input type="text" class="combo-input <%= idPeriodoSeleccionado == null ? "sin-seleccion" : ""%>" id="periodoTexto"
                                           value="<%= esc(nombrePeriodoSeleccionado)%>"
                                           placeholder="Escribe para buscar un periodo..." autocomplete="off" readonly>
                                    <input type="hidden" id="idPeriodo" name="idPeriodo" value="<%= idPeriodoSeleccionado != null ? idPeriodoSeleccionado : ""%>">
                                    <div class="combo-lista" id="periodoLista"></div>
                                </div>
                            </div>
                        </form>

                        <% if (idPeriodoSeleccionado != null) {%>
                        <form action="${pageContext.request.contextPath}/Inscripciones" method="POST">
                            <input type="hidden" name="idPeriodo" value="<%= idPeriodoSeleccionado%>">

                            <div class="form-group">
                                <label>2. Alumno a inscribir</label>
                                <div class="combo-buscable" id="comboAlumno">
                                    <input type="text" class="combo-input sin-seleccion" id="alumnoTexto"
                                           placeholder="Escribe para buscar un alumno..." autocomplete="off" readonly>
                                    <input type="hidden" id="idAlumno" name="idAlumno" required>
                                    <div class="combo-lista" id="alumnoLista"></div>
                                </div>
                                <% if (alumnosDisponibles != null && alumnosDisponibles.isEmpty()) { %>
                                <small>Todos los alumnos ya están inscritos en este periodo.</small>
                                <% } %>
                            </div>

                            <div class="form-group">
                                <label>Cuatrimestre</label>
                                <input type="text" name="cuatrimestre" maxlength="45" required placeholder="9">
                            </div>

                            <button type="submit" class="btn btn-primary">Inscribir</button>
                        </form>
                        <% } else { %>
                        <p style="color:#718096; font-size:14px;">Selecciona un periodo para ver los alumnos disponibles.</p>
                        <% } %>
                    </div>
                </div>
            </main>
        </div>

        <script>
            // Quita acentos para que "matematicas" encuentre "Matemáticas" y viceversa
            function normalizarTexto(texto)
            {
                return (texto || "")
                        .normalize("NFD")
                        .replace(/[\u0300-\u036f]/g, "")
                        .toLowerCase();
            }

            // ===== Datos para los combos (vienen del JSP) =====
            var opcionesPeriodo = [
            <% if (periodos != null) {
                        boolean primero = true;
                        for (Periodo p : periodos) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= p.getIdPeriodo()%>, nombre: "<%= esc(p.getNombre()).replace("\"", "\\\"")%>"}
            <% }
                    } %>
            ];
            var opcionesAlumno = [
            <% if (alumnosDisponibles != null) {
                        boolean primero = true;
                        for (Object[] a : alumnosDisponibles) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= a[0]%>, nombre: "<%= esc((String) a[2]).replace("\"", "\\\"")%> - <%= esc((String) a[1])%>"}
            <% }
                    } %>
                    ];

                    // ===== Componente genérico de combo buscable =====
                    function crearComboBuscable(idContenedor, idTexto, idOculto, idLista, opciones, onSeleccionar)
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
                            if (typeof onSeleccionar === "function") {
                                onSeleccionar(op);
                            }
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
                                } else if (inputTexto.value === "")
                                {
                                    var actual = opciones.find(function (o) {
                                        return String(o.id) === String(inputOculto.value);
                                    });
                                    if (actual) {
                                        inputTexto.value = actual.nombre;
                                    }
                                }
                                cerrarLista();
                            }, 150);
                        });
                    }

                    // Periodo: al seleccionar, envía el form GET para recargar con los alumnos de ese periodo
                    crearComboBuscable("comboPeriodo", "periodoTexto", "idPeriodo", "periodoLista", opcionesPeriodo, function () {
                        document.getElementById("formSeleccionPeriodo").submit();
                    });

                    // Alumno: solo guarda selección, el form POST se envía con el botón "Inscribir"
            <% if (idPeriodoSeleccionado != null) { %>
                    crearComboBuscable("comboAlumno", "alumnoTexto", "idAlumno", "alumnoLista", opcionesAlumno);
            <% }%>

                    function darBaja(id)
                    {
                        if (confirm('¿Dar de baja esta inscripción?\nEl alumno ya no podrá recibir calificaciones en este periodo.'))
                        {
                            window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=baja&idInscripcion=' + id;
                        }
                    }

                    function reactivar(id)
                    {
                        if (confirm('¿Reactivar esta inscripción?'))
                        {
                            window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=reactivar&idInscripcion=' + id;
                        }
                    }

                    function eliminarInscripcion(id)
                    {
                        if (confirm('⚠️ ¿Eliminar esta inscripción?\nSe eliminarán también sus calificaciones asociadas.'))
                        {
                            window.location.href = '${pageContext.request.contextPath}/Inscripciones?accion=eliminar&idInscripcion=' + id;
                        }
                    }
        </script>
    </body>
</html>