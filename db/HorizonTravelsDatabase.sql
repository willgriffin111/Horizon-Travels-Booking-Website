
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
