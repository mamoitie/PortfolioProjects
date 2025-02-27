use portfolio_project2;


CREATE TABLE Nashville_Housing (
UniqueID VARCHAR (255),
ParcelID VARCHAR (255),
LandUse VARCHAR(255),
PropertyAddress VARCHAR(255),
SaleDate DATE,
SalePrice VARCHAR (255),
LegalReference VARCHAR (255),
SoldAsVacant VARCHAR(255),
OwnerName VARCHAR(255),
OwnerAddress VARCHAR(255),
Acreage VARCHAR (255),
TaxDistrict VARCHAR(255),
LandValue VARCHAR (255),
BuildingValue VARCHAR (255),
TotalValue VARCHAR (255),
YearBuilt VARCHAR (255),
Bedrooms VARCHAR (255),
FullBath VARCHAR (255)
);

SHOW TABLES;
DESCRIBE Nashville_Housing;


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nashville.csv"
INTO TABLE Nashville_Housing
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
;


SELECT count(*) FROM Nashville_Housing;
SELECT * FROM nashville_housing;


UPDATE Nashville_Housing
SET
    PropertyAddress = NULLIF(TRIM(PropertyAddress), ''),
    OwnerName = NULLIF(TRIM(OwnerName), ''),
    OwnerAddress = NULLIF(TRIM(OwnerAddress), ''),
    Acreage = NULLIF(TRIM(Acreage), ''),
    TaxDistrict = NULLIF(TRIM(TaxDistrict), ''),
    LandValue = NULLIF(TRIM(LandValue), ''),
    BuildingValue = NULLIF(TRIM(BuildingValue), ''),
	TotalValue = NULLIF(TRIM(TotalValue), ''),
	YearBuilt = NULLIF(TRIM(YearBuilt), ''),
	Bedrooms = NULLIF(TRIM(Bedrooms), ''),
	FullBath = NULLIF(TRIM(FullBath), ''),
    HalfBath = NULLIF(TRIM(HalfBath), '');
    



--------------------------------------------------------------------------------------------------------
# POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress FROM nashville_housing
WHERE PropertyAddress IS NULL;



SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ifnull(A.PropertyAddress, B.PropertyAddress)
FROM PORTFOLIO_PROJECT2.nashville_housing A
JOIN PORTFOLIO_PROJECT2.nashville_housing B
ON A.ParcelID = B.ParcelID
AND A.UniqueID != B.UniqueID
WHERE A.PropertyAddress IS NULL;



UPDATE PORTFOLIO_PROJECT2.nashville_housing A
JOIN PORTFOLIO_PROJECT2.nashville_housing B
ON A.ParcelID = B.ParcelID
AND A.UniqueID != B.UniqueID
SET A.PropertyAddress = IFNULL(A.PropertyAddress, B.PropertyAddress)
WHERE A.PropertyAddress IS NULL;


------------------------------------------------------------------------------------------------------------------------------
# BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)



# SUBSTRING - INSTR 
SELECT SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS SubAddress,
       SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1) as City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1);

ALTER TABLE nashville_housing
DROP PropertyAddress;

ALTER TABLE nashville_housing
CHANGE PropertySplitAddress PropertyAddress VARCHAR(255),
CHANGE PropertySplitCity PropertyCity VARCHAR(255);



SELECT OwnerAddress FROM nashville_housing;

# SUBSTRING_INDEX

SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS city,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD COLUMN address VARCHAR(255),
ADD COLUMN city VARCHAR(255),
ADD COLUMN state VARCHAR(255);

UPDATE nashville_housing
SET address = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    city = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1),
    state = SUBSTRING_INDEX(OwnerAddress, ',', -1);


ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;




----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

# CHANGE Y AND N TO YES AND NO UN "SOLD AS VACANT" FIELD


SELECT DISTINCT(SOLDASVACANT), COUNT(SoldAsVacant)
 FROM nashville_housing
 GROUP BY SoldAsVacant;


SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END AS SoldAsVacant
FROM
    nashville_housing;
    
    
UPDATE nashville_housing
SET SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END ;
    
    
 ----------------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------
    
# REMOVING DUPLICATES

SELECT * FROM nashville_housing;

WITH ROW_CTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, SaleDate, SalePrice, LegalReference, Acreage, PropertyAddress
ORDER BY UNIQUEID) ROW_NUM
FROM nashville_housing)
#ORDER BY ParcelID;

SELECT * FROM ROW_CTE
#DELETE FROM ROW_CTE 
WHERE ROW_NUM > 1 ;
-- MySQL DOES NOT ALLOW DELETE OPERATION DIRECTLY ON CTE UNLIKE SQL SERVER


# ANOTHER WAY OF FINDING DUPLICATES

SELECT *
FROM nashville_housing nh1
JOIN (
    SELECT ParcelID, SaleDate, SalePrice, LegalReference, Acreage, PropertyAddress, COUNT(*)
    FROM nashville_housing
    GROUP BY ParcelID, SaleDate, SalePrice, LegalReference, Acreage, PropertyAddress
    HAVING COUNT(*) > 1
) nh2
ON nh1.ParcelID = nh2.ParcelID
AND nh1.SaleDate = nh2.SaleDate
AND nh1.SalePrice = nh2.SalePrice
AND nh1.LegalReference = nh2.LegalReference
AND nh1.Acreage = nh2.Acreage
AND nh1.PropertyAddress = nh2.PropertyAddress;

CREATE TEMPORARY TABLE duplicates AS
SELECT MIN(UniqueID) AS UniqueID
FROM nashville_housing
GROUP BY ParcelID, SaleDate, SalePrice, LegalReference, Acreage, PropertyAddress
HAVING COUNT(*) > 1;


SELECT * FROM DUPLICATES;

DELETE nh1
FROM nashville_housing nh1
JOIN duplicates d ON nh1.UniqueID = d.UniqueID;

DROP TEMPORARY TABLE duplicates;

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict;