package modelo;

public class Profesor 
{
    private int idProfesor;
    private String nombre;
    private String paterno;
    private String materno;
    private String cedula;
    private int idUsuario;

    private String matricula;
    private String correo;
    private String estado;

    public int getIdProfesor() 
    {
        return idProfesor;
    }

    public void setIdProfesor(int idProfesor) 
    {
        this.idProfesor = idProfesor;
    }

    public String getNombre() 
    {
        return nombre;
    }

    public void setNombre(String nombre) 
    {
        this.nombre = nombre;
    }

    public String getPaterno() 
    {
        return paterno;
    }

    public void setPaterno(String paterno) 
    {
        this.paterno = paterno;
    }

    public String getMaterno() 
    {
        return materno;
    }

    public void setMaterno(String materno) 
    {
        this.materno = materno;
    }

    public String getCedula() 
    {
        return cedula;
    }

    public void setCedula(String cedula) 
    {
        this.cedula = cedula;
    }

    public int getIdUsuario() 
    {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) 
    {
        this.idUsuario = idUsuario;
    }

    public String getMatricula() 
    {
        return matricula;
    }

    public void setMatricula(String matricula) 
    {
        this.matricula = matricula;
    }

    public String getCorreo() 
    {
        return correo;
    }

    public void setCorreo(String correo) 
    {
        this.correo = correo;
    }

    public String getEstado() 
    {
        return estado;
    }

    public void setEstado(String estado) 
    {
        this.estado = estado;
    }
}
