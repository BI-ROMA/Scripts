
CREATE procedure [Reports].[GenerateJSONDailyCommission] 

as
begin
	

	declare @fechakey varchar(8) = CONVERT(char(8), GETDATE(), 112)
	

	drop table if exists #fact_cuotadiaria, #datacomisionDeprodeca, #datacomisionMultimarca

	select 
		fechakey, b.CodVen, b.NomVen, b.CodCar, b.CodMesa, b.CodSede,
		a.CodCat, d.CodPrv, c.NomCat, a.TotalIGV, a.Cuotadiaria
	into #fact_cuotadiaria
	from ROMA_DATAMART.Ventas.Fact_CuotaDiaria  a
	inner join ROMA_DATAMART.Ventas.DimVendedores b on a.IdVen = b.IdVen
	inner join ROMA_DATAMART.Ventas.DimCategorias c on a.CodCat = c.CodCat and c.IdPrv = a.IdPrv
	inner join ROMA_DATAMART.Ventas.DimProveedores d on a.IdPrv = d.IdPrv
	where FechaKey = @fechakey



	;with dt as 
	(
		select distinct
			a.periodo , b.U_Login, a.CodVen, a.NomVen, 
			a.CodSup, a.NomSup, a.CodJV, a.CodCartera,
			a.NomJV, a.CodSede, a.NomSede,
			a.CodMesa, a.NomMesa , a.CodCan , a.NomCan 
		from  Reports.CommissionsDeprodecaReport a
		inner join roma_Datamart.ventas.DimVendedores b on a.CodCartera = b.CodCar and b.Estado = 'A'
		where periodo = left(@fechakey,6)
	)
	select a.*, b.NomSede, b.CodSup, b.NomSup, b.CodJV, b.NomJV, b.periodo, b.U_Login, b.NomMesa
	into #datacomisionDeprodeca
	from #fact_cuotadiaria a
	inner join dt b on a.CodVen = b.CodVen and a.CodCar = b.CodCartera and a.CodPrv = 'PM00000066'



	;with dt as 
	(
		select distinct
			a.Period , b.U_Login, a.SellerCode, a.SellerName, 
			a.SupervisorCode, a.SupervisorName, a.ManagerCode, a.PortfolioCode,
			a.ManagerName, a.TerritoryCode, a.TerritoryName,
			a.TeamCode, a.TeamName , a.ChannelCode , a.ChannelName 
		from  Reports.CommissionsMultibrandReport a
		inner join roma_Datamart.ventas.DimVendedores b on a.TeamCode = b.CodCar and b.Estado = 'A'
		where Period = left(@fechakey,6)
	)
	select a.*, b.TerritoryName, b.SupervisorCode, b.SupervisorName, b.ManagerCode, b.ManagerName, b.Period, b.U_Login, b.TeamName
	into #datacomisionMultimarca
	from #fact_cuotadiaria a
	inner join dt b on a.CodVen = b.SellerCode and a.CodCar = b.PortfolioCode and a.CodPrv <> 'PM00000066'


	--select * from Reports.ReporteComisiones_Deprodeca
	--select * from Reports.ReporteComisiones_Multimarca
	--select * from #fact_cuotadiaria

	
	delete from Reports.JSONDailyCommissions where date = @fechakey

	;with dt as (
		select * from #datacomisionDeprodeca
		union all
		select * from #datacomisionMultimarca
	) 
	insert into Reports.JSONDailyCommissions
	select distinct
		a.fechakey Date, 
		a.u_login UserName,
		a.CodVen SellerCode,
		'VE' TypeUser,
		(
			select distinct
				b.fechakey date,
				b.CodVen SellerCode,
				b.NomVen SellerName,
				b.CodMesa TeamCode,
				b.NomMesa TeamName,
				b.CodSede TerritoryCode,
				b.NomSede TerritoryName,
				b.CodSup SupervisorCode,
				b.NomSup SupervisorName,
				b.CodJV ManagerCode,
				b.NomJV ManagerName,
				b.U_Login username,
				(
					select distinct
						c.CodPrv SupplierCode,
						(
							select distinct 
								d.CodCat CategoryCode,
								d.NomCat CategoryName,
								d.Cuotadiaria DailyGoal
							from dt d 
							where c.U_Login = d.u_login and c.CodVen = d.CodVen and c.CodPrv = d.CodPrv
							for json path
						) CategoryData
					from dt c
					where b.U_Login = c.U_Login and b.CodVen = c.CodVen
					for json path
				) data
			from dt b
			where a.U_Login = b.U_Login and a.CodVen = b.CodVen 
			for json path, without_array_wrapper
		) data
	--INTO Reports.JSONDailyCommissions
	from dt a 
	order by 1
end

GO

