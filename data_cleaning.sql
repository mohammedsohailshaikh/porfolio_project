--getting a look at data
SELECT *
FROM nashvaille_housing
ORDER BY uniqueid;

LIMIT 20;

--Populate property Adress data and getting the adress of repeated parcelId with nulls
SELECT *
FROM nashvaille_housing
--WHERE propertyaddress ISNULL
ORDER BY parcelid;

---SELF jOING TO GET the adress of repeated using COALESCE instead on NULLIF
SELECT a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvaille_housing AS a
INNER JOIN nashvaille_housing AS b
ON a.parcelid = b.parcelid AND a.uniqueid <>b.uniqueid
WHERE a.propertyaddress ISNULL;

UPDATE nashvaille_housing a
SET propertyaddress = COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvaille_housing b
WHERE a.propertyaddress ISNULL AND a.parcelid = b.parcelid AND a.uniqueid <>b.uniqueid;

---Breaking down into individual Columns(Address, City, State)
SELECT 
SUBSTRING(propertyaddress,1,POSITION(',' IN propertyaddress) -1) AS address, SUBSTRING(propertyaddress,POSITION(',' IN propertyaddress)+2,LENGTH(propertyaddress)) AS address1
FROM nashvaille_housing

ALTER TABLE nashvaille_housing
ADD propertystreet VARCHAR;
UPDATE nashvaille_housing
SET propertystreet = SUBSTRING(propertyaddress,1,POSITION(',' IN propertyaddress) -1);

ALTER TABLE nashvaille_housing
ADD propertycity VARCHAR;
UPDATE nashvaille_housing
SET propertycity = SUBSTRING(propertyaddress,POSITION(',' IN propertyaddress)+2,LENGTH(propertyaddress));


--splitting owener address using SPLIT_PART INSTAED OF PARSENAME
SELECT SPLIT_PART(nashvaille_housing.owneraddress,', ',1),SPLIT_PART(nashvaille_housing.owneraddress,', ',2)
,SPLIT_PART(nashvaille_housing.owneraddress,', ',3)
FROM nashvaille_housing

ALTER TABLE nashvaille_housing
ADD ownerstreet VARCHAR;
UPDATE nashvaille_housing
SET ownerstreet = SPLIT_PART(nashvaille_housing.owneraddress,', ',1);

ALTER TABLE nashvaille_housing
ADD ownercity VARCHAR;
UPDATE nashvaille_housing
SET ownercity = SPLIT_PART(nashvaille_housing.owneraddress,', ',2);

ALTER TABLE nashvaille_housing
ADD ownerstate VARCHAR;
UPDATE nashvaille_housing
SET ownerstate = SPLIT_PART(nashvaille_housing.owneraddress,', ',3);

---Change Y and N to yes and no using CASE
SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
FROM nashvaille_housing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant, 
CASE 
 WHEN soldasvacant = 'Y' THEN 'Yes'
 WHEN soldasvacant = 'N' THEN 'No'
 ELSE soldasvacant
END
FROM nashvaille_housing

UPDATE nashvaille_housing
 SET soldasvacant = (
                     CASE 
 						WHEN soldasvacant = 'Y' THEN 'Yes'
 						WHEN soldasvacant = 'N' THEN 'No'
 						ELSE soldasvacant
					 END
 					)
 
--Remove duplicate by creating temptable or CTE
WITH row_dup AS(
SELECT *,ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saledate,
	 			 saleprice,
				 legalreference 
				 ORDER BY uniqueid
						)AS row_num
FROM nashvaille_housing
	             )
SELECT *
FROM row_dup
WHERE row_num = 1;---row number greater than 1 are duplicates


---Delete unwanted rows (peroperaddress,owneraddress,taxdistrict,saledate)

ALTER TABLE nashvaille_housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN saledate;


				
