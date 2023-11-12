CREATE procedure [Zur].[sp_ExtractorSales]

as begin

	drop table if exists #ExtractorSales

	select 
		b.CodPrv SupplierCode,
		case i.IdAlmacen when 4 then '20537004381.ICA' when 3 then '20537004381.CHINCHA' when 1 then '20537004381.AYACUCHO' end CompanyCode,
		c.TiDocumento DocumentType,
		CONCAT(c.Serie,c.Numero) DocumentNumber,
		d.Fecha DocumentDate,
		case c.TiDocumento when 'NC' then 'Rechazo' else '' end ReasonCreditNote,
		'App - Te vendo' Origin,
		concat(e.CodCli, e.CodDom) CustomerCode,
		f.NomCan CustomerChannelName,
		e.TiNegocio BussinesType,
		g.CodVen SellerCode,
		f.NomCan SellerChannelName,
		g.CodCar Route,
		a.Item ItemNumber,
		h.CodPro ProductCode,
		convert(decimal(18,4), a.Cantidad) MinUnitQuantity,	   
		'PZA' MinUnitType,
		convert(decimal(18,4), a.Cantidad/h.QtdPiezas) MaxUnitQuantity,
		h.CoUnidadMedidaCompra MaxUnitType,
		'PEN' Currency,
		convert(decimal(18,4), a.Total) SaleWithoutTax,
		convert(decimal(18,4), a.TotalIGV) SaleWithTax,
		convert(decimal(18,4), a.DiscPrcnt) Discount,
		case DiscPrcnt when 100 then 'B' else 'P' end SaleType,
		'' ComboCode,
		'' PromotionCode,
		c.TiDocumento ReferenceDocumentType,
		CONCAT(c.Serie,c.Numero) ReferenceDocumentNumber,
		d.Fecha ReferenceDocumentDate,
		getdate() ProccessDate,
		'' ref1,
		'' ref2,
		'' ref3,
		'' ref4,
		'' ref5,
		'' ref6,
		'' ref7,
		'' ref8,
		'' ref9,
		'' ref10,
		convert(varchar(6), d.Fecha, 112) Period
	into #ExtractorSales
	from ROMA_DATAMART.ventas.Fact_Ventas a
	inner join ROMA_DATAMART.Ventas.DimProveedores b on a.IdProveedor = b.IdPrv
	inner join ROMA_DATAMART.Ventas.DimDocumentos c on a.IdDocumento = c.IdDoc
	inner join ROMA_DATAMART.Ventas.DimFechas d on a.FechaKey = d.FechaKey
	inner join ROMA_DATAMART.Ventas.DimClientes e on a.IdCliente = e.IdCli
	inner join ROMA_DATAMART.Ventas.DimCanales f on a.IdCanal = f.IdCan
	inner join ROMA_DATAMART.Ventas.DimVendedores g on a.IdVendedor = g.IdVen
	inner join ROMA_DATAMART.Ventas.DimProductos h on a.IdProducto = h.IdPro
	inner join ROMA_DATAMART.Ventas.DimSedes i on a.IdSede = i.IdSede
	where a.FechaKey >= convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0),112) and IdProveedor = 19


	delete from Zur.ExtractorSales

	--select * into Zur.ExtractorSales from #ExtractorSales

	insert into Zur.ExtractorSales
	select * from #ExtractorSales
	--select sum(salewithtax) from #ExtractorSales where period = '202309'

end

GO

