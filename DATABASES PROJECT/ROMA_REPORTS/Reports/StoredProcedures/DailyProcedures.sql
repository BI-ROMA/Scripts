
CREATE procedure [Reports].[DailyProcedures] @Period char(6), @datekey char(8)
as

begin
	
	--declare @Period char(6) = 202311, @datekey char(8) = 20231111


	--commissions
	exec [Reports].[sp_CommissionsMultibrandReport] @Period;
	exec [Reports].[sp_CommissionsDeprodecaReport] @Period;
	exec [Reports].[sp_CommissionsSupervisorReport] @Period;
	exec [Reports].[sp_CommissionsManagerReport] @Period;
	exec [Reports].[sp_CommissionsExecutiveReport] @Period;
	exec [Reports].[sp_CommissionsConsolidatedReport] @Period;


	--focus
	exec [Reports].[sp_DeprodecaFocusSeller] @period
	exec [Reports].[sp_DeprodecaFocusSupervisor] @period
	exec [Reports].[sp_DeprodecaFocusManager] @period


	--sales&stock
	exec Reports.sp_DetailReportSale @period;
	exec Reports.sp_DetailReportStock @datekey;

	--deprodeca
	exec [Reports].[sp_DeprodecaVisiCoolerComercial] @period;
	exec [Reports].[sp_DeprodecaDetailStock] @datekey;
	exec [Reports].[sp_DeprodecaDetailCoverage] @period;


end

GO

