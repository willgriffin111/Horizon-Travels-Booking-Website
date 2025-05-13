-- MySQL dump 10.13  Distrib 8.0.31, for macos12.6 (x86_64)
--
-- Host: 127.0.0.1    Database: HorizonTravels
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accountHolder`
--
USE HorizonTravels;
DROP TABLE IF EXISTS `accountHolder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accountHolder` (
  `idAccountHolder` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(45) NOT NULL,
  `lastName` varchar(45) NOT NULL,
  `dob` date NOT NULL,
  `email` varchar(50) NOT NULL,
  `passwrd` varchar(128) NOT NULL,
  `accountHolderType` varchar(8) NOT NULL DEFAULT 'standard',
  `accountModified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `accountCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idAccountHolder`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accountHolder`
--

/*!40000 ALTER TABLE `accountHolder` DISABLE KEYS */;
INSERT INTO `accountHolder` VALUES (12,'Will','Griffin','2023-03-13','admin@admin.com','$5$rounds=535000$dA54NorXhlvlBH1M$zE7SfoRUedhmsDNvC8625UXvRTmpzimS9D2eJgXzEdC','admin','2023-05-01 13:56:29','2023-03-13 17:06:18'),(13,'Flora','Macdonald','2003-08-05','floramacdonald2003@gmail.com','$5$rounds=535000$YrUJspT/R0uaPAea$PokT78yQK2WJZdIC7eVgz/v.5F7kpsAPRgX8XIuetoD','standard','2023-05-01 13:56:34','2023-03-17 17:14:47'),(14,'Will','Griffin','2003-06-02','Willbot58@outlook.com','$5$rounds=535000$8Ngu/sUJEGTFXekm$Iz6b9.DXEB3EpmbSFgqXGwJnNiocY.e2fUTjlx55psB','standard','2023-05-01 13:56:39','2023-03-20 20:47:47'),(20,'Will','Griffin','2003-06-02','standard@standard.com','$5$rounds=535000$Nj/5Nx0psa/n4UMH$ajSeEHbyJA1tupg9MFqfbXIHq/u2G1KV//kL1dV4Qk6','standard','2023-05-01 13:56:43','2023-04-24 18:03:50'),(23,'will','griffin','2003-01-01','test@test.com','$5$rounds=535000$Ay.1hAxC0uh1aWVf$MW6HMDAjuXRsCJbV.WKYrWFq0iT0kWPS2EjYMbLnSG4','standard','2023-05-01 13:56:47','2023-04-28 16:36:55');
/*!40000 ALTER TABLE `accountHolder` ENABLE KEYS */;

--
-- Table structure for table `booking`
--

DROP TABLE IF EXISTS `booking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking` (
  `idbooking` int NOT NULL AUTO_INCREMENT,
  `accountHolder_idAccountHolder` int NOT NULL,
  `travel_idtravel` int NOT NULL,
  `bookingDate` date NOT NULL,
  `travelClass` varchar(9) NOT NULL,
  `quantity` int NOT NULL,
  `totalPrice` float NOT NULL,
  `bookingCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `bookingModified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idbooking`),
  KEY `fk_booking_accountHolder1_idx` (`accountHolder_idAccountHolder`),
  KEY `fk_booking_travel1_idx` (`travel_idtravel`),
  CONSTRAINT `fk_booking_accountHolder1` FOREIGN KEY (`accountHolder_idAccountHolder`) REFERENCES `accountHolder` (`idAccountHolder`),
  CONSTRAINT `fk_booking_travel1` FOREIGN KEY (`travel_idtravel`) REFERENCES `travel` (`idtravel`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1776 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking`
--

/*!40000 ALTER TABLE `booking` DISABLE KEYS */;
INSERT INTO `booking` VALUES (1769,12,12,'2023-04-28','business',1,120,'2023-04-28 20:41:40','2023-04-28 20:41:40'),(1770,12,13,'2023-04-28','business',1,120,'2023-04-28 20:41:40','2023-04-28 20:41:40');
/*!40000 ALTER TABLE `booking` ENABLE KEYS */;

--
-- Table structure for table `travel`
--

DROP TABLE IF EXISTS `travel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `travel` (
  `idtravel` int NOT NULL AUTO_INCREMENT,
  `travelType` varchar(5) NOT NULL,
  `departureLocation` varchar(60) NOT NULL,
  `departureTime` time NOT NULL,
  `arrivalLocation` varchar(60) NOT NULL,
  `arrivalTime` time NOT NULL,
  `travelTime` time NOT NULL,
  `price` float NOT NULL,
  `travelCreated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `travelModified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idtravel`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `travel`
--

/*!40000 ALTER TABLE `travel` DISABLE KEYS */;
INSERT INTO `travel` VALUES (1,'air','Newcastle','16:45:00','Bristol','18:00:00','01:15:00',80,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(2,'air','Bristol','08:00:00','Newcastle','09:15:00','01:15:00',80,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(3,'air','Cardiff','06:00:00','Edinburgh','07:30:00','01:30:00',80,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(4,'air','Bristol','11:30:00','Manchester','12:30:00','01:00:00',60,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(5,'air','Manchester','12:20:00','Bristol','13:20:00','01:00:00',60,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(6,'air','Bristol','07:40:00','London','08:20:00','00:40:00',60,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(7,'air','London','11:00:00','Manchester','12:20:00','01:20:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(8,'air','Manchester','12:20:00','Glasgow','13:30:00','01:10:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(9,'air','Bristol','07:40:00','Glasgow','08:45:00','01:05:00',90,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(10,'air','Glasgow','14:30:00','Newcastle','15:45:00','01:15:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(11,'air','Newcastle','16:15:00','Manchester','17:05:00','00:50:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(12,'air','Manchester','18:25:00','Bristol','19:30:00','01:05:00',60,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(13,'air','Bristol','06:20:00','Manchester','07:20:00','01:00:00',60,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(14,'air','Portsmouth','12:00:00','Dundee','14:00:00','02:00:00',100,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(15,'air','Dundee','10:00:00','Portsmouth','12:00:00','02:00:00',100,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(16,'air','Edinburgh','18:30:00','Cardiff','20:00:00','01:30:00',80,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(17,'air','Southampton','12:00:00','Manchester','13:30:00','01:30:00',70,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(18,'air','Manchester','19:00:00','Southampton','20:30:00','01:30:00',70,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(19,'air','Birmingham','16:00:00','Newcastle','17:30:00','01:30:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(20,'air','Newcastle','06:00:00','Birmingham','07:30:00','01:30:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(21,'air','Aberdeen','07:00:00','Portsmouth','09:00:00','02:00:00',75,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(22,'coach','Newcastle','16:45:00','Bristol','04:00:00','11:15:00',27,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(23,'coach','Bristol','08:00:00','Newcastle','19:15:00','11:15:00',27,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(24,'coach','Cardiff','06:00:00','Edinburgh','19:30:00','13:30:00',27,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(25,'coach','Bristol','11:30:00','Manchester','20:30:00','09:00:00',20,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(26,'coach','Manchester','12:20:00','Bristol','21:20:00','09:00:00',20,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(27,'coach','Bristol','07:40:00','London','13:40:00','06:00:00',20,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(28,'coach','London','11:00:00','Manchester','23:00:00','12:00:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(29,'coach','Manchester','12:20:00','Glasgow','22:50:00','10:30:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(30,'coach','Bristol','07:40:00','Glasgow','17:25:00','09:45:00',30,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(31,'coach','Glasgow','14:30:00','Newcastle','01:45:00','11:15:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(32,'coach','Newcastle','16:15:00','Manchester','23:45:00','07:30:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(33,'coach','Manchester','18:25:00','Bristol','04:10:00','09:45:00',20,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(34,'coach','Bristol','06:20:00','Manchester','15:20:00','09:00:00',20,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(35,'coach','Edinburgh','18:30:00','Cardiff','08:00:00','13:30:00',27,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(36,'coach','Southampton','12:00:00','Manchester','01:30:00','13:30:00',23,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(37,'coach','Manchester','19:00:00','Southampton','08:30:00','13:30:00',23,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(38,'coach','Birmingham','16:00:00','Newcastle','05:30:00','13:30:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(39,'coach','Newcastle','06:00:00','Birmingham','19:30:00','13:30:00',25,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(40,'train','Newcastle','16:45:00','Bristol','21:45:00','05:00:00',200,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(41,'train','Bristol','08:00:00','Newcastle','13:00:00','05:00:00',200,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(42,'train','Cardiff','06:00:00','Edinburgh','12:00:00','06:00:00',200,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(43,'train','Bristol','11:30:00','Manchester','15:30:00','04:00:00',150,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(44,'train','Manchester','12:20:00','Bristol','16:20:00','04:00:00',150,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(45,'train','Bristol','07:40:00','London','10:20:00','02:40:00',150,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(46,'train','London','11:00:00','Manchester','16:20:00','05:20:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(47,'train','Manchester','12:20:00','Glasgow','17:00:00','04:40:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(48,'train','Bristol','07:40:00','Glasgow','12:00:00','04:20:00',225,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(49,'train','Glasgow','14:30:00','Newcastle','19:30:00','05:00:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(50,'train','Newcastle','16:15:00','Manchester','19:35:00','03:20:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(51,'train','Manchester','18:25:00','Bristol','22:45:00','04:20:00',150,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(52,'train','Bristol','06:20:00','Manchester','10:20:00','04:00:00',150,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(53,'train','Edinburgh','18:30:00','Cardiff','00:30:00','06:00:00',200,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(54,'train','Southampton','12:00:00','Manchester','18:00:00','06:00:00',175,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(55,'train','Manchester','19:00:00','Southampton','01:00:00','06:00:00',175,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(56,'train','Birmingham','16:00:00','Newcastle','22:00:00','06:00:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(57,'train','Newcastle','06:00:00','Birmingham','12:00:00','06:00:00',188,'2023-04-24 17:51:29','2023-04-24 17:51:29'),(79,'coach','Cheltenham','22:11:12','bristol','22:11:15','22:10:52',200,'2023-04-28 22:10:55','2023-04-28 22:11:18');
/*!40000 ALTER TABLE `travel` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-05-01 13:58:12
