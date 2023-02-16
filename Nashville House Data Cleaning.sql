--GOODNESS NWOKEBU; WTF/23/DS/B/059

--This Project focuses on Cleaning Data
--In this Project, I would be
--a) Standardising Date Format
--b) Populating Property Address date
--c) Breaking out Address into individual Columns(Address, City, State)
--d)Change  'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant Field
--e)Remove Duplicates
--f) Delete Unused Columns.


Select * 
from NashvilleHouseData
---This data has 56,477 rows and 19 columns

--a) Standardising Date Format
Select SaleDate,convert(DATE,SaleDate) 
from NashvilleHouseData

Alter Table NashvilleHouseData
Add SaleDateConverted Date

Update NashvilleHouseData
Set SaleDateConverted = convert(Date, SaleDate)
-- We now have a new column of which the date in SaleDate was standardized.

--b) Populating Property Address date

Select PropertyAddress
from NashvilleHouseData
where PropertyAddress is Null

--Twenty-nine rows had null PropertyAddress
--When their is a null set, you try to look for relationships to fill in the empty spaces. 

Select *
From NashvilleHouseData
order BY ParcelID

--In this dataset, a customer ParcelID has a matching PropetyAdddress.

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHouseData a
Join NashvilleHouseData b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] != b.[UniqueID ]
AND a.PropertyAddress is null

Update a --Putting only the table might confuse the program
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHouseData a
Join NashvilleHouseData b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] != b.[UniqueID ]
AND a.PropertyAddress is null

--c) Breaking out PropertyAddress into individual Columns(Address, City, State)
Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)-1,len(PropertyAddress))
From NashvilleHouseData

Alter Table NashvilleHouseData
Add PropertySplitAddress NvarChar(255)

Alter Table NashvilleHouseData
Add PropertySplitCity NvarChar(255)

Update NashvilleHouseData
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

--d) Breaking out OwnerAddress into individual Columns(Address, City, State)
Select 
Parsename(Replace(OwnerAddress, ',', '.'),3),
Parsename(Replace(OwnerAddress, ',', '.'),2),
Parsename(Replace(OwnerAddress, ',', '.'),1)
FROM [PortFolio Projects].[dbo].[NashvilleHouseData]

Alter Table NashvilleHouseData
Add OwnerSplitCity NvarChar (255)


Alter Table NashvilleHouseData
Add OwnerSplitAddress NvarChar (255)


Alter Table NashvilleHouseData
Add OwnerSplitState NvarChar (255)

Update NashvilleHouseData
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'),1)

Update NashvilleHouseData
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'),2)

Update NashvilleHouseData
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'),3)

--Simplifying the addresses makes the data better for workability and better understanding.
-- We splitted the data using substring and Parsename. Parsename only splits sentences with a fullstop 
--so we converted comma to fullstop then spliited it.

--Change  'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant Field
select distinct(SoldAsVacant),
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHouseData

Update [NashvilleHouseData]
SET SoldAsVacant =
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

with rom_numCTE as(
Select *,
Row_Number() Over (Partition by ParcelID, PropertyAddress, SalePrice,SaleDate, LegalReference oRDER BY UniqueID) AS rom_num
From NashvilleHouseData)

Delete--This deleted 104 duplicates present.
from rom_numCTE 
WHERE rom_num > 1

--f) Delete Unused Columns.
--This dataset currently have 23 columns such as:
--LandUse
--PropertyAddress
--SaleDate
--SalePrice
--LegalReference
--SoldAsVacant
--OwnerName
--OwnerAddress
--Acreage
--TaxDistrict
--LandValue
--BuildingValue
--TotalValue
--YearBuilt
--Bedrooms
--FullBath
--HalfBath
--SaleDateConverted
--PropertySplitAddress
--PropertySplitCity
--OwnerSplitCity
--OwnerSplitAddress
--OwnerSplitState
--we would be dropping PropertyAddress, OwnerAddress and SaleDate

Alter Table NashvilleHouseData
Drop Column PropertyAddress, OwnerAddress, SaleDate







