CREATE procedure Zur.sp_ExtractorProducts

AS

BEGIN
	
	drop table if exists #items, #ExtractorProducts

	;with dt as (
		select SupplierCode, CompanyCode, ProductCode from ZUR.ExtractorSales
		union 
		select SupplierCode, CompanyCode, ProductCode from ZUR.Extractorstock
	)select * into #items from dt ORDER BY 2
	

	select 
		a.*,
		b.NomPro ProductName,
		'' EAN,
		'' DUN,
		b.QtdPiezas BoxFactor,
		CONVERT(decimal(18,4), 0) Weight,
		'P' FlagBonus,
		'1' Tax,
		b.Precio_dCompra BuyPrice,
		b.Precio_dVenta SalePrice,
		(b.Precio_dCompra + b.Precio_dVenta)/2 AveragePrice,
		getdate() ProcessDate,
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
	into #ExtractorProducts
	from #items a
	inner join ROMA_DATAMART.Ventas.DimProductos b on a.ProductCode = b.CodPro


	
	delete from Zur.ExtractorProducts


	insert into Zur.ExtractorProducts
	select * from #ExtractorProducts

END

GO

