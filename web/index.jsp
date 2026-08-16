<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bienvenid@</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/recursos/css/bienvenida.css">
    </head>

    <body>
        <main class="main">
            <div class="container">
                <div class="line"></div>

                <h1 id="welcome-title"><span id="typing-text"></span><span class="cursor"></span></h1>

                <p class="subtitle">
                    Sistema institucional para la gestión de usuarios.
                    Acceda con su cuenta o regístrese para comenzar a utilizar el sistema.
                </p>

                <div class="buttons-container">
                    <a href="${pageContext.request.contextPath}/SLogin?vista=login"    class="btn btn-login">Iniciar Sesión</a>
                    <a href="${pageContext.request.contextPath}/SLogin?vista=registro" class="btn btn-register">Registrarse</a>
                </div>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/recursos/js/scripIndex.js"></script>
    </body>
</html>