
CREATE procedure [Reports].[sp_DetailReportStock] @fechakey varchar(8)
as
begin
	

	--declare @fechakey varchar(8) = 20231031

	drop table if exists #data, #stock

		SELECT 
		  c.CodAlmacen WarehouseCode,
		  c.NomAlmacen WarehouseName,
		  b.CodPrv SupplierCode,
		  b.NomPrv SupplierName,
		  b.u_login SupplierLogin,
		  d.CodPro ProductCode, 
		  d.NomPro ProductName,
		  e.CodCat CategoryCode,
		  e.NomCat CategoryName,
		  'Pza' as Piece,
		  a.Valorizado ValuatedStock,
		  d.QtdPiezas*Cantidad Stock
	into #data
	FROM [ROMA_DATAMART].[Ventas].[Fact_Inventarios] a
	inner join [ROMA_DATAMART].Ventas.dimproveedores b on a.IdProveedor = b.IdPrv
	inner join [ROMA_DATAMART].Ventas.DimAlmacenes c on a.IdAlmacen = c.IdAlmacen
	inner join [ROMA_DATAMART].Ventas.DimProductos d on a.IdProducto = d.IdPro
	inner join [ROMA_DATAMART].Ventas.DimCategorias e on d.IdCat_xPrv = e.IdCat_xPrv
	where b.IdPrv <> 16 and a.FechaKey = @fechakey

	update #data set SupplierLogin = 'u_amaras' where CategoryCode = 196 

	select * into #stock from #data pivot(sum(stock) for WarehouseCode in ([05AYPR1],[11CHPR1],[11ICPR1])) as pivotee




	delete from Reports.DetailReportStock

	

	insert into Reports.DetailReportStock
	select 
		SupplierCode,
		SupplierName, 
		SupplierLogin,
		ProductCode, 
		ProductName,
		Piece, 
		SUM(ValuatedStock) as ValuatedStock,
		SUM(ISNULL([05AYPR1],0)) as Ayacucho, 
		SUM(ISNULL([11CHPR1],0)) as Chincha,
		SUM(ISNULL([11ICPR1],0)) as Ica, 
		SUM(ISNULL([05AYPR1],0)+ISNULL([11CHPR1],0)+ISNULL([11ICPR1],0)) as total
	from #stock
	group by 
		SupplierCode,
		SupplierName, 
		SupplierLogin,
		ProductCode, 
		ProductName,
		Piece
	

end

GO

