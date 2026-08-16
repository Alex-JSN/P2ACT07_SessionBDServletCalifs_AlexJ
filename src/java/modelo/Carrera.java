package modelo;

public class Carrera
{
    private int idCarrera;
    private String clave;
    private String carrera;
    private int totalCuatrimestres;
    private int cuatrimestreEstadia;

    public int getIdCarrera()
    {
        return idCarrera;
    }
    public void setIdCarrera(int idCarrera)
    {
        this.idCarrera = idCarrera;
    }
    public String getClave()
    {
        return clave;
    }
    public void setClave(String clave)
    {
        this.clave = clave;
    }
    public String getCarrera()
    {
        return carrera;
    }
    public void setCarrera(String carrera)
    {
        this.carrera = carrera;
    }
    public int getTotalCuatrimestres()
    {
        return totalCuatrimestres;
    }
    public void setTotalCuatrimestres(int totalCuatrimestres)
    {
        this.totalCuatrimestres = totalCuatrimestres;
    }
    public int getCuatrimestreEstadia()
    {
        return cuatrimestreEstadia;
    }
    public void setCuatrimestreEstadia(int cuatrimestreEstadia)
    {
        this.cuatrimestreEstadia = cuatrimestreEstadia;
    }
}