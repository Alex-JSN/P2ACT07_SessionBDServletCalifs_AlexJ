<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null || !"Administrador".equals(usuarioActual.getTipoUsuario()))
    {
        response.sendRedirect(request.getContextPath() + "/loginUsuario.jsp");
        return;
    }

    Object totalAlumnos = request.getAttribute("totalAlumnos");
    Object totalProfesores = request.getAttribute("totalProfesores");
    Object totalMaterias = request.getAttribute("totalMaterias");
    Object totalCarreras = request.getAttribute("totalCarreras");
    Object totalGrupos = request.getAttribute("totalGrupos");
    Object totalPeriodos = request.getAttribute("totalPeriodos");
    Object totalInscripciones = request.getAttribute("totalInscripciones");
    Object totalAsignaciones = request.getAttribute("totalAsignaciones");
    Object totalCuentas = request.getAttribute("totalCuentas");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Panel Administrador - Inicio</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/basePanel.css">
    </head>
    <body>
        <div class="app-shell">

            <jsp:include page="menuAdministrador.jsp"><jsp:param name="seccion" value="inicio"/></jsp:include>

            <main class="content-area">
                <div class="panel-header">
                    <div class="left">
                        <h1>Bienvenido, <%= usuarioActual.getNombre()%></h1>
                        <span class="welcome-text">Resumen general del sistema</span>
                    </div>
                </div>

                <div class="module-grid">
                    <a class="module-card mc-alumnos" href="${pageContext.request.contextPath}/Alumnos">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><path d="M22 10 12 5 2 10l10 5 10-5Z"/><path d="M6 12v5c0 1.5 2.7 3 6 3s6-1.5 6-3v-5"/></svg></div>
                            <div class="module-count"><strong><%= totalAlumnos != null ? totalAlumnos : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Alumnos</h3>
                        <p>Alta, edición y baja de alumnos registrados en el sistema.</p>
                    </a>
                    <a class="module-card mc-profesores" href="${pageContext.request.contextPath}/GestionProfesores">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                            <div class="module-count"><strong><%= totalProfesores != null ? totalProfesores : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Profesores</h3>
                        <p>Gestión de cuentas y datos de profesores.</p>
                    </a>
                    <a class="module-card mc-materias" href="${pageContext.request.contextPath}/Materias">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v17H6.5A2.5 2.5 0 0 0 4 21.5Z"/><path d="M20 19H6.5a2.5 2.5 0 0 0 0 5H20"/></svg></div>
                            <div class="module-count"><strong><%= totalMaterias != null ? totalMaterias : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Materias</h3>
                        <p>Catálogo de materias por carrera y cuatrimestre.</p>
                    </a>
                    <a class="module-card mc-carreras" href="${pageContext.request.contextPath}/Carreras">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="0.8" fill="currentColor"/></svg></div>
                            <div class="module-count"><strong><%= totalCarreras != null ? totalCarreras : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Carreras</h3>
                        <p>Carreras ofertadas, duración y cuatrimestre de estadía.</p>
                    </a>
                    <a class="module-card mc-grupos" href="${pageContext.request.contextPath}/Grupos">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><circle cx="8.5" cy="8" r="3"/><circle cx="16" cy="9" r="2.5"/><path d="M2.5 20v-1.5C2.5 15.9 5 14 8.5 14s6 1.9 6 4.5V20"/></svg></div>
                            <div class="module-count"><strong><%= totalGrupos != null ? totalGrupos : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Grupos</h3>
                        <p>Grupos por generación, cuatrimestre y periodo.</p>
                    </a>
                    <a class="module-card mc-periodos" href="${pageContext.request.contextPath}/Periodos">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18"/><path d="M8 3v4M16 3v4"/></svg></div>
                            <div class="module-count"><strong><%= totalPeriodos != null ? totalPeriodos : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Periodos</h3>
                        <p>Periodos académicos y su estado (programado/activo/cerrado).</p>
                    </a>
                    <a class="module-card mc-inscripciones" href="${pageContext.request.contextPath}/Inscripciones">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><path d="M6 3h9l5 5v13a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1Z"/><path d="m9.5 15.5 2 2 4-4.5"/></svg></div>
                            <div class="module-count"><strong><%= totalInscripciones != null ? totalInscripciones : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Inscripciones</h3>
                        <p>Inscribe alumnos a un periodo para que puedan tener calificaciones.</p>
                    </a>
                    <a class="module-card mc-asignaciones" href="${pageContext.request.contextPath}/Asignaciones">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><path d="M10 13a4 4 0 0 0 5.7.3l2.3-2.3a4 4 0 1 0-5.6-5.6L11 6"/><path d="M14 11a4 4 0 0 0-5.7-.3L6 13a4 4 0 1 0 5.6 5.6L13 18"/></svg></div>
                            <div class="module-count"><strong><%= totalAsignaciones != null ? totalAsignaciones : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Asignaciones</h3>
                        <p>Vincula profesores con materias y grupos.</p>
                    </a>
                    <a class="module-card mc-cuentas" href="${pageContext.request.contextPath}/Cuentas">
                        <div class="module-card-top">
                            <div class="module-icon"><svg width="28" height="28" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7"/></svg></div>
                            <div class="module-count"><strong><%= totalCuentas != null ? totalCuentas : 0%></strong><span>Total</span></div>
                        </div>
                        <h3>Cuentas</h3>
                        <p>Activar, desactivar o restablecer contraseñas de cualquier cuenta.</p>
                    </a>
                </div>
            </main>
        </div>
    </body>
</html>