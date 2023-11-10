CREATE procedure [Quala].[sp_ExtractorStock]
as

begin
	
	drop table if exists #ExtractorStock

	select 
	c.CodPro ProductCode, c.NomPro ProductName, 'PZA' Unit,
	(a.cantidad*c.QtdPiezas) Quantity, convert(varchar, b.Fecha, 103) Date,
	case a.IdAlmacen when 1 then '03' when 3 then '02' when 4 then '01' end CompanyCode,
	b.NuNombreMes Period
	into #ExtractorStock
	from ROMA_DATAMART.Ventas.Fact_Inventarios a
	inner join ROMA_DATAMART.Ventas.DimFechas b on a.FechaKey = b.FechaKey
	inner join ROMA_DATAMART.Ventas.DimProductos c on a.IdProducto = c.IdPro
	where b.Fecha = convert(date, GETDATE()-1) and IdProveedor = 31

	delete from quala.ExtractorStock

	insert into quala.ExtractorStock
	select * from #ExtractorStock

end

GO

