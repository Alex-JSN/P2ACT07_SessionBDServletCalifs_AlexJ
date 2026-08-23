package modelo;
import java.sql.Timestamp;

public class Calificacion
{
    private Double parcial1;
    private Double parcial2;
    private Double parcial3;
    private Timestamp fechaRegistro;
    private Timestamp fechaModificacion;
    private int idInscripcion;
    private int idAsigna;
    
    private int idMateria;
    private String nombreMateria;
    private String nombrePeriodo;
    private String matriculaAlumno;

    public Double getParcial1()
    {
        return parcial1;
    }
    
    public void setParcial1(Double parcial1)
    {
        this.parcial1 = parcial1;
    }
    
    public Double getParcial2()
    {
        return parcial2;
    }
    
    public void setParcial2(Double parcial2)
    {
        this.parcial2 = parcial2;
    }
    
    public Double getParcial3()
    {
        return parcial3;
    }
    
    public void setParcial3(Double parcial3)
    {
        this.parcial3 = parcial3;
    }
    
    public Timestamp getFechaRegistro()
    {
        return fechaRegistro;
    }
    
    public void setFechaRegistro(Timestamp fechaRegistro)
    {
        this.fechaRegistro = fechaRegistro;
    }
    
    public Timestamp getFechaModificacion()
    {
        return fechaModificacion;
    }
    
    public void setFechaModificacion(Timestamp fechaModificacion)
    {
        this.fechaModificacion = fechaModificacion;
    }
    
    public int getIdInscripcion()
    {
        return idInscripcion;
    }
    
    public void setIdInscripcion(int idInscripcion)
    {
        this.idInscripcion = idInscripcion;
    }
    
    public int getIdAsigna()
    {
        return idAsigna;
    }
    
    public void setIdAsigna(int idAsigna)
    {
        this.idAsigna = idAsigna;
    }
    
    public int getIdMateria()
    {
        return idMateria;
    }
    
    public void setIdMateria(int idMateria)
    {
        this.idMateria = idMateria;
    }
    
    public String getNombreMateria()
    {
        return nombreMateria;
    }
    
    public void setNombreMateria(String nombreMateria)
    {
        this.nombreMateria = nombreMateria;
    }
    
    public String getNombrePeriodo()
    {
        return nombrePeriodo;
    }
    
    public void setNombrePeriodo(String nombrePeriodo)
    {
        this.nombrePeriodo = nombrePeriodo;
    }
    
    public String getMatriculaAlumno()
    {
        return matriculaAlumno;
    }
    
    public void setMatriculaAlumno(String matriculaAlumno)
    {
        this.matriculaAlumno = matriculaAlumno;
    }
    
    public Double getPromedio()
    {
        int count = 0;
        double sum = 0;
        if (parcial1 != null) { sum += parcial1; count++; }
        if (parcial2 != null) { sum += parcial2; count++; }
        if (parcial3 != null) { sum += parcial3; count++; }
        return count > 0 ? sum / count : null;
    }
}