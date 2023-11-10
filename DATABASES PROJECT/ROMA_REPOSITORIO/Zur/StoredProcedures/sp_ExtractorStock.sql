CREATE procedure [Zur].[sp_ExtractorStock] 
as

begin
	

	/*
	select 
		FechaKey, b.IdAlmacen, a.IdProducto, sum(Cantidad) Cantidad, sum(TotalIGV) Total
	from ROMA_DATAMART.Planillas.Fact_Ventas a
	inner join ROMA_DATAMART.Ventas.DimSedes b on a.IdSede = b.IdSede
	where fechakey = convert(varchar, GETDATE()-1,112) and a.IdProveedor = 19 and IdProducto =1923
	group by FechaKey, b.IdAlmacen, a.IdProducto
	
	select * from ROMA_DATAMART.Planillas.Fact_Ventas a
	where fechakey = convert(varchar, GETDATE()-1,112) and a.IdProveedor = 19 and IdProducto =1923

		select * from ROMA_DATAMART.Planillas.Fact_Ventas a
	where fechakey = convert(varchar, GETDATE()-2,112) and a.IdProveedor = 19 and IdProducto =1923
	*/

	select 
		e.CodPrv SupplierCode,
		case a.IdAlmacen when 4 then '20537004381.ICA' when 3 then '20537004381.CHINCHA' when 1 then '20537004381.AYACUCHO' end CompanyCode,
		f.CodAlmacen WarehouseCode,
		F.NomAlmacen WarehouseName,
		C.CodPro ProductCode,
		'' Lot,
		'' DueDate,
		CONVERT(int,a.Cantidad_xPiezas) StockMinUnit,
		'PZA' UnitMin,
		CONVERT(int,a.cantidad) StockMaxUnit,
		'CJA' UnitMax,
		CONVERT(decimal(18,4),a.valorizado) ValuedStock,
		GETDATE() ProcessDate,
		0 IncomeConsumptionUnit,
		CONVERT(decimal(18,4),0) IncomeValues,
		0 SalesConsumptionUnit,
		CONVERT(decimal(18,4),0) SalesValues,
		0 OtherConsuMptionUnit,
		CONVERT(decimal(18,4),0) OtherValues,
		left(a.FechaKey,6) Period,
		'' Ref1,
		'' Ref2,
		'' Ref3,
		'' Ref4,
		'' Ref5,
		'' Ref6,
		'' Ref7,
		'' Ref8,
		'' Ref9,
		'' Ref10
	into #ExtractorStock
	from ROMA_DATAMART.Ventas.Fact_Inventarios a
	inner join ROMA_DATAMART.Ventas.DimFechas b on a.FechaKey = b.FechaKey
	inner join ROMA_DATAMART.Ventas.DimProductos c on a.IdProducto = c.IdPro
	inner join ROMA_DATAMART.Ventas.DimCategorias d on a.IdCat_xPrv = d.IdCat_xPrv
	inner join ROMA_DATAMART.Ventas.DimProveedores e on d.IdPrv = e.IdPrv
	inner join ROMA_DATAMART.Ventas.DimAlmacenes f on a.IdAlmacen = f.IdAlmacen
	where b.Fecha = convert(date, GETDATE()-1) and a.IdProveedor = 19

	delete from Zur.ExtractorStock

	insert into Zur.ExtractorStock
	select * from #ExtractorStock
	--select top 10 * from roma_datamart.ventas.Fact_Inventarios where idproveedor = 19 and fechakey = 20231108 and idproducto = 1923
	--select * from roma_datamart.ventas.dimproductos where codpro = 'ZUR210818'

end

GO

