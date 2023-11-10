

CREATE procedure [Ventas].[SP_Fact_Cuota_Diaria] 

as 

begin



	declare @periodo varchar(6) = convert(varchar(6), getdate()-1, 112)


	drop table if exists #ventas, #cuotas, #tmp



	select 
		left(a.FechaKey,6) periodo, IdSede, IdVendedor, IdCartera, IdSupervisor, IdCanal, CodCat, idmesa, IdProveedor, sum(TotalIGV) TotalIGV, convert(decimal(18,4), 0) FactorSoles
	into #ventas
	from Planillas.Fact_Ventas a
	inner join ventas.DimCategorias b on a.IdCat_xPrv = b.IdCat_xPrv
	where left(a.FechaKey,6) = @periodo
	group by left(a.FechaKey,6), IdSede, IdVendedor, IdCartera, IdSupervisor, IdCanal, CodCat, idmesa, IdProveedor
	having SUM(TotalIGV) > 0



	select
		left(a.FechaKey,6) periodo, IdSede, IdVen, IdCar, IdSupervisor, IdCanal, CodCat, idmesa, a.IdPrv, sum(Cuota) Cuota, convert(decimal(18,4), 0) FactorSoles
	into #cuotas
	from Ventas.Fact_Cuotas a
	inner join ventas.DimCategorias b on a.IdCat_xPrv = b.IdCat_xPrv
	where left(a.FechaKey,6) = @periodo
	group by left(a.FechaKey,6), IdSede, IdVen, IdCar, IdSupervisor, IdCanal, CodCat, idmesa, a.IdPrv


	;with dt as (
			select a.*, b.TotalIGV
			from #cuotas a
			left join #ventas b on a.periodo = b.periodo and a.IdSede = b.IdSede and a.IdVen = b.IdVendedor and a.IdCanal = b.IdCanal and a.CodCat = b.CodCat and a.IdCar = b.IdCartera
		) 
	select 
		dt.periodo, dt.IdSede, dt.IdVen, dt.IdCar, dt.IdSupervisor, dt.IdCanal, dt.CodCat, dt.IdMesa, dt.IdPrv, dt.Cuota, dt.FactorSoles, 
		isnull(dt.TotalIGV,0) TotalIGV, convert(varchar, getdate(), 112) fechakey, 
		case 
			when (dt.Cuota - isnull(dt.TotalIGV,0))/nullif(DiasFaltantes,0) < 0 then 0 
			else (dt.Cuota - isnull(dt.TotalIGV,0))/nullif(DiasFaltantes,0)
		end Cuotadiaria
	into #tmp
	from dt
	right join Ventas.Dim_vw_FactorProyectado df on dt.periodo = left(FechaKey,6)

	--select * from #tmp
	--update #tmp set FactorSoles  = 0.1111
	--select * from Ventas.Dim_vw_FactorProyectado


	--update #tmp set IdSede = 10 where IdVen in (42,414,489)
	--update #tmp set IdSede = 9 where IdVen in (31,32,423)

	Update #tmp Set IdSede = 1 Where IdVen In (36)
	Update #tmp Set IdSede = 10 Where IdVen In (451, 415)
	Update #tmp Set IdSede = 9 Where IdVen In (31, 499, 523)


	--select * from Ventas.DimVendedores where codven = 2354
	--select * from Ventas.Dimsedes
		-- (42,414,489) -- AP
	-- (15,31,32,423) -- AV

	--select * from #tmp
	--select * from #cuotas
	--select * from #ventas

	delete from ventas.Fact_CuotaDiaria where fechakey = convert(varchar, getdate(), 112)

	insert into	ventas.Fact_CuotaDiaria
	select * from #tmp

	/*
	drop table ventas.Fact_CuotaDiaria
	select * 
	into ventas.Fact_CuotaDiaria
	from #tmp
	*/


end

GO

