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
  `club_rank_label` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `users` ADD `club` VARCHAR(30) NULL, ADD `club_rank` TINYINT(5) NULL;