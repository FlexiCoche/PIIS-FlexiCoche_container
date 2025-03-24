-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: db
-- Tiempo de generación: 28-02-2025 a las 16:58:02
-- Versión del servidor: 11.7.2-MariaDB-ubu2404

-- Configuración inicial
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Privilegios de usuario
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS `flexicoche`;
USE `flexicoche`;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `usuario`
-- --------------------------------------------------------

CREATE TABLE `usuario` (
  `correo` varchar(40) PRIMARY KEY,
  `n_documento` int(10) DEFAULT NULL,
  `nombre` varchar(30) NOT NULL,
  `apellidos` varchar(50) NOT NULL,
  `telefono` int(9) DEFAULT NULL,
  `fec_nac` date DEFAULT NULL,
  `rol` tinyint(1) DEFAULT 1,
  `foto` blob DEFAULT NULL,
  `passwd` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


--
-- Estructura de tabla para `Localizaciones`
--
CREATE TABLE `localizaciones` (
  `localizacion` int(3) NOT NULL,
  `descripcion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;


-- --------------------------------------------------------
-- Estructura de tabla para la tabla `vehiculo`
-- --------------------------------------------------------

CREATE TABLE `vehiculo` (
  `id` int(11) PRIMARY KEY NOT NULL,
  `matricula` varchar(10) NOT NULL UNIQUE,
  `marca` varchar(20) NOT NULL,
  `modelo` varchar(20) DEFAULT NULL,
  `combustible` enum('gasolina','diésel','híbrido no enchufable','híbrido enchufable','eléctrico') NOT NULL,
  `color` enum('negro','blanco','gris','plata','rojo','azul','verde','amarillo','naranja','marrón','dorado','púrpura','rosa','multicolor') NOT NULL,
  `precio_dia` float NOT NULL CHECK (`precio_dia` >= 0),
  `anio_matricula` date NOT NULL,
  `disponibilidad` tinyint(1) NOT NULL DEFAULT 1,  
  `n_plazas` int(2) DEFAULT NULL,
  `transmision` enum('Manual','Automática','CVT','Semiautomática','Dual-Clutch') DEFAULT NULL,
  `localizacion` int(3) DEFAULT 30
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Tablas especializadas de vehículos
-- --------------------------------------------------------

CREATE TABLE `moto` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `cilindrada` int(11) NOT NULL CHECK (`cilindrada` > 0),
  `baul` tinyint(1) DEFAULT 0,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `coche` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `carroceria` enum('Sedán','SUV','Hatchback','Coupé','Convertible','Pickup','Furgoneta','Wagon','Deportivo') NOT NULL,
  `puertas` int(11) DEFAULT 5 CHECK (`puertas` > 0),
  `potencia` int(11) NOT NULL CHECK (`potencia` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `furgoneta` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `volumen` float DEFAULT NULL CHECK (`volumen` > 0),
  `longitud` float DEFAULT NULL CHECK (`longitud` > 0),
  `peso_max` float NOT NULL CHECK (`peso_max` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `camion` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `peso_max` float NOT NULL CHECK (`peso_max` > 0),
  `altura` float NOT NULL CHECK (`altura` > 0),
  `n_remolques` int(11) DEFAULT 0 CHECK (`n_remolques` >= 0),
  `tipo_carga` varchar(30) DEFAULT 'General',
  `matricula_rem` varchar(10) DEFAULT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `alquiler`
-- --------------------------------------------------------

CREATE TABLE `alquiler` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `id_vehiculo` int(11) NOT NULL,
  `id_usuario` varchar(40) NOT NULL,
  `estado` enum('a pagar','procesando','denegado','en alquiler','devuelto','retraso') NOT NULL DEFAULT 'a pagar',
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`),
  FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `factura`
-- --------------------------------------------------------

CREATE TABLE `factura` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `id_alquiler` int(11) NOT NULL UNIQUE,
  `importe` float NOT NULL CHECK (`importe` >= 0),
  FOREIGN KEY (`id_alquiler`) REFERENCES `alquiler`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `imagen`
-- --------------------------------------------------------

CREATE TABLE `imagen` (
  `id_vehiculo` int(11) NOT NULL,
  `imagen` blob NOT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Disparadores
-- --------------------------------------------------------

DELIMITER $$
CREATE TRIGGER `check_fec_nac_usuario` BEFORE INSERT ON `usuario`
FOR EACH ROW BEGIN
    IF NEW.fec_nac > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fecha de nacimiento no válida';
    END IF;
END$$

CREATE TRIGGER `check_fechas_alquiler` BEFORE INSERT ON `alquiler`
FOR EACH ROW BEGIN
    IF NEW.fecha_inicio > NEW.fecha_fin THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fecha inicio debe ser anterior a fecha fin';
    END IF;
END$$
DELIMITER ;

-- --------------------------------------------------------
-- Inserts de datos
-- --------------------------------------------------------

-- Usuarios
INSERT INTO `usuario` (`correo`, `n_documento`, `nombre`, `apellidos`, `telefono`, `fec_nac`, `rol`, `passwd`) VALUES
('admin@flexicoche.com', 12345678, 'Admin', 'Sistema', 600000000, '1990-01-01', 1, 'admin123'),
('mario.moreno@email.com', 10123457, 'Mario', 'Moreno Romero', 612345687, '1983-12-18', 1, 'contraseña117'),
('carlos.garcia@email.com', 12345678, 'Carlos', 'García Pérez', 612345678, '1985-03-10', 0, 'contraseña123'),
('ana.martinez@email.com', 23456789, 'Ana', 'Martínez Sánchez', 612345679, '1990-07-22', 0, 'contraseña456'),
('juan.rodriguez@email.com', 34567890, 'Juan', 'Rodríguez López', 612345680, '1982-01-15', 0, 'contraseña789'),
('laura.fernandez@email.com', 45678901, 'Laura', 'Fernández Gómez', 612345681, '1995-11-25', 0, 'contraseña101'),
('jose.lopez@email.com', 56789012, 'José', 'López Ruiz', 612345682, '1979-02-14', 0, 'contraseña112'),
('pedro.sanchez@email.com', 67890123, 'Pedro', 'Sánchez Martínez', 612345683, '1988-08-30', 0, 'contraseña113'),
('marta.gonzalez@email.com', 78901234, 'Marta', 'González García', 612345684, '1992-06-05', 0, 'contraseña114'),
('david.alvarez@email.com', 89012345, 'David', 'Álvarez Díaz', 612345685, '1980-04-20', 0, 'contraseña115');

-- Localizaciones
INSERT INTO localizaciones (localizacion, descripcion) VALUES (1, 'Álava');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (2, 'Albacete');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (3, 'Alicante');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (4, 'Almería');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (5, 'Asturias');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (6, 'Ávila');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (7, 'Badajoz');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (8, 'Barcelona');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (9, 'Burgos');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (10, 'Cáceres');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (11, 'Cádiz');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (12, 'Cantabria');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (13, 'Castellón');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (14, 'Ciudad Real');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (15, 'Córdoba');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (16, 'Cuenca');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (17, 'Gerona');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (18, 'Granada');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (19, 'Guadalajara');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (20, 'Guipúzcoa');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (21, 'Huelva');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (22, 'Huesca');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (23, 'Jaén');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (24, 'La Coruña');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (25, 'La Rioja');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (26, 'León');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (27, 'Lérida');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (28, 'Lugo');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (29, 'Madrid');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (30, 'Málaga');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (31, 'Murcia');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (32, 'Navarra');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (33, 'Orense');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (34, 'Palencia');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (35, 'Pontevedra');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (36, 'Salamanca');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (37, 'Segovia');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (38, 'Sevilla');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (39, 'Soria');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (40, 'Tarragona');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (41, 'Teruel');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (42, 'Toledo');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (43, 'Valencia');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (44, 'Valladolid');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (45, 'Vizcaya');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (46, 'Zamora');
INSERT INTO localizaciones (localizacion, descripcion) VALUES (47, 'Zaragoza');

-- Vehículos
INSERT INTO `vehiculo` (`id`, `matricula`, `marca`, `modelo`, `combustible`, `color`, `precio_dia`, `anio_matricula`, `disponibilidad`, `n_plazas`, `transmision`, `localizacion`) VALUES
(1, '1234ABC', 'Ford', 'Focus', 'gasolina', 'rojo', 50, '2018-04-15', 1, 5, 'Automática', 38),
(2, '2345DEF', 'Volkswagen', 'Golf', 'diésel', 'blanco', 60, '2020-07-10', 1, 5, 'Manual', 8),
(3, '3456GHI', 'Toyota', 'Prius', 'híbrido enchufable', 'azul', 70, '2022-01-20', 1, 5, 'CVT', 29),
(4, '4567JKL', 'Honda', 'CB500', 'gasolina', 'negro', 80, '2021-08-10', 1, 2, 'Manual', 43),
(5, '5678MNO', 'Kawasaki', 'Ninja', 'diésel', 'plata', 55, '2017-06-12', 1, 2, 'Manual', 29),
(6, '6789PQR', 'Yamaha', 'MT-07', 'híbrido no enchufable', 'rojo', 65, '2020-09-15', 1, 2, 'Semiautomática', 43),
(7, '7890STU', 'Renault', 'Master', 'gasolina', 'gris', 70, '2023-02-02', 1, 3, 'Manual', 29),
(8, '8901VWX', 'Mercedes-Benz', 'Vito', 'diésel', 'amarillo', 85, '2019-11-11', 1, 3, 'Automática', 38),
(9, '9012XYZ', 'Ford', 'Transit', 'gasolina', 'verde', 75, '2022-03-22', 1, 3, 'Manual', 38),
(10, '1234ZZZ', 'Scania', 'R500', 'híbrido no enchufable', 'marrón', 100, '2021-04-10', 1, 2, 'Manual', 31),
(11, '2345AAA', 'Volvo', 'FH16', 'gasolina', 'azul', 120, '2020-12-01', 1, 2, 'Manual', 43),
(12, '3456BBB', 'Mercedes', 'Actros', 'diésel', 'rojo', 110, '2019-05-14', 1, 2, 'Automática', 8),
(13, '4567CCC', 'BMW', 'X5', 'gasolina', 'negro', 95, '2018-07-20', 1, 5, 'Automática', 29),
(14, '5678DDD', 'Audi', 'Q7', 'diésel', 'blanco', 80, '2021-10-10', 1, 5, 'Automática', 29),
(15, '6789EEE', 'Tesla', 'Model Y', 'híbrido enchufable', 'gris', 85, '2022-08-15', 1, 5, 'Automática', 31),
(16, '7890FFF', 'Mazda', 'CX-5', 'gasolina', 'rojo', 70, '2017-06-18', 1, 5, 'Manual', 43),
(17, '8901GGG', 'Nissan', 'Qashqai', 'diésel', 'azul', 75, '2019-12-05', 1, 5, 'Manual', 8),
(18, '9012HHH', 'Hyundai', 'Tucson', 'híbrido no enchufable', 'verde', 65, '2020-03-25', 1, 5, 'Automática', 38),
(19, '1234III', 'Jeep', 'Wrangler', 'gasolina', 'marrón', 110, '2021-07-30', 1, 4, 'Manual', 29),
(20, '2345JJJ', 'Land Rover', 'Defender', 'diésel', 'negro', 90, '2023-01-12', 1, 5, 'Automática', 38),
(21, '3456KKK', 'Porsche', 'Cayenne', 'gasolina', 'plata', 120, '2019-04-14', 1, 5, 'Automática', 29),
(22, '4567LLL', 'Mitsubishi', 'Outlander', 'híbrido enchufable', 'blanco', 100, '2022-11-11', 1, 5, 'CVT', 29),
(23, '5678MMM', 'Toyota', 'Hilux', 'diésel', 'rojo', 95, '2018-05-10', 1, 5, 'Manual', 8),
(24, '6789NNN', 'Chevrolet', 'Camaro', 'gasolina', 'gris', 110, '2020-09-28', 1, 4, 'Manual', 8),
(25, '7890OOO', 'Ford', 'Mustang Mach-E', 'eléctrico', 'azul', 130, '2023-02-05', 1, 5, 'Automática', 8),
(26, '8901PPP', 'Volkswagen', 'Tiguan', 'híbrido no enchufable', 'blanco', 85, '2021-06-17', 1, 5, 'Automática', 8),
(27, '9012QQQ', 'Mercedes', 'Sprinter', 'diésel', 'negro', 75, '2019-08-22', 1, 3, 'Manual', 8),
(28, '1234RRR', 'Dodge', 'Challenger', 'gasolina', 'verde', 105, '2017-11-14', 1, 4, 'Automática', 38),
(29, '2345SSS', 'Ferrari', 'Roma', 'híbrido enchufable', 'amarillo', 115, '2022-04-10', 1, 2, 'Automática', 29),
(30, '3456TTT', 'Peugeot', '3008', 'diésel', 'azul', 95, '2019-10-30', 1, 5, 'Manual', 29),
(31, '4567UUU', 'Lucid', 'Air', 'eléctrico', 'plata', 140, '2023-07-20', 1, 5, 'Automática', 29),
(32, '5678VVV', 'Honda', 'Civic Type R', 'gasolina', 'rojo', 90, '2018-09-18', 1, 5, 'Manual', 8),
(33, '6789WWW', 'BMW', 'Serie 3', 'diésel', 'blanco', 85, '2020-12-12', 1, 5, 'Automática', 8),
(34, '7890XXX', 'Lexus', 'RX', 'híbrido enchufable', 'gris', 110, '2021-05-25', 1, 5, 'CVT', 8),
(35, '8901YYY', 'Jaguar', 'F-Type', 'gasolina', 'negro', 100, '2019-07-07', 1, 2, 'Automática', 38),
(36, '9012ZZZ', 'Rivian', 'R1T', 'eléctrico', 'azul', 120, '2023-03-15', 1, 5, 'Automática', 31),
(37, '1234AAA', 'Volvo', 'XC90', 'diésel', 'plata', 95, '2017-10-10', 1, 5, 'Automática', 38),
(38, '2345BBB', 'Porsche', 'Taycan', 'híbrido enchufable', 'blanco', 105, '2022-02-28', 1, 4, 'Automática', 31),
(39, '3456CCC', 'Lamborghini', 'Huracán', 'gasolina', 'rojo', 130, '2018-06-14', 1, 2, 'Automática', 43),
(40, '4567DDD', 'Tesla', 'Model S Plaid', 'eléctrico', 'verde', 150, '2023-09-10', 1, 5, 'Automática', 43),
(41, '5678EEE', 'Skoda', 'Kodiaq', 'diésel', 'negro', 85, '2019-12-20', 1, 5, 'Manual', 8),
(42, '6789FFF', 'Ford', 'Escape Hybrid', 'híbrido enchufable', 'azul', 90, '2021-04-12', 1, 5, 'CVT', 31),
(43, '7890GGG', 'Chevrolet', 'Silverado', 'gasolina', 'gris', 95, '2018-11-30', 1, 5, 'Manual', 43),
(44, '8901HHH', 'BMW', 'i4', 'eléctrico', 'marrón', 140, '2023-05-21', 1, 5, 'Automática', 43),
(45, '9012III', 'Citroën', 'C5 Aircross', 'diésel', 'amarillo', 75, '2020-08-15', 1, 5, 'Manual', 38),
(46, '1234JJJ', 'Nissan', 'X-Trail', 'gasolina', 'rojo', 85, '2019-03-14', 1, 5, 'Manual', 31),
(47, '2345KKK', 'Hyundai', 'Ioniq', 'híbrido no enchufable', 'blanco', 95, '2021-06-20', 1, 5, 'Automática', 8),
(48, '3456LLL', 'Kia', 'Sportage', 'diésel', 'negro', 90, '2020-01-10', 1, 5, 'Manual', 29),
(49, '4567MMM', 'Nissan', 'Leaf', 'eléctrico', 'plata', 100, '2023-04-02', 1, 5, 'Automática', 38),
(50, '5678NNN', 'Suzuki', 'Vitara', 'gasolina', 'azul', 75, '2018-07-15', 1, 5, 'Manual', 29),
(51, '6789OOO', 'Mazda', 'MX-5', 'gasolina', 'rojo', 95, '2018-08-12', 1, 2, 'Manual', 29),
(52, '7890PPP', 'Volkswagen', 'Passat', 'diésel', 'negro', 110, '2019-05-17', 1, 5, 'Automática', 29),
(53, '8901QQQ', 'Hyundai', 'Ioniq', 'híbrido enchufable', 'blanco', 120, '2021-06-10', 1, 5, 'CVT', 29),
(54, '9012RRR', 'Tesla', 'Model X', 'eléctrico', 'azul', 140, '2023-03-08', 1, 5, 'Automática', 38),
(55, '1234SSS', 'Alfa Romeo', 'Giulia', 'gasolina', 'gris', 100, '2017-12-25', 1, 5, 'Manual', 29),
(56, '2345TTT', 'Ford', 'Kuga', 'diésel', 'rojo', 90, '2019-07-14', 1, 5, 'Automática', 29),
(57, '3456UUU', 'Honda', 'CR-V', 'híbrido no enchufable', 'marrón', 85, '2020-02-22', 1, 5, 'CVT', 8),
(58, '4567VVV', 'Chevrolet', 'Corvette', 'gasolina', 'negro', 130, '2021-10-30', 1, 2, 'Automática', 38),
(59, '5678WWW', 'Renault', 'Koleos', 'diésel', 'blanco', 95, '2018-05-09', 1, 5, 'Manual', 8),
(60, '6789XXX', 'Nissan', 'Ariya', 'eléctrico', 'verde', 145, '2023-01-15', 1, 5, 'Automática', 38),
(61, '7890YYY', 'Toyota', 'RAV4', 'híbrido enchufable', 'azul', 110, '2022-06-19', 1, 5, 'CVT', 38),
(62, '8901ZZZ', 'Dodge', 'Charger', 'gasolina', 'plata', 125, '2021-09-21', 1, 5, 'Automática', 38),
(63, '9012AAA', 'Jeep', 'Grand Cherokee', 'diésel', 'gris', 100, '2020-12-11', 1, 5, 'Manual', 8),
(64, '1234BBB', 'Lexus', 'NX', 'híbrido no enchufable', 'rojo', 120, '2023-02-05', 1, 5, 'CVT', 29),
(65, '2345CCC', 'BMW', 'i4', 'eléctrico', 'blanco', 135, '2022-05-28', 1, 5, 'Automática', 29),
(66, '3456DDD', 'Subaru', 'Forester', 'gasolina', 'azul', 90, '2019-04-14', 1, 5, 'Manual', 8),
(67, '4567EEE', 'Audi', 'A6', 'diésel', 'negro', 110, '2020-08-10', 1, 5, 'Automática', 8),
(68, '5678FFF', 'Mitsubishi', 'Eclipse Cross', 'híbrido enchufable', 'plata', 115, '2021-11-13', 1, 5, 'CVT', 8),
(69, '6789GGG', 'Polestar', '2', 'eléctrico', 'verde', 140, '2023-07-02', 1, 5, 'Automática', 31),
(70, '7890HHH', 'Ford', 'Mustang GT', 'gasolina', 'marrón', 130, '2018-06-05', 1, 4, 'Manual', 31),
(71, '8901III', 'Citroën', 'C5 Aircross', 'diésel', 'blanco', 95, '2019-09-18', 1, 5, 'Manual', 8),
(72, '9012JJJ', 'Kia', 'Sorento', 'híbrido no enchufable', 'azul', 105, '2020-11-24', 1, 5, 'CVT', 8),
(73, '1234KKK', 'Lucid', 'Gravity', 'eléctrico', 'rojo', 150, '2023-04-12', 1, 5, 'Automática', 29),
(74, '2345LLL', 'Peugeot', '208 GT', 'gasolina', 'gris', 90, '2017-07-22', 1, 5, 'Manual', 29),
(75, '3456MMM', 'Mercedes', 'CLA', 'diésel', 'negro', 100, '2019-06-08', 1, 5, 'Automática', 31),
(76, '4567NNN', 'Volvo', 'XC60', 'híbrido enchufable', 'plata', 120, '2022-03-01', 1, 5, 'CVT', 38),
(77, '5678OOO', 'Tesla', 'Model 3', 'eléctrico', 'verde', 135, '2023-09-05', 1, 5, 'Automática', 29),
(78, '6789PPP', 'Hyundai', 'Tucson', 'gasolina', 'blanco', 95, '2018-10-10', 1, 5, 'Manual', 38),
(79, '7890QQQ', 'Jaguar', 'F-Pace', 'diésel', 'azul', 110, '2020-05-29', 1, 5, 'Automática', 38),
(80, '8901RRR', 'Honda', 'HR-V', 'híbrido no enchufable', 'marrón', 125, '2021-12-20', 1, 5, 'CVT', 29),
(81, '9012SSS', 'Porsche', 'Macan EV', 'eléctrico', 'gris', 140, '2023-07-15', 1, 5, 'Automática', 8),
(82, '1234TTT', 'Alfa Romeo', 'Stelvio', 'gasolina', 'rojo', 130, '2019-02-14', 1, 5, 'Automática', 8),
(83, '2345UUU', 'Toyota', 'Corolla', 'diésel', 'negro', 95, '2018-11-17', 1, 5, 'Manual', 29),
(84, '3456VVV', 'BMW', 'X3', 'híbrido enchufable', 'plata', 110, '2021-08-12', 1, 5, 'CVT', 43),
(85, '4567WWW', 'Ford', 'Explorer EV', 'eléctrico', 'azul', 145, '2023-06-09', 1, 5, 'Automática', 38),
(86, '5678XXX', 'Mini', 'Cooper S', 'gasolina', 'verde', 90, '2017-05-25', 1, 4, 'Manual', 43),
(87, '6789YYY', 'Volkswagen', 'T-Roc', 'diésel', 'blanco', 100, '2019-03-15', 1, 5, 'Automática', 29),
(88, '5678AAA', 'Ducati', 'Panigale V4', 'gasolina', 'negro', 75, '2021-05-14', 1, 2, 'Manual', 38),
(89, '6789BBB', 'Harley-Davidson', 'Sportster', 'diésel', 'rojo', 80, '2022-03-20', 1, 2, 'Manual', 29),
(90, '7890CCC', 'KTM', 'Duke 790', 'gasolina', 'blanco', 65, '2020-06-11', 1, 2, 'Manual', 29),
(91, '8901DDD', 'Yamaha', 'XSR700', 'diésel', 'azul', 70, '2019-08-05', 1, 2, 'Manual', 38),
(92, '9012EEE', 'BMW', 'R1250GS', 'híbrido no enchufable', 'verde', 90, '2023-01-17', 1, 2, 'Manual', 38),
(93, '1234FFF', 'Honda', 'CBR500R', 'gasolina', 'negro', 85, '2018-10-22', 1, 2, 'Manual', 43),
(94, '2345GGG', 'Suzuki', 'V-Strom 650', 'diésel', 'gris', 95, '2021-07-30', 1, 2, 'Manual', 38),
(95, '3456HHH', 'Kawasaki', 'Versys 1000', 'híbrido enchufable', 'plata', 100, '2022-11-15', 1, 2, 'Manual', 38),
(96, '4567III', 'Zero', 'SR/F', 'eléctrico', 'rojo', 110, '2023-09-01', 1, 2, 'Automática', 29),
(97, '5678JJJ', 'Triumph', 'Tiger 900', 'gasolina', 'azul', 105, '2019-05-25', 1, 2, 'Manual', 43),
(98, '6789KKK', 'Fiat', 'Ducato', 'diésel', 'blanco', 85, '2018-08-10', 1, 3, 'Manual', 38),
(99, '7890LLL', 'Peugeot', 'Boxer', 'gasolina', 'gris', 95, '2020-12-05', 1, 3, 'Automática', 8),
(100, '8901MMM', 'Ford', 'E-Transit', 'híbrido no enchufable', 'azul', 90, '2019-11-30', 1, 3, 'Automática', 8),
(101, '9012NNN', 'Iveco', 'Daily', 'diésel', 'negro', 100, '2021-06-22', 1, 3, 'Manual', 43),
(102, '1234OOO', 'Volkswagen', 'Crafter', 'gasolina', 'rojo', 105, '2023-03-18', 1, 3, 'Automática', 29),
(103, '2345PPP', 'Opel', 'Movano', 'diésel', 'plata', 110, '2017-07-07', 1, 3, 'Manual', 31),
(104, '3456QQQ', 'Renault', 'Trafic', 'híbrido enchufable', 'verde', 115, '2022-04-10', 1, 3, 'Automática', 8),
(105, '4567RRR', 'Mercedes', 'eSprinter', 'eléctrico', 'marrón', 120, '2023-08-25', 1, 3, 'Automática', 31),
(106, '5678SSS', 'Volvo', 'FH16', 'diésel', 'negro', 150, '2020-10-10', 1, 2, 'Manual', 31),
(107, '6789TTT', 'MAN', 'TGX', 'diésel', 'blanco', 140, '2019-09-15', 1, 2, 'Automática', 8),
(108, '7890UUU', 'DAF', 'XF', 'híbrido no enchufable', 'rojo', 130, '2021-12-01', 1, 2, 'Manual', 8),
(109, '8901VVV', 'Iveco', 'S-Way', 'diésel', 'azul', 160, '2022-06-20', 1, 2, 'Automática', 31),
(110, '9012WWW', 'Tesla', 'Semi', 'eléctrico', 'gris', 180, '2023-05-05', 1, 2, 'Automática', 29),
(111, '1234XXX', 'Scania', 'Super', 'híbrido enchufable', 'blanco', 170, '2022-07-12', 1, 2, 'Manual', 38);


-- Coches
INSERT INTO `coche` (`id_vehiculo`, `carroceria`, `puertas`, `potencia`) VALUES
(1, 'Sedán', 4, 150),
(2, 'Hatchback', 5, 180),
(3, 'Sedán', 4, 120);

-- Motos
INSERT INTO `moto` (`id_vehiculo`, `cilindrada`, `baul`) VALUES
(4, 500, 0),
(5, 600, 0),
(6, 700, 0);

-- Furgonetas
INSERT INTO `furgoneta` (`id_vehiculo`, `volumen`, `longitud`, `peso_max`) VALUES
(7, 18, 6.2, 3500),
(8, 20, 6.5, 3700),
(9, 22, 7.0, 4000);

-- Camiones
INSERT INTO `camion` (`id_vehiculo`, `peso_max`, `altura`, `n_remolques`, `tipo_carga`, `matricula_rem`) VALUES
(10, 18000, 4.5, 1, 'Carga general', 'AB1234CD');

-- Alquileres
INSERT INTO `alquiler` (`id_vehiculo`, `id_usuario`, `estado`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 'mario.moreno@email.com', 'en alquiler', '2025-02-01', '2025-02-05'),
(2, 'carlos.garcia@email.com', 'a pagar', '2025-02-02', '2025-02-06'),
(3, 'ana.martinez@email.com', 'procesando', '2025-02-03', '2025-02-07');

-- Facturas
INSERT INTO `factura` (`id_alquiler`, `importe`) VALUES
(1, 250.0),
(2, 300.0),
(3, 280.0);

-- Finalización
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
