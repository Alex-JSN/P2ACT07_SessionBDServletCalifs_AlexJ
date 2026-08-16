<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String mensajeExito = (String) session.getAttribute("mensajeExito");
    
    if (mensajeExito != null)
    {
%>
    <div class="mensaje-exito"><%= mensajeExito %></div>
<%
        session.removeAttribute("mensajeExito");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Login Usuario</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/login.css">
    </head>
    <body>
        <main class="auth-main">
            <div class="auth-container">
                <div class="auth-card">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">&larr; Volver al inicio</a>

                    <h1 class="auth-title">Iniciar Sesión</h1>
                    <p  class="auth-subtitle">Ingresa tu correo y contraseña para continuar</p>

                    <form id="formLogin" action="${pageContext.request.contextPath}/Login" method="post" novalidate>
                        <div class="form-group">
                            <label for="correo">Correo electrónico</label>
                            <input type="email"        id="correo" name="correo" placeholder="correo@gmail.com" value="${correo}" required autocomplete="email">
                            <span  class="field-error" id="errorCorreo">Ingresa un correo válido.</span>
                        </div>

                        <div class="form-group">
                            <label for="contrasena">Contraseña</label>
                            <div class="password-wrapper">
                                <input  type="password" id="contrasena" name="contrasena" placeholder="Tu contraseña" required autocomplete="current-password">
                                <button type="button" class="toggle-password" data-target="contrasena" aria-label="Mostrar contraseña"></button>
                            </div>
                            <span class="field-error" id="errorContrasena">La contraseña es obligatoria.</span>
                        </div>

                        <button type="submit" class="btn-auth">Iniciar</button>
                    </form>

                    <p class="auth-footer-link">¿No tienes cuenta? <a href="${pageContext.request.contextPath}/registroUsuario.jsp">Regístrate aquí</a></p>
                </div>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/recursos/js/ojitoContrasena.js"></script>
    </body>
</html>