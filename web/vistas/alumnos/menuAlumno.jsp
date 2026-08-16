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
            <span>Panel del alumno</span>
        </div>
    </div>

    <div class="sidebar-user">
        <div class="avatar"><%= usuarioActual.getNombre() != null && usuarioActual.getNombre().length() > 0 ? usuarioActual.getNombre().substring(0,1).toUpperCase() : "A" %></div>
        <div class="info">
            <small>Alumno</small>
            <strong><%= usuarioActual.getNombre() %></strong>
        </div>
    </div>

    <ul class="sidebar-nav">
        <li class="active"><a href="#seccionCalificaciones"><span class="icon">📊</span> Mis calificaciones</a></li>
        <li><a href="#seccionSeguridad"><span class="icon">🔒</span> Cambiar contraseña</a></li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">⎋ Cerrar sesión</a>
    </div>
</aside>