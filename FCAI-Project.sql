--  ........................   FCAI Project  ............................

-- 1 . Display instructor Name and Department Name 
-- Note: display all the instructors if they are attached to a department or not
select Ins_Name , Dept_Name
from Instructor S left join Department D
On D.Dept_Id = S.Dept_Id


-- 2.	Display student full name and the name of the course he is taking
-- For only courses which have a grade  
select St_Fname +'  '+ St_Lname as StudentName , Crs_Name ,Sc.Grade
from Student S Join  Stud_Course Sc  
On S.St_Id = Sc.St_Id  and Sc.Grade is not NULL
JOIN Course C 
On Sc.Crs_Id = C.Crs_Id

--  3.	Display number of courses for each topic name
select T.Top_Name, Count(Crs_Id) [Number Of Courses]
from Topic T join Course C 
On T.Top_Id = C.Top_Id
group by T.Top_Name

--  4.	Display max and min salary for instructors
select max(Salary) as MaxSalary , Min(Salary) as MinSalary
from Instructor


-- 5. Display instructors who have salaries less than the average salary of all instructors.
select Ins_Name , Salary
from  Instructor
where Salary < (select avg(Salary) from Instructor)


 -- 6.Display the Department name that contains the instructor who receives the minimum salary.
 select Distinct Dept_Name
 from Department D join Instructor S
 On D.Dept_Id = S.Dept_Id 
 and S.Salary = (select Min(Salary) from Instructor)
 -----------------------------------------------------------------------------------------------------------------
/*
What is Schema Binding?
Schema binding is an option in SQL Server that ensures the view is dependent on the schema of the underlying tables.
When you use WITH SCHEMABINDING in a view, the following rules apply:

Prevents Schema Changes:

You cannot modify the structure of the underlying tables (e.g., drop or alter columns) without first removing or altering the view. 
This ensures the integrity of the view.
Fully Qualified Table Names:

All table names in the view must include the schema prefix (e.g., dbo.Instructors instead of just Instructors).
Improves Performance:

Views with SCHEMABINDING can improve performance when indexed views are created, as the database knows the schema of the underlying tables won’t change unexpectedly.
*/
/*
WITH ENCRYPTION:
Purpose:
Hides the definition of the View so that no one, not even the DBA, can see or access its code.

Use Cases:

To protect your code from being leaked or modified.
When working in shared environments (e.g., a company) and you want to prevent others from accessing the View's definition
*/

-- 7.	Create a view that displays student full name, course name , Grade if the student
-- has a grade more than 50.

CREATE VIEW StudentWith_MoreThan_50 
AS
SELECT St_Fname + ' ' + St_Lname AS FullName , Crs_Name , SC.Grade
FROM  Student S
JOIN  Stud_Course Sc
On S.St_Id = Sc.St_Id 
And Sc.Grade > 50
JOIN Course C 
ON Sc.Crs_Id = C.Crs_Id

-- Check ...
select * from StudentWith_MoreThan_50 

----------------------------------------------------------------------
--8.	Create an Encrypted view that displays manager names and the topics they teach.

Create view ManaegrData 

WITH ENCRYPTION 
AS
select  D.Dept_Id , Ins_Name  , Top_Name
from Instructor Ins
JOIN Department D 
On Ins.Ins_Id = D.Dept_Manager

Join Ins_Course InsC 
On Ins.Ins_Id = InsC.Ins_Id

Join Course C 
On C.Crs_Id = InsC.Crs_Id

Join Topic T 
On C.Top_Id = T.Top_Id 
-- Check .......
SELECT * FROM ManaegrData
EXEC sp_helptext 'ManaegrData';
--------------------------------------------------------------------
-- 9.	Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department “use Schema binding” 
-- and describe what is the meaning of Schema Binding

CREATE VIEW InstructorDepartmentView
WITH SCHEMABINDING
AS
SELECT 
    Ins_Name, 
    Dept_Name
FROM 
    dbo.Instructor Ins   -- Must mention to schema Name while using "SCHEMABINDING"
JOIN 
    dbo.Department D 
ON 
    Ins.Dept_Id = D.Dept_Id
AND 
    Dept_Name IN ('SD', 'Java');


-- Check -----
Select * from InstructorDepartmentView
--------------------------------------------------------------
-- 10 .	Create a view “V1” that displays student data for student who lives in Alex or Cairo. 
-- Note: Prevent the users to run the following query Update V1 set st_address=’tanta’ Where st_address=’alex’.


CREATE VIEW V1 
AS
select * from Student
where St_Address in ('Alex' ,'Cairo')
WITH CHECK OPTION;

/*
WITH CHECK OPTION: This ensures that any INSERT or UPDATE operations made through the view must meet the conditions defined 
in the WHERE clause of the view. In this case, users can only update the st_address to values that are either 'Alex' or 'Cairo'. 
Trying to set it to 'Tanta' will result in an error.
*/
Select*from V1

-- To make sure this SQL script must return Error
update  V1 
set St_Address = 'gggg'
where St_Address = 'Cairo'


------------------------------------------------------------------------------------------------------
-- 11.	 Create a scalar function that takes date and returns Month name of that date.

CREATE FUNCTION GetMonthName (@date DATE)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @MonthName VARCHAR(50);
    SELECT @MonthName = DATENAME(MONTH, @date); -- convert date into monthName
    RETURN @MonthName;
END

SELECT dbo.GetMonthName( getdate()) AS MonthName;



-- 12.	 Create a multi-statements table-valued function that takes 2 integers and returns the values between them.
CREATE FUNCTION ReturnBetween (@num1 INT, @num2 INT)
RETURNS @y TABLE (NumbersBetween INT)
AS
BEGIN
    -- Ensure @num1 is less than @num2
    IF (@num1 < @num2)
    BEGIN
        WHILE (@num1 < @num2 - 1) --as In the WHILE loop, @num1 is incremented before being inserted into the table.
        BEGIN
            SET @num1 = @num1 + 1; -- Increment @num1
            INSERT INTO @y VALUES (@num1); -- Insert the incremented value into the table
        END
    END
    RETURN;
END


SELECT * FROM dbo.ReturnBetween(3, 7);
SELECT * FROM dbo.ReturnBetween(1, 10);



-- 13.	 Create a tabled valued function that takes Student No and returns Department Name with Student full name.
CREATE FUNCTION GetStudentDepartment (@StudentNo INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        S.St_Fname + ' ' + S.St_Lname AS St_FullName,
        D.Dept_Name AS DepartmentName
    FROM 
        Student S
    INNER JOIN 
        Department D
    ON 
        S.Dept_Id = D.Dept_Id
    WHERE 
        S.St_Id = @StudentNo
);

SELECT * FROM dbo.GetStudentDepartment(1);


-- create table variable function returns Department Name with Student full name

Declare @StudentData table (St_FullName varchar(50) , DepartmentName varchar(50))

Insert into  @StudentData   -- insert based on select
select S.St_Fname +' ' +S.St_Lname as FullName ,  D.Dept_Name
from Student S
JOIN Department D
ON S.Dept_Id = D.Dept_Id

select  *from @StudentData

-- 14.	Create a scalar function that takes Student ID and returns a message to user 
/*
a.	If first name and Last name are null then display 'First name & last name are null'
b.	If First name is null then display 'first name is null'
c.	If Last name is null then display 'last name is null'
d.	Else display 'First name & last name are not null'

*/
Select*from Student
CREATE FUNCTION GetStudentName(@id INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @First_Name VARCHAR(50), @Last_Name VARCHAR(50);
    DECLARE @ResultMessage VARCHAR(50);

    -- Retrieve the first name and last name for the given Student ID
    SELECT @First_Name = St_Fname, @Last_Name = St_Lname 
    FROM Student 
    WHERE St_Id = @id;

    -- Check the conditions and assign appropriate messages
    IF (@First_Name IS NULL AND @Last_Name IS NULL)
        SET @ResultMessage = 'First name & last name are null';
    ELSE IF (@First_Name IS NULL AND @Last_Name IS NOT NULL)
        SET @ResultMessage = 'First name is null';
    ELSE IF (@First_Name IS NOT NULL AND @Last_Name IS NULL)
        SET @ResultMessage = 'Last name is null';
    ELSE
        SET @ResultMessage = 'First name & last name are not null';

    -- Return the result message
    RETURN @ResultMessage;
END;
--------------------------------------------------------------------------------------------------------------
/*
15 .	Create multi-statements table-valued function that takes a string
If string='first name' returns student first name
If string='last name' returns student last name 
If string='full name' returns Full Name from student table 
Note: Use “ISNULL” function

*/


-----------------------------------------------------------------------------------------------------
CREATE FUNCTION StudentName(@stringVar VARCHAR(20))
RETURNS @TableName TABLE (Stname VARCHAR(50))
AS
BEGIN
    IF (@stringVar = 'first')
        INSERT INTO @TableName
        SELECT ISNULL(St_Fname, 'Unknown') AS FirstName FROM Student;
    ELSE IF (@stringVar = 'last')
        INSERT INTO @TableName
        SELECT ISNULL(St_Lname, 'Unknown') AS LastName FROM Student;
    ELSE IF (@stringVar = 'full')
        INSERT INTO @TableName
        SELECT ISNULL(St_Fname, 'Unknown') + ' ' + ISNULL(St_Lname, 'Unknown') AS FullName FROM Student;
    RETURN;
END;
GO

-- Call the function correctly
SELECT * FROM dbo.StudentName('full');
-----------------------------------------------------------------------------------------------------
/*
16 . Write a query that takes the columns list and table name into variables and then return the result of this query
“Use exec command”
*/
select*from Student

declare @ColumnName varchar(20) = 'St_Fname' ,
@Column2 varchar(20)='St_Lname',
@TableName varchar(20) ='Student'
Execute('select '+@ColumnName+','+@Column2+' from '+@TableName)



-- 17.	Create a stored procedure to show the number of students per department.[use ITI DB] 

Create Proc NumberOfStudent_PerDepartment
AS
   Select Dept_Id ,count(St_Id)
   from Student 
   group by Dept_Id

-- Call
EXEC NumberOfStudent_PerDepartment;


-------------------------------------------------------------------------------
-- 18.	Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB]
-- “Print a message for user to tell him that he can’t insert a new record in that table”
Create trigger NO_Insertion
On Department
instead of insert
AS
   Select 'You can’t insert a new record in that table'
   --  PRINT 'You can’t insert a new record in that table';


-- Check
Insert into Department (Dept_Id,Dept_Name)
values(80 , 'GG')  -- You can’t insert a new record in that table
-------------------------------------------------------------------------------
/*
19.	Create a trigger on student table after insert to add Row in Student Audit table (Server User Name , Date, Note) 
where note will be “[username] Inserted New row with Key=[Key Value] in table [table name]” .[use ITI DB]
*/


--Desktop/M987 inserted new row with key=500 in table student
-- Create the StudentAudit table if it does not already exist
CREATE TABLE StudentAudit (
    ServerUserName NVARCHAR(100),
    EventDate DATETIME,
    Note NVARCHAR(500)
);

--20 . Create the trigger on the Student table
CREATE TRIGGER AfterInsertStudentAudit
ON Student
AFTER INSERT
AS
BEGIN
    -- Insert into StudentAudit for each new row in the Student table
    INSERT INTO StudentAudit (ServerUserName, EventDate, Note)
    SELECT 
        SYSTEM_USER AS ServerUserName,  -- Current server username
        GETDATE() AS EventDate,        -- Current date and time
        FORMATMESSAGE(
            '%s Inserted New Row with Key=[%s] in Table Studen]',
            SYSTEM_USER, CAST(i.St_Id as NVARCHAR)
        ) AS Note
    FROM inserted i; -- Use the 'inserted' pseudo table to get the new row data
END;

-- Check test case : 
INSERT INTO Student (St_Id , St_Fname,St_Lname)
VALUES (200, 'John', 'Doe');

select*from StudentAudit
-------------------------------------------------------------------------
/*
What FORMATMESSAGE Does:
FORMATMESSAGE is a SQL Server function that creates a formatted string using placeholders (like %s) 
and the values you provide to replace those placeholders.

In this case :
FORMATMESSAGE(
    '%s Inserted New Row with Key=[%s] in Table [Student]',
    SYSTEM_USER, CAST(i.StudentID AS NVARCHAR)
)

This means:

The first %s will be replaced with the current username (SYSTEM_USER).
The second %s will be replaced with the StudentID value from the inserted table (after converting it to a string).
The string [Student] is static—it stays the same for every log entry.
*/

------------------------------------------------------------------------------------------------------------------------
/*
21.	 Create a trigger on student table instead of delete to add row in Student Audit table
(Server User Name, Date, Note) where note will be “[username] tried to delete row with Key=[Key Value]” .[use ITI DB]
*/


