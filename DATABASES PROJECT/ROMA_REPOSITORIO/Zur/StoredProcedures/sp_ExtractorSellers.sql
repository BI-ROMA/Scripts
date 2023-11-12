CREATE procedure [Zur].[sp_ExtractorSellers]
AS
BEGIN

	drop table if exists #extractorsellers
	
	select DISTINCT
		'PM00000071' SupplierCode,
		case c.IdAlmacen when 4 then '20537004381.ICA' when 3 then '20537004381.CHINCHA' when 1 then '20537004381.AYACUCHO' end CompanyCode,
		b.CodVen SellerCode,
		b.NomVen SellerName,
		'DNI' DocumentType,
		b.documento DocumentNumber, 
		d.NomCan ChannelName,
		b.FeIngreso DateIncome,
		b.FeIngreso DateUpdate,
		convert(date,getdate()) ProcessDate,
		0 Exclusive,
		b.CodSup SupervisorCode,
		e.NomSup SupervisorName,
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
	into #ExtractorSellers	
	from ROMA_DATAMART.ventas.Fact_Ventas a
	inner join ROMA_DATAMART.Ventas.DimVendedores b on a.IdVendedor = b.IdVen
	inner join ROMA_DATAMART.Ventas.DimSedes c on a.IdSede = c.IdSede
	inner join ROMA_DATAMART.Ventas.DimCanales d on b.CodCan = d.CodCan
	inner join ROMA_DATAMART.Ventas.Dim_vw_Supervisores e on b.CodSup = e.CodSup collate SQL_Latin1_General_CP1_CI_AS
	where a.FechaKey >= convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0),112) and IdProveedor = 19

	delete from Zur.ExtractorSellers


	insert into Zur.ExtractorSellers
	select * from #ExtractorSellers
	

END

GO

