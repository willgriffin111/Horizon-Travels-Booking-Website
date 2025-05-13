
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema horizontravels
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema horizontravels
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `horizontravels` DEFAULT CHARACTER SET utf8 ;
USE `horizontravels` ;

-- -----------------------------------------------------
-- Table `horizontravels`.`accountHolder`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `horizontravels`.`accountHolder` (
  `idAccountHolder` INT NOT NULL AUTO_INCREMENT,
  `firstName` VARCHAR(45) NOT NULL,
  `lastName` VARCHAR(45) NOT NULL,
  `dob` DATE NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  `passwrd` VARCHAR(128) NOT NULL,
  `accountHolderType` VARCHAR(8) NOT NULL DEFAULT 'standard',
  `accountModified` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `accountCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idAccountHolder`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `horizontravels`.`travel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `horizontravels`.`travel` (
  `idtravel` INT NOT NULL AUTO_INCREMENT,
  `travelType` VARCHAR(5) NOT NULL,
  `departureLocation` VARCHAR(60) NOT NULL,
  `departureTime` TIME NOT NULL,
  `arrivalLocation` VARCHAR(60) NOT NULL,
  `arrivalTime` TIME NOT NULL,
  `travelTime` TIME NOT NULL,
  `price` FLOAT NOT NULL,
  `travelCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `travelModified` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idtravel`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `horizontravels`.`booking`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `horizontravels`.`booking` (
  `idbooking` INT NOT NULL AUTO_INCREMENT,
  `accountHolder_idAccountHolder` INT NOT NULL,
  `travel_idtravel` INT NOT NULL,
  `bookingDate` DATE NOT NULL,
  `travelClass` VARCHAR(9) NOT NULL,
  `quantity` INT NOT NULL,
  `totalPrice` FLOAT NOT NULL,
  `bookingCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `bookingModified` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idbooking`),
  INDEX `fk_booking_accountHolder1_idx` (`accountHolder_idAccountHolder` ASC) VISIBLE,
  INDEX `fk_booking_travel1_idx` (`travel_idtravel` ASC) VISIBLE,
  CONSTRAINT `fk_booking_accountHolder1`
    FOREIGN KEY (`accountHolder_idAccountHolder`)
    REFERENCES `horizontravels`.`accountHolder` (`idAccountHolder`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_booking_travel1`
    FOREIGN KEY (`travel_idtravel`)
    REFERENCES `horizontravels`.`travel` (`idtravel`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
INSERT INTO travel (idtravel, TravelType, departureLocation, departureTime, arrivalLocation, arrivalTime, travelTime, price) 
VALUES 
(1, 'air', 'Newcastle', '16:45:00', 'Bristol', '18:00:00', '1:15:00', 80),
(2, 'air', 'Bristol', '8:00:00', 'Newcastle', '9:15:00', '1:15:00', 80),
(3, 'air', 'Cardiff', '6:00:00', 'Edinburgh', '7:30:00', '1:30:00', 80),
(4, 'air', 'Bristol', '11:30:00', 'Manchester', '12:30:00', '1:00:00', 60),
(5, 'air', 'Manchester', '12:20:00', 'Bristol', '13:20:00', '1:00:00', 60),
(6, 'air', 'Bristol', '7:40:00', 'London', '8:20:00', '0:40:00', 60),
(7, 'air', 'London', '11:00:00', 'Manchester', '12:20:00', '1:20:00', 75),
(8, 'air', 'Manchester', '12:20:00', 'Glasgow', '13:30:00', '1:10:00', 75),
(9, 'air', 'Bristol', '7:40:00', 'Glasgow', '8:45:00', '1:05:00', 90),
(10, 'air', 'Glasgow', '14:30:00', 'Newcastle', '15:45:00', '1:15:00', 75),
(11, 'air', 'Newcastle', '16:15:00', 'Manchester', '17:05:00', '0:50:00', 75),
(12, 'air', 'Manchester', '18:25:00', 'Bristol', '19:30:00', '1:05:00', 60),
(13, 'air', 'Bristol', '6:20:00', 'Manchester', '7:20:00', '1:00:00', 60),
(14, 'air', 'Portsmouth', '12:00:00', 'Dundee', '14:00:00', '2:00:00', 100),
(15, 'air', 'Dundee', '10:00:00', 'Portsmouth', '12:00:00', '2:00:00', 100),
(16, 'air', 'Edinburgh', '18:30:00', 'Cardiff', '20:00:00', '1:30:00', 80),
(17, 'air', 'Southampton', '12:00:00', 'Manchester', '13:30:00', '1:30:00', 70),
(18, 'air', 'Manchester', '19:00:00', 'Southampton', '20:30:00', '1:30:00', 70),
(19, 'air', 'Birmingham', '16:00:00', 'Newcastle', '17:30:00', '1:30:00', 75),
(20, 'air', 'Newcastle', '6:00:00', 'Birmingham', '7:30:00', '1:30:00', 75),
(21, 'air', 'Aberdeen', '7:00:00', 'Portsmouth', '9:00:00', '2:00:00', 75),
(22, 'coach', 'Newcastle', '16:45:00', 'Bristol', '4:00:00', '11:15:00', 27),
(23, 'coach', 'Bristol', '8:00:00', 'Newcastle', '19:15:00', '11:15:00', 27),
(24, 'coach', 'Cardiff', '6:00:00', 'Edinburgh', '19:30:00', '13:30:00', 27),
(25, 'coach', 'Bristol', '11:30:00', 'Manchester', '20:30:00', '9:00:00', 20),
(26, 'coach', 'Manchester', '12:20:00', 'Bristol', '21:20:00', '9:00:00', 20),
(27, 'coach', 'Bristol', '7:40:00', 'London', '13:40:00', '6:00:00', 20),
(28, 'coach', 'London', '11:00:00', 'Manchester', '23:00:00', '12:00:00', 25),
(29, 'coach', 'Manchester', '12:20:00', 'Glasgow', '22:50:00', '10:30:00', 25),
(30, 'coach', 'Bristol', '7:40:00', 'Glasgow', '17:25:00', '9:45:00', 30),
(31, 'coach', 'Glasgow', '14:30:00', 'Newcastle', '1:45:00', '11:15:00', 25),
(32, 'coach', 'Newcastle', '16:15:00', 'Manchester', '23:45:00', '7:30:00', 25),
(33, 'coach', 'Manchester', '18:25:00', 'Bristol', '4:10:00', '9:45:00', 20),
(34, 'coach', 'Bristol', '6:20:00', 'Manchester', '15:20:00', '9:00:00', 20),
(35, 'coach', 'Edinburgh', '18:30:00', 'Cardiff', '8:00:00', '13:30:00', 27),
(36, 'coach', 'Southampton', '12:00:00', 'Manchester', '1:30:00', '13:30:00', 23),
(37, 'coach', 'Manchester', '19:00:00', 'Southampton', '8:30:00', '13:30:00', 23),
(38, 'coach', 'Birmingham', '16:00:00', 'Newcastle', '5:30:00', '13:30:00', 25),
(39, 'coach', 'Newcastle', '6:00:00', 'Birmingham', '19:30:00', '13:30:00', 25),
(40, 'train', 'Newcastle', '16:45:00', 'Bristol', '21:45:00', '5:00:00', 200),
(41, 'train', 'Bristol', '8:00:00', 'Newcastle', '13:00:00', '5:00:00', 200),
(42, 'train', 'Cardiff', '6:00:00', 'Edinburgh', '12:00:00', '6:00:00', 200),
(43, 'train', 'Bristol', '11:30:00', 'Manchester', '15:30:00', '4:00:00', 150),
(44, 'train', 'Manchester', '12:20:00', 'Bristol', '16:20:00', '4:00:00', 150),
(45, 'train', 'Bristol', '7:40:00', 'London', '10:20:00', '2:40:00', 150),
(46, 'train', 'London', '11:00:00', 'Manchester', '16:20:00', '5:20:00', 188),
(47, 'train', 'Manchester', '12:20:00', 'Glasgow', '17:00:00', '4:40:00', 188),
(48, 'train', 'Bristol', '7:40:00', 'Glasgow', '12:00:00', '4:20:00', 225),
(49, 'train', 'Glasgow', '14:30:00', 'Newcastle', '19:30:00', '5:00:00', 188),
(50, 'train', 'Newcastle', '16:15:00', 'Manchester', '19:35:00', '3:20:00', 188),
(51, 'train', 'Manchester', '18:25:00', 'Bristol', '22:45:00', '4:20:00', 150),
(52, 'train', 'Bristol', '6:20:00', 'Manchester', '10:20:00', '4:00:00', 150),
(53, 'train', 'Edinburgh', '18:30:00', 'Cardiff', '0:30:00', '6:00:00', 200),
(54, 'train', 'Southampton', '12:00:00', 'Manchester', '18:00:00', '6:00:00', 175),
(55, 'train', 'Manchester', '19:00:00', 'Southampton', '1:00:00', '6:00:00', 175),
(56, 'train', 'Birmingham', '16:00:00', 'Newcastle', '22:00:00', '6:00:00', 188),
(57, 'train', 'Newcastle', '6:00:00', 'Birmingham', '12:00:00', '6:00:00', 188);

/*!40000 ALTER TABLE `accountHolder` DISABLE KEYS */;
INSERT INTO `accountHolder` VALUES (12,'Will','Griffin','2023-03-13','admin@admin.com','$5$rounds=535000$dA54NorXhlvlBH1M$zE7SfoRUedhmsDNvC8625UXvRTmpzimS9D2eJgXzEdC','admin','2023-05-01 13:56:29','2023-03-13 17:06:18'),(13,'Flora','Macdonald','2003-08-05','floramacdonald2003@gmail.com','$5$rounds=535000$YrUJspT/R0uaPAea$PokT78yQK2WJZdIC7eVgz/v.5F7kpsAPRgX8XIuetoD','standard','2023-05-01 13:56:34','2023-03-17 17:14:47'),(14,'Will','Griffin','2003-06-02','Willbot58@outlook.com','$5$rounds=535000$8Ngu/sUJEGTFXekm$Iz6b9.DXEB3EpmbSFgqXGwJnNiocY.e2fUTjlx55psB','standard','2023-05-01 13:56:39','2023-03-20 20:47:47'),(20,'Will','Griffin','2003-06-02','standard@standard.com','$5$rounds=535000$Nj/5Nx0psa/n4UMH$ajSeEHbyJA1tupg9MFqfbXIHq/u2G1KV//kL1dV4Qk6','standard','2023-05-01 13:56:43','2023-04-24 18:03:50'),(23,'will','griffin','2003-01-01','test@test.com','$5$rounds=535000$Ay.1hAxC0uh1aWVf$MW6HMDAjuXRsCJbV.WKYrWFq0iT0kWPS2EjYMbLnSG4','standard','2023-05-01 13:56:47','2023-04-28 16:36:55');
/*!40000 ALTER TABLE `accountHolder` ENABLE KEYS */;