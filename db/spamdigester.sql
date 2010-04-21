-- phpMyAdmin SQL Dump
-- version 2.11.9.5
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 20, 2010 at 10:13 AM
-- Server version: 5.0.22
-- PHP Version: 5.1.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `spamdigester`
--

-- --------------------------------------------------------

--
-- Table structure for table `challenges`
--

CREATE TABLE IF NOT EXISTS `challenges` (
  `challengeid` int(11) NOT NULL auto_increment,
  `sender` varchar(255) default NULL,
  `cr_hash` varchar(255) default NULL,
  `date_added` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`challengeid`),
  KEY `cr_sender` (`sender`),
  KEY `cr_hash_idx` (`cr_hash`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=922512 ;

-- --------------------------------------------------------

--
-- Table structure for table `cr_whitelist`
--

CREATE TABLE IF NOT EXISTS `cr_whitelist` (
  `cr_wl_id` int(11) NOT NULL auto_increment,
  `sender` varchar(255) default NULL,
  `date_added` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`cr_wl_id`),
  KEY `sender_idx` (`sender`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=76370 ;

-- --------------------------------------------------------

--
-- Table structure for table `digests`
--

CREATE TABLE IF NOT EXISTS `digests` (
  `digestid` int(11) NOT NULL auto_increment,
  `digestkey` char(32) default NULL,
  `userid` int(11) default NULL,
  `created` datetime default NULL,
  `closed` datetime default NULL,
  PRIMARY KEY  (`digestid`),
  KEY `dig_user_create` (`userid`,`created`),
  KEY `dig_digkey` (`digestkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1041695 ;

-- --------------------------------------------------------

--
-- Table structure for table `greylist`
--

CREATE TABLE IF NOT EXISTS `greylist` (
  `greylistid` int(11) NOT NULL auto_increment,
  `sender` varchar(255) default NULL,
  `recipient` varchar(255) default NULL,
  `relayaddr` varchar(255) default NULL,
  `messageid` varchar(255) default NULL,
  `first_sent` datetime default NULL,
  `last_sent` datetime default NULL,
  PRIMARY KEY  (`greylistid`),
  KEY `tripple` (`sender`,`recipient`,`messageid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=4196810 ;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE IF NOT EXISTS `messages` (
  `messageid` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL default '0',
  `fromaddress` varchar(255) default NULL,
  `emailid` varchar(255) default NULL,
  `received` datetime default NULL,
  `subject` varchar(255) default NULL,
  `preview` varchar(255) default NULL,
  `message` longtext,
  `score` double(4,1) default NULL,
  `messagekey` varchar(32) default NULL,
  `digestid` int(11) default '0',
  PRIMARY KEY  (`messageid`),
  UNIQUE KEY `mesgkey` (`messagekey`),
  KEY `digestid` (`digestid`),
  KEY `userid` (`userid`),
  KEY `mesg_rcvd` (`received`),
  KEY `mesg_user_score` (`userid`,`score`),
  KEY `mesg_score` (`score`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=3418920 ;

-- --------------------------------------------------------

--
-- Table structure for table `messages_safe`
--

CREATE TABLE IF NOT EXISTS `messages_safe` (
  `messageid` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL default '0',
  `fromaddress` varchar(255) default NULL,
  `emailid` varchar(255) default NULL,
  `received` datetime default NULL,
  `subject` varchar(255) default NULL,
  `preview` varchar(255) default NULL,
  `message` longtext,
  `score` double(4,1) default NULL,
  `messagekey` varchar(32) default NULL,
  `digestid` int(11) default '0',
  PRIMARY KEY  (`messageid`),
  UNIQUE KEY `mesgkey` (`messagekey`),
  KEY `digestid` (`digestid`),
  KEY `userid` (`userid`),
  KEY `mesg_rcvd` (`received`),
  KEY `mesg_user_score` (`userid`,`score`),
  KEY `mesg_score` (`score`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1143474 ;

-- --------------------------------------------------------

--
-- Table structure for table `senderkeys`
--

CREATE TABLE IF NOT EXISTS `senderkeys` (
  `senderkeyid` int(11) NOT NULL auto_increment,
  `messageid` int(11) NOT NULL,
  `senderkey` char(32) default NULL,
  PRIMARY KEY  (`senderkeyid`),
  KEY `idx_senderkey` (`senderkey`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1268466 ;

-- --------------------------------------------------------

--
-- Table structure for table `userpref`
--

CREATE TABLE IF NOT EXISTS `userpref` (
  `username` varchar(100) NOT NULL default '',
  `preference` varchar(50) NOT NULL default '',
  `value` varchar(100) NOT NULL default '',
  `prefid` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`prefid`),
  KEY `username` (`username`),
  KEY `pref_username_preference` (`username`,`preference`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=26233 ;

-- --------------------------------------------------------

--
-- Table structure for table `userpref_bak`
--

CREATE TABLE IF NOT EXISTS `userpref_bak` (
  `username` varchar(100) NOT NULL default '',
  `preference` varchar(50) NOT NULL default '',
  `value` varchar(100) NOT NULL default '',
  `prefid` int(11) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `userid` int(11) NOT NULL auto_increment,
  `user` text NOT NULL,
  `last_send` datetime default NULL,
  `freq` int(11) default NULL,
  `freq_type` enum('mesgs','time') default NULL,
  `userkey` varchar(32) default NULL,
  PRIMARY KEY  (`userid`),
  UNIQUE KEY `userkey` (`userkey`),
  KEY `user_username` (`user`(50))
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=390097 ;
