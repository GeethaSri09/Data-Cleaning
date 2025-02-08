-- Displaying Contents of the Table
Select * from layoffs;

-- Remove Duplicates
-- Standardizing the data
-- Remove or Fill the NULL values and Blank values
-- Remove the unnecessary columns

-- Creating the another Table
create table layoffs_stagging like layoffs;

-- Copying data of layoffs into layoffs_stagging
insert layoffs_stagging select * from layoffs;

--  Displaying Contents of the Table
select * from layoffs_stagging;

-- REMOVE DUPLICATES
-- Giving row number
select *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions) from layoffs_stagging;

-- Finding duplicates rows using cte's
WITH duplicate_cte AS
(
select *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num from layoffs_stagging
)
select * from duplicate_cte where row_num>1;

-- DELETING 
WITH duplicate_cte AS
(
select *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num from layoffs_stagging
)
DELETE FROM duplicate_cte where row_num>1;
-- Gives error, DELETE treated as update statement

-- so to avoid this we need to create another table
CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy the data from layoffs_stagging to layoffs_stagging2
insert into layoffs_stagging2 select *,ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions) row_num from layoffs_stagging;

-- display the data from layoffs_stagging2
select * from layoffs_stagging2;

-- DELETING DUPLICATES;
DELETE FROM layoffs_stagging2 where row_num>1;

-- check in the table
select row_num from layoffs_stagging2 where row_num=2;

-- STANDARDIZING THE DATA

-- DISPLAY THE DATA
select * from layoffs_stagging2;

-- REMOVING THE SPACES
-- Knowing spaces
select company,trim(company)from layoffs_stagging2;
-- UPDATE TABLE
update layoffs_stagging2 set company=trim(company);

-- check names
-- if we think the two names meaning are same and then need to update into one name syntax
select industry from layoffs_stagging where industry like 'crypto%';
update layoffs_stagging set industry='Crypto' where industry like 'Crypto%';

-- Removing the trailings
update layoffs_stagging set country=trim(trailing '.' from country)where country like 'United States%';

-- Date should be date data type
select date from layoffs_stagging2;
update layoffs_stagging2 set date=STR_TO_DATE(date,'%m/%d/%Y');
-- change the data type
alter table layoffs_stagging2 modify column `date` DATE;


-- REMOVE NULL VALUES OR BLANK VALUES
-- display null and blank values
select industry from layoffs_stagging2 where industry is null or industry='';

-- use self join to know the actual values for filling null values
select t1.industry,t2.industry from layoffs_stagging2 t1 join layoffs_stagging2 t2 on t1.company=t2.company where(t1.industry is NULL or t1.industry='')and t2.industry is not NULL; 

-- inorder to update the values,first we need to make all blank values to null
update layoffs_stagging2 set industry=NULL where industry='';

-- updating
update layoffs_stagging2 t1 join layoffs_stagging2 t2 on t1.company=t2.company
set t1.industry=t2.industry 
where (t1.industry is NULL or t1.industry='') and t2.industry is not NULL;


-- working with other columns
select total_laid_off,percentage_laid_off from layoffs_stagging where total_laid_off is null and percentage_laid_off is null;

-- DELETING
DELETE from layoffs_stagging2 where total_laid_off is null and percentage_laid_off is null;

delete from layoffs_stagging2 where company='Bally\'s Interactive';

ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;

select* from layoffs_stagging2;
















