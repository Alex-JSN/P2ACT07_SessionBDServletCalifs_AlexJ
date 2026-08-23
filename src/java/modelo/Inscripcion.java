package modelo;

import java.sql.Timestamp;

public class Inscripcion
{
    private int idInscripcion;
    private String cuatrimestre;
    private Timestamp fechaInscripcion;
    private String estado;
    private int idAlumno;
    private int idPeriodo;

    private String matriculaAlumno;
    private String nombreAlumno;
    private String nombrePeriodo;

    public int getIdInscripcion()
    {
        return idInscripcion;
    }

    public void setIdInscripcion(int idInscripcion)
    {
        this.idInscripcion = idInscripcion;
    }

    public String getCuatrimestre()
    {
        return cuatrimestre;
    }

    public void setCuatrimestre(String cuatrimestre)
    {
        this.cuatrimestre = cuatrimestre;
    }

    public Timestamp getFechaInscripcion()
    {
        return fechaInscripcion;
    }

    public void setFechaInscripcion(Timestamp fechaInscripcion)
    {
        this.fechaInscripcion = fechaInscripcion;
    }

    public String getEstado()
    {
        return estado;
    }

    public void setEstado(String estado)
    {
        this.estado = estado;
    }

    public int getIdAlumno()
    {
        return idAlumno;
    }

    public void setIdAlumno(int idAlumno)
    {
        this.idAlumno = idAlumno;
    }

    public int getIdPeriodo()
    {
        return idPeriodo;
    }

    public void setIdPeriodo(int idPeriodo)
    {
        this.idPeriodo = idPeriodo;
    }

    public String getMatriculaAlumno()
    {
        return matriculaAlumno;
    }

    public void setMatriculaAlumno(String matriculaAlumno)
    {
        this.matriculaAlumno = matriculaAlumno;
    }

    public String getNombreAlumno()
    {
        return nombreAlumno;
    }

    public void setNombreAlumno(String nombreAlumno)
    {
        this.nombreAlumno = nombreAlumno;
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
