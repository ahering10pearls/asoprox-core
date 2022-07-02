--
-- Script was generated by Devart dbForge Studio 2020 for MySQL, Version 9.0.897.0
-- Product home page: http://www.devart.com/dbforge/mysql/studio
-- Script date 7/2/2022 12:24:02 PM
-- Server version: 8.0.29
-- Client version: 4.1
--

-- 
-- Disable foreign keys
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Set SQL mode
-- 
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

DROP DATABASE IF EXISTS `asoprox-core-db`;

CREATE DATABASE `asoprox-core-db`
	CHARACTER SET utf8mb4
	COLLATE utf8mb4_0900_ai_ci;

--
-- Set default database
--
USE `asoprox-core-db`;

--
-- Create table `admins`
--
CREATE TABLE admins (
  admin_id INT NOT NULL AUTO_INCREMENT,
  puesto VARCHAR(255) NOT NULL,
  PRIMARY KEY (admin_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 7,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

--
-- Create table `members`
--
CREATE TABLE members (
  member_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  personal_email VARCHAR(255) DEFAULT NULL,
  id BIGINT NOT NULL,
  initial_date DATE NOT NULL DEFAULT (now()),
  account_access TINYINT(1) NOT NULL DEFAULT 1,
  admin INT DEFAULT NULL,
  date_updated DATETIME DEFAULT NULL,
  date_created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  inactive TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (member_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 32,
AVG_ROW_LENGTH = 528,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

--
-- Create foreign key
--
ALTER TABLE members 
  ADD CONSTRAINT FK_members_admin FOREIGN KEY (admin)
    REFERENCES admins(admin_id);

DELIMITER $$

--
-- Create procedure `getMember`
--
CREATE 

PROCEDURE getMember(IN pMemberId INT)
BEGIN

  IF pMemberId > 0 THEN
SELECT
  `members`.`member_id`,
  `members`.`full_name`,
  `members`.`email`,
  `members`.`personal_email`,
  `members`.`id`,
  `members`.`initial_date`,
  `members`.`account_access`,
  `members`.`date_created`,
  `members`.`inactive`
FROM `members`
WHERE `members`.`inactive` = 0
AND `members`.`member_id` = pMemberId
;

ELSEIF pMemberId = -1 THEN

SELECT
  `members`.`member_id`,
  `members`.`full_name`
FROM `members`
WHERE `members`.`inactive` = 0
ORDER BY `full_name` ASC
;

ELSE

SELECT
  `members`.`member_id`,
  `members`.`full_name`,
  `members`.`email`,
  `members`.`personal_email`,
  `members`.`id`,
  `members`.`initial_date`,
  `members`.`account_access`,
  `members`.`date_created`,
  `members`.`inactive`
FROM `members`
WHERE `members`.`inactive` = 0
ORDER BY `full_name` ASC
;

END IF
;

END
$$

--
-- Create procedure `getAuthenticateUser`
--
CREATE 

PROCEDURE getAuthenticateUser(
IN pEmail VARCHAR(200)
)
BEGIN

SELECT
  `member_id` AS `id`,
  `full_name`,
  `email`,
  `personal_email`
FROM `members`
WHERE `email` = pEmail
AND `inactive` = 0
;

END
$$

--
-- Create procedure `crudMember`
--
CREATE 

PROCEDURE crudMember(

IN pMemberId INT, 
IN pFullName VARCHAR(255), 
IN pEmail VARCHAR(255),
IN pPersonalEmail VARCHAR(255),
IN pId BIGINT, 
IN pInitialDate DATE, 
IN pAccountAccess TINYINT,
IN pInactive TINYINT

)
BEGIN

CASE
  WHEN CAST(pMemberId AS UNSIGNED) > 0 THEN
    IF (LENGTH(pFullName)>0 
        OR LENGTH(pEmail)>0 
        OR LENGTH(pPersonalEmail)>0 
        OR pId > 0 
        ) AND pInactive = 0
      THEN /** Update */

    UPDATE `members`
    SET `full_name` = pFullName,
        `email` = pEmail,
        `personal_email` = pPersonalEmail,
        `id` = pId,
        `initial_date` = pInitialDate,
        `account_access` = pAccountAccess,
        `date_updated` = CURRENT_TIMESTAMP
    WHERE `member_id` = pMemberId
    ;

    ELSEIF LENGTH(pFullName) = 0
      AND LENGTH(pEmail) = 0
      AND LENGTH(pPersonalEmail) = 0
      AND pId = 0
      AND pAccountAccess = 0
      AND pInactive = 1 THEN /** Delete */

    UPDATE `members`
    SET `inactive` = 1,
        `account_access` = 0,
        `date_updated` = CURRENT_TIMESTAMP
    WHERE `member_id` = pMemberId
    ;

    END IF
    ;

  ELSE /** Insert */

    IF NOT EXISTS ( SELECT
      1
    FROM `members` AS `m`
    WHERE `m`.`full_name` = pFullName
    AND `m`.`personal_email` = pPersonalEmail
    AND `m`.`id` = pId
    AND `m`.`initial_date` = pInitialDate) THEN

  INSERT INTO `members` (`full_name`, `email`, `personal_email`, `id`, `initial_date`)
    VALUES (pFullName, pEmail, pPersonalEmail, pId, pInitialDate)
  ;

  END IF
  ;

END CASE;

END
$$

DELIMITER ;

--
-- Create table `statements`
--
CREATE TABLE statements (
  statement_id INT NOT NULL AUTO_INCREMENT,
  member_id INT NOT NULL,
  entry_date DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  entry_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
  company_match_amount DECIMAL(15, 2) NOT NULL,
  date_updated DATETIME DEFAULT NULL,
  date_created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  inactive TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (statement_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 1,
AVG_ROW_LENGTH = 4096,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

--
-- Create foreign key
--
ALTER TABLE statements 
  ADD CONSTRAINT FK_statements_member_id FOREIGN KEY (member_id)
    REFERENCES members(member_id);

DELIMITER $$

--
-- Create procedure `getStatement`
--
CREATE 

PROCEDURE getStatement(
IN pMemberId INT,
IN pSummary TINYINT
)
BEGIN

  IF pMemberId > 0 THEN

    IF pSummary = 0 THEN

SELECT
  `s`.`statement_id`,
  `s`.`member_id`,
  `s`.`entry_amount`,
  `s`.`company_match_amount`,
  `s`.`entry_date`,
  `s`.`date_updated`,
  `s`.`date_created`
FROM `statements` AS `s`
  LEFT JOIN `members` AS `m`
    ON (`s`.`member_id` = `m`.`member_id`)
WHERE `s`.`member_id` = pMemberId
AND `s`.`inactive` = 0
;

ELSE

SELECT
  `t`.`member_id`,
  `t`.`full_name`,
  COALESCE(SUM(`t`.`entry_amount`), 0) AS `entry_amount`,
  COALESCE(SUM(`t`.`company_match_amount`), 0) AS `company_match_amount`,
  (SELECT
      `entry_date`
    FROM `statements`
    WHERE `member_id` = `t`.`member_id`
    ORDER BY `entry_date` DESC
    LIMIT 1) AS `entry_date`
FROM (SELECT
    `s`.`member_id`,
    `m`.`full_name`,
    SUM(`s`.`entry_amount`) AS `entry_amount`,
    SUM(`s`.`company_match_amount`) AS `company_match_amount`
  FROM `members` AS `m`
    LEFT JOIN `statements` AS `s`
      ON (`m`.`member_id` = `s`.`member_id`)
  WHERE `s`.`member_id` = pMemberId
  AND `s`.`inactive` = 0
  GROUP BY `s`.`member_id`,
           `s`.`entry_date`,
           `m`.`full_name`) AS `t`
WHERE `t`.`member_id` = pMemberId
GROUP BY `t`.`member_id`,
         `t`.`full_name`
ORDER BY `t`.`full_name` ASC
;

END IF
;

ELSE

    IF pSummary = 0 THEN

SELECT
  `t`.`member_id`,
  `t`.`full_name`,
  COALESCE(SUM(`t`.`entry_amount`), 0) AS `entry_amount`,
  COALESCE(SUM(`t`.`company_match_amount`), 0) AS `company_match_amount`,
  (SELECT
      `entry_date`
    FROM `statements`
    WHERE `member_id` = `t`.`member_id`
    ORDER BY `entry_date` DESC
    LIMIT 1) AS `entry_date`
FROM (SELECT
    `s`.`member_id`,
    `m`.`full_name`,
    SUM(`s`.`entry_amount`) AS `entry_amount`,
    SUM(`s`.`company_match_amount`) AS `company_match_amount`
  FROM `members` AS `m`
    LEFT JOIN `statements` AS `s`
      ON (`m`.`member_id` = `s`.`member_id`)
  WHERE `s`.`inactive` = 0
  GROUP BY `s`.`member_id`,
           `m`.`full_name`) AS `t`
GROUP BY `t`.`entry_amount`,
         `t`.`member_id`,
         `t`.`full_name`
ORDER BY `t`.`full_name` ASC
;

ELSE

SELECT
  COALESCE(SUM(`t`.`entry_amount`), 0) AS `entry_amount`,
  COALESCE(SUM(`t`.`company_match_amount`), 0) AS `company_match_amount`
FROM (SELECT
    SUM(`s`.`entry_amount`) AS `entry_amount`,
    SUM(`s`.`company_match_amount`) AS `company_match_amount`
  FROM `members` AS `m`
    LEFT JOIN `statements` AS `s`
      ON (`m`.`member_id` = `s`.`member_id`)
  WHERE `s`.`inactive` = 0) AS `t`
GROUP BY `t`.`entry_amount`
;

END IF
;

END IF
;

END
$$

--
-- Create procedure `crudIndividualStatement`
--
CREATE 

PROCEDURE crudIndividualStatement(
  IN pStatementId INT,
  IN pMemberId INT,
  IN pEntryDate DATE,
  IN pEntryAmount DECIMAL(15,2), 
  IN pCompanyMatchAmount DECIMAL(15,2)
)
BEGIN

  IF pStatementId = 0 THEN

INSERT INTO `statements` (`member_id`, `entry_date`, `entry_amount`, `company_match_amount`)
  VALUES (pMemberId, pEntryDate, pEntryAmount, pCompanyMatchAmount)
;
SELECT
  1 AS `status`;

ELSE

    IF pMemberId=0 AND pEntryAmount=0 AND pCompanyMatchAmount=0 THEN

UPDATE `statements`
SET `inactive` = 1,
    `date_updated` = CURRENT_TIMESTAMP
WHERE `statement_id` = pStatementId
;

ELSE

UPDATE `statements`
SET `entry_date` = pEntryDate,
    `entry_amount` = pEntryAmount,
    `company_match_amount` = pCompanyMatchAmount,
    `date_updated` = CURRENT_TIMESTAMP
WHERE `statement_id` = pStatementId
;

END IF
;

SELECT
  1 AS `status`;

END IF
;

END
$$

DELIMITER ;

--
-- Create table `policies`
--
CREATE TABLE policies (
  policy_id INT NOT NULL AUTO_INCREMENT,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(700) DEFAULT NULL,
  protected TINYINT(1) NOT NULL DEFAULT 0,
  inactive TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (policy_id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 5,
AVG_ROW_LENGTH = 16384,
CHARACTER SET utf8mb4,
COLLATE utf8mb4_0900_ai_ci;

DELIMITER $$

--
-- Create procedure `getUserPolicies`
--
CREATE 

PROCEDURE getUserPolicies(
IN pMemberId INT
)
BEGIN

  DROP TEMPORARY TABLE IF EXISTS `Policy`;
  CREATE TEMPORARY TABLE IF NOT EXISTS `Policy` (
    `code` VARCHAR(50)
  );

  IF EXISTS ( SELECT
    1
  FROM `members`
  WHERE `member_id` = pMemberId) THEN

INSERT INTO `Policy`
  SELECT
    `policies`.`code`
  FROM `policies`
  WHERE `policy_id` = 3
;

END IF;

  IF EXISTS ( SELECT
    1
  FROM `members` AS `m`
  WHERE `m`.`admin` IS NOT NULL) THEN

INSERT INTO `Policy`
  SELECT
    `policies`.`code`
  FROM `policies`
  WHERE `policy_id` = 2
;
END IF;

SELECT
  *
FROM `Policy`
;

END
$$

--
-- Create procedure `getDateRange`
--
CREATE 

PROCEDURE getDateRange()
BEGIN
	DROP TEMPORARY TABLE IF EXISTS `Variables`;
    CREATE TEMPORARY TABLE IF NOT EXISTS `Variables` AS (SELECT
    @now := NOW() AS `now`,
    @start_day := LAST_DAY(@now - INTERVAL 6 MONTH) + INTERVAL 15 DAY AS `first_day`,
    @last_day := CASE WHEN DAY(LAST_DAY(@start_day)) IN (30, 31) THEN DATE(CONCAT(YEAR(@start_day), '-', MONTH(@start_day), '-30')) ELSE DATE(CONCAT(YEAR(@start_day), '-', MONTH(@start_day), '-', (DAY(LAST_DAY(@start_day))))) END AS `last_day`);

	DROP TEMPORARY TABLE IF EXISTS `FiveIn4Calendar`;
	CREATE TEMPORARY TABLE IF NOT EXISTS `FiveIn4Calendar` (
		`entry_date` DATE,
		PRIMARY KEY (`entry_date`), 
    INDEX IDX_FiveIn4Calendar (`entry_date`)
	) AS (SELECT
    (@start_day + INTERVAL d.num - 1 MONTH) AS `entry_date`
  FROM (SELECT
      @num := @num + 1 `num`
    FROM information_schema.columns,
         (SELECT
             @num := 0) n
    LIMIT 6) AS d);

INSERT INTO `FiveIn4Calendar` (`entry_date`)
  SELECT
    CASE WHEN DATE_FORMAT(LAST_DAY((@start_day + INTERVAL d.num - 1 MONTH)), '%d') < 30 THEN LAST_DAY((@start_day + INTERVAL d.num - 1 MONTH)) ELSE DATE_FORMAT(DATE(CONCAT(DATE_FORMAT((@start_day + INTERVAL d.num - 1 MONTH), '%Y-%m'), '-30')), '%Y-%m-%d') END AS `entry_date`
  FROM (SELECT
      @num := @num + 1 `num`
    FROM information_schema.columns,
         (SELECT
             @num := 0) n
    LIMIT 6) AS d
;

SELECT
  `entry_date`
FROM `FiveIn4Calendar`
ORDER BY `entry_date` DESC
;

END
$$

DELIMITER ;

-- 
-- Dumping data for table admins
--
INSERT INTO admins VALUES
(1, 'Presidencia'),
(2, 'VidePresidencia'),
(3, 'Secretariado'),
(4, 'Tesorería'),
(5, 'Vocalía'),
(6, 'Fiscalía');

-- 
-- Dumping data for table members
--
INSERT INTO members VALUES
(1, 'Laura Pamela Lara Delgado', 'laura.lara@10pearls.com', NULL, 603480773, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(2, 'Alberto Hering Guzman', 'alberto.hering@10pearls.com', NULL, 108320275, '2022-06-26', 1, 2, NULL, '2018-01-01 00:00:00', 0),
(3, 'Kenneth Mauricio Granados Madrigal', 'kenneth.granados@10pearls.com ', NULL, 115190963, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(4, 'Alejandra Tatiana Gil Calderon', 'alejandra.gil@10pearls.com', NULL, 116350542, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(5, 'Ronald Alfredo De San Martin Brenes Bonilla', 'ronald.brenes@10pearls.com', NULL, 106050652, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(6, 'Marcela Aguilar Cabezas', 'marcela.aguilar@10pearls.com ', NULL, 113310755, '2022-06-26', 1, 6, NULL, '2018-01-01 00:00:00', 0),
(7, 'Fabricio Jose Duarte Picado', 'fabricio.duarte@10pearls.com', NULL, 109840918, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(8, 'Sebastian Antonio Arroyo Viquez', 'sebastian.arroyo@10pearls.com', NULL, 113990265, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(9, 'Claudia Melania Quesada Acuña', 'claudia.quesada@10pearls.com', NULL, 110980227, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(10, 'Evelyn Vanessa Hernandez Blanco', 'evelyn.hernandez@10pearls.com', NULL, 112270232, '2022-06-26', 1, 3, NULL, '2018-01-01 00:00:00', 0),
(11, 'Jonathan Watson Coto', 'jonathan.watson@10pearls.com', NULL, 115040108, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(12, 'Michael Francisco Gonzalez Sanchez', 'michael.gonzalez@10pearls.com', NULL, 110210222, '2022-06-26', 1, 1, NULL, '2018-01-01 00:00:00', 0),
(13, 'Emilia Maria Vega Lacayo', 'emilia.vega@10pearls.com', NULL, 701290225, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(14, 'Luis Diego Zuñiga Vargas', 'diego.zuniga@10pearls.com', NULL, 207520283, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(15, 'Raquel Lugo Arguedas', 'raquel.lugo@10pearls.com', NULL, 116210329, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(16, 'Jorge Antonio Solano Morales', 'jorge.solano@10pearls.com', NULL, 110790041, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(17, 'Norvin Alberto Martinez Romero', 'norvin.martinez@10pearls.com', NULL, 155814134213, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(18, 'Pablo Esteban Meza Ulloa', 'pablo.meza@10pearls.com', NULL, 114120949, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(19, 'Denia Stephany Calvo Barrantes', 'denia.calvo@10pearls.com', NULL, 206390006, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(20, 'Jeudrin Ali Marchena Sanchez', 'jeudrin.marchena@10pearls.com', NULL, 504000598, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(21, 'Dennis Josue Salazar Rivera', 'dennis.salazar@10pearls.com', NULL, 604380802, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(22, 'Karla De Los Angeles Fernandez Carvajal', 'karla.fernandez@10pearls.com', NULL, 109750820, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(23, 'Xavier Alexander Marchena Calderon', 'xavier.marchena@10pearls.com', NULL, 116050072, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 1),
(24, 'Tasha Kalila Steward Vargas', 'tasha.steward@10pearls.com', NULL, 701600038, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(25, 'Carlos Augusto Osejo Bermudez', 'carlos.osejo@10pearls.com', NULL, 115140709, '2022-06-26', 1, 5, NULL, '2018-01-01 00:00:00', 0),
(26, 'Jose Ricardo Chacon Vargas', 'ricardo.chacon@10pearls.com', NULL, 207370971, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(27, 'Nathalie Vanessa Soto Camacho', 'nathalie.soto@10pearls.com', NULL, 604230343, '2022-06-26', 1, 4, NULL, '2018-01-01 00:00:00', 0),
(28, 'Lissette Zamora Monge', 'lissette.zamora@10pearls.com', NULL, 603820091, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(29, 'Annes Bibiana Calvo Badilla', 'viviana.calvo@10pearls.com', NULL, 502990715, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(30, 'Jonathan Enrique Fernandez Seravalli', 'jonathan.fernandez@10pearls.com', NULL, 112750973, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0),
(31, 'Emanuel Ulises Santamaria Calderon', 'emanuel.santamaria@10pearls.com', NULL, 702060363, '2022-06-26', 1, NULL, NULL, '2018-01-01 00:00:00', 0);

-- 
-- Dumping data for table policies
--
INSERT INTO policies VALUES
(1, 'super_admin', 'Super Admin', 'System admin user has full unrestricted access', 1, 0),
(2, 'admin', 'Admin', 'Admin user has full access', 1, 0),
(3, 'public', 'Public', 'User has access to all non-policy-protected areas if any', 1, 0);

-- 
-- Restore previous SQL mode
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Enable foreign keys
-- 
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;