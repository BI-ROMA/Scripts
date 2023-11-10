
CREATE procedure [Reports].[GenerateJSONCommission] 

as
begin
	
	declare @period varchar(6) = CONVERT(char(6), GETDATE()-1,112)
	drop table if exists #JSONCommissionsDeprodeca, #JSONCommissionsMultimarca
	
	delete from Reports.JSONCommissions where period = @period


	;with dt as 
	(
		select distinct
			a.periodo Period, b.U_Login Username, a.CodVen SellerCode, a.NomVen SellerName, 
			a.CodSup SupervisorCode, a.NomSup SupervisorName, a.CodJV ManagerCode, 
			a.NomJV ManagerName, a.CodSede TerritoryCode, a.NomSede TerritoyName, 
			a.CodMesa TeamCode, a.NomMesa TeamName, a.CodCan ChannelCode, a.NomCan ChannelName, 
			a.escala Escale, a.BaseVtaCom SaleBaseCommission, a.BaseCobCom CoverageBaseCommission, a.Sueldo Salary
		from  Reports.CommissionsDeprodecaReport a
		inner join roma_Datamart.ventas.DimVendedores b on a.CodCartera = b.CodCar and b.Estado = 'A'
		where periodo = @period
	)
	select * into #JSONCommissionsDeprodeca from dt 

	insert into Reports.JSONCommissions
	select  
		df.Period, 
		df.Username, 
		df.SellerCode,
		'VE' TypeUser,
		(
			select * from #JSONCommissionsDeprodeca dr
			where dr.Username = df.Username
			for json path, without_array_wrapper
		) data_json
	from #JSONCommissionsDeprodeca df



	;with dt as 
	(
		select distinct
			a.Period , b.U_Login Username, a.SellerCode, a.SellerName, 
			a.SupervisorCode, a.SupervisorName, a.ManagerCode, 
			a.ManagerName, a.TerritoryCode, a.TerritoryName, 
			a.TeamCode, a.TeamName, a.ChannelCode, a.ChannelName, 
			a.Scale, a.CommissionSaleBase, a.CommissionCobBase, a.Salary
		from  Reports.CommissionsMultibrandReport a
		inner join roma_Datamart.ventas.DimVendedores b on a.PortfolioCode = b.CodCar and b.Estado = 'A'
		where Period = @period
	)
	select * into #JSONCommissionsMultimarca from dt 

	delete from Reports.JSONCommissions where @period = @period
	--select * from Reports.JSONCommissions


	insert into Reports.JSONCommissions
	select  
		df.Period, 
		df.Username, 
		df.SellerCode,
		'VE' TypeUser,
		(
			select * from #JSONCommissionsMultimarca dr
			where dr.Username = df.Username
			for json path, without_array_wrapper
		) data_json
	from #JSONCommissionsMultimarca df
end

GO

