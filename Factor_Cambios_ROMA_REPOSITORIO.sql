
	If Exists(Select * From Temp.Cambio_dFactores Where Tipo = 'FactorCob')
	Begin		
		Update a Set a.FactorCobertura = b.[Factor Cobertura]
		--select *
		From SrvSAP.Roma_Productiva.Reportes.Mov_Cuotas a
		Inner Join Temp.Cambio_dFactores b 
		On b.Tipo='FactorCob' 
		And a.codven = b.[Cod Ven] 
		And a.CodSedenew Collate SQL_Latin1_General_CP1_CI_AS = b.Sede_Cub
		And a.codgrupo Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Cat] 
		And a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Mesa] 
		And a.grupovnd Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Canal] 
		And a.codprv Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Prv]	
		And a.codcar Collate SQL_Latin1_General_CP1_CI_AS = b.CodCartera
		Where a.Periodo = 202207 And a.FactorCobertura != b.[Factor Cobertura]
	End
	--select * from Temp.Cambio_dFactores
	--update Temp.Cambio_dFactores set tipo = 'FactorCob' 
	If Exists(Select * From Temp.Cambio_dFactores Where Tipo = 'FactorVta')
	Begin		
		Update a Set a.FactorVenta = b.[Factor Venta], a.cuota = a.Cuota_dVtaTot * b.[Factor Venta]
		-- Select *
		From SrvSAP.Roma_Productiva.Reportes.Mov_Cuotas a
		Inner Join Temp.Cambio_dFactores b 
		On b.Tipo='FactorVta' 
		And a.codven = b.[Cod Ven] 
		And a.CodSedeNew Collate SQL_Latin1_General_CP1_CI_AS = b.Sede_Cub
		And a.codgrupo Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Cat] 
		And a.codmesa Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Mesa] 
		And a.grupovnd Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Canal] 
		And a.codprv Collate SQL_Latin1_General_CP1_CI_AS = b.[Cod Prv]		
		Where a.Periodo = 202207 And a.FactorVenta != b.[Factor Venta]
	End
