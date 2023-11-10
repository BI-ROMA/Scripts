

CREATE View [Gloria].[vw_DimVendedor]
As

	WITH dt AS
		  (SELECT DISTINCT cvendedor
		   FROM gloria.Extractor_Ventas)
	SELECT Convert(Varchar(5), a.CodVen) CodVen,
		   NomVen,
		   a.CodCar
	FROM ventas.DimVendedores a
	INNER JOIN dt b ON a.CodVen = b.cvendedor

GO