Create Trigger DeletionAuditTrigger 
On Student
instead of delete
As
   Insert into StudentAudit
   Select  SYSTEM_USER AS ServerUserName,  -- Current server username
        GETDATE() AS EventDate,        -- Current date and time
        FORMATMESSAGE(
            '%s tried to delete row with Key =[%s] in Table Studen' ,
            SYSTEM_USER, CAST(d.St_Id as NVARCHAR)
        ) AS Note
	from Deleted d

-- check test case :
delete from Student where St_Id = 5
select * from StudentAudit
----------------------------------------------------------------------------------------------
-- 22.	Write a query to rank the students according to their ages in each dept without gapping in ranking.use ITI
Select *  , 
DENSE_RANK() over (Partition by Dept_Id order by St_Age) AS RANK
from Student 


-- 23.	 Write a query to select the all highest two salaries for instructors in Each Department who have salaries. 
--sing one of Ranking Functions”.use ITI

Select Dept_Id , Salary
from (Select Dept_Id , Salary , DENSE_RANK() over (Partition by Dept_Id Order by Salary DESC) as RN
from Instructor) as Ranking
where RN between 1 and 2
-----------------------------------
-- 24.	Try to create index on column (Hiredate) that allow u to cluster the data in table Department. What will happen?
Create clustered index HiredateCluster 
ON Department(Manager_hiredate)
-- Cannot create more than one clustered index on table 'Department'.
-- Drop the existing clustered index 'PK_Department' before creating another.

-- instead of : 
Create nonclustered index HiredateCluster 
ON Department(Manager_hiredate)

select*from Department
----------------------------------------------------------------------

-- 25.	Try to create index that allow u to enter unique ages in student table.What will happen?
Select*from Student

Create unique index Uk_Cluster
On Student(St_Age)

-- The CREATE UNIQUE INDEX statement terminated because a duplicate key was found for the object name 'dbo.Student' 
-- and the index name 'Uk_Cluster'. The duplicate key value is (<NULL>).
-- The statement has been terminated.
----------------------------------------------------------------------
-- 26.	create a non-clustered index on column(Dept_Manager) that allows you to enter a unique instructor id in the table Department.
select * from Department

CREATE NONCLUSTERED INDEX IX_Dept_Manager 
ON Department (Dept_Manager);

-- 1.	Display all the data from the Employee table as an XML document “Use XML Raw”. Use company DB 
--  A)	Elements
--  B)	Attributes

-- A) Use XML Raw (Attributes)
Select*from Employee
FOR XML RAW 

-- B) Use XML Raw (Elements )
Select*from Employee
FOR XML RAW ('Employee') , elements

-- 2.	Display Each Department Name with its instructors. “Use ITI DB”
-- A)	Use XML Raw
-- B)	Use XML Auto
-- C)	Use XML Path


-- A)	Use XML Raw
select Dept_Name,Ins_Name 
from Instructor S JOIn Department D
ON S.Dept_Id = D.Dept_Id
for xml raw 


-- B)	Use XML Auto
select Dept_Name,Ins_Name 
from Instructor  JOIn Department 
ON Instructor.Dept_Id = Department.Dept_Id
for xml auto


-- C)	Use XML Path
select Dept_Name     "@Department_Name",
Ins_Name             "Instructor_Name"
from Instructor  JOIn Department 
ON Instructor.Dept_Id = Department.Dept_Id
for xml path ('Department_Ins')

