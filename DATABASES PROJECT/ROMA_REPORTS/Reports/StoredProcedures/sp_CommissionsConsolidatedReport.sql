
CREATE procedure [Reports].[sp_CommissionsConsolidatedReport] @Period char(6)
as
begin
	
	--declare @Period varchar(6) = 202309


	delete from Reports.CommissionsConsolidatedReport where period = @Period


	--Sellers
	insert into Reports.CommissionsConsolidatedReport
	select
		Period, 'Vendedor', SellerCode, SellerName, TerritoryCode, TerritoryName, TeamCode, TeamName, ChannelCode, ChannelName, 
		sum(SalePreviousMonth) VtaMesAnt,
		sum(Goal) Cuota, 
		sum(Sale) Vta, 
		(sum(Sale)/sum(Goal))PrcVta,
		MAX(Salary) Sueldo
	from Reports.CommissionsMultibrandReport
	where Period = @Period and PortfolioCode not in ('HCH05', 'HIC07', 'HAY07')
	group by Period, SellerCode, SellerName, TerritoryCode, TerritoryName, TeamCode, TeamName, ChannelCode, ChannelName
	

	insert into Reports.CommissionsConsolidatedReport
	select 
		Periodo, 'Vendedor', CodVen, NomVen, CodSede, NomSede, CodMesa, grupo Mesa, CodCan, NomCan, 
		sum(vtamesant) VtaMesAnt,
		sum(cuota) Cuota, 
		sum(vta) Vta, 
		(sum(vta)/sum(cuota))PrcVta, 
		MAX(Sueldo) Sueldo
	from Reports.CommissionsDeprodecaReport
	where periodo = @Period
	group by Periodo, CodVen, NomVen, CodSede, NomSede, CodMesa, grupo, CodCan, NomCan



	--Supervisor
	insert into Reports.CommissionsConsolidatedReport(Period, TypeUser, UserCode, UserName, TerritoryCode, TerritoryName, SalePreviousMonth, Goal, Sale, SalePercentage, Salary )
	select
		Period, 'Supervisor', SupervisorCode, SupervisorName, TerritoryCode, TerritoryName,
		sum(SalePreviousMonth) VtaMesAnt,
		sum(Goal) Cuota, 
		sum(Sale) Vta, 
		(sum(Sale)/sum(Goal))PrcVta,
		MAX(Salary) Sueldo
	from Reports.CommissionsSupervisorReport
	WHERE Period = @Period
	group by Period, SupervisorCode,  SupervisorName, TerritoryCode, TerritoryName



	--SalesManager
	insert into Reports.CommissionsConsolidatedReport(Period, TypeUser, UserCode, UserName, TerritoryCode, TerritoryName, SalePreviousMonth, Goal, Sale, SalePercentage, Salary )
	select
		Period, 'Jefe de Venta', ManagerCode, ManagerName, TerritoryCode, TerritoryName,
		sum(SalePreviousMonth) VtaMesAnt,
		sum(Goal) Cuota, 
		sum(Sale) Vta, 
		(sum(Sale)/sum(Goal))PrcVta,
		MAX(Salary) Sueldo
	from Reports.CommissionsManagerReport
	WHERE Period = @Period
	group by Period, ManagerCode,  ManagerName, TerritoryCode, TerritoryName



	--SalesExecutive
	insert into Reports.CommissionsConsolidatedReport(Period, TypeUser, UserCode, UserName, SalePreviousMonth, Goal, Sale, SalePercentage, Salary )
	select
		Period, 'Jefe Comercial', ExecutiveCode, ExecutiveName,
		sum(SalePreviousMonth) VtaMesAnt,
		sum(Goal) Cuota, 
		sum(Sale) Vta, 
		(sum(Sale)/sum(Goal))PrcVta,
		MAX(Salary) Sueldo
	from Reports.CommissionsExecutiveReport
	WHERE Period = @Period and ExecutiveCode = '0001'
	group by Period, ExecutiveCode,  ExecutiveName


	insert into Reports.CommissionsConsolidatedReport(Period, TypeUser, UserCode, UserName, SalePreviousMonth, Goal, Sale, SalePercentage, Salary )
	select
		Period, 'Ejecutivo Comercial', ExecutiveCode, ExecutiveName, 
		sum(SalePreviousMonth) VtaMesAnt,
		sum(Goal) Cuota, 
		sum(Sale) Vta, 
		(sum(Sale)/sum(Goal))PrcVta,
		MAX(Salary) Sueldo
	from Reports.CommissionsExecutiveReport
	WHERE Period = @Period and ExecutiveCode <> '0001'
	group by Period, ExecutiveCode, ExecutiveName

end

GO

