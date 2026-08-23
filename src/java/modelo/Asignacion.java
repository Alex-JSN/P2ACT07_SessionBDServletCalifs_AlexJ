package modelo;

public class Asignacion
{
    private int idAsigna;
    private int idProfesor;
    private int idMateria;
    private int idGrupo;

    private String nombreProfesor;
    private String nombreMateria;
    private String nombreGrupo;
    private String nombrePeriodo;

    public int getIdAsigna()
    {
        return idAsigna;
    }

    public void setIdAsigna(int idAsigna)
    {
        this.idAsigna = idAsigna;
    }

    public int getIdProfesor()
    {
        return idProfesor;
    }

    public void setIdProfesor(int idProfesor)
    {
        this.idProfesor = idProfesor;
    }

    public int getIdMateria()
    {
        return idMateria;
    }

    public void setIdMateria(int idMateria)
    {
        this.idMateria = idMateria;
    }

    public int getIdGrupo()
    {
        return idGrupo;
    }

    public void setIdGrupo(int idGrupo)
    {
        this.idGrupo = idGrupo;
    }

    public String getNombreProfesor()
    {
        return nombreProfesor;
    }

    public void setNombreProfesor(String nombreProfesor)
    {
        this.nombreProfesor = nombreProfesor;
    }

    public String getNombreMateria()
    {
        return nombreMateria;
    }

    public void setNombreMateria(String nombreMateria)
    {
        this.nombreMateria = nombreMateria;
    }

    public String getNombreGrupo()
    {
        return nombreGrupo;
    }

    public void setNombreGrupo(String nombreGrupo)
    {
        this.nombreGrupo = nombreGrupo;
    }

    public String getNombrePeriodo()
    {
        return nombrePeriodo;
    }

    public void setNombrePeriodo(String nombrePeriodo)
    {
        this.nombrePeriodo = nombrePeriodo;
    }
}
