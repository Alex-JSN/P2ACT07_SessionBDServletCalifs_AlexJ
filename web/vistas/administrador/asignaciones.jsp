<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Asignacion, modelo.Profesor, modelo.Materia, modelo.Grupo, java.util.*"%>
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

    List<Asignacion> asignaciones = (List<Asignacion>) request.getAttribute("asignaciones");
    List<Profesor> profesores = (List<Profesor>) request.getAttribute("profesores");
    List<Materia> materias = (List<Materia>) request.getAttribute("materias");
    List<Grupo> grupos = (List<Grupo>) request.getAttribute("grupos");

    boolean faltanDatos = (profesores == null || profesores.isEmpty() || materias == null || materias.isEmpty() || grupos == null || grupos.isEmpty());

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
        <title>Panel Administrador - Asignaciones</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="asignaciones"/></jsp:include>

                <main class="content-area">
                    <div class="panel-header">
                        <div class="left">
                            <h1>Asignación de Materias a Profesores</h1>
                            <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) {%><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) {%><div class="alert alert-error"><%= esc(error)%></div><% } %>

                <% if (faltanDatos) { %>
                <div class="alert alert-error">
                    Necesitas al menos un Profesor, una Materia y un Grupo registrados antes de asignar.
                    <a href="${pageContext.request.contextPath}/GestionProfesores">Profesores</a> |
                    <a href="${pageContext.request.contextPath}/Materias">Materias</a> |
                    <a href="${pageContext.request.contextPath}/Grupos">Grupos</a>
                </div>
                <% }%>

                <div class="title-section">
                    <div class="left">
                        <h2>Asignaciones registradas</h2>
                        <span>Total: <%= (asignaciones != null) ? asignaciones.size() : 0%> asignaciones</span>
                    </div>
                </div>

                <div class="main-content">
                    <div class="table-container">
                        <% if (asignaciones == null || asignaciones.isEmpty()) { %>
                        <div style="text-align:center; padding:40px; color:#718096;">
                            <p style="font-size:14px;">No hay asignaciones registradas</p>
                        </div>
                        <% } else { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th class="col-num">#</th>
                                    <th>Profesor</th>
                                    <th>Materia</th>
                                    <th>Grupo</th>
                                    <th>Periodo</th>
                                    <th class="col-acciones">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    int contador = 0;
                                    for (Asignacion a : asignaciones) {
                                        contador++;
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><%= esc(a.getNombreProfesor())%></td>
                                    <td><%= esc(a.getNombreMateria())%></td>
                                    <td><%= esc(a.getNombreGrupo())%></td>
                                    <td><%= esc(a.getNombrePeriodo())%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-danger btn-sm" onclick="eliminarAsignacion(<%= a.getIdAsigna()%>)" title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% }%>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3>Nueva Asignación</h3>
                        <form action="${pageContext.request.contextPath}/Asignaciones" method="POST">

                            <div class="form-group">
                                <label>Profesor</label>
                                <div class="combo-buscable" id="comboProfesor">
                                    <input type="text" class="combo-input sin-seleccion" id="profesorTexto"
                                           placeholder="Escribe para buscar un profesor..." autocomplete="off" readonly>
                                    <input type="hidden" id="idProfesor" name="idProfesor" required>
                                    <div class="combo-lista" id="profesorLista"></div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Materia</label>
                                <div class="combo-buscable" id="comboMateria">
                                    <input type="text" class="combo-input sin-seleccion" id="materiaTexto"
                                           placeholder="Escribe para buscar una materia..." autocomplete="off" readonly>
                                    <input type="hidden" id="idMateria" name="idMateria" required>
                                    <div class="combo-lista" id="materiaLista"></div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label>Grupo</label>
                                <div class="combo-buscable" id="comboGrupo">
                                    <input type="text" class="combo-input sin-seleccion" id="grupoTexto"
                                           placeholder="Escribe para buscar un grupo..." autocomplete="off" readonly>
                                    <input type="hidden" id="idGrupo" name="idGrupo" required>
                                    <div class="combo-lista" id="grupoLista"></div>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary" <%= faltanDatos ? "disabled" : ""%> style="margin-top:10px;">Asignar</button>
                        </form>
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
            var opcionesProfesor = [
            <% if (profesores != null) {
                        boolean primero = true;
                        for (Profesor p : profesores) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= p.getIdProfesor()%>, nombre: "<%= esc(p.getNombre() + " " + p.getPaterno()).replace("\"", "\\\"")%>"}
            <% }
                    } %>
            ];
            var opcionesMateria = [
            <% if (materias != null) {
                        boolean primero = true;
                        for (Materia m : materias) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= m.getIdMateria()%>, nombre: "<%= esc(m.getMateria()).replace("\"", "\\\"")%> (Cuatri <%= m.getCuatrimestre()%>)"}
            <% }
                    } %>
            ];
            var opcionesGrupo = [
            <% if (grupos != null) {
                        boolean primero = true;
                        for (Grupo g : grupos) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= g.getIdGrupo()%>, nombre: "<%= g.getCuatrimestre()%><%= esc(g.getLetra())%> - <%= esc(g.getGeneracion()).replace("\"", "\\\"")%>"}
            <% }
                    }%>
                    ];

                    // ===== Componente genérico de combo buscable =====
                    function crearComboBuscable(idContenedor, idTexto, idOculto, idLista, opciones)
                    {
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

                    crearComboBuscable("comboProfesor", "profesorTexto", "idProfesor", "profesorLista", opcionesProfesor);
                    crearComboBuscable("comboMateria", "materiaTexto", "idMateria", "materiaLista", opcionesMateria);
                    crearComboBuscable("comboGrupo", "grupoTexto", "idGrupo", "grupoLista", opcionesGrupo);

                    function eliminarAsignacion(id)
                    {
                        if (confirm('⚠️ ¿Eliminar esta asignación?\nSe eliminarán también las calificaciones capturadas para ella.'))
                        {
                            window.location.href = '${pageContext.request.contextPath}/Asignaciones?accion=eliminar&idAsigna=' + id;
                        }
                    }
        </script>
    </body>
</html>