CREATE table coviddeaths23(
iso_code VARCHAR (50),
continent VARCHAR (50),
location VARCHAR (50),
date DATE,
total_cases NUMERIC,
population NUMERIC,
new_cases NUMERIC,
new_cases_smoothed NUMERIC,
total_deaths NUMERIC,
new_deaths NUMERIC,
new_deaths_smoothed NUMERIC,
total_cases_per_million NUMERIC,
new_cases_per_million NUMERIC,
new_cases_smoothed_per_million NUMERIC,
total_deaths_per_million NUMERIC,
new_deaths_per_million NUMERIC,
new_deaths_smoothed_per_million NUMERIC,
reproduction_rate NUMERIC,
icu_patients NUMERIC,
icu_patients_per_million NUMERIC,
hosp_patients NUMERIC,
hosp_patients_per_million NUMERIC,
weekly_icu_admissions NUMERIC,
weekly_icu_admissions_per_million NUMERIC,
weekly_hosp_admissions NUMERIC,
weekly_hosp_admissions_per_million NUMERIC
);


CREATE table covidvaccinations23(
iso_code VARCHAR (50),
continent VARCHAR (50),
location VARCHAR (50),
date DATE,
new_tests NUMERIC,
total_tests NUMERIC,
new_tests_per_thousand NUMERIC,
new_tests_smoothed NUMERIC,
new_tests_smoothed_per_thousand NUMERIC,
positive_rate NUMERIC,
tests_per_case NUMERIC,
tests_units VARCHAR,
total_vaccinations NUMERIC,
people_vaccinated NUMERIC,
people_fully_vaccinated NUMERIC,
total_boosters NUMERIC,
new_vaccinations NUMERIC,
new_vaccinations_smoothed NUMERIC,
total_vaccinations_per_hundred NUMERIC,
people_vaccinated_per_hundred NUMERIC,
people_fully_vaccinated_per_hundred NUMERIC,
total_boosters_per_hundred NUMERIC,
new_vaccinations_smoothed_per_million NUMERIC,
new_people_vaccinated_smoothed NUMERIC,
new_people_vaccinated_smoothed_per_hundred NUMERIC,
stringency_index NUMERIC,
population_density NUMERIC,
median_age NUMERIC,
aged_65_older NUMERIC,
aged_70_older NUMERIC,
gdp_per_capita NUMERIC,
extreme_poverty NUMERIC,
cardiovasc_death_rate NUMERIC,
diabetes_prevalence NUMERIC,
female_smokers NUMERIC,
male_smokers NUMERIC,
handwashing_facilities NUMERIC,
hospital_beds_per_thousand NUMERIC,
life_expectancy NUMERIC,
human_development_index NUMERIC,
population NUMERIC,
excess_mortality_cumulative_absolute NUMERIC,
excess_mortality_cumulative NUMERIC,
excess_mortality NUMERIC,
excess_mortality_cumulative_per_million numeric
);

/* Replace empty values in columns with 'NULL' Values */

select continent, NULLIF(continent, '') from coviddeaths23;

UPDATE coviddeaths23 SET continent=NULL where continent='';

UPDATE covidvaccinations23 SET continent=NULL where continent='';

UPDATE covidvaccinations23 SET tests_units=NULL where tests_units='';

SELECT continent FROM coviddeaths23;


/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select *
from coviddeaths23
where continent is not null 
order by 3,4

/* Select Data that we are going to start exploring*/

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths23
where continent is not null 
order by 1,2

/* total_cases vs total_deaths*/
/* Likelyhood of dying from covid in any specified country*/

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths23
where location like'Germany'
order by 1,2

/* total cases vs population*/
/* shows what percentage of population is infected with Covid*/

select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from coviddeaths23
where location like'Germany'
order by 1,2

/* Countries with highest infection rate vs population*/

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths23
where continent is not null 
group by location, population 
order by PercentPopulationInfected desc

/*Looking at countries with highest death rate vs population*/

select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths23
where continent is not null
group by location 
order by TotalDeathCount desc 

/* Break data down by continent*/
/* Continents with the highest death count per population*/

select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths23
where continent is not null
group by continent 
order by TotalDeathCount desc 


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths23
where continent is null
group by location 
order by TotalDeathCount desc 


/*Global numbers agrigate */

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths23
where continent is not null
group by date
order by 1,2 

/* Global numbers */

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths23
where continent is not null
group by date
order by 1,2 

/* total population vs vaccination */
/* Shows Percentage of Population that has recieved at least one Covid Vaccine */

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths23 dea
join covidvaccinations23 vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

/* Using CTE to perform Calculation on Partition By in previous query */

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths23 dea
join covidvaccinations23 vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
/*order by 2,3*/
)
select *, (RollingPeopleVaccinated/population)*100 as percentvaccinated
from PopvsVac

/*Using Temp Table to perform Calculation on Partition By in previous query*/

drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated1
(
continent varchar(255),
location varchar(255),
date date, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated1
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths23 dea
join covidvaccinations23 vac
	on dea.location = vac.location
	and dea.date = vac.date 


select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated1

/* Creating View to store data for later visualizations*/
/* Percentage of population vaccinated*/

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from coviddeaths23 dea
join covidvaccinations23 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from percentpopulationvaccinated 

