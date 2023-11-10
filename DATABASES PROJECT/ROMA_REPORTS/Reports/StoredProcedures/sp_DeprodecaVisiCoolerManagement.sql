

CREATE Procedure [Reports].[sp_DeprodecaVisiCoolerManagement]
@Period Char(6)
As
Begin

	-- Declare @Period Char(6) = 202310

	
	drop table if exists #visicoolers

	select * 
	into #visicoolers
	from [Reports].[DeprodecaVisiCoolerComercial] where period = @Period
	
	
	drop Table If Exists #Range

	Create Table #Range(Label Varchar(100), vMin Smallint, vMax Smallint)
	Insert Into #Range Values('0%', 0, 1)
	Insert Into #Range Values('1% - 50%', 1, 50)
	Insert Into #Range Values('50% - 70%', 50, 70)
	Insert Into #Range Values('70% - 85%', 70, 85)
	Insert Into #Range Values('85% - 95%', 85, 95)
	Insert Into #Range Values('95% - +', 95, 10000)


	--SELECT * FROM #visicoolers
	;with dt as (
		select TerritoryCode, SellerName, Goal, Serie, CustomerName, CustomerCode, CustomerAddressCode, 
		sum(ISNULL(Sale,0)) as Sale, Convert(Decimal(18, 0), 100*sum(ISNULL(Sale,0))/Goal) Value
		from #visicoolers a
		group by TerritoryCode, SellerName, Goal, serie, CustomerName, CustomerCode, CustomerAddressCode
	) 
	select *, 
	Count(serie) Over(Partition by SellerName, Goal) QtdCustomer,
	Count(serie) Over(Partition by Goal, TerritoryCode) QtdCustomer_xTerritory,
	Count(serie) Over(Partition by Goal) QtdCustomer_xGoal,

	Count(serie) Over(Partition by SellerName) QtdCustomerTot_xSeller,
	Count(serie) Over(Partition by TerritoryCode) QtdCustomerTot_xTerritory,
	Count(serie) Over() QtdCustomerTot,

	Count(serie) Over(Partition by SellerName, Label) QtdCustomerTot_xLabel
	from dt a
	inner join #Range b on a.Value >= b.vMin And a.Value < b.vMax
	

End

GO

