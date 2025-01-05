-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)
--
-- Host: localhost    Database: RLVRelay
-- ------------------------------------------------------
-- Server version	8.0.40-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Command`
--

DROP TABLE IF EXISTS `Command`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Command` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Command` varchar(50) NOT NULL,
  `FunctionalCategoryID` int NOT NULL,
  `CommandTypeID` int NOT NULL,
  `IsObsolete` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `fk_Command_FunctionalCategory` (`FunctionalCategoryID`),
  KEY `fk_Command_CommandType` (`CommandTypeID`),
  CONSTRAINT `fk_Command_CommandType` FOREIGN KEY (`CommandTypeID`) REFERENCES `CommandType` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_Command_FunctionalCategory` FOREIGN KEY (`FunctionalCategoryID`) REFERENCES `FunctionalCategory` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=307 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Command`
--

LOCK TABLES `Command` WRITE;
/*!40000 ALTER TABLE `Command` DISABLE KEYS */;
INSERT INTO `Command` VALUES (1,'@acceptpermission=y/n/add/rem',10,2,0),(2,'@accepttp?:*=y/n/add/rem',7,2,0),(3,'@accepttprequest?:*=y/n/add/rem',7,2,0),(4,'@addattach?:*=y/n/add/rem',10,1,0),(5,'@addoutfit?:*=y/n/add/rem',10,1,0),(6,'@adjustheight:*=force',4,4,0),(7,'@allowidle=y/n/add/rem',17,1,0),(8,'@alwaysrun=y/n/add/rem',4,1,0),(9,'@attach:*=force',10,4,0),(10,'@attachover:*=force',10,4,0),(11,'@attachthis_except:*=y/n/add/rem',10,2,0),(12,'@camavdist:*=y/n/add/rem',5,1,0),(13,'@camdistmax:*=y/n/add/rem',5,1,0),(14,'@camdistmin:*=y/n/add/rem',5,1,0),(15,'@camdrawalphamax:*=y/n/add/rem',5,1,0),(16,'@camdrawalphamin:*=y/n/add/rem',5,1,0),(17,'@camdrawcolor:*=y/n/add/rem',5,1,0),(18,'@camdrawmax:*=y/n/add/rem',5,1,0),(19,'@camdrawmin:*=y/n/add/rem',5,1,0),(20,'@camtextures?:*=y/n/add/rem',5,1,0),(21,'@camunlock=y/n/add/rem',5,1,0),(22,'@camzoommax:*=y/n/add/rem',5,1,0),(23,'@camzoommin:*=y/n/add/rem',5,1,0),(24,'@chatnormal=y/n/add/rem',6,1,0),(25,'@chatshout=y/n/add/rem',6,1,0),(26,'@chatwhisper=y/n/add/rem',6,1,0),(27,'@clear',3,4,0),(28,'@clear=*',3,4,0),(29,'@defaultwear=y/n/add/rem',10,1,0),(30,'@denypermission=y/n/add/rem',10,2,0),(31,'@detach:*=force',10,4,0),(32,'@detach:*=y/n/add/rem',10,1,0),(33,'@detach=y/n/add/rem',10,1,0),(34,'@detachme=force',10,4,0),(35,'@detachthis_except:*=y/n/add/rem',10,2,0),(36,'@edit:*=y/n/add/rem',8,2,0),(37,'@edit=y/n/add/rem',8,1,0),(38,'@editattach=y/n/add/rem',8,1,0),(39,'@editobj:*=y/n/add/rem',8,1,0),(40,'@editworld=y/n/add/rem',8,1,0),(41,'@emote=y/n/add/rem',6,2,0),(42,'@fartouch?:*=y/n/add/rem',12,1,0),(43,'@findfolder:*=#',10,3,0),(44,'@findfolders:*=#',10,3,0),(45,'@fly=y/n/add/rem',4,1,0),(46,'@getattach?:*=#',10,3,0),(47,'@getblacklist',2,3,0),(48,'@getblacklist?:*=#',2,3,0),(49,'@getcam_avdistmax=#',5,3,0),(50,'@getcam_avdistmin=#',5,3,0),(51,'@getcam_fov=#',5,3,0),(52,'@getcam_fovmax=#',5,3,0),(53,'@getcam_fovmin=#',5,3,0),(54,'@getcam_zoommin=#',5,3,0),(55,'@getdebug_avatarsex=#',16,3,0),(56,'@getdebug_renderresolutiondivisor=#',16,3,0),(57,'@getdebug_restrainedloveforbidgivetorlv=#',16,3,0),(58,'@getdebug_restrainedlovenosetenv=#',16,3,0),(59,'@getdebug_windlightuseatmosshaders=#',16,3,0),(60,'@getenv_ambient=#',16,3,0),(61,'@getenv_ambientb=#',16,3,0),(62,'@getenv_ambientg=#',16,3,0),(63,'@getenv_ambienti=#',16,3,0),(64,'@getenv_ambientr=#',16,3,0),(65,'@getenv_asset=#',16,3,0),(66,'@getenv_bluedensity=#',16,3,0),(67,'@getenv_bluedensityb=#',16,3,0),(68,'@getenv_bluedensityg=#',16,3,0),(69,'@getenv_bluedensityi=#',16,3,0),(70,'@getenv_bluedensityr=#',16,3,0),(71,'@getenv_bluehorizon=#',16,3,0),(72,'@getenv_bluehorizonb=#',16,3,0),(73,'@getenv_bluehorizong=#',16,3,0),(74,'@getenv_bluehorizoni=#',16,3,0),(75,'@getenv_bluehorizonr=#',16,3,0),(76,'@getenv_cloud=#',16,3,0),(77,'@getenv_cloudcolor=#',16,3,0),(78,'@getenv_cloudcolorb=#',16,3,0),(79,'@getenv_cloudcolorg=#',16,3,0),(80,'@getenv_cloudcolori=#',16,3,0),(81,'@getenv_cloudcolorr=#',16,3,0),(82,'@getenv_cloudcoverage=#',16,3,0),(83,'@getenv_cloudd=#',16,3,0),(84,'@getenv_clouddetail=#',16,3,0),(85,'@getenv_clouddetaild=#',16,3,0),(86,'@getenv_clouddetailx=#',16,3,0),(87,'@getenv_clouddetaily=#',16,3,0),(88,'@getenv_cloudimage=#',16,3,0),(89,'@getenv_cloudscale=#',16,3,0),(90,'@getenv_cloudscroll=#',16,3,0),(91,'@getenv_cloudscrollx=#',16,3,0),(92,'@getenv_cloudscrolly=#',16,3,0),(93,'@getenv_cloudvariance=#',16,3,0),(94,'@getenv_cloudx=#',16,3,0),(95,'@getenv_cloudy=#',16,3,0),(96,'@getenv_daytime=#',16,3,0),(97,'@getenv_densitymultiplier=#',16,3,0),(98,'@getenv_distancemultiplier=#',16,3,0),(99,'@getenv_dropletradius=#',16,3,0),(100,'@getenv_eastangle=#',16,3,0),(101,'@getenv_hazedensity=#',16,3,0),(102,'@getenv_hazehorizon=#',16,3,0),(103,'@getenv_icelevel=#',16,3,0),(104,'@getenv_maxaltitude=#',16,3,0),(105,'@getenv_moisturelevel=#',16,3,0),(106,'@getenv_moonazim=#',16,3,0),(107,'@getenv_moonbrightness=#',16,3,0),(108,'@getenv_moonelev=#',16,3,0),(109,'@getenv_moonimage=#',16,3,0),(110,'@getenv_moonscale=#',16,3,0),(111,'@getenv_preset=#',16,3,0),(112,'@getenv_scenegamma=#',16,3,0),(113,'@getenv_starbrightness=#',16,3,0),(114,'@getenv_sunazim=#',16,3,0),(115,'@getenv_sunelev=#',16,3,0),(116,'@getenv_sunglowfocus=#',16,3,0),(117,'@getenv_sunglowsize=#',16,3,0),(118,'@getenv_sunimage=#',16,3,0),(119,'@getenv_sunmooncolor=#',16,3,0),(120,'@getenv_sunmooncolorb=#',16,3,0),(121,'@getenv_sunmooncolorg=#',16,3,0),(122,'@getenv_sunmooncolori=#',16,3,0),(123,'@getenv_sunmooncolorr=#',16,3,0),(124,'@getenv_sunmoonposition=#',16,3,0),(125,'@getenv_sunscale=#',16,3,0),(126,'@getgroup=#',15,3,0),(127,'@getinv?:*=#',10,3,0),(128,'@getinvworn?:*=#',10,3,0),(129,'@getoutfit?:*=#',10,3,0),(130,'@getsitid=#',9,3,0),(131,'@getstatus?:*=#',3,3,0),(132,'@getstatusall?:*=#',3,3,0),(133,'@interact=y/n/add/rem',12,1,0),(134,'@notify:*=y/n/add/rem',3,3,0),(135,'@permissive=y/n/add/rem',3,3,0),(136,'@recvchat_sec=y/n/add/rem',6,1,0),(137,'@recvchat:*=y/n/add/rem',6,2,0),(138,'@recvchat=y/n/add/rem',6,1,0),(139,'@recvchatfrom:*=y/n/add/rem',6,1,0),(140,'@recvemote_sec=y/n/add/rem',6,1,0),(141,'@recvemote:*=y/n/add/rem',6,2,0),(142,'@recvemote=y/n/add/rem',6,1,0),(143,'@recvemotefrom:*=y/n/add/rem',6,1,0),(144,'@recvim_sec=y/n/add/rem',6,1,0),(145,'@recvim:*=y/n/add/rem',6,2,0),(146,'@recvim=y/n/add/rem',6,1,0),(147,'@recvimfrom:*=y/n/add/rem',6,1,0),(148,'@redirchat:*=y/n/add/rem',6,1,0),(149,'@rediremote:*=y/n/add/rem',6,1,0),(150,'@remattach:*=force',10,4,0),(151,'@remattach?:*=y/n/add/rem',10,1,0),(152,'@remoutfit:*=force',10,4,0),(153,'@remoutfit?:*=y/n/add/rem',10,1,0),(154,'@rez=y/n/add/rem',8,1,0),(155,'@sendchannel_except:*=y/n/add/rem',6,1,0),(156,'@sendchannel_sec:*=y/n/add/rem',6,2,0),(157,'@sendchannel_sec=y/n/add/rem',6,1,0),(158,'@sendchannel:*=y/n/add/rem',6,2,0),(159,'@sendchannel=y/n/add/rem',6,1,0),(160,'@sendchat=y/n/add/rem',6,1,0),(161,'@sendgesture=y/n/add/rem',6,1,0),(162,'@sendim_sec=y/n/add/rem',6,1,0),(163,'@sendim:*=y/n/add/rem',6,2,0),(164,'@sendim=y/n/add/rem',6,1,0),(165,'@sendimto:*=y/n/add/rem',6,1,0),(166,'@setcam_avdistmax:*=y/n/add/rem',5,1,0),(167,'@setcam_avdistmin:*=y/n/add/rem',5,1,0),(168,'@setcam_fov:*=force',5,4,0),(169,'@setcam_fovmax:*=y/n/add/rem',5,1,0),(170,'@setcam_fovmin:*=y/n/add/rem',5,1,0),(171,'@setcam_textures?:*=y/n/add/rem',5,1,0),(172,'@setcam_unlock=y/n/add/rem',5,1,0),(173,'@setdebug_avatarsex:*=force',16,4,0),(174,'@setdebug_renderresolutiondivisor:*=force',16,4,0),(175,'@setdebug_restrainedloveforbidgivetorlv:*=force',16,4,0),(176,'@setdebug_restrainedlovenosetenv:*=force',16,4,0),(177,'@setdebug_windlightuseatmosshaders:*=force',16,4,0),(178,'@setenv_ambient:*=force',16,4,0),(179,'@setenv_ambientb:*=force',16,4,0),(180,'@setenv_ambientg:*=force',16,4,0),(181,'@setenv_ambienti:*=force',16,4,0),(182,'@setenv_ambientr:*=force',16,4,0),(183,'@setenv_asset:*=force',16,4,0),(184,'@setenv_bluedensity:*=force',16,4,0),(185,'@setenv_bluedensityb:*=force',16,4,0),(186,'@setenv_bluedensityg:*=force',16,4,0),(187,'@setenv_bluedensityi:*=force',16,4,0),(188,'@setenv_bluedensityr:*=force',16,4,0),(189,'@setenv_bluehorizon:*=force',16,4,0),(190,'@setenv_bluehorizonb:*=force',16,4,0),(191,'@setenv_bluehorizong:*=force',16,4,0),(192,'@setenv_bluehorizoni:*=force',16,4,0),(193,'@setenv_bluehorizonr:*=force',16,4,0),(194,'@setenv_cloud:*=force',16,4,0),(195,'@setenv_cloudcolor:*=force',16,4,0),(196,'@setenv_cloudcolorb:*=force',16,4,0),(197,'@setenv_cloudcolorg:*=force',16,4,0),(198,'@setenv_cloudcolori:*=force',16,4,0),(199,'@setenv_cloudcolorr:*=force',16,4,0),(200,'@setenv_cloudcoverage:*=force',16,4,0),(201,'@setenv_cloudd:*=force',16,4,0),(202,'@setenv_clouddetail:*=force',16,4,0),(203,'@setenv_clouddetaild:*=force',16,4,0),(204,'@setenv_clouddetailx:*=force',16,4,0),(205,'@setenv_clouddetaily:*=force',16,4,0),(206,'@setenv_cloudimage:*=force',16,4,0),(207,'@setenv_cloudscale:*=force',16,4,0),(208,'@setenv_cloudscroll:*=force',16,4,0),(209,'@setenv_cloudscrollx:*=force',16,4,0),(210,'@setenv_cloudscrolly:*=force',16,4,0),(211,'@setenv_cloudvariance:*=force',16,4,0),(212,'@setenv_cloudx:*=force',16,4,0),(213,'@setenv_cloudy:*=force',16,4,0),(214,'@setenv_daytime:*=force',16,4,0),(215,'@setenv_densitymultiplier:*=force',16,4,0),(216,'@setenv_distancemultiplier:*=force',16,4,0),(217,'@setenv_dropletradius:*=force',16,4,0),(218,'@setenv_eastangle:*=force',16,4,0),(219,'@setenv_hazedensity:*=force',16,4,0),(220,'@setenv_hazehorizon:*=force',16,4,0),(221,'@setenv_icelevel:*=force',16,4,0),(222,'@setenv_maxaltitude:*=force',16,4,0),(223,'@setenv_moisturelevel:*=force',16,4,0),(224,'@setenv_moonazim:*=force',16,4,0),(225,'@setenv_moonbrightness:*=force',16,4,0),(226,'@setenv_moonelev:*=force',16,4,0),(227,'@setenv_moonimage:*=force',16,4,0),(228,'@setenv_moonscale:*=force',16,4,0),(229,'@setenv_preset:*=force',16,4,0),(230,'@setenv_reset:*=force',16,4,0),(231,'@setenv_scenegamma:*=force',16,4,0),(232,'@setenv_starbrightness:*=force',16,4,0),(233,'@setenv_sunazim:*=force',16,4,0),(234,'@setenv_sunelev:*=force',16,4,0),(235,'@setenv_sunglowfocus:*=force',16,4,0),(236,'@setenv_sunglowsize:*=force',16,4,0),(237,'@setenv_sunimage:*=force',16,4,0),(238,'@setenv_sunmooncolor:*=force',16,4,0),(239,'@setenv_sunmooncolorb:*=force',16,4,0),(240,'@setenv_sunmooncolorg:*=force',16,4,0),(241,'@setenv_sunmooncolori:*=force',16,4,0),(242,'@setenv_sunmooncolorr:*=force',16,4,0),(243,'@setenv_sunmoonposition:*=force',16,4,0),(244,'@setenv_sunscale:*=force',16,4,0),(245,'@setgroup:*=force',15,4,0),(246,'@setgroup=y/n/add/rem',15,1,0),(247,'@setrot:*=force',4,4,0),(248,'@share_sec=y/n/add/rem',8,1,0),(249,'@share:*=y/n/add/rem',8,2,0),(250,'@share=y/n/add/rem',8,1,0),(251,'@sharedunwear=y/n/add/rem',10,1,0),(252,'@sharedwear=y/n/add/rem',10,1,0),(253,'@showhovertext:*=y/n/add/rem',14,2,0),(254,'@showhovertextall=y/n/add/rem',14,1,0),(255,'@showhovertexthud=y/n/add/rem',14,1,0),(256,'@showhovertextworld=y/n/add/rem',14,1,0),(257,'@showinv=y/n/add/rem',8,1,0),(258,'@showloc=y/n/add/rem',13,1,0),(259,'@showminimap=y/n/add/rem',13,1,0),(260,'@shownames_sec?:*=y/n/add/rem',14,1,0),(261,'@shownames?:*=y/n/add/rem',14,1,0),(262,'@shownametags=y/n/add/rem',14,1,0),(263,'@shownearby=y/n/add/rem',14,1,0),(264,'@showworldmap=y/n/add/rem',13,1,0),(265,'@sit:*=force',9,4,0),(266,'@sit=y/n/add/rem',9,1,0),(267,'@sitground=force',9,4,0),(268,'@sittp?:*=y/n/add/rem',7,1,0),(269,'@standtp=y/n/add/rem',7,1,0),(270,'@startim:*=y/n/add/rem',6,2,0),(271,'@startim=y/n/add/rem',6,1,0),(272,'@startimto:*=y/n/add/rem',6,1,0),(273,'@temprun=y/n/add/rem',4,1,0),(274,'@touchall=y/n/add/rem',12,1,0),(275,'@touchattach=y/n/add/rem',12,1,0),(276,'@touchattachother:*=y/n/add/rem',12,1,0),(277,'@touchattachother=y/n/add/rem',12,1,0),(278,'@touchattachself=y/n/add/rem',12,1,0),(279,'@touchfar?:*=y/n/add/rem',12,1,0),(280,'@touchhud?:*=y/n/add/rem',12,1,0),(281,'@touchme=y/n/add/rem',12,2,0),(282,'@touchthis:*=y/n/add/rem',12,2,0),(283,'@touchworld:*=y/n/add/rem',12,2,0),(284,'@touchworld=y/n/add/rem',12,1,0),(285,'@tplm=y/n/add/rem',7,1,0),(286,'@tploc=y/n/add/rem',7,1,0),(287,'@tplocal?:*=y/n/add/rem',7,1,0),(288,'@tplure_sec=y/n/add/rem',7,1,0),(289,'@tplure:*=y/n/add/rem',7,2,0),(290,'@tplure=y/n/add/rem',7,1,0),(291,'@tprequest_sec=y/n/add/rem',7,1,0),(292,'@tprequest:*=y/n/add/rem',7,2,0),(293,'@tprequest=y/n/add/rem',7,1,0),(294,'@tpto:*=force',7,4,0),(295,'@unsharedunwear=y/n/add/rem',10,1,0),(296,'@unsharedwear=y/n/add/rem',10,1,0),(297,'@unsit=force',9,4,0),(298,'@unsit=y/n/add/rem',9,1,0),(299,'@version',1,3,0),(300,'@version=#',1,3,0),(301,'@versionnew=#',1,3,0),(302,'@versionnum=#',1,3,0),(303,'@versionnumbl=#',2,3,0),(304,'@viewnote=y/n/add/rem',8,1,0),(305,'@viewscript=y/n/add/rem',8,1,0),(306,'@viewtexture=y/n/add/rem',8,1,0);
/*!40000 ALTER TABLE `Command` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `CommandAnalysis`
--

DROP TABLE IF EXISTS `CommandAnalysis`;
/*!50001 DROP VIEW IF EXISTS `CommandAnalysis`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `CommandAnalysis` AS SELECT 
 1 AS `Filter`,
 1 AS `Command`,
 1 AS `RequiresColon`,
 1 AS `RequiresOptions`,
 1 AS `RequiresValue`,
 1 AS `Value`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CommandDesc`
