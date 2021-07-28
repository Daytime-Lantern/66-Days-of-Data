--SELECT *
--FROM GW_Contaminants
--ORDER BY 3,4;

--Selecting data for lifestyle variables

SELECT *
FROM County_Lifestyles
ORDER BY 3,4;

--Determining top 5 most populated counties

SELECT TOP 5 County_Name, Below_Poverty, Population_Totals, County_Key
FROM County_Lifestyles
ORDER BY 3 DESC;

--Determining top 5 least populated counties

SELECT TOP 5 County_Name, Rural_Percent, Population_Totals, County_Key
FROM County_Lifestyles
ORDER BY 3 ASC;

--Highest colorectal cancer cases per county with population

SELECT County_Name, Colorectal_Cancer_Per100k, Population_Totals
FROM County_Lifestyles
ORDER BY 2 DESC;

--Highest breast cancer cases per county with population

SELECT County_Name, Female_Breast_Cancer_Per100k, Population_Totals
FROM County_Lifestyles
ORDER BY 2 DESC;

--Smoking correlation against cancer cases

SELECT County_Name, Adult_Smokers, Colorectal_Cancer_Per100k, Female_Breast_Cancer_Per100k,
ROUND (Adult_Smokers/Colorectal_Cancer_Per100k*100, 2)
AS SmokingColorectalCases,
ROUND (Adult_Smokers/Female_Breast_Cancer_Per100k*100,2)
AS SmokingBreastCancerCases
FROM County_Lifestyles
ORDER BY 2 DESC;

--Poverty correlation against cancer cases (experimenting with filtering)

SELECT County_Name, Below_Poverty, Colorectal_Cancer_Per100k, Female_Breast_Cancer_Per100k,
ROUND (Below_Poverty/Colorectal_Cancer_Per100k*100,2)
AS PovertyColorectalCases,
ROUND (Below_Poverty/Female_Breast_Cancer_Per100k*100,2)
AS PovertyBreastCancerCases
FROM County_Lifestyles
WHERE County_Name LIKE '%E'
ORDER BY County_Name DESC;

--Poverty correlation against cancer cases (no filters)

SELECT County_Name, Below_Poverty, Colorectal_Cancer_Per100k, Female_Breast_Cancer_Per100k,
ROUND (Below_Poverty/Colorectal_Cancer_Per100k*100,2)
AS PovertyColorectalCases,
ROUND (Below_Poverty/Female_Breast_Cancer_Per100k*100,2)
AS PovertyBreastCancerCases
FROM County_Lifestyles
ORDER BY Below_Poverty DESC;

--Rural population correlation possibility

SELECT County_Name, Rural_Percent, Colorectal_Cancer_Per100k, Female_Breast_Cancer_Per100k
FROM County_Lifestyles
ORDER BY Rural_Percent DESC;

--Viewing the top counties for different contaminants

SELECT TOP 10 County_Name, Positive_VOC, Arsenic_Over_10PPB, Nitrates_Over_20mg_per_L
FROM GW_Contaminants
WHERE Positive_VOC = '20+' OR Nitrates_Over_20mg_per_L = '20+';

-- Looking at combined data of Ground Water variables against county lifestyle factors

SELECT *
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key;

--Looking at population vs arsenic levels

SELECT gw.County_Name, gw.Arsenic_Over_10PPB, cl.Population_Totals, cl.Rural_Percent
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key
ORDER BY gw.Arsenic_Over_10PPB DESC;

--Comparing extremely rural counties vs heavier populations

SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, 
cl.Population_Totals, cl.Rural_Percent, cl.Colorectal_Cancer_Per100k, cl.Female_Breast_Cancer_Per100k
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key
WHERE cl.County_Key IN ('1', '64', '82', '63');

--Comparing smokers and poverty levels to contaminant cases

SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, cl.Adult_Smokers, cl.Below_Poverty
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key 
WHERE cl.Below_Poverty > '0.220';

-- Looking at cancer cases vs contaminants

SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, cl.Colorectal_Cancer_Per100k,
cl.Female_Breast_Cancer_Per100k, cl.Rural_Percent
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key
WHERE gw.Arsenic_Over_10PPB >'0'
ORDER BY 3,4;

-- Looking at cancer cases vs contaminants in top 5 rural and populated counties 

SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, cl.Colorectal_Cancer_Per100k,
cl.Female_Breast_Cancer_Per100k, cl.Rural_Percent
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key
WHERE gw.County_Key IN ('82', '63', '50', '41', '25', '42', '66', '48', '77', '68')
ORDER BY cl.Rural_Percent ASC;

-- TEMP TABLE

DROP TABLE IF exists #CancervsContaminants
CREATE TABLE #CancervsContaminants
(
County_Name nvarchar(255),
Arsenic_Over_10PPB nvarchar (255),
Nitrates_Over_20mg_per_L nvarchar(255),
Positive_VOC nvarchar(255),
Rural_Percent int, 
Colorectal_Cancer_Per100k nvarchar(255),
Female_Breast_Cancer_Per100k nvarchar(255))


INSERT INTO #CancervsContaminants
SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, cl.Colorectal_Cancer_Per100k,
cl.Female_Breast_Cancer_Per100k, cl.Rural_Percent
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key
WHERE Arsenic_Over_10PPB > '0';


SELECT * FROM #CancervsContaminants;

-- Creating Views to store data for future visualizations

CREATE VIEW SmokerstoContaminants AS
SELECT gw.County_Name, gw.Arsenic_Over_10PPB, gw.Nitrates_Over_20mg_per_L, gw.Positive_VOC, cl.Adult_Smokers, cl.Below_Poverty
FROM GW_Contaminants gw
JOIN County_Lifestyles cl
ON gw.County_Name = cl.County_Name
AND gw.County_Key = cl.County_Key 
WHERE cl.Below_Poverty > '0.220';

SELECT * FROM SmokerstoContaminants;


