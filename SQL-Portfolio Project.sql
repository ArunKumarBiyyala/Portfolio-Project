select*
from portfolioproject.[dbo].[Covid Deaths]
order by 3,4
--select*from portfolioproject.dbo.[owid Vaccination]
--order by 1,2
    /*death percantage in india*/
select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage,population
from portfolioproject.dbo.[Covid Deaths] 
where location ='India'
order by 1,2 
   /*total cases vs total polpolation in india*/
select location,date,total_cases,new_cases,total_deaths,population,(total_cases/population)*100 as cases_percentage
from portfolioproject.dbo.[Covid Deaths] 
where location ='India'
order by 1,2 
/*total cases_perecentage and maximun noof cases in all countries*/
select location,population,MAX(total_cases) as Total_infections,MAX((total_cases/population))*100 as Totalcases_percentage
from portfolioproject.dbo.[Covid Deaths] 
/*where location ='India'*/
group by location,population
order by Totalcases_percentage desc
   /*country wide total deaths*/
select location, MAX(cast(total_deaths as int)) as Total_no_of_deaths 
from portfolioproject.dbo.[Covid Deaths]
where continent is not null
group by location
order by Total_no_of_deaths desc
   /*date wise total deaths,total cases and percentage of deaths through out world*/
select date, SUM(new_cases) as Totalnoofcases,SUM(cast(new_deaths as int)) as Total_no_of_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) as deathpercentage
from portfolioproject.dbo.[Covid Deaths]
where continent is not null
group by date
order by 1,2 desc
   /*total cases vs total deaths till date in world*/
select  SUM(new_cases) as Totalnoofcases,SUM(cast(new_deaths as int)) as Total_no_of_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject.dbo.[Covid Deaths]
where continent is not null
--group by date
--order by Total_no_of_deaths desc
select*from portfolioproject.dbo.[owid Vaccination]
order by 3,4
   /*  Total No.of people vaccinated in india - Day wise*/
select location, date,new_vaccinations, /*SUM(cast(total_tests as bigint)) as totalvaccination_count,*/
SUM(cast(new_vaccinations as bigint)) over (/*partition by location*/order by location, date) as total_vaccinations_till_date
from portfolioproject.dbo.[owid Vaccination]  where location like '%India%'
--group by location
--order by date


 /* Population vs Vaccination in india - Date Wise*/
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations))
over (/*partition by dea.location*/order by dea.location, dea.date) as totalpeoplevaccinated
from portfolioproject.dbo.[Covid Deaths] dea
join portfolioproject.dbo.[owid Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location like '%india%' 
--order by dea.date
   /*Vaccination percentage in india - Date wise*/ 
with PopulationVSvaccination (continent,location,date,population,new_vaccinations,totalpeoplevaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations))
over (/*partition by dea.location*/order by dea.location, dea.date) as totalpeoplevaccinated
from portfolioproject.dbo.[Covid Deaths] dea
join portfolioproject.dbo.[owid Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location like '%india%'
)
select*,totalpeoplevaccinated/population*100 as vaccination_percentage
from PopulationVSvaccination
  /** creating temparory table**/
drop table if exists totalpeoplevaccinated
create table totalpeoplevaccinated
(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
totalpeoplevaccinated numeric)

insert into totalpeoplevaccinated 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations))
over (/*partition by dea.location*/order by dea.location, dea.date) as totalpeoplevaccinated
from portfolioproject.dbo.[Covid Deaths] dea
join portfolioproject.dbo.[owid Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location like '%india%'
select*,totalpeoplevaccinated/population*100 as vaccination_percentage
from totalpeoplevaccinated
  /** Creating view for later visualization purpose**/
create view PeopleVaccinated 
as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(bigint,vac.new_vaccinations))
over (/*partition by dea.location*/order by dea.location, dea.date) as totalpeoplevaccinated
from portfolioproject.dbo.[Covid Deaths] dea
join portfolioproject.dbo.[owid Vaccination] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
select*from PeopleVaccinated