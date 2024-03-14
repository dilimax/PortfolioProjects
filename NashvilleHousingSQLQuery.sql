/*

Cleaning Data in SQL Querries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-- Breaking out Address into individual colums (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress VarChar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)


alter table NashvilleHousing
add PropertySplitCity VarChar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

-- Another Way If you dont want to use 'SUBSTRING'
select 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1) 
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress VarChar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity VarChar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState VarChar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)


select *
from PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in 'SoldAsVacant' field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

select *
from PortfolioProject.dbo.NashvilleHousing


-- Remove Dupliates

with RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				order by
				UniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress


SELECT *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate

