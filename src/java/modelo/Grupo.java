package modelo;

public class Grupo
{
    private int idGrupo;
    private String generacion;
    private int cuatrimestre;
    private String letra;
    private int idCarrera;
    private int idPeriodo;

    public int getIdGrupo()
    {
        return idGrupo;
    }
    
    public void setIdGrupo(int idGrupo)
    {
        this.idGrupo = idGrupo;
    }
    
    public String getGeneracion()
    {
        return generacion;
    }
    
    public void setGeneracion(String generacion)
    {
        this.generacion = generacion;
    }
    
    public int getCuatrimestre()
    {
        return cuatrimestre;
    }
    
    public void setCuatrimestre(int cuatrimestre)
    {
        this.cuatrimestre = cuatrimestre;
    }
    
    public String getLetra()
    {
        return letra;
    }
    
    public void setLetra(String letra)
    {
        this.letra = letra;
    }
    
    public int getIdCarrera()
    {
        return idCarrera;
    }
    
    public void setIdCarrera(int idCarrera)
    {
        this.idCarrera = idCarrera;
    }
    
    public int getIdPeriodo()
    {
        return idPeriodo;
    }
    
    public void setIdPeriodo(int idPeriodo)
    {
        this.idPeriodo = idPeriodo;
    }
}