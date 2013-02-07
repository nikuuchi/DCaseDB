USE `dcasecloud`;
-- Init id=0
SET sql_mode='NO_AUTO_VALUE_ON_ZERO';
INSERT INTO `snapshot`(`id`,`prev_snapshot_id`,`root_node_id`,`unix_time`) VALUES(0,0,0,0);
INSERT INTO `process_context`(`id`,`current_snapshot_id`) VALUES(0,0);
INSERT INTO `argument`(`id`,`current_process_id`) VALUES(0,0);

INSERT INTO `node_type` (`type_name`) VALUES
('Goal'),
('Strategy'),
('Context'),
('Evidence');
