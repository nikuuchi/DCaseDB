SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `dcasedb` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `dcasedb` ;

-- -----------------------------------------------------
-- Table `dcasedb`.`Argument`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`Argument` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `name` TEXT NULL DEFAULT NULL ,
  `goal_id` INT(11) NULL DEFAULT NULL ,
  `master_branch_id` INT(11) NULL DEFAULT NULL ,
  `description` TEXT NULL DEFAULT NULL ,
  `parent_argument_id` INT(11) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`Branch`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`Branch` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `name` TEXT NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`Commit`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`Commit` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `method` TEXT NULL DEFAULT NULL ,
  `args` TEXT NULL DEFAULT NULL ,
  `revision` TEXT NOT NULL ,
  `time` INT(11) NOT NULL ,
  `Branch_id` INT(11) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_Commit_Branch1_idx` (`Branch_id` ASC) ,
  CONSTRAINT `fk_Commit_Branch1`
    FOREIGN KEY (`Branch_id` )
    REFERENCES `dcasedb`.`Branch` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`NodeType`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`NodeType` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `type_name` VARCHAR(45) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`DBNode`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`DBNode` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `name` TEXT NULL DEFAULT NULL ,
  `description` TEXT NULL DEFAULT NULL ,
  `evidence_flag` TINYINT(1) NULL DEFAULT NULL ,
  `nodeType_id` INT(11) NOT NULL ,
  `Branch_id` INT(11) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_Node_NodeType1_idx` (`nodeType_id` ASC) ,
  INDEX `fk_DBNode_Branch1_idx` (`Branch_id` ASC) ,
  CONSTRAINT `fk_Node_NodeType1`
    FOREIGN KEY (`nodeType_id` )
    REFERENCES `dcasedb`.`NodeType` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DBNode_Branch1`
    FOREIGN KEY (`Branch_id` )
    REFERENCES `dcasedb`.`Branch` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`Context`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`Context` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `context_key` TEXT NOT NULL ,
  `value` TEXT NOT NULL ,
  `node_id` INT(11) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_Context_DBNode1_idx` (`node_id` ASC) ,
  CONSTRAINT `fk_Context_DBNode1`
    FOREIGN KEY (`node_id` )
    REFERENCES `dcasedb`.`DBNode` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`NodeLink`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`NodeLink` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `parent_Node_id` INT(11) NOT NULL ,
  `child_Node_id` INT(11) NOT NULL ,
  `branch_id` INT(11) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_NodeLink_Node1_idx` (`parent_Node_id` ASC) ,
  INDEX `fk_NodeLink_Node2_idx` (`child_Node_id` ASC) ,
  CONSTRAINT `fk_NodeLink_Node1`
    FOREIGN KEY (`parent_Node_id` )
    REFERENCES `dcasedb`.`DBNode` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_NodeLink_Node2`
    FOREIGN KEY (`child_Node_id` )
    REFERENCES `dcasedb`.`DBNode` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `dcasedb`.`ArgumentBranch`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `dcasedb`.`ArgumentBranch` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `Branch_id` INT(11) NOT NULL ,
  `Argument_id` INT(11) NOT NULL ,
  INDEX `fk_table1_Branch1_idx` (`Branch_id` ASC) ,
  INDEX `fk_table1_Argument1_idx` (`Argument_id` ASC) ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_table1_Branch1`
    FOREIGN KEY (`Branch_id` )
    REFERENCES `dcasedb`.`Branch` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_Argument1`
    FOREIGN KEY (`Argument_id` )
    REFERENCES `dcasedb`.`Argument` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
