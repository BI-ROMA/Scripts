




CREATE view [Reports].[vw_SalaryScale]

as

	select 
		b.NomMesa TeamName, 
		(case b.grupo when 'OTRO' then '---' else b.grupo end) GroupTeamName,
		c.TipoUser Typeuser,
		a.escala SalaryScale, 
		a.remfija FixedCompensation,
		(a.escala - a.remfija) SalaryCommissionable,
		a.excedenteporc MaximumPercentage, 
		factor_xvta SaleFactor, 
		factor_xcob CoverageFactor, 
		factor_xdev DevolutionFactor,
		((a.escala - a.remfija)*factor_xvta) SaleCommissionable,
		((a.escala - a.remfija)*factor_xcob) CoverageCommissionable
	from ROMA_DATAMART.Ventas.DimComision a
	inner join ROMA_DATAMART.Ventas.DimMesas b on a.idmesa = b.IdMesa
	inner join ROMA_DATAMART.Ventas.DimTiposUsuarios c on a.idtipouser = c.idtipouser

GO

