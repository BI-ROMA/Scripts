CREATE procedure [Reports].[sp_DeprodecaDetailStock] @datekey varchar(8)

as 
begin
	
	--declare @datekey varchar(8) = 20231102

	drop table if exists #data, #stock

	SELECT 
		a.fechakey,
		c.CodAlmacen, 
		d.CodPro, 
		d.NomPro, 
		a.Cantidad_xPiezas stock
	into #data
	FROM [ROMA_DATAMART].[Ventas].[Fact_Inventarios] a
	inner join [ROMA_DATAMART].Ventas.dimproveedores b on a.IdProveedor = b.IdPrv
	inner join [ROMA_DATAMART].Ventas.DimAlmacenes c on a.IdAlmacen = c.IdAlmacen
	inner join [ROMA_DATAMART].Ventas.DimProductos d on a.IdProducto = d.IdPro
	where IdProveedor = 16 and FechaKey = @datekey

	select * into #stock from #data pivot(sum(stock) for codalmacen in ([05AYPR1],[11CHPR1],[11ICPR1])) as pivotee


	delete from Reports.DeprodecaDetailStock


	insert into Reports.DeprodecaDetailStock
	select 
		FechaKey DateKey,
		CodPro ProductCode,
		NomPro ProductName,
		'Pza' Piece,
		ISNULL([05AYPR1],0) as Ayacucho, 
		ISNULL([11CHPR1],0) as Chincha,
		ISNULL([11ICPR1],0) as Ica, 
		ISNULL([05AYPR1],0)+ISNULL([11CHPR1],0)+ISNULL([11ICPR1],0) as Total
	from  #stock 


end

GO

