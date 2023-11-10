
CREATE PROCEDURE reports.sp_DeprodecaDailyMonitoring @date_init date, @date_end date

AS

BEGIN
	
	--declare @date_init date = '2023-10-01', @date_end date = '2023-10-30'
	
	drop table if exists #data

	select 
			b.Fecha, c.CodPro, c.NomPro, d.CodSede, d.NomSede, d.Sucursal, e.CodVen, 
			e.NomVen, g.CodCan, g.NomCan, a.Soles, a.UMES, f.CodCli 
	into #data
	from ROMA_DATAMART.Ventas.Fact_Digitacion a
	inner join ROMA_DATAMART.Ventas.DimFechas b on a.FechaKey = b.FechaKey
	inner join ROMA_DATAMART.Ventas.DimProductos c on a.IdProducto = c.IdPro
	inner join ROMA_DATAMART.Ventas.DimSedes d on a.IdSede = d.IdSede
	inner join ROMA_DATAMART.Ventas.DimVendedores e on a.IdVen = e.IdVen
	inner join ROMA_DATAMART.Ventas.DimClientes f on a.IdCli = f.IdCli
	inner join ROMA_DATAMART.Ventas.DimCanales g on a.IdCan = g.IdCan
	where c.CodPro in ('DEP049030') and b.Fecha between @date_init and @date_end



	select Fecha, sucursal, CodSede, NomVen, CodPro, NomPro, NomCan, SUM(Soles) venta, SUM(UMES) UMES, COUNT(DISTINCT CodCli) cobertura from #data
	GROUP BY Fecha, sucursal, CodSede, NomVen, CodPro, NomPro, NomCan

END

GO

