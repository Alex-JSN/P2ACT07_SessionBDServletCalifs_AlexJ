<%@page contentType="text/html" pageEncoding="UTF-8"%>
<div id="modalContrasena" class="modal-overlay" style="display: none;">
    <div class="modal-container">
        <div class="modal-header">
            <h2>Cambiar contraseña</h2>
            <button type="button" class="modal-close" onclick="cerrarModalContrasena()">&times;</button>
        </div>
        <div class="modal-body">
            <form action="${pageContext.request.contextPath}/CambiarContrasena" method="POST" id="formModalContrasena">
                <input type="hidden" name="accion" value="cambiarContrasena">

                <div class="form-group">
                    <label for="modalContrasenaActual">Contraseña actual</label>
                    <div class="password-wrapper">
                        <input type="password" id="modalContrasenaActual" name="contrasenaActual" required>
                        <button type="button" class="toggle-password" data-target="modalContrasenaActual" aria-label="Mostrar contraseña"></button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="modalContrasenaNueva">Contraseña nueva</label>
                    <div class="password-wrapper">
                        <input type="password" id="modalContrasenaNueva" name="contrasenaNueva" minlength="8" required>
                        <button type="button" class="toggle-password" data-target="modalContrasenaNueva" aria-label="Mostrar contraseña"></button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="modalContrasenaConfirmar">Confirmar contraseña nueva</label>
                    <div class="password-wrapper">
                        <input type="password" id="modalContrasenaConfirmar" name="contrasenaConfirmar" minlength="8" required>
                        <button type="button" class="toggle-password" data-target="modalContrasenaConfirmar" aria-label="Mostrar contraseña"></button>
                    </div>
                </div>

                <div id="modalMensajeError" class="alert alert-error" style="display: none;"></div>
                <div id="modalMensajeExito" class="alert alert-success" style="display: none;"></div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="cerrarModalContrasena()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Actualizar contraseña</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function abrirModalContrasena() {
        const modal = document.getElementById('modalContrasena');
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        
        document.getElementById('modalMensajeError').style.display = 'none';
        document.getElementById('modalMensajeExito').style.display = 'none';
        
        document.getElementById('modalContrasenaActual').value = '';
        document.getElementById('modalContrasenaNueva').value = '';
        document.getElementById('modalContrasenaConfirmar').value = '';
        
        setTimeout(function() {
            document.getElementById('modalContrasenaActual').focus();
        }, 200);
    }

    function cerrarModalContrasena() {
        const modal = document.getElementById('modalContrasena');
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
        location.reload();
    }

    document.addEventListener('DOMContentLoaded', function() {
        const modal = document.getElementById('modalContrasena');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === this) {
                    cerrarModalContrasena();
                }
            });
        }

        const form = document.getElementById('formModalContrasena');
        if (form) {
            form.addEventListener('submit', function(e) {
                const actual = document.getElementById('modalContrasenaActual').value.trim();
                const nueva = document.getElementById('modalContrasenaNueva').value.trim();
                const confirmar = document.getElementById('modalContrasenaConfirmar').value.trim();
                const errorDiv = document.getElementById('modalMensajeError');
                const exitoDiv = document.getElementById('modalMensajeExito');

                errorDiv.style.display = 'none';
                exitoDiv.style.display = 'none';

                if (actual === '') {
                    e.preventDefault();
                    errorDiv.textContent = 'Debes ingresar tu contraseña actual.';
                    errorDiv.style.display = 'block';
                    return;
                }

                if (nueva.length < 8) {
                    e.preventDefault();
                    errorDiv.textContent = 'La contraseña nueva debe tener al menos 8 caracteres.';
                    errorDiv.style.display = 'block';
                    return;
                }

                if (nueva !== confirmar) {
                    e.preventDefault();
                    errorDiv.textContent = 'La contraseña nueva y la confirmación no coinciden.';
                    errorDiv.style.display = 'block';
                    return;
                }

                if (actual === nueva) {
                    e.preventDefault();
                    errorDiv.textContent = 'La contraseña nueva debe ser diferente a la actual.';
                    errorDiv.style.display = 'block';
                    return;
                }
            });
        }

        const error = '<%= session.getAttribute("error") != null ? session.getAttribute("error") : "" %>';
        const mensaje = '<%= session.getAttribute("mensaje") != null ? session.getAttribute("mensaje") : "" %>';
        
        if (error && error.trim() !== '' && error.trim() !== 'null') {
            const errorDiv = document.getElementById('modalMensajeError');
            errorDiv.textContent = error;
            errorDiv.style.display = 'block';
            abrirModalContrasena();
            <% session.removeAttribute("error"); %>
        }
        
        if (mensaje && mensaje.trim() !== '' && mensaje.trim() !== 'null') {
            const exitoDiv = document.getElementById('modalMensajeExito');
            exitoDiv.textContent = mensaje;
            exitoDiv.style.display = 'block';
            abrirModalContrasena();
            <% session.removeAttribute("mensaje"); %>
            
            setTimeout(function() {
                cerrarModalContrasena();
            }, 2500);
        }
    });
</script>