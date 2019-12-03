USE `essentialmode`;

CREATE TABLE `sody_clubs` (
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sody_clubs`
  ADD PRIMARY KEY (`name`);

CREATE TABLE `sody_clubs_ranks` (
  `id` tinyint(5) NOT NULL,
  `club_name` varchar(50) NOT NULL,
  `club_rank` tinyint(5) NOT NULL,
  `club_rank_name` varchar(30) NOT NULL,
  `club_rank_label` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sody_clubs_ranks`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `sody_clubs_ranks`
  MODIFY `id` tinyint(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `users` ADD `club` VARCHAR(30) NULL, ADD `club_rank` TINYINT(5) NULL;

--- EXAMPLE CLUB - LMC
INSERT INTO `sody_clubs` (`name`, `label`) VALUES
('lmc', 'Lost Motorcycle Club');

INSERT INTO `sody_clubs_ranks` (`club_name`, `club_rank`, `club_rank_name`, `club_rank_label`, `pay`) VALUES
('lmc', 0, 'biker', 'Biker', 1500),
('lmc', 1, 'saa', 'Sergeant at Arms', 2000),
('lmc', 2, 'vicepresident', 'Vice President', 2500),
('lmc', 3, 'treasurer', 'Treasurer', 2500),
('lmc', 4, 'owner', 'President', 1000);

INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('club_lmc', 'LMC', 1),
('club_lmc_black', 'LMC Black', 1),
('club_lmc_priv', 'LMC Priv', 1),
('club_lmc_pub', 'LMC Pub', 1);

INSERT INTO `addon_inventory` (`name`, `label`, `shared`) VALUES
('club_lmc', 'LMC', 1),
('club_lmc_priv', 'LMC Private', 1),
('club_lmc_pub', 'LMC Public', 1);

INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
('club_lmc', 'LMC', 1),
('club_lmc_priv', 'LMC Priv', 1),
('club_lmc_pub', 'LMC Pub', 1);