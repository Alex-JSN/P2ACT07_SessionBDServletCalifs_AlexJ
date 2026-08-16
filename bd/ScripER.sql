-- -----------------------------------------------------
-- Table `usuarios`
-- -----------------------------------------------------
CREATE TABLE `usuarios`
(
  `IdUsuario`                INT          NOT NULL AUTO_INCREMENT,
  `Matricula`                VARCHAR(13)  NOT NULL,
  `Nombre`                   VARCHAR(45)  NOT NULL,
  `Paterno`                  VARCHAR(45)  NOT NULL,
  `Materno`                  VARCHAR(45)      NULL,
  `Correo`                   VARCHAR(100) NOT NULL,
  `Contrasena`               VARCHAR(255) NOT NULL,
  `TipoUsuario`              ENUM('Administrador', 'Profesor', 'Alumno')          NOT NULL,
  `Estado`                   ENUM('Activo', 'Inactivo', 'Pendiente', 'Rechazado') NOT NULL,
  `EsProtegido`              TINYINT(1)   NOT NULL,
  `TokenActivacion`          VARCHAR(100)     NULL,
  `TokenExpiracion`          DATETIME         NULL,
  `FechaRegistro`            DATETIME     NOT NULL,
  `FechaActivacion`          DATETIME         NULL,
  `RequiereCambioContrasena` TINYINT(1)   NOT NULL,
  PRIMARY KEY (`IdUsuario`),
  UNIQUE INDEX `uk_Matricula` (`Matricula` ASC),
  UNIQUE INDEX `uk_Correo`    (`Correo`    ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `carreras`
-- -----------------------------------------------------
CREATE TABLE `carreras`
(
  `IdCarrera`           INT              NOT NULL AUTO_INCREMENT,
  `Clave`               VARCHAR(10)      NOT NULL,
  `Carrera`             VARCHAR(100)     NOT NULL,
  `TotalCuatrimestres`  TINYINT UNSIGNED NOT NULL,
  `CuatrimestreEstadia` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`IdCarrera`),
  UNIQUE INDEX `uk_Clave` (`Clave` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `periodos`
-- -----------------------------------------------------
CREATE TABLE `periodos`
(
  `IdPeriodo`   INT         NOT NULL AUTO_INCREMENT,
  `Nombre`      VARCHAR(45) NOT NULL,
  `FechaInicio` DATE        NOT NULL,
  `FechaFin`    DATE        NOT NULL,
  `Estado`      ENUM('Programado', 'Activo', 'Cerrado') NOT NULL,
  PRIMARY KEY (`IdPeriodo`),
  UNIQUE INDEX `uk_Nombre` (`Nombre` ASC)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `grupos`
-- -----------------------------------------------------
CREATE TABLE `grupos`
(
  `IdGrupo`      INT              NOT NULL AUTO_INCREMENT,
  `Generacion`   VARCHAR(45)      NOT NULL,
  `Cuatrimestre` TINYINT UNSIGNED NOT NULL,
  `Letra`        VARCHAR(1)       NOT NULL,
  `IdCarrera`    INT              NOT NULL,
  `IdPeriodo`    INT              NOT NULL,
  PRIMARY KEY (`IdGrupo`),
  INDEX `fk_grupos_carreras_idx` (`IdCarrera` ASC),
  INDEX `fk_grupos_periodos_idx` (`IdPeriodo` ASC),
  UNIQUE INDEX `uk_unico` (`Generacion` ASC, `Cuatrimestre` ASC, `Letra` ASC, `IdCarrera` ASC, `IdPeriodo` ASC),
  CONSTRAINT `fk_grupos_carreras` FOREIGN KEY (`IdCarrera`) REFERENCES `carreras` (`IdCarrera`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_grupos_periodo`  FOREIGN KEY (`IdPeriodo`) REFERENCES `periodos` (`IdPeriodo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `alumnos`
-- -----------------------------------------------------
CREATE TABLE `alumnos`
(
  `IdAlumno`  INT          NOT NULL AUTO_INCREMENT,
  `Matricula` VARCHAR(13)  NOT NULL,
  `Nombre`    VARCHAR(45)  NOT NULL,
  `Paterno`   VARCHAR(45)  NOT NULL,
  `Materno`   VARCHAR(45)      NULL,
  `Correo`    VARCHAR(100) NOT NULL,
  `FechaRegistro` DATETIME NOT NULL,
  `IdCarrera`     INT      NOT NULL,
  `IdUsuario`     INT          NULL,
  `IdGrupo`       INT          NULL,
  PRIMARY KEY (`IdAlumno`),
  INDEX `fk_alumnos_carreras_idx` (`IdCarrera` ASC),
  UNIQUE INDEX `uk_Matricula`     (`Matricula` ASC),
  INDEX `fk_alumnos_usuarios_idx` (`IdUsuario` ASC),
  INDEX `fk_alumnos_grupos_idx`   (`IdGrupo`   ASC),
  UNIQUE INDEX `uk_Correo`        (`Correo`    ASC),
  UNIQUE INDEX `uk_IdUsuario`     (`IdUsuario` ASC),
  CONSTRAINT `fk_alumnos_carreras` FOREIGN KEY (`IdCarrera`) REFERENCES `carreras` (`IdCarrera`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_alumnos_usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `usuarios` (`IdUsuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_alumnos_grupos`   FOREIGN KEY (`IdGrupo`)   REFERENCES `grupos`   (`IdGrupo`)   ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inscripcion`
-- -----------------------------------------------------
CREATE TABLE `inscripcion`
(
  `IdInscripcion`    INT         NOT NULL AUTO_INCREMENT,
  `Cuatrimestre`     VARCHAR(45) NOT NULL,
  `FechaInscripcion` DATETIME    NOT NULL,
  `Estado`           ENUM('Inscrito', 'Baja') NOT NULL,
  `IdAlumno`         INT         NOT NULL,
  `IdPeriodo`        INT         NOT NULL,
  PRIMARY KEY (`IdInscripcion`),
  INDEX `fk_inscripcion_alumnos_idx`  (`IdAlumno`  ASC),
  INDEX `fk_inscripcion_periodos_idx` (`IdPeriodo` ASC),
  UNIQUE INDEX `uk_unico` (`IdAlumno` ASC, `IdPeriodo` ASC),
  CONSTRAINT `fk_inscripcion_alumnos`  FOREIGN KEY (`IdAlumno`)  REFERENCES `alumnos`  (`IdAlumno`)  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_inscripcion_periodos` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodos` (`IdPeriodo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `profesores`
-- -----------------------------------------------------
CREATE TABLE `profesores`
(
  `IdProfesor` INT         NOT NULL AUTO_INCREMENT,
  `Nombre`     VARCHAR(45) NOT NULL,
  `Paterno`    VARCHAR(45) NOT NULL,
  `Materno`    VARCHAR(45)     NULL,
  `Cedula`     VARCHAR(45)     NULL,
  `IdUsuario`  INT         NOT NULL,
  PRIMARY KEY (`IdProfesor`),
  INDEX `fk_profesores_usuarios_idx` (`IdUsuario` ASC),
  UNIQUE INDEX `uk_IdUsuario`        (`IdUsuario` ASC),
  CONSTRAINT `fk_profesores_usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `usuarios` (`IdUsuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `materias`
-- -----------------------------------------------------
CREATE TABLE `materias`
(
  `IdMateria`    INT                 NOT NULL AUTO_INCREMENT,
  `Materia`      VARCHAR(255)        NOT NULL,
  `Cuatrimestre` TINYINT(1) UNSIGNED NOT NULL,
  `IdCarrera`    INT                 NOT NULL,
  PRIMARY KEY (`IdMateria`),
  INDEX `fk_materias_carreras_idx` (`IdCarrera` ASC),
  UNIQUE INDEX `uk_unico`          (`Materia`   ASC, `IdCarrera` ASC),
  CONSTRAINT `fk_materias_carreras` FOREIGN KEY (`IdCarrera`) REFERENCES `carreras` (`IdCarrera`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `asigna`
-- -----------------------------------------------------
CREATE TABLE `asigna`
(
  `IdAsigna`   INT NOT NULL AUTO_INCREMENT,
  `IdProfesor` INT NOT NULL,
  `IdMateria`  INT NOT NULL,
  `IdGrupo`    INT NOT NULL,
  PRIMARY KEY (`IdAsigna`),
  INDEX `fk_asigna_grupos_idx`     (`IdGrupo`    ASC),
  INDEX `fk_asigna_profesores_idx` (`IdProfesor` ASC),
  INDEX `fk_asigna_materias_idx`   (`IdMateria`  ASC),
  UNIQUE INDEX `uk_unico` (`IdMateria` ASC, `IdGrupo` ASC),
  CONSTRAINT `fk_asigna_grupos`   FOREIGN KEY (`IdGrupo`)    REFERENCES `grupos`     (`IdGrupo`)    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_asigna_profesor` FOREIGN KEY (`IdProfesor`) REFERENCES `profesores` (`IdProfesor`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_asigna_materias` FOREIGN KEY (`IdMateria`)  REFERENCES `materias`   (`IdMateria`)  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `calificaciones`
-- -----------------------------------------------------
CREATE TABLE `calificaciones`
(
  `Parcial1` DECIMAL(3,1) UNSIGNED NULL,
  `Parcial2` DECIMAL(3,1) UNSIGNED NULL,
  `Parcial3` DECIMAL(3,1) UNSIGNED NULL,
  `FechaRegistro`     DATETIME NOT NULL,
  `FechaModificacion` DATETIME     NULL,
  `IdInscripcion`     INT      NOT NULL,
  `IdAsigna`          INT      NOT NULL,
  INDEX `fk_calificaciones_inscripcion_idx` (`IdInscripcion` ASC),
  INDEX `fk_calificaciones_asigna_idx`      (`IdAsigna`      ASC),
  PRIMARY KEY (`IdInscripcion`, `IdAsigna`),
  CONSTRAINT `fk_calificaciones_inscripcion` FOREIGN KEY (`IdInscripcion`) REFERENCES `inscripcion` (`IdInscripcion`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_calificaciones_asigna`      FOREIGN KEY (`IdAsigna`)      REFERENCES `asigna`      (`IdAsigna`)      ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `apertura_calificaciones`
-- -----------------------------------------------------
CREATE TABLE `apertura_calificaciones`
(
  `IdApertura`    INT              NOT NULL AUTO_INCREMENT,
  `Parcial`       TINYINT UNSIGNED NOT NULL,
  `FechaApertura` DATETIME         NOT NULL,
  `FechaCierre`   DATETIME         NOT NULL,
  `Estado`        ENUM('Programada', 'Abierta', 'Cerrada') NOT NULL,
  `IdPeriodo`     INT              NOT NULL,
  PRIMARY KEY (`IdApertura`),
  INDEX `fk_apertura_calificaciones_periodos_idx` (`IdPeriodo` ASC),
  UNIQUE INDEX `uk_unico`                         (`Parcial`   ASC, `IdPeriodo` ASC),
  CONSTRAINT `fk_apertura_calificaciones_periodos` FOREIGN KEY (`IdPeriodo`) REFERENCES `periodos` (`IdPeriodo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;