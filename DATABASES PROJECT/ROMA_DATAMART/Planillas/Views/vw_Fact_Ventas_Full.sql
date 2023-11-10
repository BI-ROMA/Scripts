



















CREATE View [Planillas].[vw_Fact_Ventas_Full]
As
Select a.*,  ISNULL(FactorUME, 1) * Cantidad AS UME, IdAlmacen, 
'i'+Right('000000000'+Ltrim(Str(IdDocumento)), 9)+ Right('00000000'+Ltrim(Str(IdProducto)), 8) Prod_xDoc
-- Select Distinct PartitionMonth
From Planillas.Fact_Ventas a
Inner Join Ventas.DimSedes b On a.IdSede = b.IdSede 
Where PartitionMonth>= 202001
--Order By 1

GO

