--Fecha Referencia 01/08/2022

--1.-Guardar la venta de los clientes de los dos �ltimos meses en una tabla temporal
select a.* --codcli as codcli,codmesa,sum(CASE tipo when 'V' then monigv else -monigv end) as montosinigv 
into entregas22.dbo.resvtaprvdia_ped_202207
from reportes.resvtaprvdia_ped a
where fecvta>='20220601' and fecvta<='20220731'and codmesa in (select code from "@BKS_MESA" where u_bks_estado ='Y' and code not in ('000','002'))


--Drop Table #tmpvta
select codcli as codcli,codmesa,sum(CASE tipo when 'V' then monigv else -monigv end) as montosinigv 
into #tmpvta
from reportes.resvtaprvdia_ped a
where fecvta>='20220601' and fecvta<='20220731'and codmesa in (select code from "@BKS_MESA" where u_bks_estado ='Y' and code not in ('000','002'))
group by codcli,codmesa

--2.- guardar las bajas a realizar en una tabla en la base de datos  entregas22

select distinct  U_BKP_CLIENTE,U_BKP_CODMESA 
into entregas22..Bajas_Julio2022
from "@BKS_CLIENTE_MESA" a where U_BKP_CODMESA in (select code from "@BKS_MESA" where u_bks_estado ='Y' and code not in ('000','002'))  and U_BKP_ESTADO ='A'
and not exists (select 1 from #tmpvta b where b.codcli=a.U_BKP_CLIENTE and b.codmesa=a.U_BKP_CODMESA    )
and exists (select 1 from ocrd x where x.CardCode=a.U_BKP_CLIENTE and x.CreateDate <'20220801')

--3.- Actualizar la baja de los clientes por mesa
update "@BKS_CLIENTE_MESA" set U_BKP_ESTADO='I' 
from "@BKS_CLIENTE_MESA" a
where a.U_BKP_CODMESA in (select code from "@BKS_MESA" where u_bks_estado ='Y' and code not in ('000','002')) and a.U_BKP_ESTADO ='A' and
not exists (select 1 from #tmpvta b where b.codcli=a.U_BKP_CLIENTE and b.codmesa=a.U_BKP_CODMESA    )
and exists (select 1 from ocrd x where x.CardCode=a.U_BKP_CLIENTE and x.CreateDate <'20220801')

--4.- crear nuevamente la cartera

Select * 
Into Entregas22.dbo.gCAR1_Julio2022 
From gProc.gCAR1 
where exists (select 1 from gProc.gCAR where gProc.gCAR1.id=gProc.gCAR.id and docdate between '20220801' and '20220802')

delete from gProc.gCAR1 
where exists (select 1 from gProc.gCAR where gProc.gCAR1.id=gProc.gCAR.id and docdate between '20220801' and '20220802')

Select * Into Entregas22.dbo.gCar_Julio2022 From gProc.gCAR where docdate>='20220801'

Select * 
--Delete
from gProc.gCAR1 Where id In (Select Id from gProc.gCAR where docdate>='20220801')

delete from gProc.gCAR where docdate>='20220801'




-- delete from gProc.gCAR where docdate='20201001'

--5.- coordinar con h�ctor para que informa a los vendedores y sincronice nuevamente la cartera


Select * From Entregas22.dbo.gCar_Julio2022 




