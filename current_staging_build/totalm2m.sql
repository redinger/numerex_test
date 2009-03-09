DROP DATABASE IF EXISTS ublip_totalm2m;
CREATE DATABASE ublip_totalm2m;
USE ublip_totalm2m;


-- MySQL dump 10.11
--
-- Host: localhost    Database: ublip_totalm2m
-- ------------------------------------------------------
-- Server version	5.0.45-Debian_1ubuntu3.3-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `AT_REQUEST`
--

DROP TABLE IF EXISTS `AT_REQUEST`;
CREATE TABLE `AT_REQUEST` (
  `ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `SEQUENCE_NO` int(11) default NULL,
  `RAW_DATA_ID` varchar(36) default NULL,
  `COMMAND` varchar(2047) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `AT_RESPONSE`
--

DROP TABLE IF EXISTS `AT_RESPONSE`;
CREATE TABLE `AT_RESPONSE` (
  `ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `SEQUENCE_NO` int(11) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `AT_REQUEST_ID` varchar(36) default NULL,
  `AT_REQUEST_CMD` varchar(2047) default NULL,
  `COMMAND` varchar(2047) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `DEVICE`
--

DROP TABLE IF EXISTS `DEVICE`;
CREATE TABLE `DEVICE` (
  `ID` varchar(126) NOT NULL default '',
  `IMEI` varchar(126) default NULL,
  `IMSI` varchar(126) default NULL,
  `CNUM` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `HOST` varchar(64) NOT NULL,
  `PORT` int(11) NOT NULL default '1720',
  `SERVER_HOST` varchar(2047) NOT NULL,
  `SERVER_PORT` int(11) NOT NULL,
  `CREATED` datetime default NULL,
  `MODIFIED` datetime default NULL,
  `LAST_SEND` datetime default NULL,
  `LAST_RECV` datetime default NULL,
  `LAST_PROBE` datetime default NULL,
  `PROBES` smallint(6) default '0',
  PRIMARY KEY  (`ID`),
  UNIQUE KEY `DEVICE_UNIQUE_CST` (`HOST`,`PORT`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `DEVICE_PROP`
--

DROP TABLE IF EXISTS `DEVICE_PROP`;
CREATE TABLE `DEVICE_PROP` (
  `DEVICE_ID` varchar(126) NOT NULL default '',
  `PROP_NAME` varchar(126) NOT NULL default '',
  `PROP_VALUE` varchar(126) default NULL,
  `REQUEST` varchar(2047) default NULL,
  `RESPONSE` varchar(2047) default NULL,
  `PROBE` char(1) default NULL,
  `REPROBE` bigint(20) default NULL,
  `CREATED` datetime default NULL,
  `MODIFIED` datetime default NULL,
  `LAST_SEND` datetime default NULL,
  `LAST_RECV` datetime default NULL,
  `PROBES` smallint(6) default NULL,
  PRIMARY KEY  (`DEVICE_ID`,`PROP_NAME`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_1`
--

DROP TABLE IF EXISTS `EVENT_1`;
CREATE TABLE `EVENT_1` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `GPIO1` char(1) default NULL,
  `GPIO2` char(1) default NULL,
  `GPIO3` char(1) default NULL,
  `GPIO4` char(1) default NULL,
  `GPIO5` char(1) default NULL,
  `GPIO6` char(1) default NULL,
  `GPIO7` char(1) default NULL,
  `GPIO8` char(1) default NULL,
  `AD1` int(11) default NULL,
  `AD2` int(11) default NULL,
  `STATUS` int(11) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  `SAT_COUNT` int(11) default NULL,
  `ODOMETER` int(11) default NULL,
  `RTC` datetime default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_101`
--

DROP TABLE IF EXISTS `EVENT_101`;
CREATE TABLE `EVENT_101` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `GPIO1` char(1) default NULL,
  `GPIO2` char(1) default NULL,
  `GPIO3` char(1) default NULL,
  `GPIO4` char(1) default NULL,
  `GPIO5` char(1) default NULL,
  `GPIO6` char(1) default NULL,
  `GPIO7` char(1) default NULL,
  `GPIO8` char(1) default NULL,
  `AD1` int(11) default NULL,
  `AD2` int(11) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_11`
--

DROP TABLE IF EXISTS `EVENT_11`;
CREATE TABLE `EVENT_11` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_12`
--

DROP TABLE IF EXISTS `EVENT_12`;
CREATE TABLE `EVENT_12` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_13`
--

DROP TABLE IF EXISTS `EVENT_13`;
CREATE TABLE `EVENT_13` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_14`
--

DROP TABLE IF EXISTS `EVENT_14`;
CREATE TABLE `EVENT_14` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_143`
--

DROP TABLE IF EXISTS `EVENT_143`;
CREATE TABLE `EVENT_143` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `GPIO1` char(1) default NULL,
  `GPIO2` char(1) default NULL,
  `GPIO3` char(1) default NULL,
  `GPIO4` char(1) default NULL,
  `GPIO5` char(1) default NULL,
  `GPIO6` char(1) default NULL,
  `GPIO7` char(1) default NULL,
  `GPIO8` char(1) default NULL,
  `AD1` int(11) default NULL,
  `AD2` int(11) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_144`
--

DROP TABLE IF EXISTS `EVENT_144`;
CREATE TABLE `EVENT_144` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `GPIO1` char(1) default NULL,
  `GPIO2` char(1) default NULL,
  `GPIO3` char(1) default NULL,
  `GPIO4` char(1) default NULL,
  `GPIO5` char(1) default NULL,
  `GPIO6` char(1) default NULL,
  `GPIO7` char(1) default NULL,
  `GPIO8` char(1) default NULL,
  `AD1` int(11) default NULL,
  `AD2` int(11) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_145`
--

DROP TABLE IF EXISTS `EVENT_145`;
CREATE TABLE `EVENT_145` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `GPIO1` char(1) default NULL,
  `GPIO2` char(1) default NULL,
  `GPIO3` char(1) default NULL,
  `GPIO4` char(1) default NULL,
  `GPIO5` char(1) default NULL,
  `GPIO6` char(1) default NULL,
  `GPIO7` char(1) default NULL,
  `GPIO8` char(1) default NULL,
  `AD1` int(11) default NULL,
  `AD2` int(11) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_2`
--

DROP TABLE IF EXISTS `EVENT_2`;
CREATE TABLE `EVENT_2` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_21`
--

DROP TABLE IF EXISTS `EVENT_21`;
CREATE TABLE `EVENT_21` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_22`
--

DROP TABLE IF EXISTS `EVENT_22`;
CREATE TABLE `EVENT_22` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_23`
--

DROP TABLE IF EXISTS `EVENT_23`;
CREATE TABLE `EVENT_23` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_24`
--

DROP TABLE IF EXISTS `EVENT_24`;
CREATE TABLE `EVENT_24` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_3`
--

DROP TABLE IF EXISTS `EVENT_3`;
CREATE TABLE `EVENT_3` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_40`
--

DROP TABLE IF EXISTS `EVENT_40`;
CREATE TABLE `EVENT_40` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_41`
--

DROP TABLE IF EXISTS `EVENT_41`;
CREATE TABLE `EVENT_41` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_42`
--

DROP TABLE IF EXISTS `EVENT_42`;
CREATE TABLE `EVENT_42` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_43`
--

DROP TABLE IF EXISTS `EVENT_43`;
CREATE TABLE `EVENT_43` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_44`
--

DROP TABLE IF EXISTS `EVENT_44`;
CREATE TABLE `EVENT_44` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_45`
--

DROP TABLE IF EXISTS `EVENT_45`;
CREATE TABLE `EVENT_45` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_51`
--

DROP TABLE IF EXISTS `EVENT_51`;
CREATE TABLE `EVENT_51` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_52`
--

DROP TABLE IF EXISTS `EVENT_52`;
CREATE TABLE `EVENT_52` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_53`
--

DROP TABLE IF EXISTS `EVENT_53`;
CREATE TABLE `EVENT_53` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_54`
--

DROP TABLE IF EXISTS `EVENT_54`;
CREATE TABLE `EVENT_54` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `EVENT_61`
--

DROP TABLE IF EXISTS `EVENT_61`;
CREATE TABLE `EVENT_61` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_62`
--

DROP TABLE IF EXISTS `EVENT_62`;
CREATE TABLE `EVENT_62` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_63`
--

DROP TABLE IF EXISTS `EVENT_63`;
CREATE TABLE `EVENT_63` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `EVENT_64`
--

DROP TABLE IF EXISTS `EVENT_64`;
CREATE TABLE `EVENT_64` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `MODEM` varchar(22) default NULL,
  `LATITUDE` float default NULL,
  `LONGITUDE` float default NULL,
  `SPEED` int(11) default NULL,
  `HEADING` int(11) default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `ALTITUDE` int(11) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `GPS_POSITION`
--

DROP TABLE IF EXISTS `GPS_POSITION`;
CREATE TABLE `GPS_POSITION` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `TYPE` varchar(10) NOT NULL,
  `UTC_GPS_TIME` datetime NOT NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `LATITUDE` float NOT NULL,
  `LAT_DEGREES` smallint(6) default NULL,
  `LAT_MINUTES` smallint(6) default NULL,
  `LAT_SECONDS` float default NULL,
  `LAT_COMPASS` char(1) default NULL,
  `LONGITUDE` float NOT NULL,
  `LON_DEGREES` smallint(6) default NULL,
  `LON_MINUTES` smallint(6) default NULL,
  `LON_SECONDS` float default NULL,
  `LON_COMPASS` char(1) default NULL,
  `QUALITY` smallint(6) default NULL,
  `SAT_COUNT` smallint(6) default NULL,
  `HDOP` float default NULL,
  `ALTITUDE` int(11) default NULL,
  `ALT_UNITS` char(1) default NULL,
  `SEPARATION` int(11) default NULL,
  `SEP_UNITS` char(1) default NULL,
  `AGE` int(11) default NULL,
  `DIFF_REF_ID` varchar(50) default NULL,
  `STATUS` char(1) default NULL,
  `GPS_MODE` char(1) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `GPS_SATELLITE`
--

DROP TABLE IF EXISTS `GPS_SATELLITE`;
CREATE TABLE `GPS_SATELLITE` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `TYPE` varchar(10) NOT NULL,
  `GROUP_ID` varchar(36) NOT NULL,
  `SATELLITE_ID` int(11) NOT NULL,
  `CHANNEL` smallint(6) NOT NULL,
  `ACQ_MODE` char(1) default NULL,
  `STATUS_MODE` smallint(6) default NULL,
  `SAT_COUNT` smallint(6) default NULL,
  `PDOP` float default NULL,
  `HDOP` float default NULL,
  `VDOP` float default NULL,
  `ELEVATION` smallint(6) default NULL,
  `AZIMUTH` smallint(6) default NULL,
  `SNR` smallint(6) default NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `GPS_VECTOR`
--

DROP TABLE IF EXISTS `GPS_VECTOR`;
CREATE TABLE `GPS_VECTOR` (
  `ID` varchar(36) NOT NULL,
  `RAW_DATA_ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `TYPE` varchar(10) NOT NULL,
  `COURSE_TRUE` float default NULL,
  `COURSE_MAG` float default NULL,
  `SPEED_KNOTS` float default NULL,
  `SPEED_KM_HR` float default NULL,
  `UTC_GPS_TIME` datetime default NULL,
  `UTC_GPS_DATE` datetime default NULL,
  `STATUS` char(1) default NULL,
  `GPS_MODE` char(1) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `RAW_DATA`
--

DROP TABLE IF EXISTS `RAW_DATA`;
CREATE TABLE `RAW_DATA` (
  `ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `DEVICE_HOST` varchar(2047) NOT NULL,
  `DEVICE_PORT` int(11) NOT NULL,
  `SERVER_HOST` varchar(2047) NOT NULL,
  `SERVER_PORT` int(11) NOT NULL,
  `TYPE` smallint(6) NOT NULL,
  `DATA` varbinary(2048) NOT NULL,
  `PARAMETER` int(11) NOT NULL,
  `STATUS` smallint(6) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `WAKEUP`
--

DROP TABLE IF EXISTS `WAKEUP`;
CREATE TABLE `WAKEUP` (
  `ID` varchar(36) NOT NULL,
  `CREATED` datetime default NULL,
  `DEVICE_ID` varchar(126) default NULL,
  `RAW_DATA_ID` varchar(36) default NULL,
  `COMMAND` varchar(10) NOT NULL,
  `MODEM_ID` varchar(22) NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-08-28 16:05:36
