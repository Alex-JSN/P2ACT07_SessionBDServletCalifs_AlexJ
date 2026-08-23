package modelo;

public class Alumno
{
    private int idAlumno;
    private String matricula;
    private String nombre;
    private String paterno;
    private String materno;
    private String correo;
    private String fechaRegistro;
    private int idCarrera;
    private int idUsuario;
    private int idGrupo;

    public int getIdAlumno()
    {
        return idAlumno;
    }

    public void setIdAlumno(int idAlumno)
    {
        this.idAlumno = idAlumno;
    }

    public String getMatricula()
    {
        return matricula;
    }

    public void setMatricula(String matricula)
    {
        this.matricula = matricula;
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

    public String getCorreo()
    {
        return correo;
    }

    public void setCorreo(String correo)
    {
        this.correo = correo;
    }

    public String getFechaRegistro()
    {
        return fechaRegistro;
    }

    public void setFechaRegistro(String fechaRegistro)
    {
        this.fechaRegistro = fechaRegistro;
    }
    
    public int getIdCarrera()
    {
        return idCarrera;
    }
    
    public void setIdCarrera(int idCarrera)
    {
        this.idCarrera = idCarrera;
    }
    
    public int getIdUsuario()
    {
        return idUsuario;
    }
    
    public void setIdUsuario(int idUsuario)
    {
        this.idUsuario = idUsuario;
    }
    
    public int getIdGrupo()
    {
        return idGrupo;
    }
    
    public void setIdGrupo(int idGrupo)
    {
        this.idGrupo = idGrupo;
    }
}