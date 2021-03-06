/*
select * from viewTrrUm
*/

if OBJECT_ID('viewTrrUm') is not null
	drop view viewTrrUm
go

create view viewTrrUm as (

select spm.ServicePackageMapId
	, spm.ServicePackageId
	, sp.Code [SP]
	, sp.Name [SPName]
	, spm.ServiceTypeId
	, st.Name [ServiceType]
	, spm.ServiceId
	, s.Name [Service]
	, s.UnitType
	, sut.Name [UnitTypeName]
	, spm.StandardUnits
	, spm.HighNeedUnits
	, avg(cast(sac.UOSFee as float)) [AvgStdFee]
	, case when s.unittype = 1 /*unittype = hours*/
	     then spm.StandardUnits * s.ValuePerUnit
	     else null
	  end [StandardHours]
	, case when s.unittype = 1 /*unittype = hours*/
	     then spm.HighNeedUnits * s.ValuePerUnit
	     else null
	end [HighNeedHours]
	--, sm.ServiceActivityCode, sac.UOSFee
	, spm.StandardUnits * avg(cast(sac.UOSFee as float)) [StandardDollars]
	, spm.HighNeedUnits * avg(cast(sac.UOSFee as float)) [HighDollars]
	, sp.effectivedate
	, sp.expirationdate
from trr_um_service_package_map spm
join trr_um_service_package sp
  on spm.ServicePackageId = sp.ServicePackageId
join trr_um_service_type st
  on st.ServiceTypeId = spm.ServiceTypeId
join trr_um_service s
  on s.ServiceId = spm.ServiceId
join trr_um_service_unit_type sut
  on s.unittype = sut.serviceunittypeid
join trr_um_service_sac_map sm
  on sm.ServiceId = s.serviceid
join SysFile.SAC sac
  on sac.SAC = sm.ServiceActivityCode
group by sp.code
	, spm.ServicePackageMapId
	, spm.ServicePackageId
	, sp.Name, spm.ServiceTypeId
	, st.Name, spm.ServiceId
	, s.Name
	, s.unittype
	, sut.Name
	, s.ValuePerUnit
	, spm.StandardUnits
	, spm.HighNeedUnits
	, sp.effectivedate
	, sp.expirationdate
)