------------------------------------------------------------------
/*
Memory Management:

Each time you call sp_xml_preparedocument, SQL Server allocates memory to store the internal representation of the XML document.
If you don't release it using sp_xml_removedocument, the memory remains allocated, which can lead to memory leaks or excessive memory usage,
especially if you process multiple XML documents.
*/
----------------------------------------------------------
-- 27 .	find ` of times that Amr appeared after Ahmed in st_Fname column one time
-- Assuming your table name is 'Students' and column is 'st_Fname'

DECLARE c5 CURSOR FOR 
SELECT 
    St_Fname,  LEAD(St_Fname) OVER (ORDER BY st_ID) AS 'NextName'
FROM Student
FOR READ ONLY;


DECLARE @St_Fname VARCHAR(20), @NextName VARCHAR(20), @count INT = 0;

OPEN c5 ;
FETCH c5 INTO @St_Fname, @NextName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (@St_Fname = 'Ahmed' AND @NextName = 'Amr')
    BEGIN
        SET @count = @count + 1;
    END;

    FETCH  c5 INTO @St_Fname, @NextName;
END;

SELECT @count AS CountOfOccurrences;

CLOSE c5;
DEALLOCATE c5;


-- Alternative Without Cursor:

SELECT COUNT(*)
FROM (
    SELECT 
        St_Fname, LEAD(St_Fname) OVER (ORDER BY st_ID) AS lead
    FROM Student
) SubQuery
WHERE St_Fname = 'Ahmed' AND lead = 'Amr';
--------------------------------------------------------------------
-- 28 .	Using cursor, reset every first name of student that is null to ‘no first name’.updates
-- Declare the cursor
DECLARE C6 CURSOR 
FOR
   SELECT St_Fname FROM Student
FOR UPDATE OF St_Fname;

-- Declare variables
DECLARE @Name VARCHAR(20);

-- Open the cursor
OPEN C6;

-- Fetch the first row
FETCH NEXT FROM C6 INTO @Name;

-- Loop through the rows
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if the value is NULL
    IF @Name IS NULL
    BEGIN
        -- Update the current row
        UPDATE Student
        SET St_Fname = 'no first name'
        WHERE CURRENT OF C6;  -- to>change only this row >>>>>>>>>>>>>>>>>>.
    END;

    -- Fetch the next row
    FETCH NEXT FROM C6 INTO @Name;
END;

-- Close and deallocate the cursor
Select St_Fname from Student
CLOSE C6;
DEALLOCATE C6;
-----------------------------------------------------------------------------------------------------------------------
-- 29 . make 3 types of backups 

-- Apply full backup
--  FORMAT --> When you want a completely new backup instead of adding to an old one.
-- If INIT is not used, SQL Server appends the new backup to the same file.

BACKUP DATABASE FCAI  
TO DISK = 'D:\ITI\SQL\05.Advanced SQL Server Assignments\FCAI-Project\FCAI_Full.bak'  
WITH FORMAT, INIT, NAME = 'FCAI_Full';


-- Apply Differential backup
BACKUP DATABASE FCAI  
TO DISK = 'D:\ITI\SQL\05.Advanced SQL Server Assignments\FCAI-Project\FCAI_Diff.bak'  
WITH DIFFERENTIAL, NAME = 'FCAI_Diff';

-- Apply  Transaction Log Backup 
BACKUP LOG FCAI  
TO DISK = 'D:\ITI\SQL\05.Advanced SQL Server Assignments\FCAI-Project\FCAI_Log.trn'  
WITH INIT, NAME = 'FCAI_Log';


-----------------------------
--30.try make login and user for FCAI DB on Student table allow user to make select for St_id, St_Fname 
--  prevent user from Update St_Lname


-- 1   -- right click on server name 
    -- properties
    -- Security
    -- SQL server and windows Authentication mode
    -- Restart server  


 -- 2  -- In my server choose : Security
   -- right click on Logins
   -- New login 
   -- SQL server login 
   -- give name and remove enforcement (Optional)

-- 3  -- choose DB you need to make user access 
   -- Security
   -- right click on Users 
   -- New user 
   -- wrire the name of user 



-- 4  -- disconnect and connect to user using name and password(SQL Authentication)

--5  -- attach the user with schema
   -- double click on the schema
   -- permission
   -- choose user
   -- OK
   -- choose what ( grant) and what (deny)

--6  -- disconnect and connect to user using name and password(SQL Authentication)


--- Using SQL Script ---
-- 1
USE master;
CREATE LOGIN [Iman_FCAI] WITH PASSWORD = '1234';

USE FCAI;
CREATE USER [Iman_FCAI] FOR LOGIN [Iman_FCAI];

GRANT SELECT (St_Id, St_Fname) ON Student TO [Iman_FCAI];
DENY UPDATE (St_Lname) ON Student TO [Iman_FCAI];

-- Verify permissions:
EXECUTE AS USER = 'Iman_FCAI';
SELECT * FROM fn_my_permissions('Student', 'OBJECT');  
REVERT;



-- 4
SELECT * FROM fn_my_permissions('Student', 'OBJECT');  
--fn_my_permissions returns permissions of the current session user.
--If you need to check another user's permissions, you must first switch to that user using EXECUTE AS.
EXECUTE AS USER = 'Iman@FCAI';  
SELECT * FROM fn_my_permissions('Student', 'OBJECT');  
REVERT;  
