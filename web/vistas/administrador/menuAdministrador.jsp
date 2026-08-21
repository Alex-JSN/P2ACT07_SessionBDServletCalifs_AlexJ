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
            <a href="${pageContext.request.contextPath}/PanelAdministrador"><span class="icon">🏠</span> Inicio</a>
        </li>

        <li class="nav-section-label">Gestión académica</li>
        <li class="<%= "alumnos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/PanelAdministrador"><span class="icon">🎓</span> Alumnos</a>
        </li>
        <li class="<%= "profesores".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/GestionProfesores"><span class="icon">👨‍🏫</span> Profesores</a>
        </li>
        <li class="<%= "materias".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Materias"><span class="icon">📚</span> Materias</a>
        </li>
        <li class="<%= "carreras".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Carreras"><span class="icon">🎯</span> Carreras</a>
        </li>
        <li class="<%= "grupos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Grupos"><span class="icon">👥</span> Grupos</a>
        </li>
        <li class="<%= "periodos".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Periodos"><span class="icon">🗓️</span> Periodos</a>
        </li>
        <li class="<%= "inscripciones".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Inscripciones"><span class="icon">📝</span> Inscripciones</a>
        </li>
        <li class="<%= "asignaciones".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Asignaciones"><span class="icon">🔗</span> Asignaciones</a>
        </li>

        <li class="nav-section-label">Sistema</li>
        <li class="<%= "cuentas".equals(seccion) ? "active" : ""%>">
            <a href="${pageContext.request.contextPath}/Cuentas"><span class="icon">👤</span> Cuentas</a>
        </li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">⎋ Cerrar sesión</a>
    </div>
</aside>