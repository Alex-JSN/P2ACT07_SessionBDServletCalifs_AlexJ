<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Verificar código</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/login.css">
    </head>
    <body>
        <main class="auth-main">
            <div class="auth-container">
                <div class="auth-line"></div>

                <div class="auth-card">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">&larr; Volver al inicio</a>

                    <h1 class="auth-title">Verifica tu cuenta</h1>
                    <p class="auth-subtitle">
                        Enviamos un código de 6 dígitos a
                        <strong>${correo}</strong>. Ingrésalo para activar tu cuenta.
                    </p>

                    <c:if test="${not empty error}">
                        <div class="alert alert-error">${error}</div>
                    </c:if>
                    <c:if test="${not empty mensaje}">
                        <div class="alert alert-success">${mensaje}</div>
                    </c:if>

                    <form id="formVerificar" action="${pageContext.request.contextPath}/VerificarCuenta" method="post" novalidate>
                        <input type="hidden" name="accion" value="verificar">

                        <div class="form-group">
                            <label for="codigo">Código de verificación</label>
                            <input type="text" id="codigo" name="codigo" maxlength="6" inputmode="numeric"
                                   placeholder="000000" autocomplete="one-time-code" required autofocus>
                        </div>

                        <button type="submit" class="btn-auth">Verificar cuenta</button>
                    </form>

                    <form id="formReenviar" action="${pageContext.request.contextPath}/VerificarCuenta" method="post" style="margin-top:12px;">
                        <input type="hidden" name="accion" value="reenviar">
                        <button type="submit" class="btn-auth btn-secundario">Reenviar código</button>
                    </form>

                    <p class="auth-footer-link">
                        ¿Ya tienes tu cuenta activa? <a href="${pageContext.request.contextPath}/vistas/loginUsuario.jsp">Inicia sesión aquí</a>
                    </p>
                </div>
            </div>
        </main>
    </body>
</html>
