CREATE procedure Zur.sp_ExtractorCustomers
AS
BEGIN

	drop table if exists #Extractorcustomers

	select DISTINCT
		b.CodPrv SupplierCode,
		case c.IdAlmacen when 4 then '20537004381.ICA' when 3 then '20537004381.CHINCHA' when 1 then '20537004381.AYACUCHO' end CompanyCode,
		d.CodCli CustomerCode,
		d.NomCli CustomerName,
		case d.TipDoc when 'RUC' then 'RUC' else 'DNI' end DocumentType,
		d.NumDoc DocumentName,
		d.Direccion CustomerAddress,
		'' Market,
		'' Module,
		e.NomCan ChannelName,
		d.TiNegocio BussinessType,
		'' BussinessSubType,
		'' Ubigeo,
		'' Distrit,
		'A' Status,
		'' X,
		'' Y,
		'' ParentCustomer,
		convert(date, FeRegistro) IncomeDate,
		convert(date, FeRegistro) UpdateDate,
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
	into #ExtractorCustomers
	from ROMA_DATAMART.Planillas.Fact_Ventas a
	inner join ROMA_DATAMART.Ventas.DimProveedores b on a.IdProveedor = b.IdPrv
	inner join ROMA_DATAMART.Ventas.DimSedes c on a.IdSede = c.IdSede
	inner join ROMA_DATAMART.Ventas.DimClientes d on a.IdCliente = d.IdCli
	inner join ROMA_DATAMART.Ventas.DimCanales e on a.IdCanal = e.IdCan
	where a.FechaKey >= convert(varchar, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0),112) and IdProveedor = 19


	delete from Zur.ExtractorCustomers

	insert into Zur.ExtractorCustomers
	select * from #ExtractorCustomers




END

GO

