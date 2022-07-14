
select * from temp.factor_dcob where periodo = 202207
select * from temp.factor_dcob where periodo = 202206

insert into temp.factor_dcob
	(Periodo, Categoria, Proveedor,	CatJes,	CodCat,	FactorCob, Origen, CodPrv, NomCat)
	select 
		'202207', Categoria, Proveedor, CatJes,	CodCat,	FactorCob, Origen, CodPrv, NomCat
	from temp.factor_dcob
	where Periodo = 202206
