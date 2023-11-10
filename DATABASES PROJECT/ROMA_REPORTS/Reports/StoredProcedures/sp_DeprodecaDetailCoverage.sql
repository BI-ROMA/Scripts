
CREATE procedure [Reports].[sp_DeprodecaDetailCoverage] @period varchar(6)
as
begin

	--declare @Period varchar(6) = 202310
	
	delete from Reports.DeprodecaDetailCoverage where period = @Period

	;with dt as (
		SELECT  
			a.CardCode,
			a.Sucursal, 
			b.Categoria, 
			b.Marca, 
			b.Familia, 
			b.Contenido, 
			b.ItemName,
			(sum(Case When ObjType = 14 Then -1 Else 1 End)*LineTotal) as TotalSinIGV
		FROM ROMA_DATAMART.Gloria.Extractor_Ventas a
		inner join ROMA_DATAMART.Gloria.vw_ItemsxLineaxOrden b on a.ItemCode = b.ItemCode collate SQL_Latin1_General_CP850_CI_AS
		where convert(varchar(6), TaxDate, 112) = @Period
		group by a.CardCode, a.Sucursal, b.Categoria, b.Marca, b.Familia, b.Contenido, b.ItemName,LineTotal
		having (sum(Case When ObjType = 14 Then -1 Else 1 End)*LineTotal)>0
		)
		insert into Reports.DeprodecaDetailCoverage
		select  
			@Period Period, 
			isnull(Sucursal, 'SUBTOTAL') AS BranchName,
			isnull(Categoria, 'SUBTOTAL') AS CategoryName, 
			isnull(Marca, 'SUBTOTAL') AS BrandName,	
			isnull(Familia, 'SUBTOTAL') AS FamilyName,
			isnull(Contenido, 'SUBTOTAL') AS ContentName,
			isnull(ItemName, 'SUBTOTAL') AS ProductoName,
			count(distinct cardcode) as coverage 
		from dt
		group by Sucursal, Categoria, Marca, Familia, Contenido, ItemName
		with rollup
		ORDER BY 1,2,3,4,5,6

end

GO

