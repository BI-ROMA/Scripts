CREATE procedure [Reports].[sp_ListCommissionsUsers] @tipo char(2), @tipohijo char(2), @Prv char(1), @Usuario varchar(50), @period char(6) 

as


begin

	--declare @tipo char(2) = 'CB', @tipohijo char(2) = null, @Prv char(1) = null, @Usuario varchar(50) = 'e_cordoba', @period char(6) ='202311'
	drop table if exists #UsuarioVIP, #UsuariosJV, #UsuariosSup, #UsuariosVen, #UsuariosPrv, #Result



	Create Table #UsuarioVIP(grupo varchar(4), code varchar(4), name varchar(100), Usuario Varchar(50))



	Insert Into #UsuarioVIP Values('BI', null, null, 'r_mejia')
	Insert Into #UsuarioVIP Values('GG', null, null, 'e_rodriguez')
	Insert Into #UsuarioVIP Values('GG', null, null, 'j_mansilla')
	Insert Into #UsuarioVIP Values('JC','0001', 'AIBAR TASAYCO, CANDY DEL PILAR', 'c_aybar')
	Insert Into #UsuarioVIP Values('EC','0002', 'CALDERON ALMORA, HECTOR FIDEL', 'h_calderon')
	--Insert Into #UsuarioVIP Values('EC','0003', 'HUMAN QUINTO, MADELEY YEIMMY', 'y_huaman')
	Insert Into #UsuarioVIP Values('EC','0003', 'ANTONIO CARDENAS SOTELO', 'ja_cardenas')
	Insert Into #UsuarioVIP Values('EC','0004', 'UCHUYA ORMEÑO, FANNY ANALI', 'f_uchuya')
	Insert Into #UsuarioVIP Values('EC','0005', 'LUCIANA REATEGUI PACHECO', 'l_reategui')
	Insert Into #UsuarioVIP Values('RH', null, null, 'a_ramirez')
	Insert Into #UsuarioVIP Values('RH', null, null, 'l_castro')
	Insert Into #UsuarioVIP Values('SI', null, null, 'j_pachass')


	Create Table #Result(
		GroupUser char(2),
		CodUser Varchar(20),  
		NameUser Varchar(100),
		LoginUser Varchar(100),
		CodUser2 varchar(4),
		NameUser2 varchar(100),
		LoginUser2 Varchar(100),
		CodUser3 varchar(4),
		NameUser3 varchar(100),
		LoginUser3 Varchar(100),
		Prv varchar(100)
	)

	;with 
		dt as (
		select distinct a.SupplierCode CodUser, a.SupplierName NameUser, b.u_login LoginUser, '' CodUser2, '' NameUser2, '' LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3
		from Reports.CommissionsMultibrandReport a
		inner join ROMA_DATAMART.Ventas.DimProveedores b on a.SupplierCode = b.CodPrv collate SQL_Latin1_General_CP1_CI_AS
		where period = @period
	) select distinct 'PR' GroupUser,*, '' Prv into #UsuariosPrv from dt

	--SELECT * FROM #UsuariosPrv
	insert into #UsuariosPrv 
	select 'PR', 'PM00000083', 'AMARAS','u_amaras', '', '', '', '', '', '', ''
	union all
	select 'PR', 'PM00000102', 'ALIEX S.A.C.','u_aliex', '', '', '', '', '', '', ''

	;with 
		dt as (
		select distinct a.ManagerCode CodUser, a.ManagerName NameUser, b.u_login LoginUser, '' CodUser2, '' NameUser2, '' LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3
		from Reports.CommissionsMultibrandReport a
		inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta b on a.ManagerCode = b.CodJV collate SQL_Latin1_General_CP1_CI_AS
		where period = @period
		union all 
		select distinct a.CodJV CodUser, a.NomJV NameUser, b.u_login LoginUser, '' CodUser2, '' NameUser2, '' LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3
		from Reports.CommissionsDeprodecaReport a
		inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta b on a.CodJV = b.CodJV collate SQL_Latin1_General_CP1_CI_AS
		where periodo = @period
	) select distinct 'JV' GroupUser,*, '' Prv into #UsuariosJV from dt

	/*
	select * from #UsuariosJV
	select * from #UsuarioVIP
	*/
	insert into #UsuarioVIP
	select 'JV' GroupUser, CodUser, NameUser, LoginUser    from #UsuariosJV



	;With 
		dt As (
			select distinct a.SupervisorCode CodUser, a.SupervisorName NameUser, b.u_login LoginUser, ManagerCode CodUser2, ManagerName NameUser2, c.u_login LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3
			from Reports.CommissionsMultibrandReport a
			inner join roma_Datamart.ventas.Dim_vw_Supervisores b on a.SupervisorCode = b.CodSup collate SQL_Latin1_General_CP1_CI_AS
			inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta c on a.ManagerCode = c.CodJV collate SQL_Latin1_General_CP1_CI_AS
			where period = @period
		)
	Select distinct 'SU' GroupUser, *, 'M' Prv Into #UsuariosSup From dt

	;With 
		dt As (
			select distinct a.CodSup CodUser, a.NomSup NomUser, b.u_login LoginUser, c.CodJV CodUser2, c.NomJV NameUser2, c.u_login LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3
			from Reports.CommissionsDeprodecaReport a
			inner join roma_Datamart.ventas.Dim_vw_Supervisores b on a.CodSup = b.CodSup collate SQL_Latin1_General_CP1_CI_AS
			inner join ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta c on a.CodJV = c.CodJV collate SQL_Latin1_General_CP1_CI_AS
			where periodo = @period
		)
	insert Into #UsuariosSup 
	select distinct 'SU' GroupUser, *, 'D' Prv From dt

	--select * from #UsuariosSup


	;With 
		dt As (
				select distinct 
					a.SellerCode CodUser, a.SellerName NameUser, b.u_login LoginUser, 
					c.CodSup CodUser2, c.NomSup NameUser2, c.u_login LoginUser2,
					d.CodJV CodUser3, d.NomJV NameUser3, d.u_login LoginUser3
			from Reports.CommissionsMultibrandReport a
			inner join roma_datamart.ventas.DimVendedores b on a.SellerCode = b.CodVen
			inner join roma_datamart.ventas.Dim_vw_Supervisores c on a.SupervisorCode = c.CodSup collate SQL_Latin1_General_CP1_CI_AS
			inner join roma_datamart.ventas.Dim_vw_Jefes_dVenta d on a.ManagerCode = d.CodJV collate SQL_Latin1_General_CP1_CI_AS
			where period = @period
		)
	Select distinct 'VE' GroupUser, *, 'M' Prv Into #UsuariosVen From dt

	;With 
		dt As (
				select distinct 
					a.CodVen CodUser, a.NomVen NameUser, b.u_login LoginUser, 
					c.CodSup CodUser2, c.NomSup NameUser2,c.u_login LoginUser2, 
					d.CodJV CodUser3, d.NomJV NameUser3, d.u_login LoginUser3
			from Reports.CommissionsDeprodecaReport a
			inner join roma_datamart.ventas.DimVendedores b on a.CodVen = b.CodVen
			inner join roma_datamart.ventas.Dim_vw_Supervisores c on a.CodSup = c.CodSup collate SQL_Latin1_General_CP1_CI_AS
			inner join roma_datamart.ventas.Dim_vw_Jefes_dVenta d on a.CodJV = d.CodJV collate SQL_Latin1_General_CP1_CI_AS
			where periodo = @period
		)
	insert into #UsuariosVen 
	select distinct 'VE' GroupUser , *, 'D' Prv from dt


	--select * from #UsuariosVen order by 2
	--Select * from #UsuariosSup order by 2
	--Select * from #UsuariosJV order by 2


	if @tipo = 'VE'
	begin
		if @tipohijo is null
		begin
			insert into #Result 
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  from #UsuariosVen where LoginUser = @Usuario and Prv = @Prv
		end
	end

	--select * from #Result
	
	if @tipo = 'SU'
	begin
		if @tipohijo = 'VE' 
		begin
			insert into #Result
			Select Distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv From #UsuariosSup Where LoginUser = @Usuario   and Prv = @Prv
		end

		if @tipohijo = 'VE' and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario )
		begin
			insert into #Result
			Select Distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv From #UsuariosSup Where Prv = @Prv
		end

		if @tipohijo is null and @Prv is null and not Exists(Select * From #UsuarioVIP Where Usuario = @Usuario)
		begin
			insert into #Result
			Select Distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, '' From #UsuariosSup Where LoginUser = @Usuario
		end

		if @tipohijo is null and @Prv is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo <> 'JV')
		begin
			insert into #Result
			Select Distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, '' From #UsuariosSup
		end

		if @tipohijo is null and @Prv is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo = 'JV')
		begin
			insert into #Result
			Select Distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, '' From #UsuariosSup where LoginUser2 = @Usuario
		end
	end

	if @tipo is null
	begin
		if @tipohijo is null
		begin
			insert into #Result 
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv from #UsuariosVen where CodUser2 = @Usuario and Prv = @Prv
		end
	end
	--ERROR
	if @tipo = 'JV'
	begin
		if @tipohijo is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo = 'JV')
		begin
			insert into #Result
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, '' from #UsuariosJV where LoginUser = @Usuario
		end
		if @tipohijo is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo <> 'JV')
		begin
			insert into #Result
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, '' from #UsuariosJV --where LoginUser = @Usuario
		end
	end
	
	if @tipo = 'IC'
	begin
		if @tipohijo is null
		begin
			if (select grupo from #UsuarioVIP where Usuario = @Usuario) <> 'EC'
			begin
				insert into #Result
				select distinct grupo, code CodUser, name, Usuario, NULL, NULL, NULL, NULL,null, null, '' from #UsuarioVIP where grupo in ('EC', 'JC')
			end
			if (select grupo from #UsuarioVIP where Usuario = @Usuario) = 'EC'
			begin
				insert into #Result
				select distinct grupo, code CodUser, name, Usuario, NULL, NULL, NULL, NULL,null, null, '' from #UsuarioVIP where grupo in ('EC') and Usuario = @Usuario
			end
		end
	end

	if @tipo = 'PR'
	begin
		if @tipohijo is null and not Exists(Select * From #UsuarioVIP Where Usuario = @Usuario)
		begin
			insert into #Result
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  
			from #UsuariosPrv where LoginUser = @Usuario
		end
		if @tipohijo is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario)
		begin
			insert into #Result
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv 
			from #UsuariosPrv --where Usuario = @Usuario
			
		end
	end


	if @tipo = 'CB'
	begin
		if @tipohijo is null and not Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo <> 'JV')
		begin
			
			if exists (select 1 from ROMA_DATAMART.Ventas.Dim_vw_Jefes_dVenta where u_login = @Usuario)
			begin
				insert into #Result 
				select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  from #UsuariosVen
				where LoginUser3 = @Usuario
			end
			if exists (select 1 from ROMA_DATAMART.Ventas.Dim_vw_Supervisores where u_login = @Usuario)
			begin
				insert into #Result 
				select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  from #UsuariosVen
				where LoginUser2 = @Usuario
			end
			if exists (select 1 from ROMA_DATAMART.Ventas.DimVendedores where u_login = @Usuario)
			begin
				insert into #Result 
				select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  from #UsuariosVen
				where LoginUser = @Usuario
			end


		end
		if @tipohijo is null and Exists(Select * From #UsuarioVIP Where Usuario = @Usuario and grupo <> 'JV')
		begin
			insert into #Result 
			select distinct GroupUser, CodUser, NameUser, LoginUser, CodUser2, NameUser2, LoginUser2, CodUser3, NameUser3, LoginUser3, Prv  from #UsuariosVen 
		end
	end

	
	select distinct '', '9999' CodUser, 'TODOS' NameUser, '' LoginUser, '' CodUser2, '' NameUser2, '' LoginUser2, '' CodUser3, '' NameUser3, '' LoginUser3, '' Prv
	from #Result
	union all
	select * from #Result
	order by 1,3
	

end

GO

