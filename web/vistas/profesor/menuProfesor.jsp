<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="modelo.Usuario"%>
<%
    Usuario usuarioActual = (Usuario) session.getAttribute("usuario");
    if (usuarioActual == null) {
        response.sendRedirect(request.getContextPath() + "/vistas/loginUsuario.jsp");
        return;
    }
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
        <li class="active">
            <a href="${pageContext.request.contextPath}/PanelProfesor">
                <span class="icon">
                    <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </span>
                Mis alumnos y calificaciones
            </a>
        </li>
        <!-- ELIMINADO: Cambiar contraseña -->
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/Logout" class="btn-logout">
            <span class="icon">
                <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
            </span>
            Cerrar sesión
        </a>
    </div>
</aside>