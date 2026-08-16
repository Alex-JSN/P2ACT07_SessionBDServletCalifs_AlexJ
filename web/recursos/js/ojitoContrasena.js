document.addEventListener('DOMContentLoaded', function ()
{
    var iconoOjoAbierto =
        '<svg viewBox="0 0 24 24" width="19" height="19" fill="none" stroke="currentColor" ' +
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
        '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>' +
        '<circle cx="12" cy="12" r="3"></circle>' +
        '</svg>';

    var iconoOjoCerrado =
        '<svg viewBox="0 0 24 24" width="19" height="19" fill="none" stroke="currentColor" ' +
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
        '<path d="M17.94 17.94A10.94 10.94 0 0 1 12 20c-7 0-11-8-11-8a21.6 21.6 0 0 1 5.06-6.94"></path>' +
        '<path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a21.6 21.6 0 0 1-3.22 4.44"></path>' +
        '<path d="M14.12 14.12a3 3 0 1 1-4.24-4.24"></path>' +
        '<line x1="1" y1="1" x2="23" y2="23"></line>' +
        '</svg>';

    document.querySelectorAll('.toggle-password').forEach(function (btn)
    {
        btn.innerHTML = iconoOjoAbierto;
        btn.setAttribute('aria-label', 'Mostrar contraseña');

        btn.addEventListener('click', function ()
        {
            var input = document.getElementById(btn.dataset.target);
            if (!input) return;

            var seVaAMostrar = input.type === 'password';
            input.type = seVaAMostrar ? 'text' : 'password';
            btn.innerHTML = seVaAMostrar ? iconoOjoCerrado : iconoOjoAbierto;
            btn.setAttribute('aria-label', seVaAMostrar ? 'Ocultar contraseña' : 'Mostrar contraseña');
        });
    });
});
