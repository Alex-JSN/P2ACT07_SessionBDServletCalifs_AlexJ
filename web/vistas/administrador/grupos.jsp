<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario, modelo.Grupo, modelo.Carrera, modelo.Periodo, java.util.*"%>
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

    List<Grupo> grupos = (List<Grupo>) request.getAttribute("grupos");
    List<Carrera> carreras = (List<Carrera>) request.getAttribute("carreras");
    List<Periodo> periodos = (List<Periodo>) request.getAttribute("periodos");

    Map<Integer, String> nombreCarreraPorId = new HashMap<>();
    if (carreras != null) {
        for (Carrera c : carreras) {
            nombreCarreraPorId.put(c.getIdCarrera(), c.getCarrera());
        }
    }

    Map<Integer, String> nombrePeriodoPorId = new HashMap<>();
    if (periodos != null) {
        for (Periodo p : periodos) {
            nombrePeriodoPorId.put(p.getIdPeriodo(), p.getNombre());
        }
    }

    boolean faltanDatos = (carreras == null || carreras.isEmpty() || periodos == null || periodos.isEmpty());

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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel Administrador - Grupos</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="grupos"/></jsp:include>

                <main class="content-area">
                    <div class="panel-header">
                        <div class="left">
                            <h1>Gestión de Grupos</h1>
                            <span class="welcome-text">Bienvenido, <%= esc(usuarioActual.getNombre())%></span>
                    </div>
                </div>

                <% if (mensaje != null) {%><div class="alert alert-success"><%= esc(mensaje)%></div><% } %>
                <% if (error != null) {%><div class="alert alert-error"><%= esc(error)%></div><% } %>

                <% if (faltanDatos) { %>
                <div class="alert alert-error">
                    Necesitas al menos una carrera y un periodo registrados antes de crear grupos.
                    <a href="${pageContext.request.contextPath}/Carreras">Ir a Carreras</a> |
                    <a href="${pageContext.request.contextPath}/Periodos">Ir a Periodos</a>
                </div>
                <% }%>

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
                                    for (Grupo g : grupos) {
                                        contador++;
                                        String nombreCarrera = nombreCarreraPorId.getOrDefault(g.getIdCarrera(), "—");
                                        String nombrePeriodo = nombrePeriodoPorId.getOrDefault(g.getIdPeriodo(), "—");
                                %>
                                <tr>
                                    <td class="col-num"><%= contador%></td>
                                    <td><strong><%= g.getCuatrimestre()%><%= esc(g.getLetra())%></strong></td>
                                    <td><%= esc(g.getGeneracion())%></td>
                                    <td><%= esc(nombreCarrera)%></td>
                                    <td><%= esc(nombrePeriodo)%></td>
                                    <td class="col-acciones">
                                        <button class="btn btn-warning btn-sm btn-editar"
                                                data-id="<%= g.getIdGrupo()%>"
                                                data-generacion="<%= esc(g.getGeneracion())%>"
                                                data-cuatrimestre="<%= g.getCuatrimestre()%>"
                                                data-letra="<%= esc(g.getLetra())%>"
                                                data-id-carrera="<%= g.getIdCarrera()%>"
                                                data-nombre-carrera="<%= esc(nombreCarrera)%>"
                                                data-id-periodo="<%= g.getIdPeriodo()%>"
                                                data-nombre-periodo="<%= esc(nombrePeriodo)%>"
                                                title="Editar">✏️</button>
                                        <button class="btn btn-danger btn-sm btn-eliminar"
                                                data-id="<%= g.getIdGrupo()%>"
                                                title="Eliminar">🗑️</button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% }%>
                    </div>

                    <div class="form-panel" id="formPanel">
                        <h3 id="formTitulo">Nuevo Grupo</h3>
                        <form id="formGrupo" action="${pageContext.request.contextPath}/Grupos" method="POST">
                            <input type="hidden" id="accion" name="accion" value="crear">
                            <input type="hidden" id="idGrupo" name="idGrupo" value="">

                            <div class="form-group">
                                <label>Generación</label>
                                <input type="text" id="generacion" name="generacion" maxlength="45" required
                                       placeholder="Ej: 2024-2027">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Cuatrimestre</label>
                                    <input type="number" id="cuatrimestre" name="cuatrimestre" min="1" max="20" required
                                           placeholder="Ej: 3">
                                </div>
                                <div class="form-group">
                                    <label>Letra</label>
                                    <input type="text" id="letra" name="letra" maxlength="1" required
                                           placeholder="Ej: A">
                                </div>
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
                                <label>Periodo</label>
                                <div class="combo-buscable" id="comboPeriodo">
                                    <input type="text" class="combo-input sin-seleccion" id="periodoTexto"
                                           placeholder="Escribe para buscar un periodo..." autocomplete="off" readonly>
                                    <input type="hidden" id="idPeriodo" name="idPeriodo" required>
                                    <div class="combo-lista" id="periodoLista"></div>
                                </div>
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
            // Quita acentos para que "matematicas" encuentre "Matemáticas" y viceversa
            function normalizarTexto(texto)
            {
                return (texto || "")
                        .normalize("NFD")
                        .replace(/[\u0300-\u036f]/g, "")
                        .toLowerCase();
            }

            // ===== Datos para los combos buscables (vienen del JSP) =====
            var opcionesCarrera = [
            <% if (carreras != null) {
                        boolean primero = true;
                        for (Carrera c : carreras) {
                            if (!primero) {
                                out.print(",");
                            }
                            primero = false;%>
                {id: <%= c.getIdCarrera()%>, nombre: "<%= esc(c.getCarrera()).replace("\"", "\\\"")%>"}
            <% }
                    } %>
            ];
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
                    }%>
            ];

            // ===== Componente genérico de combo buscable =====
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
            crearComboBuscable("comboPeriodo", "periodoTexto", "idPeriodo", "periodoLista", opcionesPeriodo);

            document.querySelectorAll('.btn-editar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    editarGrupo(
                            this.dataset.id,
                            this.dataset.generacion,
                            this.dataset.cuatrimestre,
                            this.dataset.letra,
                            this.dataset.idCarrera,
                            this.dataset.nombreCarrera,
                            this.dataset.idPeriodo,
                            this.dataset.nombrePeriodo
                            );
                });
            });

            document.querySelectorAll('.btn-eliminar').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    eliminarGrupo(this.dataset.id);
                });
            });

            function editarGrupo(id, generacion, cuatrimestre, letra, idCarrera, nombreCarrera, idPeriodo, nombrePeriodo)
            {
                document.getElementById('formTitulo').innerText = 'Editar Grupo';
                document.getElementById('accion').value = 'actualizar';
                document.getElementById('idGrupo').value = id;
                document.getElementById('generacion').value = generacion;
                document.getElementById('cuatrimestre').value = cuatrimestre;
                document.getElementById('letra').value = letra;

                document.getElementById('comboCarrera').setSeleccion(idCarrera, nombreCarrera);
                document.getElementById('comboPeriodo').setSeleccion(idPeriodo, nombrePeriodo);

                document.getElementById('formPanel').scrollIntoView({behavior: 'smooth', block: 'start'});
            }

            function eliminarGrupo(id)
            {
                if (confirm('⚠️ ¿Eliminar este grupo?\nSe eliminarán también sus asignaciones de materias y se desvincularán sus alumnos.'))
                {
                    window.location.href = '${pageContext.request.contextPath}/Grupos?accion=eliminar&idGrupo=' + id;
                }
            }

            function limpiarFormulario()
            {
                document.getElementById('formTitulo').innerText = 'Nuevo Grupo';
                document.getElementById('accion').value = 'crear';
                document.getElementById('idGrupo').value = '';
                document.getElementById('formGrupo').reset();
                document.getElementById('comboCarrera').limpiar();
                document.getElementById('comboPeriodo').limpiar();
            }
        </script>
    </body>
</html>