--

DROP TABLE IF EXISTS `CommandDesc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CommandDesc` (
  `CommandID` int NOT NULL,
  `Language` char(2) NOT NULL,
  `Description` text NOT NULL,
  PRIMARY KEY (`CommandID`,`Language`),
  CONSTRAINT `fk_CommandDesc_Command` FOREIGN KEY (`CommandID`) REFERENCES `Command` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CommandDesc`
--

LOCK TABLES `CommandDesc` WRITE;
/*!40000 ALTER TABLE `CommandDesc` DISABLE KEYS */;
INSERT INTO `CommandDesc` VALUES (1,'en','Allows or prevents automatically accepting attach and take control permission requests.'),(2,'en','Allows or prevents auto-accepting teleport offers from a specific avatar or everyone if unspecified.'),(3,'en','Allows or prevents auto-accepting teleport requests from a specific avatar or everyone if unspecified.'),(4,'en','Allows or prevents wearing additional attachments at a specific attachment point.'),(5,'en','Allows or prevents adding clothing layers to an outfit.'),(6,'en','Forces an adjustment to the avatar\'s height by the specified value.'),(7,'en','Allow or prevent the disabling of the automatic Away/AFK indicator. When prevented, the automatic activation of the Away status after a period of avatar inactivity cannot be disabled. If the idle timeout is set to zero, the default timeout of 30 minutes is used.'),(8,'en','Allows or prevents the user from enabling or disabling always run mode.'),(9,'en','Forces the viewer to attach every object and wear every piece of clothing contained inside the specified shared folder.'),(10,'en','Forces the viewer to attach items from a shared folder without replacing already worn items.'),(11,'en','Adds or removes exceptions for preventing the use of specific attachment points or folders.'),(12,'en','Allows or prevents the user from changing the avatar distance from the camera.'),(13,'en','Sets the maximum allowed camera distance from the avatar.'),(14,'en','Sets the minimum allowed camera distance from the avatar.'),(15,'en','Sets the maximum transparency level the camera can render.'),(16,'en','Sets the minimum transparency level the camera can render.'),(17,'en','Restricts or allows drawing a specific color with the camera view.'),(18,'en','Limits the maximum drawing distance in the camera view.'),(19,'en','Sets the minimum drawing distance in the camera view.'),(20,'en','Allows or prevents rendering textures in the camera view.'),(21,'en','Allows or prevents the user from unlocking the camera position.'),(22,'en','Sets the maximum zoom level for the camera.'),(23,'en','Sets the minimum zoom level for the camera.'),(24,'en','Allows or prevents sending normal chat messages.'),(25,'en','Allows or prevents shouting in chat.'),(26,'en','Allows or prevents whispering in chat.'),(27,'en','Clears all active restrictions and exceptions.'),(28,'en','Clears specific restrictions or exceptions.'),(29,'en','Allows or prevents using the \"Wear\" option from the inventory contextual menu, even for locked items.'),(30,'en','Forces denial of attach and take control permission requests (deprecated since v1.16.2).'),(31,'en','Forces the viewer to detach every object at the specified attachment point or shared folder.'),(32,'en','Allows or prevents detaching objects from specific attachment points or shared folders.'),(33,'en','Allows or prevents detaching objects from attachment points in general.'),(34,'en','Forces the object that issues this command to detach itself from the avatar.'),(35,'en','Adds or removes exceptions for allowing specific attachments to be detached.'),(36,'en','Allows or prevents editing a specific object identified by its UUID.'),(37,'en','Allows or prevents editing objects in general.'),(38,'en','Allows or prevents editing attachments.'),(39,'en','Allows or prevents editing a particular object identified by its UUID.'),(40,'en','Allows or prevents editing objects rezzed in-world (not attachments).'),(41,'en','Allows or prevents the use of emotes.'),(42,'en','Allows or prevents touching objects located farther than 1.5 meters away from the avatar, with an optional maximum distance.'),(43,'en','Retrieves the path to the first shared folder that matches the search criteria.'),(44,'en','Retrieves the paths to all shared folders that match the search criteria.'),(45,'en','Allows or prevents the user from enabling or disabling fly mode.'),(46,'en','Retrieves the current occupation of attachment points as a list of 0s (empty) and 1s (occupied).'),(47,'en','Retrieves the current blacklist of restricted commands.'),(48,'en','Retrieves the blacklist for a specific object or category on a specified channel.'),(49,'en','Requests the current maximum avatar distance allowed for the camera.'),(50,'en','Requests the current minimum avatar distance allowed for the camera.'),(51,'en','Requests the current field of view (FOV) of the camera.'),(52,'en','Requests the current maximum field of view (FOV) of the camera.'),(53,'en','Requests the current minimum field of view (FOV) of the camera.'),(54,'en','Requests the current minimum zoom level of the camera.'),(55,'en','Returns the gender setting (0: Female, 1: Male) of the avatar at creation on the specified chat channel.'),(56,'en','Returns the current screen \"blurriness\" factor.'),(57,'en','Returns whether the viewer restricts adding temporary folders to the \"#RLV\" folder (1: enabled, 0: disabled).'),(58,'en','Returns whether the environment settings (@setenv commands) are ignored (1: yes, 0: no).'),(59,'en','Returns whether Windlight atmospheric shaders are enabled (1: enabled, 0: disabled).'),(60,'en','Returns the ambient light vector values (RGB format).'),(61,'en','Returns the blue channel value of the ambient light.'),(62,'en','Returns the green channel value of the ambient light.'),(63,'en','Returns the intensity of the ambient light.'),(64,'en','Returns the red channel value of the ambient light.'),(65,'en','Returns the name of the active environment preset.'),(66,'en','Returns the blue density vector values (RGB format).'),(67,'en','Returns the blue channel value of the blue density.'),(68,'en','Returns the green channel value of the blue density.'),(69,'en','Returns the intensity of the blue density.'),(70,'en','Returns the red channel value of the blue density.'),(71,'en','Returns the blue horizon vector values (RGB format).'),(72,'en','Returns the blue channel value of the blue horizon.'),(73,'en','Returns the green channel value of the blue horizon.'),(74,'en','Returns the intensity of the blue horizon.'),(75,'en','Returns the red channel value of the blue horizon.'),(76,'en','Returns the cloud vector values (XYZ format: offset and density).'),(77,'en','Returns the cloud color vector values (RGB format).'),(78,'en','Returns the blue channel value of the cloud color.'),(79,'en','Returns the green channel value of the cloud color.'),(80,'en','Returns the intensity of the cloud color.'),(81,'en','Returns the red channel value of the cloud color.'),(82,'en','Returns the cloud coverage value.'),(83,'en','Returns the cloud density value.'),(84,'en','Returns the cloud detail vector values (XYZ format).'),(85,'en','Returns the cloud detail density value.'),(86,'en','Returns the X-axis offset for cloud detail.'),(87,'en','Returns the Y-axis offset for cloud detail.'),(88,'en','Returns the UUID of the cloud texture image.'),(89,'en','Returns the scale value of the clouds.'),(90,'en','Returns the cloud scroll vector values (XY format).'),(91,'en','Returns the X-axis scroll value for clouds.'),(92,'en','Returns the Y-axis scroll value for clouds.'),(93,'en','Returns the cloud variance value.'),(94,'en','Returns the X-axis offset for clouds.'),(95,'en','Returns the Y-axis offset for clouds.'),(96,'en','Returns the time of day setting (0: midnight, 0.25: sunrise, 0.567: midday, 0.75: sunset, 1.0: midnight).'),(97,'en','Returns the fog density multiplier value.'),(98,'en','Returns the fog distance multiplier value.'),(99,'en','Returns the droplet radius value.'),(100,'en','Returns the position of the east angle (0.0 is normal).'),(101,'en','Returns the haze density value.'),(102,'en','Returns the haze horizon value.'),(103,'en','Returns the ice level value.'),(104,'en','Returns the maximum altitude value for the fog.'),(105,'en','Returns the moisture level value.'),(106,'en','Returns the moon azimuth angle in radians (0 is east, counter-clockwise).'),(107,'en','Returns the moon brightness value.'),(108,'en','Returns the moon elevation angle in radians (0 is the horizon).'),(109,'en','Returns the UUID of the moon texture image.'),(110,'en','Returns the moon scale value.'),(111,'en','Returns the name of the active environment preset (alias for \"asset\").'),(112,'en','Returns the overall scene gamma value.'),(113,'en','Returns the brightness of the stars.'),(114,'en','Returns the sun azimuth angle in radians (0 is east, counter-clockwise).'),(115,'en','Returns the sun elevation angle in radians (0 is the horizon).'),(116,'en','Returns the sun glow focus value.'),(117,'en','Returns the sun glow size value.'),(118,'en','Returns the UUID of the sun texture image.'),(119,'en','Returns the sun and moon color vector values (RGB format).'),(120,'en','Returns the blue channel value of the sun and moon color.'),(121,'en','Returns the green channel value of the sun and moon color.'),(122,'en','Returns the intensity of the sun and moon color.'),(123,'en','Returns the red channel value of the sun and moon color.'),(124,'en','Returns the position of the sun or moon in the sky.'),(125,'en','Returns the scale of the sun.'),(126,'en','Returns the name of the currently active group on the specified chat channel.'),(127,'en','Retrieves the list of shared folders in the specified location of the \"#RLV\" folder.'),(128,'en','Retrieves the list of shared folders in the avatar\'s inventory, with information about worn items.'),(129,'en','Retrieves the current status of clothing layers as a list of 0s (empty) and 1s (occupied).'),(130,'en','Retrieves the UUID of the object the avatar is currently sitting on, or NULL_KEY if not sitting.'),(131,'en','Retrieves the current status of restrictions applied by a specific object, returning the result on a specified channel.'),(132,'en','Retrieves the overall status of all active restrictions, returning the result on a specified channel.'),(133,'en','Allows or prevents interacting with objects, attachments, HUDs, editing, and rezzing.'),(134,'en','Starts or stops sending notifications when restrictions are applied or removed.'),(135,'en','Enables or disables permissive mode, allowing exceptions for certain commands.'),(136,'en','Allows or prevents receiving chat messages, secure way.'),(137,'en','Allows or prevents receiving chat messages from a specific channel or all channels.'),(138,'en','Allows or prevents receiving chat messages.'),(139,'en','Allows or prevents receiving chat messages from a specific avatar.'),(140,'en','Allows or prevents receiving emotes, secure way.'),(141,'en','Allows or prevents receiving emotes from a specific source.'),(142,'en','Allows or prevents receiving emotes.'),(143,'en','Allows or prevents receiving emotes from a specific avatar.'),(144,'en','Allows or prevents receiving instant messages, secure way.'),(145,'en','Allows or prevents receiving instant messages from a specific source.'),(146,'en','Allows or prevents receiving instant messages.'),(147,'en','Allows or prevents receiving instant messages from a specific avatar.'),(148,'en','Redirects chat messages to a specific channel or prevents redirection.'),(149,'en','Redirects emotes to a specific channel or prevents redirection.'),(150,'en','Forces the viewer to remove all attachments at the specified attachment point.'),(151,'en','Allows or prevents wearing attachments on specific attachment points.'),(152,'en','Forces the viewer to remove all clothing layers.'),(153,'en','Allows or prevents removing clothing layers from an outfit.'),(154,'en','Allows or prevents rezzing objects from inventory.'),(155,'en','Allows or prevents sending chat on all channels except the specified one.'),(156,'en','Allows or prevents sending chat on a specific channel, secure way.'),(157,'en','Allows or prevents sending chat on all channels, secure way.'),(158,'en','Allows or prevents sending chat on a specific channel.'),(159,'en','Allows or prevents sending chat on all channels.'),(160,'en','Allows or prevents sending chat messages.'),(161,'en','Allows or prevents sending gestures.'),(162,'en','Allows or prevents sending instant messages, secure way.'),(163,'en','Allows or prevents sending instant messages to a specific recipient.'),(164,'en','Allows or prevents sending instant messages.'),(165,'en','Allows or prevents sending instant messages to a specific avatar.'),(166,'en','Sets or restricts the maximum distance between the camera and the avatar.'),(167,'en','Sets or restricts the minimum distance between the camera and the avatar.'),(168,'en','Forces the field of view (FOV) of the camera to a specific value.'),(169,'en','Sets or restricts the maximum field of view (FOV) for the camera.'),(170,'en','Sets or restricts the minimum field of view (FOV) for the camera.'),(171,'en','Allows or prevents rendering textures for the camera view.'),(172,'en','Allows or prevents unlocking of the camera view by the user.'),(173,'en','Forces the avatar sex setting (0: Female, 1: Male).'),(174,'en','Forces the \"blurriness\" factor of the screen.'),(175,'en','Forces the setting to restrict adding temporary folders directly under \"#RLV\".'),(176,'en','Forces the setting to ignore @setenv commands.'),(177,'en','Forces the Windlight atmospheric shaders setting.'),(178,'en','Forces the ambient light to the specified vector values (RGB format).'),(179,'en','Forces the blue channel of the ambient light to the specified value.'),(180,'en','Forces the green channel of the ambient light to the specified value.'),(181,'en','Forces the intensity of the ambient light to the specified value.'),(182,'en','Forces the red channel of the ambient light to the specified value.'),(183,'en','Forces the viewer to apply the specified environment preset.'),(184,'en','Forces the blue density to the specified vector values (RGB format).'),(185,'en','Forces the blue channel of the blue density to the specified value.'),(186,'en','Forces the green channel of the blue density to the specified value.'),(187,'en','Forces the intensity of the blue density to the specified value.'),(188,'en','Forces the red channel of the blue density to the specified value.'),(189,'en','Forces the blue horizon to the specified vector values (RGB format).'),(190,'en','Forces the blue channel of the blue horizon to the specified value.'),(191,'en','Forces the green channel of the blue horizon to the specified value.'),(192,'en','Forces the intensity of the blue horizon to the specified value.'),(193,'en','Forces the red channel of the blue horizon to the specified value.'),(194,'en','Forces the cloud offset and density to the specified vector values (XYZ format).'),(195,'en','Forces the cloud color to the specified vector values (RGB format).'),(196,'en','Forces the blue channel of the cloud color to the specified value.'),(197,'en','Forces the green channel of the cloud color to the specified value.'),(198,'en','Forces the intensity of the cloud color to the specified value.'),(199,'en','Forces the red channel of the cloud color to the specified value.'),(200,'en','Forces the cloud coverage to the specified value.'),(201,'en','Forces the cloud density to the specified value.'),(202,'en','Forces the cloud detail to the specified vector values (XYZ format).'),(203,'en','Forces the cloud detail density to the specified value.'),(204,'en','Forces the X-axis offset for the cloud detail to the specified value.'),(205,'en','Forces the Y-axis offset for the cloud detail to the specified value.'),(206,'en','Forces the viewer to use the specified texture image as the cloud texture.'),(207,'en','Forces the cloud scale to the specified value.'),(208,'en','Forces the cloud scroll vector values (XY format).'),(209,'en','Forces the X-axis scroll for the clouds to the specified value.'),(210,'en','Forces the Y-axis scroll for the clouds to the specified value.'),(211,'en','Forces the cloud variance to the specified value.'),(212,'en','Forces the X-axis offset for the clouds to the specified value.'),(213,'en','Forces the Y-axis offset for the clouds to the specified value.'),(214,'en','Forces the time of day to the specified value.'),(215,'en','Forces the fog density multiplier to the specified value.'),(216,'en','Forces the fog distance multiplier to the specified value.'),(217,'en','Forces the droplet radius to the specified value.'),(218,'en','Forces the east angle to the specified value.'),(219,'en','Forces the haze density to the specified value.'),(220,'en','Forces the haze horizon to the specified value.'),(221,'en','Forces the ice level to the specified value.'),(222,'en','Forces the maximum altitude for the fog to the specified value.'),(223,'en','Forces the moisture level to the specified value.'),(224,'en','Forces the moon azimuth angle to the specified value (radians).'),(225,'en','Forces the moon brightness to the specified value.'),(226,'en','Forces the moon elevation angle to the specified value (radians).'),(227,'en','Forces the viewer to use the specified texture image as the moon texture.'),(228,'en','Forces the moon scale to the specified value.'),(229,'en','Forces the viewer to apply the specified environment preset (alias for \"asset\").'),(230,'en','Resets the environment to the region default.'),(231,'en','Forces the overall scene gamma to the specified value.'),(232,'en','Forces the star brightness to the specified value.'),(233,'en','Forces the sun azimuth angle to the specified value (radians).'),(234,'en','Forces the sun elevation angle to the specified value (radians).'),(235,'en','Forces the sun glow focus to the specified value.'),(236,'en','Forces the sun glow size to the specified value.'),(237,'en','Forces the viewer to use the specified texture image as the sun texture.'),(238,'en','Forces the sun and moon color to the specified vector values (RGB format).'),(239,'en','Forces the blue channel of the sun and moon color to the specified value.'),(240,'en','Forces the green channel of the sun and moon color to the specified value.'),(241,'en','Forces the intensity of the sun and moon color to the specified value.'),(242,'en','Forces the red channel of the sun and moon color to the specified value.'),(243,'en','Forces the position of the sun or moon in the sky.'),(244,'en','Forces the scale of the sun.'),(245,'en','Forces the user to change their active group to the specified group name or UUID. If set to \"none\", the group tag is hidden.'),(246,'en','Allows or prevents the user from changing their active group.'),(247,'en','Forces the avatar to rotate to a specific direction.'),(248,'en','Allows or prevents sharing inventory with others, secure way (only allows exceptions from the same object).'),(249,'en','Allows or prevents sharing inventory with a specific avatar.'),(250,'en','Allows or prevents sharing inventory in general.'),(251,'en','Allows or prevents removing clothes and attachments from shared folders (#RLV).'),(252,'en','Allows or prevents wearing clothes and attachments from shared folders (#RLV).'),(253,'en','Allows or prevents the user from seeing the hovertext floating above a specific prim with the specified UUID.'),(254,'en','Allows or prevents the user from seeing any hovertext (floating 2D text above prims).'),(255,'en','Allows or prevents the user from seeing hovertext on HUDs only.'),(256,'en','Allows or prevents the user from seeing hovertext in-world (excluding HUDs).'),(257,'en','Allows or prevents opening the inventory window.'),(258,'en','Allows or prevents the avatar from knowing their current location. Prevents the world map, parcel and region names from displaying, and obfuscates system and object messages containing location details.'),(259,'en','Allows or prevents viewing the minimap. Closes the minimap if it is open when the restriction is activated.'),(260,'en','Allows or prevents the user from seeing the names of nearby avatars securely, with exceptions specified by UUIDs.'),(261,'en','Allows or prevents the user from seeing the names of nearby avatars. Exceptions can be made for specific avatars using UUIDs.'),(262,'en','Allows or prevents the user from seeing name tags without censoring the names in chat.'),(263,'en','Allows or prevents the user from seeing the names of nearby avatars in the \"Nearby\" window of the \"People\" tab.'),(264,'en','Allows or prevents viewing the world map. Closes the world map if it is open when the restriction is activated.'),(265,'en','Forces the avatar to sit on a specific object identified by its UUID.'),(266,'en','Allows or prevents sitting down in general.'),(267,'en','Forces the avatar to sit on the ground at their current location.'),(268,'en','Allows or prevents sitting as a way to teleport within a maximum distance.'),(269,'en','Allows or prevents standing up at a different location than where the avatar initially sat down.'),(270,'en','Allows or prevents starting an instant message session with a specific recipient.'),(271,'en','Allows or prevents starting an instant message session.'),(272,'en','Allows or prevents starting an instant message session with a specific avatar.'),(273,'en','Temporarily enables or disables running mode.'),(274,'en','Allows or prevents touching or grabbing any object or attachment (does not apply to HUDs).'),(275,'en','Allows or prevents touching attachments (does not apply to HUDs).'),(276,'en','Allows or prevents touching another avatar\'s specific attachment.'),(277,'en','Allows or prevents touching other avatars\' attachments (does not apply to HUDs).'),(278,'en','Allows or prevents touching one\'s own attachments (does not apply to HUDs).'),(279,'en','Allows or prevents touching objects located farther than 1.5 meters away from the avatar (synonym for @fartouch).'),(280,'en','Allows or prevents touching HUDs. When a UUID is specified, it applies to a specific HUD.'),(281,'en','Adds or removes exceptions for touching a specific object.'),(282,'en','Allows or prevents touching or grabbing a specific object.'),(283,'en','Adds or removes exceptions for touching in-world objects with a specific UUID.'),(284,'en','Allows or prevents touching or grabbing in-world objects. This does not apply to attachments or HUDs.'),(285,'en','Allows or prevents teleporting to a landmark.'),(286,'en','Allows or prevents teleporting to a specific location by coordinates.'),(287,'en','Allows or prevents teleporting locally within a maximum distance.'),(288,'en','Allows or prevents teleport offers, secure way (only accepts exceptions from the same object).'),(289,'en','Allows or prevents teleport offers from a specific avatar.'),(290,'en','Allows or prevents teleport offers from everyone.'),(291,'en','Allows or prevents teleport requests, secure way (only accepts exceptions from the same object).'),(292,'en','Allows or prevents teleport requests from a specific avatar.'),(293,'en','Allows or prevents teleport requests from everyone.'),(294,'en','Forces the avatar to teleport to the specified global coordinates or region with local coordinates.'),(295,'en','Allows or prevents removing clothes and attachments not part of shared folders (#RLV).'),(296,'en','Allows or prevents wearing clothes and attachments not part of shared folders (#RLV).'),(297,'en','Forces the avatar to stand up.'),(298,'en','Allows or prevents standing up.'),(299,'en','Returns the RLV API version in response to a manual query via IM. The viewer sends the version discreetly.'),(300,'en','Allows the viewer to return the RLV API version (as a non-zero integer) on a specified channel.'),(301,'en','Returns additional details about the viewer along with the RLV API version on a specified channel.'),(302,'en','Returns the numerical version as a single integer representing X.Y.Z.P on a specified channel.'),(303,'en','Returns the RLV API version of the viewer while considering blacklist restrictions.'),(304,'en','Allows or prevents viewing notecards.'),(305,'en','Allows or prevents viewing scripts.'),(306,'en','Allows or prevents viewing textures or snapshots.');
/*!40000 ALTER TABLE `CommandDesc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `CommandDetails`
--

DROP TABLE IF EXISTS `CommandDetails`;
/*!50001 DROP VIEW IF EXISTS `CommandDetails`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `CommandDetails` AS SELECT 
 1 AS `Command`,
 1 AS `CategoryShortName`,
 1 AS `FunctionalCategory`,
 1 AS `CommandType`,
 1 AS `Description`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `CommandType`
--

DROP TABLE IF EXISTS `CommandType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CommandType` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CommandType`
--

LOCK TABLES `CommandType` WRITE;
/*!40000 ALTER TABLE `CommandType` DISABLE KEYS */;
INSERT INTO `CommandType` VALUES (1,'Restriction'),(2,'Exception'),(3,'Get'),(4,'Action');
/*!40000 ALTER TABLE `CommandType` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CommandTypeDesc`
--

DROP TABLE IF EXISTS `CommandTypeDesc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CommandTypeDesc` (
  `ID` int NOT NULL,
  `Language` char(2) NOT NULL,
  `Description` text NOT NULL,
  PRIMARY KEY (`ID`,`Language`),
  CONSTRAINT `fk_CommandTypeDesc_CommandType` FOREIGN KEY (`ID`) REFERENCES `CommandType` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CommandTypeDesc`
--

LOCK TABLES `CommandTypeDesc` WRITE;
/*!40000 ALTER TABLE `CommandTypeDesc` DISABLE KEYS */;
INSERT INTO `CommandTypeDesc` VALUES (1,'en','Defines restrictions that limit or block specific actions.'),(2,'en','Specifies exceptions to predefined restrictions.'),(3,'en','Retrieves information or the current state of a feature.'),(4,'en','Executes specific actions or commands.');
/*!40000 ALTER TABLE `CommandTypeDesc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FunctionalCategory`
--

DROP TABLE IF EXISTS `FunctionalCategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `FunctionalCategory` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ShortName` varchar(5) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FunctionalCategory`
--

LOCK TABLES `FunctionalCategory` WRITE;
/*!40000 ALTER TABLE `FunctionalCategory` DISABLE KEYS */;
INSERT INTO `FunctionalCategory` VALUES (1,'vers'),(2,'blist'),(3,'misc'),(4,'move'),(5,'cview'),(6,'chat'),(7,'tele'),(8,'inv'),(9,'sit'),(10,'worn'),(12,'touch'),(13,'loc'),(14,'name'),(15,'group'),(16,'view'),(17,'ucom');
/*!40000 ALTER TABLE `FunctionalCategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `FunctionalCategoryDesc`
--

DROP TABLE IF EXISTS `FunctionalCategoryDesc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `FunctionalCategoryDesc` (
  `ID` int NOT NULL,
  `Language` char(2) NOT NULL,
  `Name` varchar(45) NOT NULL,
  `Description` text NOT NULL,
  PRIMARY KEY (`ID`,`Language`),
  CONSTRAINT `fk_FunctionalCategoryDesc_FunctionalCategory` FOREIGN KEY (`ID`) REFERENCES `FunctionalCategory` (`ID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `FunctionalCategoryDesc`
--

LOCK TABLES `FunctionalCategoryDesc` WRITE;
/*!40000 ALTER TABLE `FunctionalCategoryDesc` DISABLE KEYS */;
INSERT INTO `FunctionalCategoryDesc` VALUES (1,'en','Version checking','Check and validate the version compatibility.'),(2,'en','Blacklist management','Manage the blacklist for restricted features or users.'),(3,'en','Miscellaneous','Miscellaneous functions that do not fit other categories.'),(4,'en','Movement','Control and restrict avatar movements.'),(5,'en','Camera and view','Manipulate and control the camera view.'),(6,'en','Chat, Emotes, and Instant Messages','Handle chat, emotes, and instant messages functionalities.'),(7,'en','Teleporting','Manage teleportation restrictions and functionalities.'),(8,'en','Inventory, editing, and rezzing','Handle inventory, editing, and object rezzing operations.'),(9,'en','Sitting','Control avatar sitting behavior and restrictions.'),(10,'en','Worn items and attachments','Manage worn items and attachments.'),(12,'en','Touch','Control and restrict object touch interactions.'),(13,'en','Location','Provide location-related functionalities and restrictions.'),(14,'en','Name tags and floating text','Customize name tags and floating text displays.'),(15,'en','Group','Handle group-specific functionalities and restrictions.'),(16,'en','Viewer control','Control viewer-specific settings and functionalities.'),(17,'en','Unofficial commands','Utilize unofficial commands for advanced control.');
/*!40000 ALTER TABLE `FunctionalCategoryDesc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RestrictionByGroup`
--

DROP TABLE IF EXISTS `RestrictionByGroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RestrictionByGroup` (
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UserID` varchar(45) NOT NULL,
  `UserName` varchar(45) NOT NULL,
  `MemberID` varchar(45) NOT NULL,
  `MemberName` varchar(45) NOT NULL,
  `GroupID` varchar(45) NOT NULL,
  `GroupName` varchar(45) NOT NULL,
  `Restriction` varchar(45) NOT NULL,
  PRIMARY KEY (`UserID`,`MemberID`,`GroupID`,`Restriction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RestrictionByGroup`
--

LOCK TABLES `RestrictionByGroup` WRITE;
/*!40000 ALTER TABLE `RestrictionByGroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `RestrictionByGroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RestrictionByOwner`
--

DROP TABLE IF EXISTS `RestrictionByOwner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RestrictionByOwner` (
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UserID` varchar(45) NOT NULL,
  `UserName` varchar(45) NOT NULL,
  `OwnerID` varchar(45) NOT NULL,
  `OwnerName` varchar(45) NOT NULL,
  `Restriction` varchar(45) NOT NULL,
  PRIMARY KEY (`UserID`,`OwnerID`,`Restriction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RestrictionByOwner`
--

LOCK TABLES `RestrictionByOwner` WRITE;
/*!40000 ALTER TABLE `RestrictionByOwner` DISABLE KEYS */;
/*!40000 ALTER TABLE `RestrictionByOwner` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RestrictionByTrusted`
--

DROP TABLE IF EXISTS `RestrictionByTrusted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RestrictionByTrusted` (
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UserID` varchar(45) NOT NULL,
  `UserName` varchar(45) NOT NULL,
  `TrustedID` varchar(45) NOT NULL,
  `TrustedName` varchar(45) NOT NULL,
  `Restriction` varchar(45) NOT NULL,
  PRIMARY KEY (`UserID`,`TrustedID`,`Restriction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RestrictionByTrusted`
--

LOCK TABLES `RestrictionByTrusted` WRITE;
/*!40000 ALTER TABLE `RestrictionByTrusted` DISABLE KEYS */;
/*!40000 ALTER TABLE `RestrictionByTrusted` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `CommandAnalysis`
--

/*!50001 DROP VIEW IF EXISTS `CommandAnalysis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `CommandAnalysis` AS select `Command`.`Command` AS `Filter`,regexp_substr(`Command`.`Command`,'^[@a-zA-Z0-9_]*') AS `Command`,(case when (`Command`.`Command` like '%?:%') then 1 when (`Command`.`Command` like '%:%') then 2 else 0 end) AS `RequiresColon`,(case when (`Command`.`Command` like '%?*%') then 1 when (regexp_like(`Command`.`Command`,'\\*(_|=|$)') and ((not((`Command`.`Command` like '%=%'))) or regexp_like(`Command`.`Command`,'\\*[^=]*='))) then 2 else 0 end) AS `RequiresOptions`,(case when (`Command`.`Command` like '%?=%') then 1 when (`Command`.`Command` like '%=%') then 2 else 0 end) AS `RequiresValue`,(case when (`Command`.`Command` like '%=%') then substring_index(`Command`.`Command`,'=',-(1)) else NULL end) AS `Value` from `Command` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `CommandDetails`
--

/*!50001 DROP VIEW IF EXISTS `CommandDetails`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `CommandDetails` AS select `Command`.`Command` AS `Command`,`FunctionalCategory`.`ShortName` AS `CategoryShortName`,`FunctionalCategoryDesc`.`Name` AS `FunctionalCategory`,`CommandType`.`Name` AS `CommandType`,`CommandDesc`.`Description` AS `Description` from ((((`Command` left join `CommandDesc` on((`Command`.`ID` = `CommandDesc`.`CommandID`))) left join `CommandType` on((`Command`.`CommandTypeID` = `CommandType`.`ID`))) left join `FunctionalCategory` on((`Command`.`FunctionalCategoryID` = `FunctionalCategory`.`ID`))) left join `FunctionalCategoryDesc` on(((`FunctionalCategory`.`ID` = `FunctionalCategoryDesc`.`ID`) and (`FunctionalCategoryDesc`.`Language` = 'en')))) where (`CommandDesc`.`Language` = 'en') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-01-05 18:31:12
