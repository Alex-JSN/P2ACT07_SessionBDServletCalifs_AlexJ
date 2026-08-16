(function ()
{
    const frases =
                [
                    "Bienvenido al Sistema",
                    "Inicia sesión para continuar",
                    "Regístrate si aún no tienes cuenta",
                    "¡Comienza ahora!"
                ];

    const velocidadEscritura  = 80;
    const pausaAntesBorrar    = 2000;
    const velocidadBorrado    = 40;
    const pausaAntesSiguiente = 500;

    let indiceFrase    = 0;
    let indiceCaracter = 0;
    let estaBorrando   = false;
    let timeout        = null;

    const typingElement = document.getElementById('typing-text');

    function escribir() 
    {
        const fraseActual = frases[indiceFrase];

        if (!estaBorrando) 
        {
            typingElement.textContent = fraseActual.substring(0, indiceCaracter + 1);
            indiceCaracter++;

            if (indiceCaracter === fraseActual.length)
            {
                timeout = setTimeout(borrar, pausaAntesBorrar);
                return;
            }

            timeout = setTimeout(escribir, velocidadEscritura);
        }
    }

    function borrar()
    {
        const fraseActual = frases[indiceFrase];
        estaBorrando = true;

        typingElement.textContent = fraseActual.substring(0, indiceCaracter - 1);
        indiceCaracter--;

        if (indiceCaracter === 0)
        {
            estaBorrando = false;
            indiceFrase = (indiceFrase + 1) % frases.length;
            timeout = setTimeout(escribir, pausaAntesSiguiente);
            return;
        }

        timeout = setTimeout(borrar, velocidadBorrado);
    }

    typingElement.textContent = '';
    indiceFrase = 0;
    indiceCaracter = 0;
    estaBorrando = false;
    escribir();
})();