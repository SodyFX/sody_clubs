USE `essentialmode`;

CREATE TABLE `sody_clubs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `sody_clubs_ranks` (
  `id` tinyint(5) NOT NULL,
  `club_name` varchar(50) NOT NULL,
  `club_rank` tinyint(5) NOT NULL,
  `club_rank_name` varchar(30) NOT NULL,
  `club_rank_label` varchar(50) NOT NULL,
  `pay` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `users` ADD `club` VARCHAR(30) NULL, ADD `club_rank` TINYINT(5) NULL;

INSERT INTO `sody_clubs` (`name`, `label`) VALUES ('lmc', 'Lost Motorcycle Club');

INSERT INTO `sody_clubs_ranks` (`id`, `club_name`, `club_rank`, `club_rank_name`, `club_rank_label`, `pay`) VALUES
(NULL, 'lmc', 0, 'biker', 'Biker', 1500),
(NULL, 'lmc', 1, 'saa', 'Sergeant at Arms', 2000),
(NULL, 'lmc', 2, 'vicepresident', 'Vice President', 2500),
(NULL, 'lmc', 3, 'treasurer', 'Treasurer', 2500),
(NULL, 'lmc', 4, 'owner', 'President', 1000);

-- LMC EXAMPLE --
INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('club_lmc_bank', 'LMC', 1),
('club_lmc_black', 'LMC Black', 1),
('club_lmc_priv', 'LMC Priv', 1),
('club_lmc_pub', 'LMC Pub', 1);

INSERT INTO `addon_account_data` (`id`, `account_name`, `money`, `owner`) VALUES
(NULL, 'club_lmc_pub', 0, NULL),
(NULL, 'club_lmc_priv', 0, NULL),
(NULL, 'club_lmc_black', 0, NULL),
(NULL, 'club_lmc_bank', 0, NULL);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('club_lmc_pub', 'LMC Public', 1),
('club_lmc_priv', 'LMC Private', 1),
('club_lmc', 'LMC', 1);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('club_lmc', 'LMC', 1),
('club_lmc_priv', 'LMC Priv', 1),
('club_lmc_pub', 'LMC Pub', 1);
