<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Registro de Usuario</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/login.css">
    </head>
    <body>
        <main class="auth-main">
            <div class="auth-container">
                <div class="auth-card">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">&larr; Volver al inicio</a>

                    <h1>Registro de Usuario</h1>

                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null) {
                    %>
                    <div class="error-message"><%= error%></div>
                    <%
                            request.removeAttribute("error");
                        }
                    %>

                    <form action="${pageContext.request.contextPath}/Registro" method="post" class="form-registro">
                        <div class="form-group">
                            <label for="nombre">Nombre</label>
                            <input type="text" id="nombre" name="nombre"  value="${nombre}" placeholder="Chanchito feliz" required>
                        </div>

                        <div class="form-group">
                            <label for="paterno">Apellido Paterno</label>
                            <input type="text" id="paterno" name="paterno" value="${paterno}" placeholder="Santos" required>
                        </div>

                        <div class="form-group">
                            <label for="materno">Apellido Materno</label>
                            <input type="text" id="materno" name="materno" value="${materno}" placeholder="Nava">
                        </div>

                        <div class="form-group">
                            <label for="matricula">Matrícula</label>
                            <input type="text" id="matricula" name="matricula" value="${matricula}" placeholder="Solo para alumnos">
                            <small>Si eres el primer usuario, no necesitas matrícula.</small>
                        </div>

                        <div class="form-group form-group-full">
                            <label for="correo">Correo Electrónico</label>
                            <input type="email" id="correo" name="correo" value="${correo}" placeholder="correo@gmail.com" required>
                        </div>

                        <div class="form-group form-group-full">
                            <label for="contrasena">Contraseña</label>
                            <div class="password-wrapper">
                                <input type="password" id="contrasena" name="contrasena" required minlength="8" placeholder="Tu contraseña">
                                <button type="button" class="toggle-password" data-target="contrasena" aria-label="Mostrar contraseña"></button>
                            </div>
                            <small>Mínimo 8 caracteres.</small>
                        </div>

                        <!-- Confirmar Contraseña (ocupa 2 columnas) -->
                        <div class="form-group form-group-full">
                            <label for="confirmarContrasena">Confirmar Contraseña</label>
                            <div class="password-wrapper">
                                <input type="password" id="confirmarContrasena" name="confirmarContrasena" placeholder="Confirma tu contraseña" required>
                                <button type="button" class="toggle-password" data-target="confirmarContrasena" aria-label="Mostrar contraseña"></button>
                            </div>
                        </div>

                        <button type="submit" class="btn-register">Registrarse</button>
                    </form>

                    <p class="auth-footer-link">¿Ya tienes cuenta? <a href="${pageContext.request.contextPath}/SLogin?vista=login">Inicia sesión aquí</a></p>
                </div>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/js/ojitoContrasena.js"></script>
    </body>
</html>