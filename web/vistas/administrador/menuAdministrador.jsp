<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null) {
        return;
    }
    String seccion = request.getParameter("seccion");
    if (seccion == null) {
        seccion = "";
    }
%>
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="credencial">UT</div>
        <div class="brand-text">
            <h1>Sistema Escolar</h1>
            <span>Panel administrativo</span>
        </div>
    </div>
    <div class="sidebar-user">
        <div class="avatar"><%= usuarioActual.getNombre() != null && usuarioActual.getNombre().length() > 0 ? usuarioActual.getNombre().substring(0, 1).toUpperCase() : "A"%></div>
        <div class="info">
            <small>Administrador</small>
            <strong><%= usuarioActual.getNombre()%></strong>
        </div>
    </div>
    <ul class="sidebar-nav">
        <li class="<%= "inicio".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/PanelAdministrador">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M3 11.5 12 4l9 7.5"/><path d="M5 10v10h14V10"/><path d="M9.5 20v-6h5v6"/></svg>
                Inicio
            </a>
        </li>
        <li class="nav-section-label">Gestión académica</li>
        <li class="<%= "alumnos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Alumnos">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M22 10 12 5 2 10l10 5 10-5Z"/><path d="M6 12v5c0 1.5 2.7 3 6 3s6-1.5 6-3v-5"/></svg>
                Alumnos
            </a>
        </li>
        <li class="<%= "profesores".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/GestionProfesores">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="13" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                Profesores
            </a>
        </li>
        <li class="<%= "materias".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Materias">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v17H6.5A2.5 2.5 0 0 0 4 21.5Z"/><path d="M20 19H6.5a2.5 2.5 0 0 0 0 5H20"/></svg>
                Materias
            </a>
        </li>
        <li class="<%= "carreras".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Carreras">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="0.8" fill="currentColor"/></svg>
                Carreras
            </a>
        </li>
        <li class="<%= "grupos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Grupos">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><circle cx="8.5" cy="8" r="3"/><circle cx="16" cy="9" r="2.5"/><path d="M2.5 20v-1.5C2.5 15.9 5 14 8.5 14s6 1.9 6 4.5V20"/></svg>
                Grupos
            </a>
        </li>
        <li class="<%= "periodos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Periodos">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18"/><path d="M8 3v4M16 3v4"/></svg>
                Periodos
            </a>
        </li>
        <li class="<%= "inscripciones".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Inscripciones">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M6 3h9l5 5v13a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1Z"/><path d="m9.5 15.5 2 2 4-4.5"/></svg>
                Inscripciones
            </a>
        </li>
        <li class="<%= "asignaciones".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Asignaciones">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M10 13a4 4 0 0 0 5.7.3l2.3-2.3a4 4 0 1 0-5.6-5.6L11 6"/><path d="M14 11a4 4 0 0 0-5.7-.3L6 13a4 4 0 1 0 5.6 5.6L13 18"/></svg>
                Asignaciones
            </a>
        </li>
        <li class="nav-section-label">Sistema</li>
        <li class="<%= "cuentas".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Cuentas">
                <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7"/></svg>
                Cuentas
            </a>
        </li>
    </ul>
    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">
            <svg class="icon" width="19" height="19" viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>
            Cerrar sesión
        </a>
    </div>
</aside>