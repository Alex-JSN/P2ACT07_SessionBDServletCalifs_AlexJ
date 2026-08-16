<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null) { return; }
%>
<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="credencial">UT</div>
        <div class="brand-text">
            <h1>Sistema Escolar</h1>
            <span>Panel del profesor</span>
        </div>
    </div>

    <div class="sidebar-user">
        <div class="avatar"><%= usuarioActual.getNombre() != null && usuarioActual.getNombre().length() > 0 ? usuarioActual.getNombre().substring(0,1).toUpperCase() : "P" %></div>
        <div class="info">
            <small>Profesor</small>
            <strong><%= usuarioActual.getNombre() %></strong>
        </div>
    </div>

    <ul class="sidebar-nav">
        <li class="active"><a href="${pageContext.request.contextPath}/PanelProfesor"><span class="icon">🎓</span> Mis alumnos y calificaciones</a></li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">⎋ Cerrar sesión</a>
    </div>
</aside>