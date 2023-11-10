
CREATE procedure [Reports].[sp_DetailReportSale] @Period varchar(6)
as
begin
	

	--declare @period varchar(6) =202310

	drop table if exists #data

	select convert(varchar,a.FechaKey) AS DateKey,
		   f.ProductCode,
		   f.ProductName,
		   f.CategoryCode,
		   f.CategoryName,
		   f.SupplierCode,
		   f.SupplierName,
		   F.SupplierLogin,
		   b.CodCli PartnerCode,
		   b.NomCli PartnerName,
		   c.CodVen SellerCode,
		   c.NomVen SellerName,
		   d.CodSede TerritoryCode,
		   d.NomSede TerritoryName,
		   e.Serie InvoiceSequence,
		   e.Numero InvoiceNumber,
		   e.TiDocumento InvoiceType,
		   case a.DiscPrcnt
			   when 100.00000 then 'SI'
			   else 'NO'
		   end Bonus,
		   a.Cantidad Quantity,
		   a.Total/a.Cantidad Price,
		   a.TotalIGV Sale 
	into #data
	from ROMA_DATAMART.Planillas.Fact_Ventas a
	inner join ROMA_DATAMART.ventas.DimClientes b on b.IdCli = a.IdCliente
	inner join ROMA_DATAMART.ventas.DimVendedores c on c.IdVen = a.IdVendedor
	inner join ROMA_DATAMART.ventas.DimSedes d on d.IdSede = a.IdSede
	inner join ROMA_DATAMART.ventas.DimDocumentos e on e.IdDoc = a.IdDocumento
	inner join Reports.vw_SupplierCategoryProduct f on a.IdProducto = f.productid
	where left(a.FechaKey, 6) = @period and a.IdProveedor <> 16

	--select * from #data where suppliercode = 'PM00000083'

	------------------------------------------------------------------------------------------------------------
	--Separar amaras de Alicorp
	------------------------------------------------------------------------------------------------------------
	update #data set SupplierLogin = 'u_amaras' where CategoryCode = 196

	
	
	delete from Reports.DetailReportSale where left(datekey, 6) = @period
	
	
	insert into Reports.DetailReportSale
	select * from #data
	

end

GO

