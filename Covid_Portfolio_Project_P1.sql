--Looking at Total_Cases vs Total_Deaths
-- Calculated the percentage of possibly dying from getting covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Total Cases vs Population
--Shows what percentage of population who got covid

Select Location, date, total_cases, Population, (total_deaths/total_cases)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with the highest Infection rates compared to Population 

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location,Population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per Population 
-- We cast because in the data total_deaths is nvarchar(25) Instead of an integer
-- Where Continent is not Null because where its null it has the continent name under location 
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Showing Countries with Highest Death Count per Population broken down by Continent
-- The Result Data Is not perfect because in did not include Canda in North America Just the U.S.
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing Countries with Highest Death Count per Population broken down by Location
-- The Result Data is more accurate just more than just continents. It also shows Income 
--How about death based on Income?
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by Location
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          rder by TotalDeathCount desc


--------------------------------------------------------Global Data------------------------------------------ 

---Death Percentage globaly 
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 1,2

--Death Perentage across the World
--Casting because new_deaths is a Varchar

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group By date 
order by 1,2

--Joining CovidDeaths and COvidVaccinations Tables


Select *
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date

-- Total Population vs Vaccinations 

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date
Where deaths.continent is not null
order by 2,3

--We want to creat a new column where sums up new_vaccinations as the days go by; rolling count 
-- Instead of casting we can do convert as well
-- Partition by location because everytime it gets to a new location we want the count to start over 

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(convert(bigint,vacc.new_vaccinations)) Over(Partition by deaths.location Order by deaths.location,deaths.date ) as vaccinations_rolling_count
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date
Where deaths.continent is not null and deaths.continent= 'Europe' and deaths.location = 'Albania'
order by 2,3

--ERROR- U cant use a column you just creted to use in a new column so we need to use a CTE or a temp table 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(convert(bigint,vacc.new_vaccinations)) Over(Partition by deaths.location Order by deaths.location,deaths.date ) as vaccinations_rolling_count,
(vaccinations_rolling_count/deaths.population) * 100 As percent_vaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date
Where deaths.continent is not null and deaths.continent= 'Europe' and deaths.location = 'Albania'
order by 2,3

--using a CTE

With Population_Vaccinated (continent,location, date,population,new_vaccinations,vaccinations_rolling_count)
as(

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(convert(bigint,vacc.new_vaccinations)) Over(Partition by deaths.location Order by deaths.location,deaths.date ) as vaccinations_rolling_count
--(vaccinations_rolling_count/deaths.population) * 100 As percent_vaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date
Where deaths.continent is not null and deaths.continent= 'Europe' and deaths.location = 'Albania'
--order by 2,3
)
Select *, (vaccinations_rolling_count/population) * 100 As percent_vaccinated
From Population_Vaccinated

--Tempt Table 

Create Table Percent_Population_Vaccinated 
(continent nvarchar(255),
location nvarchar(255) , 
date datetime,
population numeric,
new_vaccinations numeric,
vaccinations_rolling_count numeric
)
Insert Into Percent_Population_Vaccinated 
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
Sum(convert(bigint,vacc.new_vaccinations)) Over(Partition by deaths.location Order by deaths.location,deaths.date ) as vaccinations_rolling_count
--(vaccinations_rolling_count/deaths.population) * 100 As percent_vaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
on deaths.location = vacc.location
and deaths.date= vacc.date
Where deaths.continent is not null and deaths.continent= 'Europe' and deaths.location = 'Albania'

Select *, (vaccinations_rolling_count/population) * 100 As percent_vaccinated
From Percent_Population_Vaccinated 































