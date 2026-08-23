package modelo;
public class Materia
{
    private int idMateria;
    private String materia;
    private int cuatrimestre;
    private int idCarrera;

    public int getIdMateria()
    {
        return idMateria;
    }
    
    public void setIdMateria(int idMateria)
    {
        this.idMateria = idMateria;
    }
    
    public String getMateria()
    {
        return materia;
    }
    
    public void setMateria(String materia)
    {
        this.materia = materia;
    }
    
    public int getCuatrimestre()
    {
        return cuatrimestre;
    }
    
    public void setCuatrimestre(int cuatrimestre)
    {
        this.cuatrimestre = cuatrimestre;
    }
    
    public int getIdCarrera()
    {
        return idCarrera;
    }
    
    public void setIdCarrera(int idCarrera)
    {
        this.idCarrera = idCarrera;
    }
}