/*
exec sp_TrrUtilization 
exec sp_TrrUtilization '101'
exec sp_TrrUtilization '101', 'CORE'
*/

if OBJECT_ID('sp_TrrUtilization') is not null
	drop procedure sp_TrrUtilization
go

create procedure sp_TrrUtilization (
	@sp nvarchar(max) = null,
	@serviceType nvarchar(10) = null,
	@clients nvarchar(max) = null
)
as (
select 
	ua.clientid
	, ua.ClientName
	, ua.AssmtDate
	, ua.EndDT
	, DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30 [Months of Authorization]
	, (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) - floor((datediff(dd,ua.assmtdate, getdate()) / 30)) [Months of Authorization Left]
	, ua.Purpose
	, ua.ALOC
	, um.servicetype
	, um.service
	, um.UnitTypeName
	, um.StandardUnits * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [Standard Units / Auth]
--standard
	--units/events
	, case when um.UnitTypeName = 'EVENT'
		then coalesce(count(e.eventdate), 0)
		else null
	end [Standard Utilized Events]
	
	, case when um.UnitTypeName = 'EVENT'
		then (um.StandardUnits  * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30)) - coalesce(count(e.eventdate), 0)
		else null
	end [Standard Unutilized Events]
	
	--hours
	, um.standardhours  * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [Standard Hours]
	, case when um.UnitTypeName = 'HOURS'
		then coalesce(SUM(e.clientNDur), 0)
		else null
	end [Standard Utilized Hours]
	, case when um.UnitTypeName = 'HOURS'
		then (um.standardhours  * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30)) - SUM(coalesce(e.clientNDur, 0))
		else null
	end [Standard Unutilized Hours]
	
	--dollars
	, um.standarddollars * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [standarddollars]
	, coalesce(sum(e.computedfee), 0) [Standard Utilized Dollars]
	, (um.standarddollars * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30)) - sum(coalesce(e.computedfee, 0)) [Standard Unutilized Dollars]
--high need
	--units/events
	, um.HighneedUnits * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [Hign Need Units / Auth]
	, case when um.UnitTypeName = 'EVENT'
		then coalesce(count(e.eventdate), 0)
		else null
	end [High Need Utilized Events]
	, case when um.UnitTypeName = 'EVENT'
		then (um.HighneedUnits * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) /30)) - coalesce(count(e.eventdate), 0)
		else null
	end [High Need Unutilized Events]

	--hours
	, um.Highneedhours * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [Hign Need Hours]
	, case when um.UnitTypeName = 'HOURS'
		then coalesce(SUM(e.clientNDur), 0)
		else null
	end [High Need Utilized Hours]
	, case when um.UnitTypeName = 'HOURS'
		then (um.Highneedhours * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30)) - SUM(coalesce(e.clientNDur, 0))
		else null
	end [High Need Unutilized Hours]

	--dollars
	, um.Highdollars * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30) [Hign Need Dollars]
	, coalesce(sum(e.computedfee), 0) [High Need Utilized Dollars]
	, (um.Highdollars * (DATEDIFF(dd,ua.AssmtDate, ua.EndDT) / 30)) - sum(coalesce(e.computedfee, 0)) [High Need Unutilized Dollars]

from wood.dbo.viewUAactiveChild ua
left join viewTrrUm um
  on um.sp = ua.aloc
 and ua.AuthDate between um.effectivedate and um.expirationdate
left join wood.Client.Events e
  on e.ClientID = ua.ClientID
 and e.EventDate between ua.AssmtDate and ua.EndDT
 and e.SAC in (select serviceactivitycode from trr_um_service_sac_map where serviceid = um.serviceid)

where (@sp is null or ua.ALOC in (select data from dbo.Split(@sp, ',')))
  and (@servicetype is null or um.servicetype = @serviceType)
  and (@clients is null or ua.ClientID in (select data from dbo.Split(@clients, ',')))

group by 
	ua.clientid
	, ua.ClientName
	, ua.AssmtDate
	, ua.EndDT
	, ua.Purpose
	, ua.ALOC
	, um.servicetype
	, um.service
	, um.serviceid
	, um.unittypename
	, um.StandardUnits
	, um.standardhours
	, um.standarddollars
	, um.HighneedUnits
	, um.Highneedhours
	, um.Highdollars
	
)


