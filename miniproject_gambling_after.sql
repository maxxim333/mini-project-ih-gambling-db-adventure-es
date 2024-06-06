USE gambling_project;

-- Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta
SELECT Title, FirstName, LastName, DateOfBirth FROM Customer;

-- Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?
SELECT CustomerGroup, COUNT(CustID) FROM Customer
GROUP BY CustomerGroup;

-- Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?
SELECT *, `Account`.CurrencyCode FROM Customer
JOIN `Account` ON `Account`.CustID = Customer.CustID;

-- Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?
SELECT betting.Product, BetDate, SUM(Bet_Amt) AS Total_Sum FROM Betting
JOIN Product ON Product.classid = Betting.classid AND Product.categoryid = Betting.categoryid
group by Product, BetDate
ORDER BY Total_Sum;

-- Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?
SELECT betting.Product, BetDate, SUM(Bet_Amt)  FROM Betting
JOIN Product ON Product.classid = Betting.classid AND Product.categoryid = Betting.categoryid
WHERE BetDate >= 01/11/2012 AND betting.Product = "Sportsbook"
group by Product, BetDate
ORDER BY BetDate;

-- Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.
SELECT 
    `Account`.CurrencyCode,
    Customer.CustomerGroup,
    SUM(Bet_Amt) OVER (PARTITION BY `Account`.CurrencyCode, Customer.CustomerGroup) AS TotalBetAmount
FROM 
    Betting
JOIN 
    Product ON Product.classid = Betting.classid AND Product.categoryid = Betting.categoryid
JOIN  
    `Account` ON `Account`.AccountNo = Betting.AccountNo
JOIN  
    Customer ON `Account`.CustId = Customer.CustId
WHERE 
    BetDate >= '2012-12-01';



-- Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.
SELECT Customer.Title, Customer.FirstName, Customer.LastName, COUNT(Betting.AccountNo)  FROM `Account` 
LEFT JOIN Betting ON `Account`.AccountNo = Betting.AccountNo
JOIN Customer ON Customer.CustId = `Account`.CustId
WHERE Betting.BetDate BETWEEN 01/11/2012 AND 31/11/2012;

SELECT Customer.Title, Customer.FirstName, Customer.LastName, COALESCE(SUM(Betting.Bet_Amt), 0) AS TotalBetAmount FROM Customer
JOIN `Account` ON Customer.CustId = `Account`.CustId
LEFT JOIN Betting ON `Account`.AccountNo = Betting.AccountNo AND Betting.BetDate BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY Customer.Title, Customer.FirstName, Customer.LastName;

-- Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?
SELECT 
    AccountNo, 
    COUNT(DISTINCT Product) AS DistinctProductCount
FROM 
    Betting
GROUP BY 
    AccountNo;
    


SELECT 
    AccountNo
FROM 
    Betting
WHERE 
    Product IN ('Sportsbook', 'Vegas')
GROUP BY 
    AccountNo
HAVING 
    COUNT(DISTINCT Product) = 2;
    
-- Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada jugador y la suma de sus apuestas para ambos productos.


-- Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto favorito de cada jugador
WITH BetAmount AS (
    SELECT 
        AccountNo, 
        Product, 
        SUM(Bet_Amt) AS BetAmount
    FROM 
        Betting
    GROUP BY 
        AccountNo, 
        Product
), RankedBets AS (
    SELECT 
        AccountNo, 
        Product, 
        BetAmount,
        ROW_NUMBER() OVER (PARTITION BY AccountNo ORDER BY BetAmount DESC) AS `Rank`
    FROM 
        BetAmount
)
SELECT 
    AccountNo, 
    Product, 
    BetAmount
FROM 
    RankedBets
WHERE 
   `Rank` = 1;
   


-- Create the student table
CREATE TABLE IF NOT EXISTS student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    city VARCHAR(50),
    school_id INT,
    GPA DECIMAL(3, 2)
);

-- Insert data into the student table
INSERT INTO student (student_id, student_name, city, school_id, GPA) VALUES
(1001, 'Peter Brebec', 'New York', 1, 4.0),
(1002, 'John Goorgy', 'San Francisco', 2, 3.1),
(2003, 'Brad Smith', 'New York', 3, 2.9),
(1004, 'Fabian Johns', 'Boston', 5, 2.1),
(1005, 'Brad Cameron', 'Stanford', 1, 2.3),
(1006, 'Geoff Firby', 'Boston', 5, 1.2),
(1007, 'Johnny Blue', 'New Haven', 2, 3.8),
(1008, 'Johse Brook', 'Miami', 2, 3.4);



-- Pregunta 11: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA
SELECT student_name, GPA, RANK() OVER(ORDER BY GPA DESC) AS Ranked
FROM student
ORDER BY Ranked
LIMIT 5;

-- Create the school table
CREATE TABLE IF NOT EXISTS school (
    school_id INT PRIMARY KEY,
    school_name VARCHAR(100),
    city VARCHAR(50)
);

-- Insert data into the school table
INSERT INTO school (school_id, school_name, city) VALUES
(1, 'Stanford', 'Stanford'),
(2, 'University of California', 'San Francisco'),
(3, 'Harvard University', 'New York'),
(4, 'MIT', 'Boston'),
(5, 'Yale', 'New Haven'),
(6, 'University of Westminster', 'London'),
(7, 'Corvinus University', 'Budapest');


-- Pregunta 12: Escribe una consulta que devuelva el número de estudiantes en cada escuela. (¡una escuela debería estar en la salida incluso si no tiene estudiantes!)
SELECT school_name, COALESCE(COUNT(*), 0) AS number_of_students
FROM school
group by school_name;

-- Pregunta 13: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada universidad.
WITH rankedstudents AS (
SELECT
	student_name,
	GPA,
	school_name,
	ROW_NUMBER() OVER (PARTITION BY school_name ORDER BY GPA DESC) AS rn
FROM
	school
JOIN student ON school.school_id = student.school_id)
SELECT * FROM rankedstudents
WHERE rn BETWEEN 1 AND 3;
