




CREATE PROCEDURE [Quala].[sp_ExtractorSales]
AS
	drop table if exists #ExtractorSales

	select 
		concat(g.Serie,g.Numero) NumberInvoice, 
		c.CodPro ProductCode, 
		c.NomPro ProductName,
		'PZA' Unit, 
		a.Total Sale, 
		a.Cantidad Quantity, 
		case a.discprcnt when 100 then 'BO' else '' end IsBonus,
		d.CodVen CustomerCode, 
		d.NomVen CustomerName,
		e.CodSup SupervisorCode,
		e.NomSup SupervisorName,
		f.CodCli PartnerCode,
		convert(varchar, b.Fecha, 103) Date, case h.IdAlmacen when 1 then '03' when 3 then '02' when 4 then '01' else '99' end CompanyCode, b.NuNombreMes Period
	into #ExtractorSales
	from ROMA_DATAMART.Planillas.Fact_Ventas a
	inner join ROMA_DATAMART.Ventas.DimFechas b on a.FechaKey = b.FechaKey
	inner join ROMA_DATAMART.Ventas.DimProductos c on a.IdProducto = c.IdPro
	inner join ROMA_DATAMART.Ventas.DimVendedores d on a.IdVendedor = d.IdVen
	inner join ROMA_DATAMART.Ventas.Dim_vw_Supervisores e on a.IdSupervisor = e.IdSup
	inner join ROMA_DATAMART.Ventas.DimClientes f on a.IdCliente = f.IdCli
	inner join ROMA_DATAMART.Ventas.DimDocumentos g on a.IdDocumento = g.IdDoc
	inner join ROMA_DATAMART.Ventas.DimSedes h on a.IdSede = h.IdSede
	where a.FechaKey >= convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0),112) and IdProveedor = 31



	update #ExtractorSales 
		set 
			ProductCode = CONCAT(ProductCode,IsBonus), 
			ProductName = CONCAT(ProductName,IsBonus) 
	where isbonus = 'BO'



	delete from [Quala].[ExtractorSales]

	insert into [Quala].[ExtractorSales]
	select 
		NumberInvoice, ProductCode, ProductName, Unit, Sale,
		Quantity, CustomerCode, CustomerName, SupervisorCode, 
		SupervisorName, PartnerCode,Date,CompanyCode, Period
	from #ExtractorSales

GO

