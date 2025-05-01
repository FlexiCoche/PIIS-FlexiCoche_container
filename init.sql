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
  `n_documento` varchar(15) DEFAULT NULL,
  `nombre` varchar(30) NOT NULL,
  `apellidos` varchar(50) NOT NULL,
  `telefono` int(9) DEFAULT NULL,
  `fec_nac` date DEFAULT NULL,
  `rol` tinyint(1) DEFAULT 1,
  `foto` varchar(400) DEFAULT NULL,
  `passwd` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para `localizacion`
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `localizacion` (
  `localizacion` int(3) NOT NULL,
  `descripcion` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `vehiculo`
-- --------------------------------------------------------

CREATE TABLE `vehiculo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `localizacion` int(3) DEFAULT 30,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Tablas especializadas de vehículos
-- --------------------------------------------------------

CREATE TABLE `coche` (
  `id` int(1) DEFAULT 0,
  `id_vehiculo` int(11) PRIMARY KEY,
  `carroceria` enum('Sedán','SUV','Hatchback','Coupé','Convertible','Pickup','Furgoneta','Wagon','Deportivo') NOT NULL,
  `puertas` int(11) DEFAULT 5 CHECK (`puertas` > 0),
  `potencia` int(11) NOT NULL CHECK (`potencia` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `moto` (
  `id` int(1) DEFAULT 1,
  `id_vehiculo` int(11) PRIMARY KEY,
  `cilindrada` int(11) NOT NULL CHECK (`cilindrada` > 0),
  `baul` tinyint(1) DEFAULT 0,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `furgoneta` (
  `id` int(1) DEFAULT 2,
  `id_vehiculo` int(11) PRIMARY KEY,
  `volumen` float DEFAULT NULL CHECK (`volumen` > 0),
  `longitud` float DEFAULT NULL CHECK (`longitud` > 0),
  `peso_max` float NOT NULL CHECK (`peso_max` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `camion` (
  `id` int(1) DEFAULT 3,
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
  `imagen` varchar(400) NOT NULL,
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
INSERT INTO `usuario` (`correo`, `n_documento`, `nombre`, `apellidos`, `telefono`, `fec_nac`, `rol`, `foto`, `passwd`) VALUES
('admin@flexicoche.com', 12345678, 'Admin', 'Sistema', 600000000, '1990-01-01', 1, NULL,'$2a$10$jur1CHjFQ/1wmZYr1639VOAeiPAtGoNf4oyD0Pi/wuI5WJ/pbcQda'), 
('adriana.luna@email.com', 99123456, 'Adriana', 'Luna Torres', 612345697, '1997-03-18', 0, NULL, 'contraseña127'),
('alberto.castro@email.com', 91234567, 'Alberto', 'Castro Ruiz', 612345688, '1984-05-12', 0, NULL, 'contraseña118'),
('ana.martinez@email.com', 23456789, 'Ana', 'Martínez Sánchez', 612345679, '1990-07-22', 0, NULL, 'contraseña456'),
('andrea.medina@email.com', 99789012, 'Andrea', 'Medina Torres', 612345703, '1991-04-10', 0, NULL, 'contraseña133'),
('beatriz.suarez@email.com', 99567890, 'Beatriz', 'Suárez Peña', 612345701, '1994-06-18', 0, NULL, 'contraseña131'),
('carlos.garcia@email.com', 12345678, 'Carlos', 'García Pérez', 612345678, '1985-03-10', 0, NULL, 'contraseña123'),
('carmen.reyes@email.com', 98901234, 'Carmen', 'Reyes Sánchez', 612345695, '1992-12-05', 0, NULL, 'contraseña125'),
('david.alvarez@email.com', 89012345, 'David', 'Álvarez Díaz', 612345685, '1980-04-20', 0, NULL, 'contraseña115'),
('elena.mendoza@email.com', 92345678, 'Elena', 'Mendoza Gil', 612345689, '1991-07-07', 0, NULL, 'contraseña119'),
('elisa.navarro@email.com', 99923456, 'Elisa', 'Navarro Gutiérrez', 612345707, '1997-02-28', 0, NULL, 'contraseña137'),
('fernando.cabrera@email.com', 99890123, 'Fernando', 'Cabrera León', 612345704, '1985-12-07', 0, NULL, 'contraseña134'),
('francisco.ortiz@email.com', 93456789, 'Francisco', 'Ortiz Peña', 612345690, '1987-03-15', 0, NULL, 'contraseña120'),
('gabriel.hernandez@email.com', 99234567, 'Gabriel', 'Hernández Soto', 612345698, '1983-05-22', 0, NULL, 'contraseña128'),
('isabel.dominguez@email.com', 94567890, 'Isabel', 'Domínguez Herrera', 612345691, '1993-11-20', 0, NULL, 'contraseña121'),
('javier.serrano@email.com', 95678901, 'Javier', 'Serrano Vargas', 612345692, '1986-09-25', 0, NULL, 'contraseña122'),
('joaquin.delgado@email.com', 99678901, 'Joaquín', 'Delgado Vera', 612345702, '1982-09-25', 0, NULL, 'contraseña132'),
('jose.lopez@email.com', 56789012, 'José', 'López Ruiz', 612345682, '1979-02-14', 0, NULL, 'contraseña112'),
('juan.rodriguez@email.com', 34567890, 'Juan', 'Rodríguez López', 612345680, '1982-01-15', 0, NULL, 'contraseña789'),
('laura.fernandez@email.com', 45678901, 'Laura', 'Fernández Gómez', 612345681, '1995-11-25', 0, NULL, 'contraseña101'),
('lucia.jimenez@email.com', 90123456, 'Lucía', 'Jiménez Pérez', 612345686, '1996-09-10', 0, NULL, 'contraseña116'),
('manuel.castillo@email.com', 99456789, 'Manuel', 'Castillo Paredes', 612345700, '1986-11-30', 0, NULL, 'contraseña130'),
('mario.moreno@email.com', 10123457, 'Mario', 'Moreno Romero', 612345687, '1983-12-18', 1, NULL, 'contraseña117'),
('marta.gonzalez@email.com', 78901234, 'Marta', 'González García', 612345684, '1992-06-05', 0, NULL, 'contraseña114'),
('natalia.rojas@email.com', 99345678, 'Natalia', 'Rojas Mendoza', 612345699, '1990-08-15', 0, NULL, 'contraseña129'),
('patricia.flores@email.com', 96789012, 'Patricia', 'Flores Ramírez', 612345693, '1994-08-30', 0, NULL, 'contraseña123'),
('pedro.sanchez@email.com', 67890123, 'Pedro', 'Sánchez Martínez', 612345683, '1988-08-30', 0, NULL, 'contraseña113'),
('raul.navarro@email.com', 97890123, 'Raúl', 'Navarro Morales', 612345694, '1981-02-14', 1, NULL, 'contraseña124'),
('sergio.jimenez@email.com', 99012345, 'Sergio', 'Jiménez Pérez', 612345696, '1985-06-10', 0, NULL, 'contraseña126'),
('silvia.ortega@email.com', 99901234, 'Silvia', 'Ortega Herrera', 612345705, '1993-07-21', 0, NULL, 'contraseña135'),
('tomas.perez@email.com', 99912345, 'Tomás', 'Pérez Sánchez', 612345706, '1989-03-05', 0, NULL, 'contraseña136');

-- Localizaciones
INSERT INTO `localizacion` (localizacion, descripcion) VALUES 
(1, 'Álava'),
(2, 'Albacete'),
(3, 'Alicante'),
(4, 'Almería'),
(5, 'Asturias'),
(6, 'Ávila'),
(7, 'Badajoz'),
(8, 'Barcelona'),
(9, 'Burgos'),
(10, 'Cáceres'),
(11, 'Cádiz'),
(12, 'Cantabria'),
(13, 'Castellón'),
(14, 'Ciudad Real'),
(15, 'Córdoba'),
(16, 'Cuenca'),
(17, 'Gerona'),
(18, 'Granada'),
(19, 'Guadalajara'),
(20, 'Guipúzcoa'),
(21, 'Huelva'),
(22, 'Huesca'),
(23, 'Jaén'),
(24, 'La Coruña'),
(25, 'La Rioja'),
(26, 'León'),
(27, 'Lérida'),
(28, 'Lugo'),
(29, 'Madrid'),
(30, 'Málaga'),
(31, 'Murcia'),
(32, 'Navarra'),
(33, 'Orense'),
(34, 'Palencia'),
(35, 'Pontevedra'),
(36, 'Salamanca'),
(37, 'Segovia'),
(38, 'Sevilla'),
(39, 'Soria'),
(40, 'Tarragona'),
(41, 'Teruel'),
(42, 'Toledo'),
(43, 'Valencia'),
(44, 'Valladolid'),
(45, 'Vizcaya'),
(46, 'Zamora'),
(47, 'Zaragoza');

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

-- Imágenes
INSERT INTO `imagen` (`id_vehiculo`, `imagen`) VALUES
(1, 'ford-fiesta.png'),
(2, 'toyota-corolla.png'),
(3, 'bmwx5.png'),
(4, 'audi-a3.png'),
(5, 'kia-rio.png');

-- Coches
INSERT INTO `coche` (`id`, `id_vehiculo`, `carroceria`, `puertas`, `potencia`) VALUES
(0, 1, 'Sedán', 4, 150),
(0, 2, 'Hatchback', 5, 180),
(0, 3, 'Sedán', 4, 120),
(0, 13, 'SUV', 5, 250),
(0, 14, 'SUV', 5, 280),
(0, 15, 'SUV', 5, 320),
(0, 16, 'SUV', 5, 180),
(0, 17, 'SUV', 5, 170),
(0, 18, 'SUV', 5, 200),
(0, 20, 'SUV', 5, 300),
(0, 21, 'SUV', 5, 340),
(0, 22, 'SUV', 5, 250),
(0, 23, 'Pickup', 5, 240),
(0, 24, 'Coupé', 4, 350),
(0, 25, 'SUV', 5, 400),
(0, 26, 'SUV', 5, 220),
(0, 28, 'Coupé', 4, 450),
(0, 29, 'Deportivo', 2, 500),
(0, 30, 'SUV', 5, 190),
(0, 31, 'Sedán', 5, 450),
(0, 32, 'Hatchback', 5, 320),
(0, 33, 'Sedán', 5, 250),
(0, 34, 'SUV', 5, 280),
(0, 35, 'Deportivo', 2, 400),
(0, 36, 'Pickup', 5, 350),
(0, 37, 'SUV', 5, 290),
(0, 38, 'Sedán', 4, 550),
(0, 39, 'Deportivo', 2, 650),
(0, 40, 'Sedán', 5, 1020),
(0, 41, 'SUV', 5, 220),
(0, 42, 'SUV', 5, 250),
(0, 43, 'SUV', 5, 180),
(0, 44, 'SUV', 5, 400),
(0, 45, 'SUV', 5, 300),
(0, 46, 'SUV', 5, 380),
(0, 47, 'Sedán', 5, 350),
(0, 48, 'SUV', 5, 500),
(0, 49, 'SUV', 5, 180),
(0, 50, 'Hatchback', 5, 220),
(0, 51, 'Deportivo', 2, 250),
(0, 52, 'Sedán', 5, 270),
(0, 53, 'Sedán', 5, 300),
(0, 54, 'SUV', 5, 600),
(0, 55, 'Sedán', 5, 320),
(0, 56, 'SUV', 5, 220),
(0, 57, 'SUV', 5, 210),
(0, 58, 'Deportivo', 2, 500),
(0, 59, 'SUV', 5, 190),
(0, 60, 'SUV', 5, 300),
(0, 61, 'SUV', 5, 250),
(0, 62, 'Sedán', 5, 450),
(0, 63, 'SUV', 5, 280),
(0, 64, 'SUV', 5, 300),
(0, 65, 'Sedán', 5, 500),
(0, 66, 'SUV', 5, 250),
(0, 67, 'Sedán', 5, 280),
(0, 68, 'SUV', 5, 260),
(0, 69, 'SUV', 5, 400),
(0, 70, 'Coupé', 4, 450),
(0, 71, 'SUV', 5, 200),
(0, 72, 'SUV', 5, 250),
(0, 73, 'SUV', 5, 500),
(0, 74, 'Hatchback', 5, 180),
(0, 75, 'Sedán', 5, 250),
(0, 76, 'SUV', 5, 400),
(0, 77, 'Sedán', 5, 600),
(0, 78, 'SUV', 5, 230),
(0, 79, 'SUV', 5, 300),
(0, 80, 'SUV', 5, 280),
(0, 81, 'SUV', 5, 550),
(0, 82, 'SUV', 5, 380),
(0, 83, 'Sedán', 5, 210),
(0, 84, 'SUV', 5, 320),
(0, 85, 'SUV', 5, 450),
(0, 86, 'Hatchback', 4, 200),
(0, 87, 'SUV', 5, 250);

-- Motos
INSERT INTO `moto` (`id`, `id_vehiculo`, `cilindrada`, `baul`) VALUES
(1, 4, 500, 0),
(1, 5, 600, 0),
(1, 6, 700, 0),
(1, 88, 900, 1),
(1, 89, 1100, 0),
(1, 90, 750, 1),
(1, 91, 650, 0),
(1, 92, 1200, 1),
(1, 93, 500, 0),
(1, 94, 700, 1),
(1, 95, 800, 0),
(1, 96, 600, 0),
(1, 97, 1000, 1);

-- Furgonetas
INSERT INTO `furgoneta` (`id`, `id_vehiculo`, `volumen`, `longitud`, `peso_max`) VALUES
(2, 7, 18, 6.2, 3500),
(2, 8, 20, 6.5, 3700),
(2, 9, 22, 7, 4000),
(2, 98, 16, 5.5, 3200),
(2, 99, 24, 7.2, 4000),
(2, 100, 18, 6, 3500),
(2, 101, 20, 6.8, 3700),
(2, 102, 22, 7.1, 3900),
(2, 103, 19, 6.3, 3300),
(2, 104, 21, 6.7, 3600),
(2, 105, 23, 7, 3800);

-- Camiones
INSERT INTO `camion` (`id`, `id_vehiculo`, `peso_max`, `altura`, `n_remolques`, `tipo_carga`, `matricula_rem`) VALUES
(3, 10, 18000, 4.5, 1, 'Carga general', 'AB1234CD'),
(3, 11, 22000, 5, 2, 'Automóviles', 'EF5678GH'),
(3, 12, 20000, 4.8, 1, 'Materiales de constr', 'IJ9101KL'),
(3, 106, 25000, 5.2, 2, 'Carga refrigerada', 'MN1234OP'),
(3, 107, 27000, 5.5, 3, 'Materiales de construcción', 'QR5678ST'),
(3, 108, 22000, 5, 1, 'Carga líquida', 'UV9101WX'),
(3, 109, 26000, 5.3, 2, 'Ganado', 'YZ2345AB'),
(3, 110, 24000, 4.9, 1, 'Madera', 'CD6789EF'),
(3, 111, 28000, 5.6, 3, 'Combustible', 'GH1234IJ');

-- Alquileres
INSERT INTO `alquiler` (`id`, `id_vehiculo`, `id_usuario`, `estado`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 1, 'mario.moreno@email.com', 'en alquiler', '2025-02-01', '2025-02-05'),
(2, 2, 'carlos.garcia@email.com', 'a pagar', '2025-02-02', '2025-02-06'),
(3, 3, 'ana.martinez@email.com', 'procesando', '2025-02-03', '2025-02-07'),
(4, 4, 'juan.rodriguez@email.com', 'denegado', '2025-02-04', '2025-02-08'),
(5, 5, 'laura.fernandez@email.com', 'en alquiler', '2025-02-05', '2025-02-09'),
(6, 6, 'jose.lopez@email.com', 'devuelto', '2025-02-06', '2025-02-10'),
(7, 7, 'pedro.sanchez@email.com', 'retraso', '2025-02-07', '2025-02-11'),
(8, 8, 'marta.gonzalez@email.com', 'a pagar', '2025-02-08', '2025-02-12'),
(9, 9, 'silvia.ortega@email.com', 'procesando', '2025-02-09', '2025-02-13'),
(10, 10, 'tomas.perez@email.com', 'en alquiler', '2025-02-10', '2025-02-14');

-- Facturas
INSERT INTO `factura` (`id`, `id_alquiler`, `importe`) VALUES
(1, 1, 250),
(2, 2, 300),
(3, 3, 280),
(4, 4, 200),
(5, 5, 220),
(6, 6, 190),
(7, 7, 260),
(8, 8, 210),
(9, 9, 240),
(10, 10, 230);

-- Finalización
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;